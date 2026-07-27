# Changelog

User-facing changes to the Maker Studio app and its game-side plugin. Older
releases: see [GitHub Releases](https://github.com/Toskan4134/maker-studio/releases).

## v1.2.1

Hotfix for v1.2.0: the Integration stopped games from starting.

### Fixes
- 🚑 **Fixed the game refusing to start after installing the v1.2.0 Integration** — it failed at boot with a plugin error about an invalid registration key (`Invalid plugin registry key 'msintegration'` / `Clave de registro de plugin no válida 'msintegration'`). The line the editor uses to recognise which Integration you have is now hidden from the engine, so it identifies itself exactly as before without the engine ever seeing it. Affected every folder-installed Integration on every engine; if you installed v1.2.0, update to v1.2.1.

### Documentation
User guides and mod API reference: https://makerstudio.toskan.es/

## v1.2.0

A big update to the event editor and the game-side plugin: a redesigned command picker, an editor that keeps your Integration up to date on its own, a reusable script library, per-map default music, and in-game tile colors that finally match what you see in the editor.

### Additions
- 🎛️ **Redesigned event command picker** — commands are now split across nine named tabs (Messages, Logic, Party & Items, Movement, Screen & Pictures, Audio, Actors, Battle, System) instead of three numbered pages, each with a one-line description of what it covers. The list keeps a fixed height, so the dialog no longer grows and shrinks as you switch tabs, and the picker reopens on the tab you were last using. If you have enough tabs to overflow, the tab bar scrolls with the mouse wheel and gets arrow buttons at its ends. **Favourites** can now be reordered: open the Favourites tab, click the pencil, and drag them into the order you want.
- 🔌 **The editor keeps your Integration up to date** — open a project and Maker Studio checks the plugin installed in your game. If it's older than the editor, it offers to download and install the right one for you (**Update Now**), point you at the download page, or remind you later. It works out which Integration your project uses on its own, keeps your project's mods and settings untouched, and handles the paste-in builds (BES v5, v17.1) by replacing just their script. You can run the check any time from **Help → Check Game Integration…**.
- ✂️ **Script snippets** — every script box in the event editor now has a **Snippets…** button: save the bits of code you retype, then drop them in with one click. One shared library across your whole project, with rename, overwrite, delete, and import/export to a file.
- 🎵 **Default music per map** — a new **Map Audio** dialog lets you set a map's Auto-Change BGM and BGS, so entering it starts the music you picked without needing an event to do it.
- 🧩 **One more supported engine** — vanilla Pokémon Essentials v17.1 now has its own Integration to install.
- ⌨️ **Command list touches** — multi-line commands now indent their continuation lines to line up under the command name, like the classic editor; **Ctrl+A** selects every command in the page; and cancelling an insert takes you back to the picker on the tab you were browsing.
- 🐧 **Linux polish** — `.makerstudio` project files now show the Maker Studio icon in your file manager, and the app icon shows correctly on the KDE Wayland dock.

### Fixes
- 🎨 **In-game tile colors now match the editor** — tiles with a hue or saturation change rendered far more vivid in-game than in the editor. The plugin now reproduces the editor's color math exactly, including tiles that combine hue with saturation or lighting.
- 🖌️ **Autotiles now take color and lighting in-game** — hue, saturation and lighting set on an autotile were shown in the editor but ignored by the game; they now render in-game too, animation intact, without affecting other tiles using the same autotile.
- 🧱 **Fixed tiles flickering in-game while walking** — a tile stacked on two extended layers could show one layer or the other depending on where you were standing, so parts of a map appeared and disappeared as you moved.
- 💾 Fixed Ctrl+S not saving while the Scripts window was open.

### Changes
- 🔄 **Autotiles are never rotated or flipped** — an autotile picks its pattern from the tiles around it, so a rotated or mirrored one no longer matched the edge it was chosen for (and could look upright in the editor but rotated in-game). The transform controls are now greyed out while an autotile is selected, and rotating a stamp that contains autotiles leaves them alone. Rotations saved on autotiles by older versions are ignored everywhere.

### Documentation
User guides and mod API reference: https://makerstudio.toskan.es/

## v1.1.1

Small update: a faster way to open projects, plus editor and in-game preview performance fixes.

### Additions
- 📂 **Open a project by double-clicking it** — create a `.makerstudio` file for your project (**File → Create Project File…**) and double-click it in your file manager to launch Maker Studio straight into that project, just like RPG Maker XP's project file. (On the Linux AppImage, register it once with **Help → Install Linux File Association…**.)

### Fixes
- ⚡ **Editor performance** — the map canvas no longer lags when painting lots of tiles, tiles with color or rotation properties, or autotiles, or when working on very large maps.
- 🗺️ **Faster in-game map previews** — the debug "jump to map" and map-connection editor screens no longer freeze on maps with many styled tiles.

### Documentation
User guides and mod API reference: https://makerstudio.toskan.es/

## v1.1.0

Update focused on stability: several in-game and editor bugs fixed, plus broader engine support.

### Additions
- 🍷 **Play/test on macOS** — the editor's "Run Game" button now launches your game through Wine on macOS (needs Wine, or Game Porting Toolkit/Whisky on Apple Silicon).
- 🧩 **Two more supported engines** — vanilla Pokémon Essentials v19.1 and v20.1 now have their own Integration to install.

### Fixes
- 🐢 **Big performance fix** — maps with lots of autotiles or extended-layer content used to run at single-digit FPS in-game; they now run at full speed regardless of map size.
- 🧱 Fixed several in-game collision bugs: tiles that should block movement could sometimes be walked through, and object hitboxes could land one tile off.
- 🎨 Fixed autotile passage/priority/terrain properties sometimes saving the wrong values to the wrong tileset, which could make a shared autotile graphic (e.g. sand, water) behave inconsistently across maps.
- 🖼️ Fixed a crash when placing tiles from another tileset onto very tall tilesets.
- 🌑 Fixed shadows occasionally drawing in front of or behind the wrong tiles.
- 👣 Fixed footprints (La Base de Sky 1.2.1) not appearing on sand painted with Maker Studio's autotiles or extended layers.
- 🔍 Fixed map search not finding maps nested several folders deep.
- 🖌️ Fixed autotile previews sometimes going blank after switching projects.
- 📐 Fixed map resize not saving events' new positions in-game.
- 💡 Fixed lighting/color effects looking different in the Game Simulator than in the actual game.
- 🧩 Fixed mods being unable to read or edit an event's list of commands.

### Changes
- 📝 The event editor now shows each line of a multi-line Show Text, Comment or Script command as its own row, matching the classic editor's look — while still selecting, moving and deleting as one command.
- 🪟 The event editor window no longer resizes itself when switching between pages.

### Documentation
User guides and mod API reference: https://makerstudio.toskan.es/

---

# Registro de cambios

Cambios de cara al usuario en la app de Maker Studio y su plugin del lado del
juego. Versiones anteriores: consulta los [Releases de GitHub](https://github.com/Toskan4134/maker-studio/releases).

## v1.2.0

Una actualización grande del editor de eventos y del plugin del lado del juego: selector de comandos rediseñado, un editor que mantiene tu integración al día por su cuenta, una biblioteca de fragmentos de código reutilizables, música por defecto por mapa, y colores de tiles en el juego que por fin coinciden con lo que ves en el editor.

### Novedades
- 🎛️ **Selector de comandos rediseñado** — los comandos se reparten ahora en nueve pestañas con nombre (Mensajes, Lógica, Grupo y objetos, Movimiento, Pantalla e imágenes, Audio, Héroes, Combate, Sistema) en lugar de tres páginas numeradas, cada una con una descripción de una línea de lo que incluye. La lista mantiene una altura fija, así que el diálogo ya no crece y encoge al cambiar de pestaña, y el selector se vuelve a abrir en la última pestaña que usaste. Si tienes suficientes pestañas como para que no quepan, la barra se desplaza con la rueda del ratón y aparecen botones de flecha en los extremos. Los **Favoritos** ahora se pueden reordenar: abre la pestaña de favoritos, haz clic en el lápiz y arrástralos al orden que quieras.
- 🔌 **El editor mantiene tu integración al día** — al abrir un proyecto, Maker Studio comprueba el plugin instalado en tu juego. Si es más antiguo que el editor, se ofrece a descargar e instalar el correcto por ti (**Actualizar ahora**), a llevarte a la página de descargas, o a recordártelo más tarde. Deduce solo qué integración usa tu proyecto, no toca los mods ni la configuración del proyecto, y en las versiones que se pegan en el Editor de Scripts (BES v5, v17.1) reemplaza únicamente su script. Puedes lanzar la comprobación cuando quieras desde **Ayuda → Comprobar integración del juego…**.
- ✂️ **Fragmentos de código** — cada campo de script del editor de eventos tiene ahora un botón **Fragmentos…**: guarda ese código que reescribes una y otra vez y colócalo con un clic. Una biblioteca compartida para todo el proyecto, con renombrar, sobrescribir, borrar e importar/exportar a un archivo.
- 🎵 **Música por defecto en cada mapa** — un nuevo diálogo **Audio del mapa** te deja fijar el **Cambio automático de BGM** y **BGS** de un mapa, para que al entrar suene la música que elegiste sin necesidad de un evento que lo haga.
- 🧩 **Un motor más compatible** — Pokémon Essentials v17.1 (vanilla) ya tiene su propia integración para instalar.
- ⌨️ **Detalles de la lista de comandos** — los comandos multilínea ahora indentan sus líneas de continuación para alinearlas bajo el nombre del comando, como en el editor clásico; **Ctrl+A** selecciona todos los comandos de la página; y cancelar una inserción te devuelve al selector en la pestaña que estabas mirando.
- 🐧 **Mejoras en Linux** — los archivos de proyecto `.makerstudio` ya muestran el icono de Maker Studio en el explorador de archivos, y el icono de la app se ve correctamente en el dock de KDE Wayland.

### Correcciones
- 🎨 **Los colores de los tiles en el juego ya coinciden con el editor** — los tiles con cambio de hue o saturación se veían mucho más vivos en el juego que en el editor. El plugin reproduce ahora exactamente el cálculo de color del editor, incluidos los tiles que combinan hue con saturación o iluminación.
- 🖌️ **Los autotiles ya aceptan color e iluminación en el juego** — el hue, la saturación y la iluminación aplicados a un autotile se veían en el editor pero el juego los ignoraba; ahora también se dibujan en el juego, sin romper la animación y sin afectar a otros tiles que usen el mismo autotile.
- 🧱 **Corregidos los tiles que parpadeaban en el juego al caminar** — un tile colocado en dos capas extendidas podía mostrar una capa u otra según dónde estuvieras, así que partes del mapa aparecían y desaparecían al moverte.
- 💾 Corregido que Ctrl+S no guardaba con la ventana de Scripts abierta.

### Cambios
- 🔄 **Los autotiles nunca se rotan ni se voltean** — un autotile elige su patrón según los tiles de alrededor, así que uno rotado o reflejado dejaba de encajar con el borde para el que se eligió (y podía verse recto en el editor pero rotado en el juego). Los controles de transformación aparecen ahora atenuados mientras hay un autotile seleccionado, y rotar una estampa que contenga autotiles los deja intactos. Las rotaciones guardadas en autotiles por versiones anteriores se ignoran en todas partes.

### Documentación
Guías de usuario y referencia de la API de mods: https://makerstudio.toskan.es/

## v1.1.1

Actualización pequeña: una forma más rápida de abrir proyectos, más correcciones de rendimiento en el editor y las previsualizaciones dentro del juego.

### Novedades
- 📂 **Abrir un proyecto con doble clic** — crea un archivo `.makerstudio` para tu proyecto (**Archivo → Crear archivo de proyecto…**) y haz doble clic sobre él en tu explorador de archivos para abrir Maker Studio directamente en ese proyecto, igual que el archivo de proyecto de RPG Maker XP. (En el AppImage de Linux, regístralo una vez con **Ayuda → Instalar asociación de archivo en Linux…**.)

### Correcciones
- ⚡ **Rendimiento del editor** — el lienzo del mapa ya no va lento al pintar muchos tiles, tiles con propiedades de color o rotación, o autotiles, ni al trabajar en mapas muy grandes.
- 🗺️ **Previsualizaciones de mapa más rápidas en el juego** — las pantallas de depuración "saltar a mapa" y el editor de conexiones de mapa ya no se congelan en mapas con muchos tiles con efectos.

### Documentación
Guías de usuario y referencia de la API de mods: https://makerstudio.toskan.es/

## v1.1.0

Actualización centrada en estabilidad: se corrigen varios errores del editor y del juego, y se amplía el soporte de motores.

### Novedades
- 🍷 **Jugar/probar en macOS** — el botón "Run Game" del editor ahora lanza el juego a través de Wine en macOS (necesita Wine, o Game Porting Toolkit/Whisky en Apple Silicon).
- 🧩 **Dos motores más soportados** — Pokémon Essentials vanilla v19.1 y v20.1 ya tienen su propia Integration para instalar.

### Correcciones
- 🐢 **Corrección de rendimiento importante** — los mapas con muchos autotiles o contenido de capas extendidas llegaban a ir a un puñado de FPS dentro del juego; ahora van a velocidad completa sin importar el tamaño del mapa.
- 🧱 Se corrigen varios errores de colisión en el juego: a veces se podía atravesar tiles que deberían bloquear el paso, y las hitboxes de objetos podían quedar desplazadas un tile.
- 🎨 Se corrige que las propiedades de paso/prioridad/terreno de los autotiles a veces se guardaran con valores incorrectos en el tileset equivocado, lo que podía hacer que un gráfico de autotile compartido (arena, agua...) se comportara de forma distinta según el mapa.
- 🖼️ Se corrige un cuelgue al colocar tiles de otro tileset sobre tilesets muy altos.
- 🌑 Se corrige que las sombras a veces se dibujaran delante o detrás del tile equivocado.
- 👣 Se corrige que las huellas (La Base de Sky 1.2.1) no aparecieran sobre arena pintada con autotiles o capas extendidas de Maker Studio.
- 🔍 Se corrige que el buscador de mapas no encontrara mapas anidados varias carpetas dentro.
- 🖌️ Se corrige que las previsualizaciones de autotiles a veces quedaran en blanco al cambiar de proyecto.
- 📐 Se corrige que redimensionar un mapa no guardara la nueva posición de los eventos en el juego.
- 💡 Se corrige que los efectos de iluminación/color se vieran distintos en el Simulador respecto al juego real.
- 🧩 Se corrige que los mods no pudieran leer ni editar la lista de comandos de un evento.

### Cambios
- 📝 El editor de eventos ahora muestra cada línea de un comando de Mostrar Texto, Comentario o Script multilínea como su propia fila, igual que el editor clásico — pero seleccionando, moviendo y borrando como un único comando.
- 🪟 La ventana del editor de eventos ya no cambia de tamaño al cambiar de página.

### Documentación
Guías de usuario y referencia de la API de mods: https://makerstudio.toskan.es/
