# Guía de herramientas

## Herramientas disponibles

| Herramienta | Tecla | Descripción |
|------|-----|-------------|
| Brush | B | Pinta tiles. Una vista previa translúcida del/los tile(s) que vas a colocar sigue al cursor. Admite estampas multi-tile y tamaño de pincel ajustable. Shift+clic dibuja una línea desde la última posición pintada. Ctrl+arrastrar bloquea el pintado a un solo eje. |
| Eraser | E | Borra tiles dejándolos vacíos. Tiene su propio tamaño de borrador ajustable. Shift+clic dibuja una línea desde la última posición borrada. Ctrl+arrastrar bloquea el borrado a un solo eje. |
| Fill | F | Rellena por inundación un área contigua con el tile seleccionado. |
| Rectangle | R | Haz clic y arrastra para rellenar un área rectangular. Se muestra una vista previa del patrón de tiles mientras arrastras. |
| Eyedropper | I | Toma un tile y sus propiedades desde el lienzo. |
| Select | S | Haz clic y arrastra para seleccionar un área. Arrastra la selección para mover tiles. Ctrl+arrastrar para añadir tiles, Shift+arrastrar para quitar tiles de la selección. |
| Pan | Espacio (mantener) | Desplaza el viewport. |

> **En la capa de eventos**, solo se aplican **Brush**, **Eraser**, **Select** y **Pan** — Fill, Rectangle y Eyedropper están desactivados, y el tamaño de pincel no tiene efecto. Select hace selección de caja de eventos para mover/borrar en grupo. Consulta [Editor de eventos](events-editor.md#tools-on-the-events-layer).

> **Vistas previas de autotiles:** cuando se selecciona un autotile, la vista previa del Brush y la del arrastre del Rectangle lo muestran totalmente bordeado — esquinas, bordes e interior se dibujan tal como quedarán colocados, y la vista previa se conecta con los autotiles coincidentes que ya hay en el mapa. Una parte de detalle de autotile bloqueada se previsualiza como la parte exacta que elegiste. El resultado colocado coincide con la vista previa.

## Propiedades del pincel

Cuando una herramienta está activa puedes ajustar propiedades por tile antes de pintar. Se configuran en el panel Tile Properties:

- **Opacity**: 0–255 (lo transparente que aparece el tile).
- **Rotation**: 0–360 grados.
- **Hue**: 0–360 (desplazamiento de color).
- **Saturation**: 0–200 (intensidad de color).
- **Lighting**: -255 a 255 (brillo).
- **Flip H / Flip V**: voltea el tile horizontal o verticalmente.

La rotación y el volteo no se aplican a los autotiles: un autotile elige su patrón según los tiles de alrededor, así que uno rotado o reflejado ya no encajaría con el borde para el que se eligió. Mientras hay un autotile seleccionado, los cuatro controles de transformación aparecen atenuados ("Los autotiles no se pueden rotar ni voltear — su patrón depende de los tiles de alrededor"), y las opciones del menú Edit y las teclas Q / W no hacen nada.

### Bloqueo (Lock)

El botón de bloqueo en la cabecera del panel Tile Properties (un icono de candado abierto o cerrado) controla qué ocurre al elegir un tile distinto.

- **Desbloqueado** (por defecto): seleccionar otro tile restablece todas las propiedades del pincel a sus valores por defecto — empiezas cada tile desde cero.
- **Bloqueado**: las propiedades actuales del pincel se mantienen aplicadas a lo que elijas después, así puedes pintar muchos tiles distintos con el mismo efecto.

El estado de bloqueo se recuerda entre sesiones. El Eyedropper siempre aplica las propiedades del tile tomado, independientemente del estado de bloqueo — tomar con el cuentagotas se trata como "dame este tile exacto".

### Presets

Haz clic en **Presets…** en la cabecera del panel Tile Properties para abrir el gestor de presets. Desde aquí puedes:

- **Save current** como un nuevo preset con nombre — útil para combinaciones que reutilizas (p. ej. "Noche apagada", "Sepia").
- **Apply** un preset guardado al pincel actual — el diálogo se cierra tras aplicar.
- **Rename** un preset existente.
- **Overwrite** un preset con los valores actuales del pincel.
- **Delete** un preset.
- **Export…** tus presets — marca los que quieras (todos marcados por defecto), elige una carpeta, y cada uno se guarda como su propio archivo `ms_<name>_<index>_preset.json`, así puedes compartir o respaldar solo los presets que elijas.
- **Import…** uno o varios archivos de preset a la vez — selecciona varios archivos en el selector y todos se fusionan. Los presets se fusionan por nombre (un nombre coincidente se sobrescribe); los archivos que contienen otro tipo de preset (p. ej. presets de sombra) se omiten.

Un lienzo de vista previa muestra cómo quedaría el preset resaltado aplicado al tile seleccionado actualmente. Los presets se guardan por instalación (compartidos entre todos tus proyectos) y se recuerdan entre sesiones.

## Tamaño de pincel y borrador

Usa las teclas `[` y `]` para reducir o aumentar el tamaño del pincel mientras la herramienta Brush está activa, o el tamaño del borrador mientras la herramienta Eraser está activa. Alt + rueda también ajusta el tamaño de la herramienta activa.

## Pintado de líneas (Shift+Clic)

Con la herramienta Brush o Eraser activa, pinta en una posición, luego mantén Shift y pinta en otra. Se dibuja una línea recta entre los dos puntos usando el algoritmo de Bresenham. El grosor de la línea coincide con tu tamaño actual de pincel o borrador. Funciona tanto en diagonal como en líneas alineadas con los ejes. Se muestra una vista previa de la línea mientras se mantiene Shift.

## Pintado bloqueado por eje (Ctrl+Arrastrar)

Con la herramienta Brush o Eraser activa, mantén Ctrl y arrastra. El primer tile que muevas fuera de la posición del clic elige el eje (horizontal o vertical, según en cuál te hayas movido más), y todo el pintado posterior se ajusta a ese único eje. Soltar Ctrl a mitad de trazo desbloquea y reanuda el pintado libre. Útil para líneas rectas limpias sin recurrir a Shift+clic.

## Custom Shape Brush

Un Custom Shape Brush te deja construir un pincel reutilizable a partir de una forma, un grupo ponderado de tiles y un conjunto de propiedades de pintado. Funciona con las herramientas Brush, Eraser, Fill y Rectangle.

### Abrir el editor

Abre el Brush Editor desde cualquiera de estos:

- El **popover del Brush al pasar el ratón** en la barra de herramientas (pasa sobre el botón de Brush).
- **Tools → Brush Editor…** en la barra de menús.

El popover del Brush también tiene un **conmutador rápido** — un desplegable que lista tus presets de pincel guardados más **Default (square)** y **Custom (unsaved)**. Elige uno para activarlo al instante sin abrir el editor.

Una vez que has usado un pincel personalizado, un indicador compacto en la barra muestra su **nombre** (su nombre de preset, o "Custom") y funciona como **interruptor on/off** entre ese pincel y el pincel cuadrado por defecto. Haz clic en el conmutador (o pulsa **A**) para alternar entre ellos — el indicador permanece visible, atenuado, mientras está apagado para que puedas volver. Haz clic en la **✕** para limpiar el pincel por completo y olvidarlo (el indicador desaparece, dejándote con el pincel cuadrado por defecto).

### Construir un pincel

El editor tiene tres secciones:

- **Shape** — elige **Square**, **Circle**, **Diamond**, **Plus** o **Custom**. El deslizador de tamaño define la huella, limitada por el **Min size** / **Max size** que configures debajo. No hay límite superior fijo de tamaño — pon Max tan grande como quieras. **Custom** te da en su lugar una cuadrícula: define su ancho y alto, luego haz clic en las celdas para activarlas o desactivarlas y dibujar la forma que quieras. Redimensionar la cuadrícula conserva las celdas ya dibujadas.
- **Tiles** — construye un grupo ponderado de tiles del que el pincel toma.
  - **Add fixed tile** añade el tile actualmente seleccionado en la paleta.
  - **Add Current Tile** añade una entrada especial que siempre usa el tile que esté seleccionado en el momento de pintar (puedes tener como máximo una de estas).
  - También puedes añadir **grupos multi-tile** — una pequeña cuadrícula de tiles que siempre se pintan juntos, alineados a la cuadrícula del mapa. Los grupos se mantienen coherentes dentro de un trazo (sin tiles sueltos que los rompan a mitad de grupo), mientras que los tiles individuales se dispersan independientemente por celda.
  - Cada entrada tiene un **peso**; el porcentaje mostrado junto a ella es la probabilidad de que esa entrada se elija, normalizada frente a las demás. Quita una entrada con su **✕**.
  - Deja el grupo vacío para simplemente pintar el tile seleccionado actualmente.
- **Shared Properties** — las propiedades visuales horneadas en los tiles pintados: **Hue**, **Saturation**, **Lighting**, **Opacity** y un grupo **Transform** (rotar 90° en cualquier sentido, voltear horizontal/vertical — se ignora en autotiles). Se aplican a todo el pincel. Para dar a un tile concreto del grupo sus propios valores, selecciónalo y edítalo — entonces lleva una sustitución. Haz clic en **Clear (follow shared)** en un tile para descartar su sustitución y volver a usar el conjunto compartido. (La prioridad, el terrain tag y el paso no se configuran aquí — los tiles pintados los heredan del tileset.)

Una **vista previa en vivo** en el editor muestra la forma del pincel rellena con una muestra representativa de su grupo de tiles y propiedades, para que veas el resultado antes de pintar.

Haz clic en **Apply** para guardar el pincel, o **Close** para descartar tus cambios.

### Tamaño, borrador y otras herramientas

- **Brush size**: arrastra el deslizador de tamaño en el popover del Brush, o usa `[` / `]`, o **Alt + rueda**. El tamaño se limita al rango Min/Max del pincel. Un aviso "Brush N×N" parpadea en el lienzo al redimensionar.
- **Eraser**: mientras hay un pincel personalizado activo, el Eraser usa la misma **forma** pero mantiene su **propio tamaño** (separado del tamaño del pincel, también limitado al Min/Max del pincel). Redimensiónalo de la misma forma — `[` / `]` o Alt+rueda mientras la herramienta Eraser está activa. Parpadea un aviso "Eraser N×N". El grupo de tiles se ignora — borrar siempre deja vacío. (Las formas de máscara personalizada no tienen tamaño escalar, así que redimensionar no hace nada para ellas.)
- **Fill**: el relleno por inundación coincide con la región pulsada (mismo tile / autotile) pero escribe tiles del grupo ponderado del pincel en cada celda rellenada.
- **Rectangle**: cada celda del rectángulo arrastrado toma un tile del grupo ponderado del pincel. Una vista previa con semilla fantasmea los tiles del grupo por el rectángulo mientras arrastras.

### Guardar y compartir

Haz clic en **Presets…** en el editor para guardar el pincel actual como un preset con nombre, aplicar uno guardado, o **Export** / **Import** pinceles como archivos para compartirlos o moverlos entre proyectos. El rango de tamaño del pincel viaja con él, así que un pincel importado conserva su propio Min/Max. (Funciona igual que los presets de Tile Properties — consulta [Presets](#presets) arriba.)

## Estampas multi-tile

Para pintar más de un tile a la vez, haz clic y arrastra en la Paleta de tiles para seleccionar un grupo rectangular de tiles. Toda la estampa sigue al cursor mientras pintas. Pulsa Q o W para rotar la estampa en sentido antihorario u horario — una estampa que contenga algún autotile se queda como está, ya que los autotiles no se pueden rotar. Arrastrar cerca del borde superior o inferior de la paleta autodesplaza para seleccionar tiles fuera del área visible.

## Cambiar de tileset en la paleta

El cuadro de búsqueda en la parte superior de la Paleta de tiles filtra todos los tilesets por nombre, archivo gráfico o id. Escribe para filtrar, usa las flechas y Enter (o haz clic) para elegir uno, y la paleta cambia para mostrar los tiles de ese tileset. Elegir un tileset cierra el desplegable y quita el foco del cuadro de búsqueda, así que la siguiente tecla va a tu mapa en lugar de al campo de búsqueda.

## Autotiles en la paleta

Debajo de la cuadrícula del tileset, la sección **Autotiles** lista cada autotile con nombre de tu carpeta `Graphics/Autotiles/`. Haz clic en la cabecera para expandirla o plegarla.

- **Búsqueda**: escribe en el cuadro de búsqueda encima de la cuadrícula de autotiles para filtrar la lista por nombre (sin distinguir mayúsculas, coincide con cualquier parte del nombre). Haz clic en el botón **×** para limpiar la búsqueda y mostrar todos los autotiles de nuevo.
- **Nombres al pasar el ratón**: pasa sobre cualquier autotile de la cuadrícula y un pequeño tooltip muestra su nombre.
- **Seleccionar para pintar**: haz clic en un autotile para seleccionarlo para las herramientas Brush, Fill y Rectangle.
- **Abrir detalle**: haz doble clic en un autotile (o clic derecho y elige **Open Autotile**) para abrir su panel de detalle, donde puedes elegir una pieza individual del autotile para estampar como parte fija.

Si tu filtro no coincide con nada, la sección muestra **"No autotiles match."**; si el proyecto no tiene autotiles en absoluto, muestra **"No autotiles found."**

## Actualización en vivo de gráficos de tileset

Si editas el archivo gráfico de un tileset en `Graphics/Tilesets/` mientras el proyecto está abierto — lo repintas en un editor externo, lo reemplazas o pones una versión nueva — la Paleta de tiles capta el cambio y se redibuja con la nueva imagen automáticamente, sin recargar. (Esto coincide con cómo se refrescan los gráficos de autotile en `Graphics/Autotiles/`.)

## Herramienta de selección

- **Clic y arrastrar**: selecciona un área rectangular.
- **Ctrl + clic/arrastrar**: añade tiles a la selección actual (unión).
- **Shift + clic/arrastrar**: quita tiles de la selección actual (diferencia).
- **Clic en un tile seleccionado + arrastrar**: mueve la selección a una nueva posición.
- **Ctrl+A**: selecciona todos los tiles de la capa actual.

Las selecciones pueden no ser rectangulares usando Ctrl/Shift. El overlay de resaltado hace visibles las celdas seleccionadas con un relleno dorado y bordes de celda.

### Arrastrar fuera del mapa

Para las herramientas Rectangle y Select, puedes empezar o terminar un arrastre en el área vacía junto al mapa — la selección / rectángulo se ajusta al tile de borde más cercano en lugar de cancelarse. El arrastre también continúa si tu cursor sale del lienzo por completo (p. ej. entra en otro panel); suelta el botón del ratón en cualquier sitio para terminar. Mover una selección no se ve afectado: hacer clic fuera del mapa siempre inicia una selección nueva en lugar de provocar un movimiento, aunque el tile de borde ajustado caiga dentro de tu selección actual.

## Deshacer / Rehacer con selecciones movidas

Cuando mueves una selección con la herramienta Select, el marco de selección ahora sigue el movimiento al Deshacer / Rehacer — deshacer devuelve tanto los tiles como la selección a donde estaban antes del movimiento, y rehacer reaplica ambos. Antes, deshacer un movimiento dejaba la selección en su posición posterior al movimiento aunque los tiles volvieran a su sitio.

## Copiar y pegar

- Ctrl+C copia el área seleccionada con datos completos de tile (incluidas las propiedades por tile en capas extendidas).
- Ctrl+Shift+C copia la selección de todas las capas a la vez.
- Ctrl+V entra en modo de vista previa de pegado. Mueve el cursor para posicionar el pegado, luego haz clic para confirmar.
- Ctrl+Shift+V (Paste All Layers) pega en las capas de origen originales de las que se copió cada tile, en lugar de en la capa activa — mismo flujo de vista previa y clic.
- Pulsa Escape para cancelar la vista previa de pegado.
- **Entre dos proyectos abiertos:** activa **Edit → Advanced Clipboard → Cross-Project Clipboard** en ambas ventanas, y entonces una copia de tile (o de todas las capas) se puede pegar en la ventana de otro proyecto. Desactivado por defecto.

## Referencia rápida

- Alt + clic actúa como cuentagotas sin abandonar tu herramienta actual.
- Clic derecho abre un menú contextual.
- Q y W rotan el pincel o la estampa en sentido antihorario y horario.
- Ctrl + arrastrar con Brush o Eraser bloquea el pintado a un solo eje.
