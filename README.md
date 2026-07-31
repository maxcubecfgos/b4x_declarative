# Declarative UI para B4X

Framework experimental de composición y layout declarativo para B4A. El proyecto está inspirado en patrones de Flutter (`Row`, `Column`, `Expanded`, `Scaffold`) pero está implementado como clases B4X que generan y posicionan vistas nativas.

> **Estado:** prototipo avanzado para B4A. La arquitectura está preparada para evolucionar hacia B4J, pero esta revisión no afirma compatibilidad compilada con B4J.

## Objetivo

El proyecto busca reducir el uso de coordenadas manuales y permitir construir una pantalla como un árbol composable:

```basic
Dim Title As UILabel
Title.Initialize.Text("Título").Size(20)

Dim Content As UIColumn
Content.Initialize

Dim Padding As UIPadding
Padding.Initialize.All(16dip).Child(Content)

Dim Footer As UILabel
Footer.Initialize.Text("Footer")

Dim FooterExpanded As UIExpanded
FooterExpanded.Initialize.Child(Footer)

Dim Body As UIColumn
Body.Initialize.Spacing(12dip) _
    .AddChild(Title) _
    .AddChild(Padding) _
    .AddChild(FooterExpanded)

Dim Screen As UIScaffold
Screen.Initialize.Body(Body)
```

La API actual es fluida: los métodos de configuración devuelven `Me`, por lo que los componentes se pueden encadenar.

## Componentes principales

- `UIRow`: distribución horizontal.
- `UIColumn`: distribución vertical.
- `UIExpanded`: hijo flexible que acepta el espacio restante.
- `UISpace`: espacio intrínseco fijo.
- `UIPadding`, `UIBox`, `UICard`, `UICenter`: wrappers de composición.
- `UILabel`, `UIButton`, `UIFloatingActionButton`, `UIAppBar`, `UIDivider`: componentes visuales.
- `UIScaffold`: composición de AppBar, body y FABs.
- `UINavigator`: registro y reemplazo de pantallas dentro de un host aislado.

## Contrato de componente

B4X no proporciona interfaces de usuario con comprobación estática. El framework usa un contrato por convención y `CallSub`:

```text
SetParent(Parent As B4XView)
SetPosition(Left As Int, Top As Int)
SetSize(Width As Int, Height As Int)
Render
GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
Unmount                  ' recomendado; opcional para componentes legacy
```

Un componente externo que se añada a `UIRow`, `UIColumn` o un wrapper debe implementar las cinco primeras subs. `Unmount` es opcional porque los contenedores comprueban `xui.SubExists` antes de invocarlo.

`AddChild(Null)` se ignora para evitar que un árbol inválido falle más tarde durante la medición. Solo ese caso se filtra automáticamente; la validación del resto del contrato ocurre en tiempo de ejecución y puede producir un error si faltan subs o sus firmas no coinciden.

## Medición y layout

`GetContentSize` devuelve una `List` de dos posiciones:

```text
[width, height]
```

- Una lista representa tamaño intrínseco.
- `Null` significa que el componente acepta espacio flexible.
- `UIRow` suma anchos y usa la mayor altura.
- `UIColumn` suma alturas y usa el mayor ancho.
- Una fila/columna con hijos flexibles recibe el espacio restante.
- `Spacing(Value)` añade gaps únicamente entre hijos, nunca antes del primero ni después del último.
- Si la división del espacio no es exacta, los primeros hijos flexibles reciben el píxel sobrante.

La medición todavía usa límites enteros y una convención histórica de valores no positivos como “sin límite”. La siguiente evolución debería introducir un objeto de constraints explícito para distinguir “sin límite”, “cero” y “error”.

## Ciclo de vida

El ciclo actual es retenido e imperativo, aunque la composición de componentes sea declarativa:

