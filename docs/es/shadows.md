# Guía de sombras

## Resumen

El sistema de sombras genera sombras dinámicas a partir de los tiles seleccionados. Las sombras se calculan en tiempo de ejecución cuando el juego corre — no se guardan imágenes de sombra en los datos del mapa. Puedes crear varias sombras independientes por mapa, cada una con sus propios ajustes.

## Crear una sombra

1. Usa la herramienta Select para resaltar en el lienzo los tiles que deben proyectar sombra.
2. Abre los controles de la capa de sombra y elige "Generate Shadow".
3. Se crea una sombra a partir de las siluetas de los tiles seleccionados.

## Configuración de la sombra

Haz clic en la sub-fila de una sombra en el panel de capas para seleccionarla, luego abre el popup de configuración. Ajustes disponibles:

- **Name**: etiqueta personalizada para la sombra. Se muestra en el panel de capas. Déjalo vacío para mantener el predeterminado `Shadow N`. Al generar desde una selección desconectada, el nombre lleva el sufijo `(1)`, `(2)`, … por pieza.
- **Direction** (0–360°): ángulo de brújula hacia el que la sombra apunta lejos de la fuente. El popup muestra una rejilla de brújula de 8 botones (N/NE/E/SE/S/SW/W/NW) más un deslizador de ángulo libre. `180°` (sur, hacia abajo) es el valor por defecto.
- **Height** (0–2): longitud de la sombra como multiplicador de la altura del tile fuente. `0` deja la sombra plana, `1` iguala la altura de la fuente, `2` la duplica.
- **Tint**: color con el que se rellena la silueta. Negro por defecto. Usa un color más frío para sombras de atardecer, más cálido para puesta de sol, etc.
- **3D shadow**: cuando está marcado, se genera una segunda copia de la sombra anclada al borde superior del sprite (en vez de la base) y se fusiona en el mismo bitmap. Usa **2nd Offset X / Y** para posicionarla manualmente — no hay colocación automática porque el editor no puede saber, a partir de un sprite, dónde debería caer su proyección "superior". Ajusta el segundo offset para que las dos sombras formen la proyección que quieras.
- **Opacity** (0–255): lo oscura que aparece la sombra. El valor por defecto es 89 (~35%).
- **Offset X / Y**: ajuste fino de posición en incrementos de 0,25 tiles después de aplicar la geometría de dirección + altura.

Las direcciones diagonales cizallan (sesgan) automáticamente la silueta para que la proyección se incline, no solo se traslade. El este/oeste puro (90°/270°) colapsa la caída a una línea fina — eso es lo esperado; usa la sombra 3D + el segundo offset para añadir una proyección superior que combine en una forma de sombra lateral más completa.

## Selecciones desconectadas

Si tu selección tiene varios grupos separados de tiles (con huecos entre ellos), el editor los divide automáticamente en capas de sombra separadas — una por grupo conectado. Cada sombra obtiene sus propios límites y entrada en el panel de capas.

## Migrar sombras antiguas

Las sombras guardadas antes de la actualización de dirección/altura se renderizan en blanco al cargar. Abre cada una en el editor de sombras, elige la nueva dirección + altura y haz clic en Apply para migrarla. El antiguo valor `stretch` no tiene conversión automática.

## Sombras animadas

Cuando una sombra se genera a partir de autotiles animados, la sombra resultante se convierte en una hoja de sprites animada. Sus fotogramas se ciclan en sincronía con el autotile fuente, así que los tiles animados de agua o lava producen sombras animadas suaves.

## Presets

Haz clic en **Presets…** en la cabecera del popup de configuración de sombra para abrir el gestor de presets. Guarda la combinación actual de dirección / altura / tint / opacidad / offsets como un preset con nombre y aplícalo después a cualquier sombra nueva con un clic. El diálogo también admite renombrar, sobrescribir y borrar. Usa **Export…** para elegir qué presets guardar (todos marcados por defecto) — cada uno elegido se escribe como su propio archivo `ms_<name>_<index>_preset.json` en una carpeta que elijas — e **Import…** para traer de vuelta uno o varios archivos de preset a la vez (para copias de seguridad o compartir entre equipos). Los presets se guardan por instalación (compartidos entre todos tus proyectos) y se recuerdan entre sesiones.

## Gestionar sombras

- Puedes tener varias sombras por mapa, cada una totalmente independiente.
- Alterna la visibilidad de cualquier sombra desde el panel de capas.
- Ajusta la opacidad general por sombra.
- Haz clic en la sub-fila de una sombra para mostrar un contorno de selección cian en el lienzo, lo que facilita identificar cuál es cuál.
- Las sombras nunca acumulan opacidad donde se solapan — las sombras solapadas mantienen una densidad uniforme en vez de apilarse.

## Contorno de selección

Hacer clic en la sub-fila de una sombra en el panel de capas muestra un contorno cian alrededor de esa sombra en el lienzo, y resalta la propia fila en el panel. Este contorno solo es visible para la sombra seleccionada actualmente y no aparece en el juego. Pulsa `Ctrl+D` para deseleccionar.

## Interacción con el modo Dim

Cuando el modo Dim está activado (`D`) y la capa de sombra no es la capa activa, las sombras se renderizan a opacidad reducida para que los tiles subyacentes sigan visibles. Seleccionar una sombra recupera la opacidad completa para **solo esa** — todas las demás siguen atenuadas. Esto facilita identificar y ajustar una sola sombra sin perder la vista atenuada del resto. Desactiva Dim si quieres todas las sombras a opacidad completa a la vez.
