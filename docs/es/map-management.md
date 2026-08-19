# Gestión de mapas

## Crear un mapa nuevo

Elige Mapa y luego Nuevo mapa en el menú, o haz clic en el botón **+** de la **cabecera del panel Mapas** (junto a la lista de mapas, reflejando el **+** de añadir capa del panel Capas). Rellena los datos:

- **ID**: se rellena con el **ID libre más bajo empezando por 1**, así se reaprovechan los IDs que dejaron libres los mapas borrados en vez de que la numeración suba sin parar. Puedes escribir otro: cualquier ID entre 1 y 999 que no use ningún mapa existente. Si está ocupado, el campo lo indica y Crear queda deshabilitado.
- **Nombre**: el nombre visible del mapa.
- **Ancho / Alto**: dimensiones en tiles.
- **Tileset**: qué tileset usa el mapa para sus capas nativas.
- **Padre**: dónde se sitúa el mapa en el árbol de jerarquía. La lista está ordenada y sangrada igual que el árbol de mapas, y puedes filtrarla por **nombre o ID**: escribe `cueva` o `042`. Elige **(raíz)** para un mapa de primer nivel.

Haz clic en Crear para añadir el mapa a tu proyecto.

### Crear un mapa dentro de otro

Para anidar el mapa nuevo bajo uno existente, **haz clic derecho en ese mapa** en el árbol de mapas y elige **Nuevo mapa aquí…**. El diálogo de nuevo mapa se abre con ese mapa ya puesto como **Padre**, y el mapa nuevo se crea como hijo suyo. (Puedes cambiar el padre antes de pulsar Crear.)

## Cambiar el ID de un mapa

Haz clic derecho en el mapa dentro del árbol de mapas y elige **Cambiar ID…**, luego escribe un ID libre entre 1 y 999. Maker Studio renombra `Map###.rxdata`, mueve la entrada del mapa en `MapInfos.rxdata` (sus mapas hijos siguen colgando de él), reescribe **todos los comandos Transferir jugador del proyecto** que apuntaban al ID antiguo, sigue la **posición inicial del jugador** si estaba en ese mapa, y renombra las imágenes de sombra horneadas del mapa. El aviso te dice cuántos comandos Transferir jugador se actualizaron.

Los IDs de mapa escritos dentro de **scripts de Ruby** no se tocan: no hay forma fiable de encontrarlos, así que revísalos a mano. Los mapas sin guardar se guardan primero, porque la reescritura ocurre en disco.

## Abrir mapas

Haz doble clic en cualquier mapa del árbol de mapas para abrirlo en una pestaña nueva del editor.

Al volver a abrir un proyecto, Maker Studio recupera **exactamente el mismo conjunto de pestañas de mapas que tenías abiertas**, en el mismo orden de izquierda a derecha, y hace activo el mapa que estabas editando — así la sesión continúa donde la dejaste en vez de empezar por el primer mapa de la lista. (Abrir un archivo de mapa directamente —con doble clic desde el explorador de archivos— sigue teniendo prioridad y abre solo ese mapa.) También puedes **arrastrar las pestañas de los mapas para reordenarlas**; el nuevo orden es el que se restaura la próxima vez. Las carpetas plegadas del árbol de mapas también vuelven tal y como las dejaste. Todo esto se recuerda por proyecto y solo en este ordenador: no se escribe nada dentro del proyecto.

## Duplicar un mapa

Para hacer una copia completa de un mapa como un **mapa totalmente nuevo** (un `map_id` separado, no una versión):

- Haz clic derecho en un mapa del árbol y elige **Duplicate Map**, o
- Abre el mapa y elige **Map → Duplicate Map** en el menú.

La copia se llama *"<original> (copy)"*, se coloca bajo el mismo padre y se abre automáticamente. Es un clon fiel — tiles, eventos, capas, sombras/fog **y cualquier versión de mapa** vienen con ella. Si el mapa de origen tiene ediciones sin guardar, se guardan primero para que la copia esté al día. Esto es distinto de una **versión de mapa** (el mismo mapa, intercambiado en el juego); usa Duplicate Map cuando quieras un mapa independiente que puedas cambiar sin afectar al original.

## Copiar un mapa entre proyectos

Puedes copiar un mapa entero de un proyecto a otro con **Ctrl+C / Ctrl+V** en la lista de mapas, igual que RPG Maker XP:

