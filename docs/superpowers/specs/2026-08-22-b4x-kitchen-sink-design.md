# Diseño: Kitchen Sink Declarative UI + UINavigator

Fecha: 2026-08-22 (rev. 2)
Proyecto: `examples/b4x_kitchen_sink` (B4A)
Estado: diseño aprobado; rev. 2 según decisión del usuario: navegación exclusivamente
con la vía integrada de la librería (`UINavigator`) y cada pantalla como clase propia.

## Objetivo

Convertir el template vacío en **el ejemplo de referencia** de Declarative UI para B4A:

1. **Separación de concerns**: cada pantalla vive en su propia clase módulo.
2. **Catálogo completo**: demuestra todos los factories `UI.*`.
3. **Navegación 100% librería**: rutas virtuales con `UINavigator`; nada de
   `B4XPages.ShowPage`, ni múltiples páginas, ni Designer.

Restricción general: usar la librería casi al 100% — sin `.bal`, sin
`Dim x As UIxxx` + `Initialize`, sin protocolo Tier B en código de app.

## Requisitos esenciales (condición del usuario)

1. **Gestión de estado de primera clase**: flujo unidireccional real.
   - Estados de demo por pantalla viven en la instancia de la clase (`UIState` /
     `UIAsyncState` en `Class_Globals`), creados en `Initialize`, nunca dentro de `Build`.
   - Estados compartidos (índice de navegación, progreso global de demos) en el code
     module `App`.
   - La UI solo muta vía `SetState`; los bindings son el único camino state→UI.
   - Ningún widget guarda texto "fuente de verdad": si algo se muestra y cambia,
     está bindeado o se reconstruye explícitamente.
2. **UI IMPRESIONANTE**: el ejemplo debe lucir, no solo funcionar.
   - Sistema visual coherente basado 100% en tokens `UITheme` (typography scale,
     superficies, radius, spacing rítmico).
   - Home tipo galería premium: tarjetas con icono + título + descripción,
     agrupadas por sección, jerarquía tipográfica clara.
   - Cada pantalla tiene cabecera descriptiva, chips/badges de categoría y demos
     agrupadas en tarjetas con títulos de sección.
   - Modo oscuro impecable en todas las pantallas (el toggle debe ser un momento
     "wow", no un parche).
   - Micro-detalles: iconografía consistente (FA/Material), divisores sutiles,
     espaciado generoso, SnackBars de feedback en cada interacción relevante.

## Arquitectura

### Shell

- Se elimina la dependencia de navegación de B4XPages: el proyecto vuelve al modelo
  de actividad simple (como `b4a_declarative_counter`).
- `Main.Activity_Create` inicializa `App` (tema + clases de pantalla + navigator)
  y monta: `UI.Show(Activity, App.Nav)`.

### Navegación (solo librería)

- Un único `UINavigator` global vive en el code module `App`.
- Cada pantalla es una **clase** registrada por nombre: `App.RegisterScreens`
  hace `Nav.AddScreen("home", HomeScreen.Build)` etc.
- Avanzar: las pantallas llaman `App.Navigate("inputs")` (wrapper de
  `Nav.NavigateTo`). Volver: acción flecha en cada AppBar → `Nav.GoBack`;
  el botón atrás del sistema se integra en `Main.Activity_KeyPress` → `Nav.GoBack`.

### Librerías y manifest

- Referencias: `core, xui, declarativeui, javaobject, okhttputils2`
  (+ `B4XPages` ya no es necesaria; se quita del proyecto).
- Manifest: `AddPermission(android.permission.INTERNET)` para `UI.ImageNetwork`;
  orientación portrait.

### Estado compartido y tema

Code module `App`:

```basic
Sub Process_Globals
    Public Theme As UITheme
    Public Nav As UINavigator
    Public Home As HomeScreen   ' una instancia por pantalla, creada una vez
    Public TextScr As TextScreen
    ' ... resto de pantallas
End Sub

Public Sub Start(Root As B4XView)
    Theme = UI.ThemeWithScheme(0xFF6558D3)
    RegisterScreens
    RebuildNavigator
    UI.Show(Root, Nav)
End Sub

Public Sub Navigate(Name As String)
    Nav.NavigateTo(Name)
End Sub

Public Sub ToggleTheme
    Theme.Toggle
    RebuildNavigator ' reconstruye árboles con el nuevo tema y re-monta
End Sub

Public Sub RebuildNavigator
    UI.Unmount(Nav)   ' si estaba montado
    Nav.Initialize
    Nav.AddScreen("home", Home.Build)
    ' ... resto de pantallas
    UI.Show(Root, Nav)
End Sub
```