1. Se construye el árbol con clases B4X.
2. El padre asigna `SetParent`, posición y tamaño.
3. `Render` monta o actualiza la vista nativa.
4. `Unmount` limpia referencias y desmonta recursivamente los componentes que lo soportan.

`Render` debe poder llamarse repetidamente sobre un componente montado. `Unmount` es importante cuando se retira el árbol, se cambia de pantalla o se reconstruye una raíz.

## Navegación

`UINavigator` es el propietario de la raíz de navegación:

```basic
Navigator.Initialize _
    .AddScreen("Dashboard", DashboardScreen) _
    .AddScreen("Login", LoginScreen)

Navigator.SetParent(Root)
Navigator.SetPosition(0, 0)
Navigator.SetSize(Root.Width, Root.Height)
Navigator.Render

Navigator.NavigateTo("Login")
```

El navigator crea un host propio, desmonta la pantalla actual, limpia el host y monta solo la nueva pantalla. Una pantalla legacy que no implemente `Unmount` no se reemplaza automáticamente: el navigator conserva la pantalla actual para no dejar referencias nativas en un estado desconocido.

Cuando `UINavigator` es la raíz, la aplicación no debe ejecutar `Root.RemoveAllViews` para reconstruir cada pantalla: eso elimina el host desde fuera y rompe la propiedad del árbol visual.

## Overflow y límites actuales

Los hijos intrínsecos conservan su tamaño natural. Si el tamaño natural más los gaps excede el contenedor, el framework no comprime automáticamente los controles; el resultado depende del clipping del contenedor nativo. Esta política evita deformar botones y etiquetas, pero todavía debe formalizarse con un sistema de constraints y pruebas visuales.

`UILabel` usa actualmente una medición aproximada de texto. Multilínea, wrapping, fuentes, RTL, accesibilidad y tamaños dinámicos requieren trabajo adicional.

## Compatibilidad

- **B4A:** plataforma objetivo; se realizaron validaciones estáticas, pero no se pudo compilar en este entorno.
- **B4J:** todavía no compilado en esta revisión.
- **B4X compartido:** el contrato usa `B4XView`, pero varias clases crean `Panel` directamente. Para avanzar hacia B4J, la ruta recomendada es encapsular la creación con `xui.CreatePanel("")` y aislar propiedades nativas (`Panel`, `Button`, `ColorDrawable`) detrás de adaptadores.

## Deuda técnica priorizada

1. Introducir `UIConstraints`, `UISize` y un resultado de medición no ambiguo.
2. Validar el contrato completo al añadir componentes y producir errores de debug claros.
3. Separar formalmente `Measure`, `Layout`, `Mount`, `Update` y `Unmount`.
4. Mejorar medición de texto, wrapping, teclado y accesibilidad.
5. Añadir temas y estilos propagables.
6. Crear una matriz de pruebas real para B4A y B4J.
7. Migrar progresivamente la creación de paneles a XUI para portabilidad.

Todavía no hay reconciliación/diffing, estado reactivo, Virtual DOM ni soporte de modificadores. No se deben prometer estas capacidades como si ya existieran.

## Validación

En el entorno de desarrollo usado para esta evolución no está instalado el compilador B4A. Por eso se han realizado validaciones estáticas: balance de `Sub`/`End Sub`, `git diff --check`, revisión de contratos, comprobación de referencias y modelos matemáticos del layout. La validación definitiva requiere compilar y ejecutar el proyecto en B4A, y posteriormente en B4J.

## Commits de esta evolución

- `4209f7d` — checkpoint del progreso previo.
- `497fefd` — ciclo seguro `Unmount`.
- `6ef8360` — expansión de filas basada en capacidad, no en `GetType`.
- `906a0c8` — host aislado y navegación real.
- `3d61ef8` — integración del navigator en la aplicación de ejemplo.
- `a7a0b88` — spacing consistente en Row y Column.

Cada bloque se mantiene separado para poder revertirlo sin perder el trabajo anterior.