1. Activa **Edit → Cross-Project Clipboard** (está desactivado por defecto). Con él desactivado, copiar/pegar sigue funcionando **dentro de la misma ventana**, pero la copia no se refleja en el portapapeles del SO, así que una segunda ventana no puede verla.
2. Abre dos ventanas de Maker Studio en los dos proyectos (File → Open Project… en una segunda ventana).
3. En la lista de mapas del proyecto de origen, haz clic en el mapa que quieres copiar y pulsa **Ctrl+C**. El mapa entero — tiles de cada capa, eventos, capas de sombras/fog/panorama y cualquier versión de mapa — se serializa al portapapeles del SO.
4. En la lista de mapas del proyecto de destino, haz clic en un mapa que quedará por encima del mapa nuevo (esto da foco al panel y elige dónde caerá) y pulsa **Ctrl+V**. El mapa se importa como un **mapa nuevo colocado justo debajo del mapa seleccionado** (en la raíz del árbol si no hay ningún mapa seleccionado) y se abre automáticamente.

Consejos:

- Copiar entre ventanas necesita **Cross-Project Clipboard** activado. Dentro de una sola ventana el conmutador no importa — usa **Duplicate Map** para un clon en el mismo proyecto.
- La copia pasa por el portapapeles del SO (cuando el conmutador está activado), así que sobrevive a cerrar la ventana de origen. Sin embargo, es grande — pega pronto para no dejar un payload grande en el portapapeles.
- El mapa pegado cae justo debajo del mapa seleccionado; arrástralo a otro sitio después si quieres anidarlo bajo un padre distinto (o usa **Nuevo mapa aquí…** para un mapa nuevo anidado).
- El tileset del mapa se referencia por los gráficos de tile que usa; si al proyecto de destino le faltan esos tilesets/autotiles, los tiles se pegan con sus ids originales pero se renderizarán mal hasta que añadas los gráficos ausentes. Los tiles de capas extendidas conservan su referencia original al tileset.

## Redimensionar y desplazar mapas

Abre el diálogo de redimensión desde Map y luego Resize / Shift Map, o haz clic derecho en un mapa del árbol y elige Resize/Shift.

### Redimensionar

Introduce el nuevo ancho y alto. Un **panel de anclaje de 9 posiciones** decide dónde cae el contenido existente en el nuevo lienzo — elige el centro para mantener el mapa centrado al crecer o encoger, o una esquina/borde para anclar ahí. El diálogo calcula automáticamente el desplazamiento a partir de tu elección de anclaje.

### Wrap

Un conmutador **Wrap** (activado por defecto) controla qué ocurre con el contenido que cae fuera de los nuevos límites:

- **Wrap activado**: los tiles, eventos y sombras que salen de un borde reaparecen en el lado opuesto (wrap toroidal).
- **Wrap desactivado**: todo lo que queda fuera de los nuevos límites se descarta.

También puedes desplazar el contenido manualmente sobrescribiendo los valores de desplazamiento calculados.

### Vista previa y deshacer

Una vista previa SVG muestra dónde quedará tu contenido dentro del nuevo lienzo antes de confirmar. La redimensión es un solo paso de deshacer — pulsa Ctrl+Z después para restaurar el tamaño y el contenido originales.

## Cambiar el tileset de un mapa

Haz clic derecho en un mapa del árbol y elige Change Tileset, o usa Map y luego Change Tileset en el menú. Elige de la lista con búsqueda y haz clic en Apply — el mapa se repinta con los gráficos del nuevo tileset al momento, sin recargar. Cambiar el tileset solo afecta a las capas nativas, y no remapea los IDs de tile (los tiles existentes conservan sus números, así que pueden verse distintos bajo el nuevo tileset). Las capas extendidas pueden seguir usando tiles de cualquier tileset.

## Capas de panorama y battleback

En RPG Maker XP el **panorama** (la imagen de fondo desplazable detrás de un mapa) y el **battleback** (el fondo de batalla) pertenecen al *tileset*, así que cada mapa que comparte un tileset comparte uno de cada. Maker Studio reemplaza el panorama único por **capas de panorama** editadas desde el panel de capas, y aún te deja cambiar el battleback directamente desde el mapa que estás editando.

