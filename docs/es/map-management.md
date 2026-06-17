# Gestión de mapas

## Crear un mapa nuevo

Elige Map y luego New Map en el menú, o haz clic en el botón **+** de la **cabecera del panel Maps** (junto a la lista de mapas, reflejando el **+** de añadir capa del panel Layers). Rellena los datos:

- **Name**: el nombre visible del mapa.
- **Width / Height**: dimensiones en tiles.
- **Tileset**: qué tileset usa el mapa para sus capas nativas.
- **Parent map**: dónde se sitúa el mapa en el árbol de jerarquía.

Haz clic en Create para añadir el mapa a tu proyecto.

## Abrir mapas

Haz doble clic en cualquier mapa del árbol de mapas para abrirlo en una pestaña nueva del editor.

## Duplicar un mapa

Para hacer una copia completa de un mapa como un **mapa totalmente nuevo** (un `map_id` separado, no una versión):

- Haz clic derecho en un mapa del árbol y elige **Duplicate Map**, o
- Abre el mapa y elige **Map → Duplicate Map** en el menú.

La copia se llama *"<original> (copy)"*, se coloca bajo el mismo padre y se abre automáticamente. Es un clon fiel — tiles, eventos, capas, sombras/fog **y cualquier versión de mapa** vienen con ella. Si el mapa de origen tiene ediciones sin guardar, se guardan primero para que la copia esté al día. Esto es distinto de una **versión de mapa** (el mismo mapa, intercambiado en el juego); usa Duplicate Map cuando quieras un mapa independiente que puedas cambiar sin afectar al original.

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

Elige una imagen de `Graphics/Battlebacks/` (sin deslizador de hue). Deja el nombre en blanco para quitarlo. Lo que hace el cambio depende de qué estés editando:

- **En el mapa base, estás editando el tileset** — exactamente como RPG Maker XP. El nuevo battleback se escribe en el tileset al momento y se aplica a **todos los mapas que usan ese tileset** (otros mapas abiertos se actualizan al instante). Esto funciona en cualquier juego, sin necesidad de plugin, así que el elemento de menú no muestra insignia MS mientras estás en el mapa base.
- **En una versión de mapa, estableces una sustitución por versión**, guardada en el archivo del mapa (pulsa **Ctrl+S** para conservarla) y aplicada en el juego por el plugin MakerStudio — así que esos elementos llevan la insignia MS.

El **battleback no se muestra en el lienzo del mapa** — solo aparece en las batallas en el juego — pero se guarda y se puede editar aquí.

> Los mapas guardados con una build antigua de Maker Studio pueden aún contener una sustitución base por mapa; el editor ahora la ignora (el mapa base siempre muestra los ajustes del tileset) y la quita la próxima vez que guardes ese mapa. El mismo plugin en el juego también impide que el propio fog del tileset se dibuje dos veces cuando un mapa usa capas de fog de Maker Studio.

## Borrar un mapa

Haz clic derecho en un mapa del árbol y elige Delete Map, luego confirma el borrado. Cualquier mapa hijo se mueve al padre del mapa borrado para que no se pierdan. El archivo `.rxdata` del mapa se quita del disco.

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

Haz clic en el botón verde Run de la barra de herramientas (o usa File y luego Run Game). El editor guarda todos los mapas abiertos con cambios sin guardar, luego lanza `Game.exe` en modo depuración desde la carpeta de tu proyecto.

### Ejecutar en Linux (Proton / Wine)

`Game.exe` es un ejecutable de Windows, así que en Linux el editor lo ejecuta a través de **Proton** o **Wine**. La primera vez que pulsas Run, un diálogo te deja elegir cómo lanzar:

- **Proton**: elige una versión de Proton instalada (y, si hace falta, el id de app de Steam a usar). El editor configura un prefijo de Wine dedicado para tu juego la primera vez.
- **Wine**: lanza a través del Wine de tu sistema en su lugar.

Tu elección se recuerda por proyecto, así que las ejecuciones posteriores lanzan directo sin volver a preguntar.

### Botón Saves

Tras tu primer Run, aparece un botón **Saves** en la barra que abre la carpeta donde el juego escribe sus archivos de guardado:

- **Windows / macOS**: abre la carpeta de guardado nativa (en Windows, `%AppData%\<Game>`).
- **Linux**: abre la carpeta correspondiente dentro del prefijo Proton/Wine en el que se ejecutó el juego.

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
