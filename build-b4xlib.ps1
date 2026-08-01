$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$output = Join-Path $root 'DeclarativeUI-0.1.b4xlib'
$stage = Join-Path ([IO.Path]::GetTempPath()) ('DeclarativeUI_b4xlib_' + [Guid]::NewGuid().ToString('N'))
$tempZip = Join-Path ([IO.Path]::GetTempPath()) ('DeclarativeUI_b4xlib_' + [Guid]::NewGuid().ToString('N') + '.zip')

$expectedModules = @(
    'UIAppBar.bas'
    'UIBox.bas'
    'UIButton.bas'
    'UICard.bas'
    'UICenter.bas'
    'UIColumn.bas'
    'UIDivider.bas'
    'UIExpanded.bas'
    'UIFloatingActionButton.bas'
    'UILabel.bas'
    'UINavigator.bas'
    'UIPadding.bas'
    'UIRow.bas'
    'UIScaffold.bas'
    'UIScrollView.bas'
    'UISpace.bas'
    'UITheme.bas'
)

try {
    New-Item -ItemType Directory -Path $stage -Force | Out-Null

    $modules = @(Get-ChildItem -LiteralPath $root -Filter 'UI*.bas' -File | Sort-Object Name)
    $actualModuleNames = @($modules | ForEach-Object Name)
    $missing = @($expectedModules | Where-Object { $_ -notin $actualModuleNames })
    $unexpected = @($actualModuleNames | Where-Object { $_ -notin $expectedModules })
    if ($missing.Count -gt 0 -or $unexpected.Count -gt 0 -or $modules.Count -ne $expectedModules.Count) {
        throw ('Module list mismatch. Missing: ' + ($missing -join ', ') + '; unexpected: ' + ($unexpected -join ', '))
    }

    foreach ($module in $modules) {
        Copy-Item -LiteralPath $module.FullName -Destination (Join-Path $stage $module.Name)
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $manifest = @(
        'Version=0.1'
        'Title=Declarative UI for B4A'
        'Author=Declarative UI project'
        'DependsOn=XUI, IME'
    ) -join [Environment]::NewLine
    [IO.File]::WriteAllText((Join-Path $stage 'manifest.txt'), $manifest, $utf8NoBom)

    $packageReadme = @(
        'Declarative UI for B4A - preliminary 0.1'
        ''
        'This package contains the reusable B4A UI modules only. The NOVA demo Activity'
        'and Starter service are not included.'
        ''
        'Dependencies: XUI and IME. This release is B4A-only.'
        ''
        'See the project GUIDE.md for the complete usage documentation.'
    ) -join [Environment]::NewLine
    [IO.File]::WriteAllText((Join-Path $stage 'README.txt'), $packageReadme, $utf8NoBom)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Compression.ZipFile]::CreateFromDirectory($stage, $tempZip, [IO.Compression.CompressionLevel]::Optimal, $false)

    Add-Type -AssemblyName System.IO.Compression
    $zip = [IO.Compression.ZipFile]::OpenRead($tempZip)
    try {
        $entries = @($zip.Entries)
        $expectedEntries = @('README.txt', 'manifest.txt') + $expectedModules
        $actualEntries = @($entries | ForEach-Object FullName)
        $missingEntries = @($expectedEntries | Where-Object { $_ -notin $actualEntries })
        $unexpectedEntries = @($actualEntries | Where-Object { $_ -notin $expectedEntries })
        if ($entries.Count -ne 19 -or $missingEntries.Count -gt 0 -or $unexpectedEntries.Count -gt 0) {
            throw ('Package entry mismatch. Missing: ' + ($missingEntries -join ', ') + '; unexpected: ' + ($unexpectedEntries -join ', '))
        }

        foreach ($entry in $entries | Where-Object { $_.FullName -like 'UI*.bas' }) {
            $reader = New-Object IO.StreamReader($entry.Open())
            try {
                $text = $reader.ReadToEnd()
            }
            finally {
                $reader.Dispose()
            }
            if ($text.Contains('[DBG_UI]') -or $text.Contains('Log(')) {
                throw ('Debug log found in ' + $entry.FullName)
            }
        }
    }
    finally {
        $zip.Dispose()
    }

    if (Test-Path -LiteralPath $output) {
        Remove-Item -LiteralPath $output -Force
    }
    Move-Item -LiteralPath $tempZip -Destination $output -Force

    $fileInfo = Get-Item -LiteralPath $output
    $hash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash
    Write-Host ''
    Write-Host 'Declarative UI library created successfully.' -ForegroundColor Green
    Write-Host ('File: ' + $output)
    Write-Host ('Size: ' + $fileInfo.Length + ' bytes')
    Write-Host ('SHA-256: ' + $hash)
    Write-Host 'Contents: 17 UI modules + manifest.txt + README.txt'
}
catch {
    Write-Error ('The b4xlib could not be created or validated: ' + $_.Exception.Message)
    exit 1
}
finally {
    if (Test-Path -LiteralPath $stage) {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $tempZip) {
        Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
    }
}
