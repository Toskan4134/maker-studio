# Database

La ventana **Database** reúne los editores de datos de tu proyecto en una única ventana con pestañas, como RPG Maker XP. Ábrela desde el botón **Database** de la barra de herramientas o **Tools → Database…**. Switches, Variables y Tilesets tienen cada uno su propia pestaña dentro de la ventana.

Pestañas:

- **Tilesets**, **Switches**, **Variables** — los gestores existentes, embebidos directamente en la ventana.
- **Common Events** — scripts de comandos reutilizables (ver abajo).
- **Animations** — animaciones de batalla/mapa (ver abajo).
- **Actores**, **Clases**, **Habilidades**, **Objetos**, **Armas**, **Armaduras**, **Enemigos**, **Tropas**, **Estados** y **Sistema** editan directamente los archivos estándar de RPG Maker XP.

Al cerrar y volver a abrir la ventana vuelves a la pestaña en la que estabas, con la misma entrada seleccionada en cada pestaña (hasta que cierres la app). En la pestaña Tilesets, un tileset que modificaste y aplicaste o guardaste también se reabre en la posición de scroll en la que estaba al aplicarlo o guardarlo; uno que solo miraste empieza arriba del todo.

> Usa **Aplicar** o el atajo configurado para **Guardar** (**Ctrl+S** por defecto) para aplicar cambios en las pestañas estándar de XP, Animaciones, Eventos comunes o el editor de tilesets. Cambiar de pestaña o cerrar la ventana con cambios sin guardar te pide confirmar primero — y en la pestaña Tilesets, cambiar de tileset también. Cada guardado respalda el `.rxdata` original en una carpeta `map-backups` junto a él.

## Editar registros de RPG Maker XP

La pestaña actual sigue visible hasta que la nueva está lista.

El orden predeterminado empieza por **Tilesets**, **Interruptores**, **Variables**, **Animaciones** y **Eventos comunes**.

Arrastra cualquier pestaña a la izquierda o a la derecha para reordenarla. Acércala a cualquiera de los bordes para desplazar la fila mientras la arrastras. Con una pestaña enfocada, pulsa **Alt+Mayús+Izquierda** o **Alt+Mayús+Derecha** para moverla una posición. Maker Studio guarda el orden en tu perfil local y lo usa en todos tus proyectos.

Busca los registros por su nombre o ID en la barra lateral. Los editores de registros de XP comparten la lista con búsqueda de Eventos comunes y Animaciones. Los paneles relacionados se muestran en paralelo si hay espacio y se apilan al estrechar la ventana. Edita los campos del registro y pulsa **Aplicar** para guardar los cambios de esa pestaña. Abre **Acciones** junto al buscador o haz clic derecho en una fila para copiar, cortar, pegar, duplicar, copiar varios registros, limpiar o eliminar. **Limpiar** pide confirmación antes de restaurar los valores predeterminados. Para copiar un bloque, parte del primer registro, elige **Copiar registros…** e indica cuántos quieres copiar. Las ranuras vacías se omiten. El pegado empieza en el ID seleccionado y ocupa las ranuras disponibles. **Añadir** agrega una ranura al final. **Cambiar máximo…** añade ranuras al final o elimina las que superen el nuevo límite. Usa **Deshacer** o **Rehacer** en el pie antes de aplicar tus cambios. Los atajos de registros configurados funcionan con el foco en la lista. Deshacer y Rehacer también funcionan en los campos del formulario. El buscador y el editor de comandos de evento usan sus propios atajos.

En **Sistema** puedes editar el grupo inicial, los elementos, la terminología, los gráficos, la música y los efectos de sonido. Los gráficos conservan su recuadro de vista previa cuando están vacíos o cargando. **Terminología** define los nombres de las estadísticas, la moneda, las ranuras de equipo y los comandos de menú y batalla que muestra el juego. Estos editores trabajan con los registros estándar de RPG Maker XP, incluidos los de proyectos Essentials que contienen esos archivos `.rxdata`.

