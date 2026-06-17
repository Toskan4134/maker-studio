# Database

La ventana **Database** reúne los editores de datos de tu proyecto en una única ventana con pestañas, como RPG Maker XP. Ábrela desde el botón **Database** de la barra de herramientas o **Tools → Database…**. Switches, Variables y Tilesets tienen cada uno su propia pestaña dentro de la ventana.

Pestañas:

- **Tilesets**, **Switches**, **Variables** — los gestores existentes, embebidos directamente en la ventana.
- **Common Events** — scripts de comandos reutilizables (ver abajo).
- **Animations** — animaciones de batalla/mapa (ver abajo).
- Las pestañas restantes de RPG Maker XP (Actors, Items, …) se muestran pero están desactivadas por ahora.

> Cada editor tiene su propio botón **Apply**. Cambiar de pestaña o cerrar la ventana con cambios sin guardar te pide confirmar primero. Cada guardado respalda el `.rxdata` original en una carpeta `map-backups` junto a él.

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
6. Haz clic en **Apply** para guardar.

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

Haz clic en **Apply** para guardar. Tus cambios se escriben directamente de vuelta en `Animations.rxdata`, así que aparecen en el juego.
