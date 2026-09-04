# Editor de tilesets

## Abrir el editor de tilesets

Abre el **Tileset Manager** desde la pestaña **Tilesets** de la Database (**Tools → Database…**, o el botón **Database** de la barra de herramientas). El gestor lista cada tileset (con una lista con búsqueda); selecciona uno y haz clic en **Edit Properties...** para abrir el editor de tilesets para él.

El panel de detalle del gestor muestra además una **miniatura del gráfico del tileset
seleccionado**, así de un vistazo sabes qué tileset vas a editar. El botón **…** junto al nombre
del gráfico abre el selector de gráficos normal, así ves la imagen a la que vas a cambiar —con
zoom, desplazamiento y favoritos— en lugar de elegir a ciegas de una lista de nombres.

Una vía más rápida para un tile que ya tienes a la vista: **clic derecho en ese tile en la
Paleta de tiles → Edit Properties…**. El editor se abre desplazado hasta ese tile exacto y
con él ya seleccionado, en vez de al principio de una hoja larga. Pulsa **Esc** para cerrar
el editor (sigue preguntando por los cambios sin guardar).

**Copiar, cortar y pegar un tileset completo**: clic derecho en una fila de la lista de tilesets para
**Copiar tileset** / **Cortar tileset** / **Pegar tileset (reemplazar)** / **Pegar como nuevo
tileset** / **Duplicar tileset** — ver [Copiar, cortar y pegar registros](database.md#copiar-cortar-y-pegar-registros)
en la documentación de Database. Ninguna está disponible en la fila virtual **Autotiles**. Cortar un
tileset pasa por la misma confirmación de borrado que eliminarlo directamente — otros mapas pueden
seguir usándolo. Haz clic en una fila para dar el foco a la lista, luego Ctrl+C/Ctrl+X/Ctrl+V/Ctrl+J
copian/cortan/pegan/duplican y Ctrl+Z/Ctrl+Y deshacen/rehacen el cambio, incluidas las escrituras a
disco.

**Borrar un tileset** (el icono de papelera en el panel de detalle) ahora pregunta con el mismo
diálogo de confirmación que usa el resto del editor, en lugar de su propia ventana emergente — y
borrar es deshacible: **Ctrl+Z** justo después de confirmar escribe el tileset de vuelta en su
antigua ranura.

(El comando aparte **Map → Change Tileset...** es distinto — intercambia qué tileset usa un *mapa* para sus capas nativas; consulta [Gestión de mapas](map-management.md). No edita las propiedades de los tiles.)

## Resumen

El editor de tilesets te permite modificar las propiedades base de cada tile de un tileset. Son los mismos ajustes que encuentras en RPG Maker XP bajo Database y luego Tilesets. Los cambios hechos aquí se aplican a todos los mapas que usan este tileset.

## Modos de edición

### Passage (paso)

Haz clic en un tile para alternar entre totalmente transitable (todas las direcciones abiertas) y totalmente bloqueado (mostrado como una x roja). Haz clic derecho para restablecer un tile a su ajuste de paso por defecto.

### Passage (4 direcciones)

Haz clic en uno de los cuatro cuadrantes dentro de un tile para bloquear o desbloquear esa dirección concreta (Arriba, Abajo, Izquierda, Derecha). Cada dirección se puede alternar de forma independiente, dándote control fino sobre exactamente cómo puede moverse el jugador a través de un tile.

### Priority (prioridad)

Haz clic para recorrer los niveles de prioridad 0 a 5:

- **0** = Suelo. El jugador camina por delante del tile.
- **1–5** = Por encima. El jugador camina por detrás del tile (p. ej. copas de árboles), en el juego y en el Simulador.

**Cada nivel tiene su propio color.** La prioridad 1 es amarilla, la 2 naranja, la 3 rosa, la 4 morada y la 5 azul; la estrella y el número dibujados sobre cada tile usan ese color, y el desplegable de prioridad muestra un cuadrito del color junto a cada valor. La prioridad 0 se queda en blanco neutro. Así distingues de un vistazo una franja de nivel 1 de un tejado de nivel 3 en vez de tener que leer números. (Los niveles añadidos por [mods](marketplace.md) reutilizan esos cinco colores en orden, salvo que el mod le dé a su nivel un color propio. Un mod también puede recolorear todas las marcas — las de passage, bush, counter y terrain-tag además de las de prioridad.)

La prioridad controla la **oclusión del jugador en el juego**, no el orden de dibujo del editor — en el lienzo del editor los tiles siempre se dibujan en orden de capa (ver [Capas](layers.md)). En el juego y en el Simulador la oclusión se decide **por tile** según su propia prioridad, salvo que un tile de suelo en una capa superior tapa a los que hay debajo en esa casilla. Ver [Capas](layers.md#priority-and-layer-order).

### Bush Flag

Activa o desactiva la bandera de matorral (bush). Cuando está activada, los tiles bajo un overlay de matorral aparecen parcialmente ocultos, simulando hierba alta o follaje.

### Counter Flag

Activa la bandera de mostrador (counter). Permite la interacción a través del tile — útil para cosas como mostradores de tienda donde el jugador habla con un evento al otro lado.

### Terrain Tag

Elige un terrain tag del desplegable con búsqueda, luego haz clic en un tile (o selecciona una región arrastrando y pulsa **Apply**) para asignarlo. La lista incluye tags con nombre 0–17 (los valores por defecto de Pokémon Essentials), y puedes filtrar por nombre o número. Los mods instalados pueden añadir sus propios tags con nombre a este mismo desplegable. Los terrain tags los usan eventos y scripts para comportamientos específicos del terreno, como cambiar la velocidad de movimiento en arena frente a carretera, y se leen en el juego a través del terrain tag del motor.

**Sonido de la hierba (grass rustle).** Cuando el jugador pisa un tile cuyo terrain tag hace crujir la hierba (como **Grass**), es el motor —no Maker Studio— quien reproduce la **animación 1** ("Grass rustle") de la base de datos de Animaciones de tu proyecto. En un proyecto de Pokémon Essentials sin modificar esa animación no tiene ningún timing de SE, así que el crujido se reproduce sin sonido; algunos kits (La Base de Sky, por ejemplo) sí traen un sonido en ella. Para añadirlo, dale a la animación 1 un timing de SE en la pestaña **Animations** de la [Base de datos](database.md). El terrain tag funciona correctamente — el sonido vive en la animación.

## Terrain tags y priorities personalizados

Los desplegables de Terrain Tag y Priority no se limitan a los valores integrados. El editor hace tres cosas extra por ti:

- **Nombres leídos de tu juego.** El desplegable de Terrain Tag lee los nombres que tu base define de verdad —`PBS/terrain_tags.txt`, los registros de `GameData::TerrainTag`, las constantes de `module PBTerrain` y cualquier helper de registro personalizado que use tu proyecto (p. ej. `ChronoverseManager.register_terrain_tag`)— escaneando los scripts del núcleo, el árbol suelto de `Data/Scripts/` y `Plugins/`. Un terrain tag que define tu base o un plugin (Grass, Ledge, Water, un tag personalizado Mirror…) muestra su nombre real en vez de un número suelto. Si no encuentra ninguna de esas fuentes, la lista vuelve a los defaults 0–17 de Pokemon Essentials. Priority no tiene un registro equivalente en el juego (las priorities de RMXP son los niveles z posicionales 0–5), así que siempre parte de los nombres estándar 0–5.
- **Valores detectados automáticamente.** Si tu juego ya usa un terrain tag o un nivel de priority más allá de la lista integrada —por ejemplo un valor que un script o una herramienta anterior escribió en un tile— el editor escanea cada tileset y autotile, encuentra el valor más alto en uso y sube el máximo del desplegable para que cada valor que el juego usa de verdad sea seleccionable.
- **Tus propias etiquetas, y puedes renombrarlo todo.** En la barra lateral, en modo Terrain Tag o Priority, haz clic en **Añadir nuevo…** al final de la lista para abrir un formulario en línea —elige un id, escribe un nombre y (tanto para terrain tags como para priorities) elige un color de marca que tinta el marcador del canvas y la tarjeta del desplegable. Todas las filas son editables: el icono de lápiz de cualquier fila la renombra, incluidos los defaults y los nombres que haya añadido un [mod](marketplace.md) —y tu etiqueta gana. El icono de papelera aparece solo en filas que has sobreescrito o añadido; sobre un default revierte al nombre original, sobre un tag que añadiste lo elimina. (El selector del menú contextual del clic derecho se queda como selector simple.) Los controles son iconos, no caracteres de texto. Las etiquetas personalizadas se guardan por proyecto en `.maker-studio/tile-labels.json` dentro de la carpeta de tu juego, así viajan con él.

Así puedes traducir un nombre por defecto (por ejemplo renombrar "Grass" a "Hierba"), darle color a un terrain tag igual que ya lo tienen las priorities, y ponerle nombre a cualquier id detectado automáticamente.

## Editar propiedades de autotiles

El paso/prioridad/terreno de los autotiles se edita por separado de los tilesets normales. En el Tileset Manager, elige la entrada **Autotiles** (mostrada como `000: Autotiles` en lo alto de la lista) y haz clic en **Edit Properties...**. Esto abre una cuadrícula dedicada de cada autotile (ranuras nativas + autotiles extra con nombre). Editar una propiedad para un autotile la aplica a los 48 tiles de patrón de ese autotile a la vez.

Las propiedades de autotile son **por gráfico**: la cuadrícula muestra los valores actuales de cada autotile leídos del tileset que lo contiene de forma nativa, y al guardar esos valores se aplican a todos los tilesets que usan ese gráfico (emparejado por su nombre de archivo). Los tilesets que no contienen el gráfico no se tocan, así que el resto de ajustes de autotiles de cada tileset se conservan.

Dos comodidades en esta vista: al pasar el cursor por un autotile se muestra su **nombre de
archivo** (en el panel Tile Info y como tooltip) —la cuadrícula está ordenada por nombre, no por
slot, así que el nombre es lo que lo identifica— y **Abrir carpeta de autotiles** en la barra
lateral abre `Graphics/Autotiles` en tu explorador de archivos, para meter o editar gráficos. Los
archivos que añadas o cambies ahí se detectan automáticamente; no hace falta reabrir el editor.

## Guardar

El editor tiene dos botones:

- **Aplicar** — escribe tus cambios en `Tilesets.rxdata` y **deja el editor abierto**, así puedes seguir ajustando propiedades. Está gris cuando no hay nada que guardar. **Ctrl+S** (o **Cmd+S** en macOS) hace lo mismo.
- **Guardar** — escribe tus cambios y **cierra** la ventana de la Database, igual que el OK del Editor de eventos.

Se crea una copia de seguridad del archivo original automáticamente en el primer guardado. Si cierras con cambios sin guardar, se te preguntará si guardar, descartar o cancelar.

### Cambiar a otro tileset con cambios sin guardar

Elegir otro tileset — desde la lista, desde **Edit Properties…** del clic derecho en la Paleta de tiles, o desde el selector de tilesets — pasa a editar ese tileset. Si el que dejas tiene cambios sin guardar, ahora el editor pregunta primero: **Descartar** tira los cambios y cambia, **Seguir editando** te deja donde estabas. Usa **Aplicar** antes de cambiar si quieres conservarlos.

Tras guardar, los overlays de colisión y prioridad se actualizan al instante en todos los mapas abiertos que usan el tileset — incluidos los tiles que colocaste antes. Esto se aplica a cada tile colocado: tiles normales, tiles pintados desde otro tileset, autotiles extra (con nombre) y tiles que rotaste o volteaste. Los tiles rotados y volteados reaplican automáticamente el nuevo paso en la orientación correcta, en el editor y en el juego.

## Cómo lee el overlay de colisión una pila de tiles

**Show Collision** (menú View, o el botón **Col** de la barra) ahora responde cada tile igual que el juego.
Recorre la celda desde la capa superior hacia abajo y se detiene en el primer tile que o bloquea del todo
o es un tile de **suelo** (priority 0) — ese tile decide. Un tile que es transitable pero tiene priority
**1 o más** (una franja, la copa de un árbol, el borde de un tejado) es *transparente* para la colisión,
así que el overlay sigue leyendo hacia abajo y muestra la colisión del tile de debajo. Pon encima un tile
transitable de **priority 0** y la celda se lee como abierta, porque es lo que pasa en el juego.

Los marcadores de bush, counter y terrain-tag no se cortan en ese tile de suelo: se muestran si **algún**
tile de la pila los lleva, igual que los responde el juego.