### Panoramas — el grupo "Panorama Layers"

Los panoramas se editan en el **panel de capas**, en el grupo **Panorama Layers** — exactamente como las capas de fog. (Los antiguos elementos de menú **Change Panorama…** han desaparecido; ya no hay un diálogo de panorama aparte.)

- Haz clic en el **+** del grupo para añadir una capa de panorama; usa la sub-fila de una capa para editarla o borrarla. El icono de ojo del grupo muestra/oculta todas las capas de panorama a la vez.
- El popup de edición elige la imagen de `Graphics/Panoramas/` con el mismo selector de imágenes usado en todas partes (vista previa en vivo, favoritos, Browse), y ofrece por capa **hue**, **opacidad**, **modo de mezcla**, **zoom**, velocidades de **scroll**, **Follow camera** y un deslizador **Parallax** (0–1): `1` se mueve 1:1 con el mapa, `0.5` iguala el clásico desplazamiento de panorama a media velocidad de RPG Maker XP, y `0` queda fijo en pantalla. El deslizador se oculta mientras **Follow camera** está marcado (eso ya significa totalmente fijado a pantalla). Las nuevas capas de panorama usan por defecto opacidad completa y parallax `0.5`.
- Puedes apilar **varias capas de panorama** en un mapa. Se dibujan en el lienzo del editor debajo de tus tiles, así que ves exactamente cómo quedan mientras mapeas, y en el juego los panoramas de cada mapa se recortan a ese mapa (no se mezclan con los mapas conectados).
- Cada [versión de mapa](map-versions.md) conserva sus propias capas de panorama — una versión "destruida" puede tener un cielo distinto al normal. Pulsa **Ctrl+S** para guardarlas con el mapa.

Si un mapa ya tiene un panorama de su tileset (o una sustitución por versión guardada con una build antigua), el editor lo muestra automáticamente como una sola capa de panorama. Mientras dejes esa capa intacta, nada cambia en disco — el mapa sigue usando el panorama de tileset estándar, con o sin plugin. En cuanto editas las capas de panorama (cambias, añades o borras una), pasan a formar parte del mapa: el plugin MakerStudio las renderiza en el juego y discretamente impide que el propio panorama del tileset se dibuje dos veces (el tileset en sí nunca se modifica). Como las capas de fog, las capas de panorama editadas necesitan el plugin para verse en el juego, así que el grupo lleva la insignia MS.

> Los mods también pueden registrar sus propios **grupos de capa personalizados** — grupos extra de capa de imagen como Panorama Layers o Fog Layers, dibujados debajo o encima de los tiles a una prioridad que el mod elige. Aparecen como grupos adicionales en el panel de capas y se guardan con el mapa, así que siguen funcionando en el juego incluso sin el mod instalado.

### Battleback

Hay tres formas de cambiar el battleback, todas abriendo el mismo selector de imágenes:

- **Barra de menús → Map → Change Battleback…** (junto a Change Tileset…).
- **Clic derecho en un mapa** del árbol → **Change Battleback…**.
- Cuando editas una [versión de mapa](map-versions.md), el submenú de clic derecho de la versión tiene **Change Battleback (this version)…**.

Elige un battleback de `Graphics/Battlebacks/`. Los battlebacks vienen en familias de archivos que comparten un nombre: `<nombre>_bg`, `<nombre>_base0`, `<nombre>_base1`, `<nombre>_message` en Pokémon Essentials 19.1 y posteriores (y LBDS), o `battlebg<Nombre>`, `playerbase<Nombre>`, `enemybase<Nombre>` en Essentials 17.1 y BES. En ambos casos el selector lista **una entrada por familia** y guarda ese nombre compartido, no un archivo individual. Déjalo en blanco para quitarlo.

Solo eliges el fondo: **las bases sobre las que están los combatientes vienen con él.** Elige `cave1` y los combates en ese mapa usan `cave1_base0` / `cave1_base1`, afinadas al entorno en el que estés siempre que exista esa variante — `cave1_water_base0` sobre agua, `cave1_ice_base0` sobre hielo. Si tu battleback no trae bases propias, se usan las habituales del entorno, así que nunca te quedas sin ninguna.