- Las **instancias de pantalla sobreviven** al rebuild: sus `UIState` viven en
  `Class_Globals` de la instancia, así los valores (contador, switches…) persisten
  entre cambios de tema; solo se regeneran los árboles de widgets.
- Detalle de implementación: si `UINavigator` ya montado no admite re-registro,
  `RebuildNavigator` crea un navigator nuevo y `UI.Show` lo monta sobre el root
  tras `UI.Unmount` del anterior.

### Patrón estándar de pantalla

```basic
' TextScreen.cls
Sub Class_Globals
    Private DemoState As UIState ' sobrevive rebuilds de tema
End Sub

Public Sub Initialize
    DemoState = UI.State("...")
End Sub

Public Sub Build As Object
    Return UI.Scaffold(BuildBody) _
        .AppBar(UI.AppBar("Textos") _
            .Action(UI.Icon(back glyph).OnClick(Me, "Back_Click"))) _
        .ApplyTheme(App.Theme)
End Sub

Private Sub Back_Click
    App.Nav.GoBack
End Sub

' eventos propios de la demo...
```

Reglas:

- Solo factories `UI.*` + chaining fluido (` _`); builders privados dividen
  pantallas grandes; nunca un builder por widget.
- Eventos `(Me, "...")` — callbacks dentro de la clase.
- Cambios estructurales → rebuild de la pantalla actual vía `App.RebuildNavigator`
  (o rebuild local si la demo lo permite); cambios de valor → `SetState`.

## Catálogo de pantallas

| Ruta | Clase | Demuestra |
|------|-------|-----------|
| `home` | `HomeScreen` | Galería `UI.Scroll`+`Column` de `UI.Card` por categoría; AppBar con acción toggle de tema |
| `text` | `TextScreen` | `UILabel`: typography tokens, colores, `BindText` en vivo |
| `buttons` | `ButtonsScreen` | `UIButton` (radio/border), `UIFab`, `UIIcon` clickable (Unicode/FA/Material) |
| `inputs` | `InputsScreen` | `UIInput` (hint/password/OnTextChanged→state), `UISwitch`, `UICheckbox`, `UIRadioButton` |
| `layout` | `LayoutScreen` | `Column/Row` (alignments, spacing), `Stack`, `Padding`, `Card`, `Center`, `Expanded`+`Scroll`, `Space`, `Divider`, `Visibility` |
| `media` | `MediaScreen` | `UIImage` asset/red + callbacks, `UIProgressBar` (determinate/indeterminate/BindValue), `UINative` (SeekBar), `UIPlaceholder` |
| `list` | `ListScreen` | `UIListView` (~200 items), `CreateItem`/`BindItem`, `NotifyDataSetChanged`, `ScrollTo` |
| `state` | `StateScreen` | `UIState`: label+botón+progress ligados al mismo estado |
| `async` | `AsyncScreen` | `UIAsyncState`: carga simulada (Sleep) → loading/success/error + retry vía `Visibility` |
| `overlays` | `OverlaysScreen` | `UISnackBar` (acción/duración), `UIAlertDialog` (widget de contenido), `UIAnimation` |
| `navigation` | `NavigationScreen` | Anatomía de `UIScaffold` (AppBar+acciones, FAB izq/der, `UIBottomNavigationBar`+`BindSelectedIndex`) y `UINavigator` anidado con GoBack |
| `theme` | `ThemeScreen` | `UITheme`: semillas preset, Toggle claro/oscuro, muestra de tokens |

Los ~35 factories públicos de `UI.bas` quedan representados.

## Flujo de datos

Unidireccional: evento → `SetState` → bindings re-layout automáticos.
Estructural (tema/rutas) → `App.RebuildNavigator` / `NavigateTo`.

## Manejo de errores

- `Log(UI.Errors)` tras montar (solo Debug).

## Verificación

1. `python check-b4x-source.py` tras cada módulo.
2. b4x-mcp: `validate_b4x_syntax` → `compile_project` → `get_codebundle`.
3. Smoke test opcional con `run_b4a_on_device`.

## Fuera de scope

- Carpetas `B4J/` y `B4i/`; two-way form binding; listas de alto variable;
  animaciones implícitas; localización.

## Abierto durante implementación

- Confirmar vía b4x-mcp si `UIPlaceholder` tiene factory o requiere `Initialize`.
- Comprobar comportamiento exacto de re-registro en `UINavigator.AddScreen`
  (define si `RebuildNavigator` recicla o recrea el navigator).
