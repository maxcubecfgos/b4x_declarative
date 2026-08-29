$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$output = Join-Path $root 'DeclarativeUI.b4xlib'
$stage = Join-Path ([IO.Path]::GetTempPath()) ('DeclarativeUI_b4xlib_' + [Guid]::NewGuid().ToString('N'))
$tempZip = Join-Path ([IO.Path]::GetTempPath()) ('DeclarativeUI_b4xlib_' + [Guid]::NewGuid().ToString('N') + '.zip')
$licenseFile = Join-Path $root 'LICENSE.txt'

$expectedModules = @(
    'UI.bas'
    'UIAlertDialog.bas'
    'UIAnimation.bas'
    'UIAppBar.bas'
    'UIAsyncState.bas'
    'UIBottomNavigationBar.bas'
    'UIBox.bas'
    'UIButton.bas'
    'UICard.bas'
    'UICenter.bas'
    'UICheckbox.bas'
    'UIColumn.bas'
    'UIDiagnostics.bas'
    'UIDivider.bas'
    'UIExpanded.bas'
    'UIFloatingActionButton.bas'
    'UIIcon.bas'
    'UIImage.bas'
    'UIInput.bas'
    'UILabel.bas'
    'UIListView.bas'
    'UIMeasureEngine.bas'
    'UINative.bas'
    'UINavigator.bas'
    'UIPadding.bas'
    'UIPlaceholder.bas'
    'UIProgressBar.bas'
    'UIRadioButton.bas'
    'UIRadioGroup.bas'
    'UIRoundedSurface.bas'
    'UIRebuildScheduler.bas'
    'UIRow.bas'
    'UIScaffold.bas'
    'UIScrollView.bas'
    'UISnackBar.bas'
    'UISpace.bas'
    'UIStack.bas'
    'UIState.bas'
    'UIStateTextBinding.bas'
    'UISwitch.bas'
    'UITheme.bas'
    'UIVisibility.bas'
    'UIWidgetBridge.bas'
    'UIWindowBar.bas'
)

try {
    # --- B4X source validation gate ----------------------------------------
    # Structural sanity for every B4X source file in the repository (.b4a and
    # .bas: parenthesis balance per statement, ' _' continuation rules,
    # Sub/Region/Type pairing, BOM/header sanity). Catches AI/author edits
    # that would break the B4A compiler before packaging. The checker scans
    # the repository itself, so it keeps working even if examples/ changes.
    $checker = Join-Path $root 'check-b4x-source.py'
    if (Test-Path -LiteralPath $checker) {
        $python = Get-Command python -ErrorAction SilentlyContinue
        if ($python) {
            & python $checker
            if ($LASTEXITCODE -ne 0) {
                throw 'B4X source validation failed. Fix the reported issues or run: python check-b4x-source.py'
            }
            Write-Host 'B4X source validation passed (check-b4x-source.py).' -ForegroundColor Green
        } else {
            Write-Warning 'Python not found; skipping source validation (check-b4x-source.py).'
        }
    } else {
        Write-Warning 'check-b4x-source.py not found; skipping source validation.'
    }

    New-Item -ItemType Directory -Path $stage -Force | Out-Null

    $allSourceModules = @(Get-ChildItem -LiteralPath $root -Filter 'UI*.bas' -File | Sort-Object Name)
    $modules = $allSourceModules
    $actualModuleNames = @($modules | ForEach-Object Name)
    $missing = @($expectedModules | Where-Object { $_ -notin $actualModuleNames })
    $unexpected = @($actualModuleNames | Where-Object { $_ -notin $expectedModules })
    if ($missing.Count -gt 0 -or $unexpected.Count -gt 0 -or $modules.Count -ne $expectedModules.Count) {
        throw ('Module list mismatch. Missing: ' + ($missing -join ', ') + '; unexpected: ' + ($unexpected -join ', '))
    }

    foreach ($module in $modules) {
        Copy-Item -LiteralPath $module.FullName -Destination (Join-Path $stage $module.Name)
    }
    if (-not (Test-Path -LiteralPath $licenseFile)) {
        throw 'Missing LICENSE.txt. The package must include the license.'
    }
    Copy-Item -LiteralPath $licenseFile -Destination (Join-Path $stage 'LICENSE.txt')

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $manifest = @(
        'Version=1.0'
        'Title=Declarative UI for B4X'
        'Author=Maxel Chark Guzm' + [char]0xE1 + 'n'
        'Contact=maxelcfgos@gmail.com'
        'License=Public Development Release - see LICENSE.txt'
        'Usage=Free personal and commercial application use; testing and local modification welcome'
        'CommercialUse=Permitted for this release; please respect source authorship'
        'Modification=Testing and local project modifications welcome'
        'ReverseEngineering=Study, debugging and experimentation welcome'
        'Redistribution=Please do not repackage the implementation as your own library'
        'B4A.DependsOn=XUI, JavaObject, OkHttpUtils2'
        'B4J.DependsOn=jXUI, JavaObject, jOkHttpUtils2'
    ) -join [Environment]::NewLine
    [IO.File]::WriteAllText((Join-Path $stage 'manifest.txt'), $manifest, $utf8NoBom)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Compression.ZipFile]::CreateFromDirectory($stage, $tempZip, [IO.Compression.CompressionLevel]::Optimal, $false)

    Add-Type -AssemblyName System.IO.Compression
    $zip = [IO.Compression.ZipFile]::OpenRead($tempZip)
    try {
        $entries = @($zip.Entries)
        $expectedEntries = @('manifest.txt', 'LICENSE.txt') + $expectedModules
        $actualEntries = @($entries | ForEach-Object FullName)
        $missingEntries = @($expectedEntries | Where-Object { $_ -notin $actualEntries })
        $unexpectedEntries = @($actualEntries | Where-Object { $_ -notin $expectedEntries })
        if ($entries.Count -ne 46 -or $missingEntries.Count -gt 0 -or $unexpectedEntries.Count -gt 0) {
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
    Write-Host 'Contents: 44 UI modules + manifest.txt + LICENSE.txt'
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