> **Necesita el plugin.** Por su cuenta, Pokémon Essentials 19.1 y posteriores nombran las bases según el *entorno*, no según tu battleback — un battleback de cueva en un mapa con hierba muestra bases de hierba. El plugin de MakerStudio es el que pone tu battleback por delante. Essentials 17.1 y BES ya funcionaban así.

Lo que hace el cambio depende de qué estés editando:

- **En el mapa base, estás editando el tileset** — exactamente como RPG Maker XP. El nuevo battleback se escribe en el tileset al momento y se aplica a **todos los mapas que usan ese tileset** (otros mapas abiertos se actualizan al instante). En un juego RPG Maker XP estándar eso es todo lo que hace falta; los juegos Pokémon Essentials / LBDS ignoran el campo del tileset y leen el fondo desde los metadatos del mapa, así que el plugin de MakerStudio puentea el valor a ese campo en el juego — en todas las bases soportadas (Essentials 17.1, 19.1, 20.1, 21.1, LBDS y BES), cada una de las cuales guarda esos metadatos en un sitio distinto. El elemento del mapa base no lleva insignia MS porque la propia escritura del editor es RPG Maker XP plano.
- **En una versión de mapa, estableces una sustitución por versión**, guardada en el archivo del mapa (pulsa **Ctrl+S** para conservarla) y aplicada en el juego por el plugin MakerStudio — así que esos elementos llevan la insignia MS.

El **battleback no se muestra en el lienzo del mapa** — solo aparece en las batallas en el juego — pero se guarda y se puede editar aquí.

> Los mapas guardados con una build antigua de Maker Studio pueden aún contener una sustitución base por mapa; el editor ahora la ignora (el mapa base siempre muestra los ajustes del tileset) y la quita la próxima vez que guardes ese mapa. El mismo plugin en el juego también impide que el propio fog del tileset se dibuje dos veces cuando un mapa usa capas de fog de Maker Studio.

## Audio del mapa (Auto-Change BGM / BGS)

Cada mapa puede llevar su propia música y sonido de fondo, que suenan automáticamente al entrar el jugador — los mismos campos **Auto-Change BGM / BGS** que RPG Maker XP pone en Map Properties. Abre el diálogo desde:

- **Barra de menú → Map → Map Audio…**, o
- **Clic derecho en un mapa** del árbol → **Map Audio…**

El diálogo tiene una fila por pista:

- Marca **Auto-Change BGM** (o **Auto-Change BGS**) para activar esa pista en este mapa. Mientras la casilla está desmarcada el selector aparece atenuado y el mapa sigue reproduciendo lo que ya sonaba.
- Haz clic en el botón **…** para elegir el archivo de la carpeta `Audio/BGM/` (o `Audio/BGS/`) de tu proyecto, con los habituales deslizadores de volumen y tono y un botón de reproducción para escucharlo.

Haz clic en **OK** para escribir el cambio **directamente en el archivo del mapa** — no hay un paso de guardado aparte ni marca de cambios sin guardar, así que **no hace falta Ctrl+S** (funciona igual que cambiar el battleback de un mapa base). **Cancel** lo descarta.

Estos son **campos nativos de RPG Maker XP**, así que la música suena en cualquier juego sin plugin instalado — por eso los elementos de menú no llevan insignia MS.

> **Un ajuste por mapa, compartido por todas las versiones.** El audio del mapa se guarda en el archivo del mapa base, así que todas las [versiones](map-versions.md) de un mapa reproducen el mismo BGM/BGS — no hay sustitución por versión (la misma limitación que Change Tileset). Para cambiar la música en una situación concreta, usa los comandos de evento **Play BGM** / **Play BGS**.

## Borrar un mapa

Haz clic derecho en un mapa del árbol y elige Delete Map, luego confirma el borrado. Cualquier mapa hijo se mueve al padre del mapa borrado para que no se pierdan. El archivo `.rxdata` del mapa se quita del disco.

También puedes **borrar el mapa seleccionado desde el teclado**: con el panel Mapas con el foco, pulsa **Delete**. Aparece el mismo aviso de confirmación (los mapas hijo se mueven al padre y el archivo `.rxdata` se quita del disco).

## Exportar mapas

El editor admite cuatro formatos de exportación. Todas las exportaciones procesan su trabajo en segundo plano — la barra de estado inferior muestra una barra de progreso mientras los frames se renderizan y codifican, y aparece un toast cuando la exportación termina con un botón **Open folder** que revela el archivo de salida en el explorador de archivos de tu SO.

