# Database

La ventana **Database** reúne los editores de datos de tu proyecto en una única ventana con pestañas, como RPG Maker XP. Ábrela desde el botón **Database** de la barra de herramientas o **Tools → Database…**. Switches, Variables y Tilesets tienen cada uno su propia pestaña dentro de la ventana.

Pestañas:

- **Tilesets**, **Switches**, **Variables** — los gestores existentes, embebidos directamente en la ventana.
- **Common Events** — scripts de comandos reutilizables (ver abajo).
- **Animations** — animaciones de batalla/mapa (ver abajo).
- Las pestañas restantes de RPG Maker XP (Actors, Items, …) se muestran pero están desactivadas por ahora.

> Cada editor tiene su propio botón **Aplicar**. Cambiar de pestaña o cerrar la ventana con cambios sin guardar te pide confirmar primero — y en la pestaña Tilesets, cambiar de tileset también. Cada guardado respalda el `.rxdata` original en una carpeta `map-backups` junto a él.

## Copiar, cortar y pegar registros

**Haz clic derecho en una fila** de Tilesets, Common Events o Animations para copiar o cortar el
registro completo y pegarlo en otro sitio — en otra ranura del mismo proyecto, o (con **Edit →
Advanced Clipboard → Cross-Project Clipboard** activado) en otra ventana de Maker Studio abierta:

- **Copiar tileset** / **Copiar evento común** / **Copiar animación** pone el registro — con todos
  sus ajustes — en el portapapeles.
- **Cortar tileset** / **Cortar evento común** / **Cortar animación** lo copia y luego lo quita. En
  **Common Events** y **Animations** no puede quitar la ranura del todo (otros comandos apuntan a
  estas por número), así que Cortar en su lugar **vacía la ranura** y deja la numeración intacta. En
  **Tilesets**, Cortar abre la confirmación de borrado normal, porque eliminar un tileset puede dejar
  otros mapas apuntando a nada.
- **Pegar tileset (reemplazar)** / **Pegar evento común (reemplazar)** / **Pegar animación
  (reemplazar)** sobrescribe el registro bajo el cursor. Se te pide confirmar antes de reemplazar un
  tileset.
- **Pegar como nuevo tileset** / **Pegar como nuevo evento común** / **Pegar como nueva
  animación** añade el registro copiado como una entrada nueva en lugar de sobrescribir nada.
- **Duplicar tileset** / **Duplicar evento común** / **Duplicar animación** copia el registro
  directamente en una ranura nueva al final de la lista, en un solo paso — sin usar el portapapeles.
  Su atajo es **Ctrl+J**, la misma tecla "Duplicar" que usa el resto del editor (selección de mapa,
  eventos, capas, mapas, páginas y comandos de evento).

Una misma copia se puede pegar tantas veces como quieras — volver a copiar reemplaza lo que hay en
el portapapeles. Pegar un tileset lleva todo consigo: su gráfico, los nombres de autotile, panorama/
niebla/fondo de batalla, y sus datos completos de paso/prioridad/etiqueta de terreno (ver [Editor de
tilesets](tileset-editor.md)).

**Switches** y **Variables** admiten la misma idea para un solo nombre: clic derecho en una entrada
para **Copiar nombre** / **Cortar nombre** / **Pegar nombre** / **Duplicar nombre**. Como el nombre
de un switch y el de una variable son el mismo tipo de dato por debajo, un nombre copiado (o cortado,
o duplicado) en Switches se puede pegar en Variables (y al revés).

**Atajos de teclado y deshacer**: haz clic en una fila para dar el foco de teclado a su lista, luego
**Ctrl+C** / **Ctrl+X** / **Ctrl+V** / **Ctrl+J** copian, cortan, pegan y duplican igual que el menú
contextual — las teclas exactas son las que tengas asignadas a Copiar/Cortar/Pegar/Duplicar en
**Help → Keyboard Shortcuts...**. **Ctrl+Z** / **Ctrl+Y** deshacen y rehacen ediciones a nivel de
registro en esa lista — ya no solo pegar/cortar/reemplazar/duplicar, sino también **+ Add**, **Change
Maximum…**, **New Tileset** y borrar un registro, incluyendo las escrituras a disco de Tilesets:
deshacer un tileset pegado o recién añadido escribe de vuelta los datos anteriores (o quita la ranura
que creó), y deshacer un tileset borrado lo escribe de vuelta en su antigua ranura. El deshacer de
cada lista es independiente del de los demás paneles — deshacer aquí nunca toca el lienzo del mapa ni
el historial de deshacer propio de un editor abierto.