Elige **Eliminar** o pulsa **Supr** con el foco en la lista. La confirmación se abre mientras Maker Studio comprueba las referencias al registro. Si las hay, elige un sustituto. La eliminación queda en el borrador y se puede deshacer o rehacer. Al eliminar un registro, la lista se renumera al instante y **Añadir** usa el siguiente ID en ese orden. **Cambiar máximo…** queda desactivado si hay eliminaciones pendientes. Guarda los cambios de los mapas y cierra los editores de eventos antes de pulsar **Aplicar**. Al aplicar, Maker Studio guarda juntos el borrador y las eliminaciones, cierra los huecos entre los ID y actualiza las referencias nativas en la base de datos, los mapas, los eventos comunes y los eventos de tropa. Las referencias que ya apuntaban a un ID vacío o inexistente siguen rotas en lugar de pasar a otro registro. Los archivos `.rxdata` modificados se respaldan en `.maker-studio/database-backups`. Revisa manualmente los ID escritos en los scripts Ruby.

En **Actores**, la gráfica muestra cómo cambia el parámetro seleccionado con el nivel. Puedes modificar un nivel concreto o generar una curva de crecimiento para ese parámetro. **Curva de experiencia** muestra la experiencia total y la necesaria para el siguiente nivel entre el nivel inicial y el máximo. Los controles de gráficos muestran una vista previa de los archivos del proyecto. **Clases** y **Enemigos** usan tablas para el aprendizaje de habilidades y las acciones. La tabla de acciones de un enemigo muestra solo las condiciones que se aplican, o **Siempre**; selecciona una acción para editarla junto con sus condiciones, con el turno en forma `A + B × n`. Cuando un efecto permite aplicar y quitar estados, ambas opciones aparecen en la misma tabla.

Usa la barra de herramientas de **Tropas** para alternar entre **Formación** y **Eventos de batalla**. En Formación, selecciona un enemigo en el inspector de miembros para editar sus opciones o haz clic en la vista previa para colocarlo. **Alinear** reparte todos los miembros en una fila y **Nombre automático**, junto al nombre, lo genera a partir de los miembros, por ejemplo `Ghost*2, Basilisk`. Si un evento de batalla apunta a ese miembro o depende de su posición en la lista, revisa el objetivo antes de quitarlo. En Eventos de batalla, selecciona una página numerada. Usa las flechas para desplazar la barra de páginas, **+** para añadir una página o **×** para eliminar la seleccionada. Cada tropa conserva al menos una página. **Prueba de batalla** está disponible en las dos vistas y usa el mismo fondo que Formación.

En **Tropas**, abre **Prueba de batalla** para ver la tropa con el mismo fondo que en Formación. Las cuatro ranuras del grupo aparecen encima de la vista previa. Usa el **+** de la siguiente ranura vacía para añadir un miembro y el botón rojo con papelera para quitar el seleccionado. Elige entre uno y cuatro actores distintos y selecciona una ranura para ajustar el nivel y el equipo de ese actor. Igual que RPG Maker XP, escribe los archivos de batalla `BT_*.rxdata` en la carpeta `Data` del proyecto, con el borrador actual de la tropa y los datos guardados del resto de la base de datos, y ejecuta el juego desde ahí. La prueba requiere que los scripts y el ejecutable del juego admitan el modo de prueba de XP. En Windows se usa el ejecutable del proyecto, en macOS se ejecuta mediante Wine y en Linux se usa `Game_Linux` o Wine, con Proton como alternativa.

En **Animaciones** y **Eventos comunes**, el botón **Acciones** junto al buscador abre el mismo menú que el clic derecho en un registro. Las flechas del pie deshacen y rehacen cambios en la lista, como añadir, cortar o duplicar un registro.

## Eliminar y renumerar tilesets

En la pestaña Tilesets, **Eliminar** y **Cortar** actúan sobre todos los tilesets seleccionados con Ctrl/Shift+clic. Eliminar siempre pide confirmación: lista los mapas que usan los tilesets (esos mapas mostrarán tiles de sustitución después) o indica que ningún mapa los usa. Deshacer los restaura todos. Un mapa cuyo tileset falta se abre igualmente, con tiles de sustitución y un aviso.

La fila **ID:** tiene un botón de edición para cambiar el ID de un tileset, actualizando todos los mapas que lo usan. Se rechaza si el ID ya está en uso, o si la base de datos o algún mapa abierto tiene cambios sin guardar. Los mapas abiertos afectados se recargan y el cambio se puede deshacer.

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