### Exportar como JSON

Map y luego Export Map y luego Export as JSON guarda un volcado completo del mapa incluyendo capas extendidas y datos de sombra. Es útil para copias de seguridad, compartir o reimportar.

### Exportar como PNG

Map y luego Export Map y luego Export as PNG renderiza todo el mapa a una imagen PNG a resolución completa.

### Exportar como GIF (animado)

Map y luego Export Map y luego Export as GIF crea un GIF animado mostrando las animaciones de autotile y sombra en movimiento. El GIF se limita a una paleta de 256 colores, así que los mapas muy sombreados pueden verse posterizados — prefiere WebP para esos.

### Exportar como WebP (animado)

Map y luego Export Map y luego Export as WebP crea un WebP animado. WebP admite el espacio de color completo de 24 bits, así que conserva los degradados de sombra y los colores de fog que el GIF no puede. Antes de guardar, el editor pregunta si la animación debe repetirse para siempre o reproducirse una vez y parar — elige "Play once" si piensas incrustar el archivo en algún sitio que no deba repetir. La salida es sin pérdida por defecto.

## Importar mapas

Map y luego Import Map from JSON carga un archivo JSON exportado previamente como un mapa nuevo en tu proyecto.

## Establecer la posición de inicio del jugador

La posición de inicio del jugador es donde aparece el jugador cuando empieza una partida nueva. Para establecerla:

1. Haz clic derecho en cualquier tile del mapa en el que quieras que empiece el juego.
2. Elige **Set as Player Start** en el menú.

Un marcador verde **Start** aparece en ese tile, y la posición se guarda en tu proyecto al instante (sin necesidad de guardar el mapa). Solo hay una posición de inicio por proyecto — establecer una nueva la mueve. El marcador solo se dibuja en el mapa al que pertenece. Para moverla, haz clic derecho en otro tile (en cualquier mapa) y elige Set as Player Start de nuevo.

## Ejecutar el juego

Haz clic en el botón verde Run de la barra de herramientas (o usa File y luego Run Game). El editor lanza `Game.exe` en modo depuración desde la carpeta de tu proyecto.

Si algún mapa abierto tiene cambios sin guardar, primero te pregunta — el editor ya no los guarda por su cuenta:

- **Guardar y ejecutar** — guarda todos los mapas con cambios sin guardar y luego lanza el juego.
- **Ejecutar sin guardar** — lanza el juego tal y como están los archivos en disco, dejando tus cambios sin guardar abiertos en el editor. Útil cuando quieres comprobar cómo se comporta el mapa *antes* de tus últimos cambios.
- **Cancelar** — no se guarda nada y el juego no se lanza.

Si no hay nada sin guardar no aparece ningún aviso: Run lanza el juego directamente.

### Si el juego ya está abierto

Si pulsas Run mientras sigue abierto un juego que lanzó el editor, te pregunta qué quieres hacer, con tres opciones:

- **Cancelar** — deja las cosas como están.
- **Cerrar y volver a abrir** — cierra el juego en marcha y arranca uno nuevo. Útil cuando has cambiado algo que un juego ya iniciado no va a recoger (solo cierra el juego que lanzó *el editor*, nunca uno que hayas abierto tú).
- **Abrir igualmente** — arranca una segunda copia junto a la primera.

La pregunta aparece siempre. Las dos respuestas hacen algo que no se puede deshacer — una cierra el juego que estás jugando y la otra deja dos copias escribiendo sobre los mismos archivos de guardado —, así que no hay ningún «no volver a avisar».

### Elegir en qué pantalla se abre el juego