## Common Events

Los common events son listas de comandos que puedes llamar desde cualquier sitio (mediante **Call Common Event**) o ejecutar automáticamente.

1. Elige un evento de la lista de la izquierda. Usa **Change Maximum…** para añadir o quitar ranuras.
2. Define su **Name**.
3. Elige un **Trigger**:
   - **None** — solo se ejecuta cuando otro evento lo llama.
   - **Autorun** — se ejecuta por sí solo y pausa el juego mientras corre (hasta que su switch de condición se apaga).
   - **Parallel** — se ejecuta en segundo plano junto con el juego.
4. Para Autorun/Parallel, elige un **Condition Switch** — el evento solo corre mientras ese switch esté ON.
5. Construye la **lista de comandos** con el mismo editor que los eventos de mapa (Insert / Edit / Delete / arrastrar para reordenar, copiar y pegar, deshacer/rehacer).
6. Haz clic en **Aplicar** para guardar.

También puedes copiar, cortar, pegar y duplicar un common event completo — ver [Copiar, cortar y
pegar registros](#copiar-cortar-y-pegar-registros) más arriba.

## Animations

El editor de Animations recrea la herramienta de animación de RPG Maker XP, con algunos extras.

**Configurar la animación**

1. Selecciona una animación a la izquierda (o **Change Maximum…** para añadir ranuras) y dale un **Name**.
2. Haz clic en **Graphic** para elegir la spritesheet de `Graphics/Animations/` (y un desplazamiento de hue opcional).
3. Elige una **Position** (Top / Middle / Bottom / Screen) y el número de **Frames**.

**Editar las celdas de un frame**

Cada frame se compone de *celdas* — piezas de la spritesheet colocadas sobre el objetivo.

- Haz clic en una celda de la **hoja** (abajo a la derecha) para añadirla; haz clic en una celda del **lienzo** para seleccionarla, y arrastra para moverla.
- Con una celda seleccionada, ajusta **X / Y / Zoom / Angle / Opacity / Blend / Mirror** y su **Pattern** (qué imagen de la hoja muestra). Usa **Add / Dup / Del** para las celdas.
- Avanza por los frames con **◀ / ▶** o la tira numerada de frames. Activa **Onion** para ver el frame anterior tenue detrás del actual.
- **▶ Play** previsualiza la animación (frames + destellos de pantalla). **↶ / ↷** deshacen/rehacen tus ediciones.
- Teclado: **Ctrl+C / Ctrl+V / Ctrl+X** copian/pegan/cortan celdas, **Supr** quita la celda seleccionada, **Ctrl+Z / Ctrl+Y** deshacer/rehacer.

**Herramientas de frame**

- **+ Frame** añade un frame; **Paste Last** copia las celdas del frame anterior en el actual.
- **Copy Frame / Paste Frame / Clear Frame** actúan sobre todo el frame actual.
- **Tweening…** interpola suavemente un rango de celdas entre dos frames (elige qué frames, qué celdas y si interpolar Pattern, Position/Zoom/Angle y/o Opacity/Blending).
- **Cell Batch…** establece valores elegidos (X, Y, Zoom, Angle, Flip, Opacity, Blending, Pattern) en un rango de celdas a lo largo de un rango de frames.
- **Entire Slide…** desliza cada celda a lo largo de un rango de frames por una cantidad X/Y por frame.

**Temporización de SE y flash**

En la lista **SE and Flash Timing** (derecha), pulsa **Add** para una temporización, luego configura:

- **Frame** en el que se dispara.
- **SE** — un efecto de sonido (elige nombre/volumen/pitch).
- **Flash** — None / Target / Screen / Hide Target, más color, alpha y duración.
- **Condition** — None / Hit / Miss (cuándo se aplica la temporización).

Haz clic en **Aplicar** para guardar. Tus cambios se escriben directamente de vuelta en `Animations.rxdata`, así que aparecen en el juego.

También puedes copiar, cortar, pegar y duplicar una animación completa — ver [Copiar, cortar y pegar
registros](#copiar-cortar-y-pegar-registros) más arriba.