En **Windows**, la pestaña **Juego** de **Help → Settings…** tiene la opción **En qué pantalla se abre el juego**. Por defecto, **La misma que el editor** abre el juego en la pantalla en la que estés trabajando; sin esto RPG Maker centra siempre el juego en la pantalla principal. También puedes fijarlo a una pantalla concreta con **Siempre en esta pantalla**. Se aplica en el siguiente Run, y la ventana puede dar uno o dos saltos mientras el juego arranca antes de asentarse. En macOS y Linux la opción está, pero deshabilitada — la ventana del juego la controla Wine/Proton. Ver [Ajustes](interface-guide.md#ajustes-ayuda--ajustes).

### Ejecutar en macOS (Wine)

`Game.exe` es un ejecutable de Windows, así que en macOS el editor lo lanza a través de **Wine**. Necesitas una instalación de Wine que funcione: Wine normal en Macs con Intel, o **Game Porting Toolkit / Whisky** en Apple Silicon (ambos exponen el comando `wine`/`wine64` que el editor busca). El editor crea su propio prefijo de Wine dedicado la primera vez que pulsas Run, separado del `~/.wine` por defecto, y suprime los avisos habituales de instalación de Mono/Gecko del primer arranque. Si Wine no está instalado, Run se detiene con un error pidiéndote que lo instales y reintentes.

### Ejecutar en Linux (Proton / Wine / Nativo)

`Game.exe` es un ejecutable de Windows, así que en Linux el editor normalmente lo ejecuta a través de **Proton** o **Wine**. Si tu proyecto también tiene una build nativa de Linux (una carpeta `Game_Linux` junto a `Game.exe`, de una build nativa de mkxp-z), el editor la detecta y también la ofrece como opción. La primera vez que pulsas Run, un diálogo te deja elegir cómo lanzar:

- **Proton**: elige una versión de Proton instalada (y, si hace falta, el id de app de Steam a usar). El editor configura un prefijo de Wine dedicado para tu juego la primera vez.
- **Wine**: lanza a través del Wine de tu sistema en su lugar.
- **Build nativa de Linux** (cuando está disponible): ejecuta `Game_Linux` directamente, sin Proton ni Wine de por medio. Si ya se está ejecutando, el editor simplemente enfoca su ventana en vez de abrir una segunda copia; si no, abre tu emulador de terminal y lo lanza ahí en modo depuración.

Tu elección se recuerda por proyecto, así que las ejecuciones posteriores lanzan directo sin volver a preguntar. Para que el diálogo vuelva a aparecer más adelante — por ejemplo, para cambiar entre Proton y la build nativa — usa **File → Clear Proton Preference**. Esa entrada solo aparece cuando hay realmente una elección de Proton/Wine que olvidar: en Linux, con un proyecto abierto y solo si lo lanzaste con Proton o Wine (un proyecto que ejecutas con la build nativa de Linux no tiene nada que limpiar).

### Recarga en caliente con el juego abierto

Con el plugin de Maker Studio instalado no hace falta reiniciar el juego para ver un cambio. Al
guardar cualquier cosa — tiles, capas, eventos, tilesets, la base de datos, el árbol de mapas — el
editor deja una marca en la carpeta del plugin, y el juego en marcha la detecta en menos de un
segundo y vuelve a aplicar el mapa en el que estés. Tiles, eventos, colisiones y las capas extendidas
se recargan.

**Los gráficos también cuentan.** Repinta un tileset, un autotile o una hoja de personaje en Photoshop
(o donde dibujes) y guárdalo sobre el archivo: la paleta y el editor de mapas se actualizan solos, y el
juego en marcha recarga esos bitmaps en su siguiente comprobación — sin reiniciar ni volver a entrar al
mapa.

Solo puede ocurrir con el editor abierto en ese proyecto (es el editor quien escribe la marca), y
puedes desactivarlo por proyecto con `LIVE_RELOAD = false` en
`Plugins/MakerStudio/000_Settings.rb` — o, sin salir del juego, desde el menú de depuración en
**Maker Studio… → Live Reload (on save)**, que lo cambia para esa sesión.

### Abrir la carpeta de guardados

**File → Abrir carpeta de partidas guardadas** abre la carpeta donde el juego escribe sus archivos de guardado. Tras tu primer Run, el botón **Saves** de la barra hace lo mismo. En ambos casos, la carpeta depende de cómo se lanzó el juego:

- **Windows**: abre la carpeta de guardado nativa, `%AppData%\<Game>`.
- **macOS**: abre la carpeta de guardado dentro del prefijo Wine en el que se ejecutó el juego — macOS ejecuta `Game.exe` a través de Wine, así que el juego escribe en el `AppData\Roaming` de Wine, no en `~/Library/Application Support`.
- **Linux, Proton/Wine**: abre la carpeta correspondiente dentro del prefijo Proton/Wine en el que se ejecutó el juego.
- **Linux, build nativa**: abre `~/.local/share/<GameTitle>/`, donde las builds nativas de Linux guardan sus datos de guardado.

Esto facilita respaldar o limpiar archivos de guardado mientras pruebas.

## Autoguardado y recuperación tras fallos

Sigues guardando con **Ctrl+S** como siempre, pero el editor protege discretamente el trabajo sin guardar en segundo plano:

- Cada **5 minutos**, cualquier mapa abierto con cambios sin guardar se captura en una carpeta de autoguardado privada en tu perfil de usuario. Tus archivos de mapa reales **nunca** son tocados por un autoguardado — no hay nada que limpiar y nada cambia en tu proyecto.
- Guardar un mapa normalmente descarta su captura (ya no se necesita).
- Si el editor (o tu PC) se cae con cambios sin guardar, la próxima vez que abras ese proyecto una notificación lista los mapas con trabajo autoguardado y ofrece dos opciones. La notificación permanece hasta que elijas una:
  - **Restore** — escribe los cambios autoguardados en los archivos de mapa y recarga cualquiera de esos mapas que tengas abiertos. El estado previo a la restauración se conserva en el historial habitual `Data/map-backups/`, así que aún puedes volver atrás si no querías la restauración.
  - **Discard** — descarta el trabajo autoguardado y quita la captura, así la notificación no volverá por él.
- Cerrar la notificación con la **✕** sin elegir deja la captura en su sitio, así se te ofrecerá la recuperación de nuevo la próxima sesión. Usa **Discard** para detener el aviso definitivamente.
- Descartar los cambios sin guardar de un mapa (al cerrar una pestaña, cambiar de proyecto o salir) también descarta la captura de ese mapa, así que el trabajo descartado nunca se ofrece para recuperación más tarde.

Los guardados en sí también son a prueba de fallos: el editor escribe en un archivo temporal y lo intercambia solo una vez que está totalmente en disco, así que un fallo o corte de luz a mitad de guardado nunca puede dejar un archivo de mapa a medio escribir. Además, cada guardado primero copia el archivo anterior en `Data/map-backups/` (se conservan las 10 copias más recientes por archivo).

## Abrir el mismo proyecto en dos ventanas

Ejecutar dos ventanas de Maker Studio en proyectos **distintos** está totalmente soportado (así funciona el [Cross-Project Clipboard](interface-guide.md)). Abrir el **mismo** proyecto en dos ventanas es arriesgado, sin embargo: ambas ventanas escriben los mismos archivos de mapa, y la última en guardar gana en silencio. El editor lo detecta y muestra una advertencia cuando una segunda ventana abre un proyecto que ya está abierto en otro sitio. Puedes seguir editando, pero es mejor cerrar una de las ventanas.

## Confirmación de cierre

Cuando cierras una pestaña que tiene cambios sin guardar, el editor te pide confirmar:

- **Save**: guarda el mapa, luego cierra la pestaña.
- **Discard**: cierra la pestaña sin guardar.
- **Cancel**: vuelve al editor sin cerrar.

## Cambiar de proyecto con cambios sin guardar

Si eliges **File → Open Project…** o eliges un proyecto de **File → Open Recent** mientras algún mapa abierto tiene cambios sin guardar, el editor abre un diálogo Save All / Discard / Cancel antes de cambiar de proyecto:

- **Save All**: guarda cada mapa sucio, luego cambia al nuevo proyecto.
- **Discard**: cambia sin guardar — las ediciones sin guardar se pierden.
- **Cancel**: se queda en el proyecto actual.

Es el mismo aviso usado por Help → Reset App y View → Layout → Refresh Layout, así que el trabajo sin guardar no se puede perder en silencio al abrir un proyecto distinto.

## Diálogo "Not a Project Folder"

Cuando apuntas el editor a una carpeta que no parece un proyecto de RPG Maker XP (sin `Data/MapInfos.rxdata` dentro), muestra un diálogo **Not a Project Folder** con dos botones:

- **Choose Another…**: reabre el selector de carpetas para que pruebes otra carpeta.
- **Go Back**: vuelve a tu proyecto anterior (o a la pantalla de bienvenida si era el primer arranque).

Esto reemplaza el comportamiento anterior donde elegir una carpeta sin juego dejaba el editor en un estado vacío / atascado.
