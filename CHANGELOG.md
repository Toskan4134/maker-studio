# Changelog

User-facing changes to the Maker Studio app and its game-side plugin. Older
releases: see [GitHub Releases](https://github.com/Toskan4134/maker-studio/releases).

## v1.4.0

Event pages stopped being a straitjacket: conditions can now be a tree of ANDs and ORs, a switch can be required OFF, and an event can block the tile it stands on. Graphics can be a slice of an image — pick tiles straight off a tileset and give them to an event. The tileset editor lets you write your own terrain tags, and battlebacks finally work in Pokémon Essentials, bases included.

### Additions
- 🌳 **Advanced Conditions on event pages** — a condition *tree* instead of the vanilla four checks: as many switches, variables and self switches as you want, mixed **AND / OR**, nested in groups, each one negatable. "Boss defeated **or** cheat switch on", "any one of five NPCs talked to", "rival beaten **and** not (badge 3 **or** debug mode)". Needs the MakerStudio plugin in-game; the built-in Game Simulator always honours it.
- 🔀 **Switch conditions can ask for OFF** — Switch 1, Switch 2 and Self Switch each get an ON / OFF dropdown, so a page can turn on precisely when a switch turns off.
- 🧱 **Block** — a new page option that makes the event impassable whatever the tile underneath allows. Made for events drawn with a walkable floor tile, which the player used to walk straight through.
- 🔻 **Always on Bottom** — the mirror of Always on Top: the event is drawn underneath every character, for floor decals, rugs, puddles and shadows built as events.
- 🖼️ **Use part of an image as a graphic** — pick a rectangle, or click and drag **tiles straight off a tileset**, and that slice becomes the event's graphic (also available for pictures and move routes). Everything downstream treats the slice as the whole image, so the sheet grid and the animation frames keep working.
- 🏷️ **Custom terrain tags and priorities in the Tileset Editor** — name your own terrain tags instead of living with 0–7, and extract the ones your game already defines from its own data.
- 🖌️ **Multi-tile stamps** — fill an area with a repeating pattern, drag to stamp continuously, and turn any map selection into a brush.
- 🗺️ **New Map, where you meant it** — the New Map dialog now lets you pick the parent map, and the map tree has **New Map Here**.
- ↩️ **Adding and deleting extended layers can be undone.**
- 👁️ **The event-cells view stays how you left it** between sessions, and a double-click confirms your pick in the graphic picker.
- 🐧 **Linux gets the already-running prompt too** — launching a second copy of the game asks first, as it does on Windows.
- 🧩 **For mod developers**: floating panels can set their own size, mods can read and react to events, toasts can carry up to two action buttons, and a mod can open the Keyboard Shortcuts dialog scrolled to a specific action.

### Fixes
- ⚔️ **Fixed the battleback being ignored in Pokémon Essentials and La Base de Sky** — those games read the backdrop from the map's metadata and never looked at the field the editor was writing. It now applies on every supported base (Essentials 17.1, 19.1, 20.1, 21.1, LBDS and BES), each of which keeps that metadata somewhere different.
- 🪨 **Fixed the bases not following the battleback** — picking `cave1` changed the background but left the battlers standing on grass, because Essentials names the bases after the environment. Your battleback now leads, and the environment only narrows it (`cave1_water_base0` on water, `cave1_ice_base0` on ice).
- 💥 **Fixed the plugin refusing to load on Essentials 17.1 and BES** — one line used Ruby syntax those engines are too old to parse, which took the whole plugin down at boot.
- 💾 **Fixed a crash on loading a save in Essentials 17.1 and BES** — the single-file version of the plugin had fallen behind the rest and still called a method those engines don't have.
- 🔄 **Fixed reordering extended layers not showing in the running game.**
- 🧭 **Fixed the location picker opening blank** and made its panning smooth, with a tile grid.
- 🖼️ **Fixed panoramas and battlebacks not hot-reloading** into the game you already had open.
- 👀 **Event indicators are clearer** on the map.
- 🌍 **Fixed untranslated text** in export, map versions, the tile right-click menu, and the ON/OFF labels.

### Changes
- 📄 **The per-project editor settings file is now `ms-editor-config.json`.** Existing projects are unaffected — it is created again on the next save.
- 📐 **The event editor's left panel can be resized**, and the window opens at a more sensible size.
- 🔍 **The tile info section moved to the bottom of the tileset editor's sidebar.**

### Documentation
User guides and mod API reference: https://makerstudio.toskan.es/

## v1.3.0

The interface is yours now: pick a theme, recolour anything, and keep your place between sessions. Graphics you repaint in another program reload into the editor **and** into the game you already have running. The tileset editor moved into the Database and got a lot faster on big sheets.

### Additions
- 🎨 **Make the editor look how you want** — a new **Appearance** tab in **Help → Settings…** lets you pick a theme, switch dark/light, and recolour anything the editor draws: backgrounds, text, accents, the event command list, the Ruby syntax colours. Every colour is saved **per theme and per light/dark mode**, so your dark palette and your light one stay separate, and edits to a mod's theme are kept for the next time you turn it on. Colours update as you pick them and are stored when you press Save.
- 🖌️ **Themes from mods** — a mod can ship a full theme, including a wallpaper painted behind your map. A theme can offer both a light and a dark look and follow the Dark Mode toggle, or pin the editor to the one it was designed for. Pick one under **View → Theme** or in the new Appearance tab.
- ♻️ **Graphics reload into the running game** — repaint a tileset, autotile or character sheet in another program and it refreshes in the editor and in the playtest you already have open, without restarting either. Character sheets filed in subfolders are watched too. You can turn it off per project, or for one session from the game's debug menu.
- 🧱 **The tileset editor lives in the Database** — it is now the **Tilesets** tab: the list, the name, the graphic and the property grid on one screen. Each priority level has its **own colour** so a sheet mixing several can be read at a glance, and **Apply** saves without closing while **Save** saves and closes. Right-clicking a tile in the palette and choosing **Edit Properties…** opens it scrolled to that exact tile.
- 🎵 **Audio Browser** — a listening-only audio picker under **Tools** and in the toolbar, with a pitch slider that resamples the way the game does.
- ⚙️ **Editor settings** — a new **Help → Settings…** window: choose the size the editor opens at (default, remember the last one, maximized, fullscreen, or an exact size) and which monitor it opens on, picked by name so it survives unplugging a screen. On Windows you can also choose **which monitor the game opens on**; by default it follows whichever screen you are working on.
- 🪟 **Dialogs can be resized** — drag any edge or corner of a dialog to resize it, and when dialogs are stacked, Escape closes only the one on top.
- 🚶 **Autonomous Movement → Custom** now edits the event page's own route instead of a blank one, and **Wait for Move's Completion** can wait for one character instead of every character on the map.
- 👁️ **Alt+click a layer's eye** to show only that layer; Alt+click again puts back exactly what was visible before.
- 🗂️ **The editor remembers where you were** — reopening a project restores the map you were last editing and the map-tree folders you had folded.
- 📂 **File → Open Project Folder** and **Open Saves Folder** open those folders in your file manager.
- 🖊️ **Syntax highlighting in event script boxes**, and a **Snippets** library for the code you retype.
- 🌍 **Set Move Route is fully translated** — the route options, all 45 move actions and the Frame section.
- ⌨️ **Digit shortcuts in the tileset editor** — in Priority and Terrain Tag mode, 1–9 and 0 pick the value to paint. Rebindable.
- 🔍 **A Marketplace built for many mods** — tags in a searchable popover, All/Installed/Updates filters, a result count, and card or list views.
- 🎯 **Multi-tile stamps** — Ctrl+click adds a tile to the stamp and Shift+click removes it, on the palette and on the map.
- 🎮 **The simulator's Max FPS** is configurable, so it can match your game's own frame rate.
- 🔁 **Close and Reopen** — when the game is already running, Run can close it and start a fresh one.

### Fixes
- 🍎 **Fixed the Saves button doing nothing on macOS** — it pointed at a folder the game never writes to, and failed silently. It now opens the saves folder inside the Wine prefix the game actually ran in.
- 🎨 **Fixed parts of the interface ignoring the theme** — around 130 places were pinned to a fixed colour and never followed the theme you had chosen.
- ⌨️ **Fixed number fields you could not clear** — selecting the number and pressing Backspace snapped it straight back to the minimum. You can now empty a field; it fills in the minimum when you click away.
- 🧊 **Fixed the editor freezing when opening a very large tileset** — a 500-row sheet is no longer drawn all at once.
- ⏱️ **Fixed the simulator running every Wait 1.65× too fast**, and a move route re-issued while still running skipping its Waits.
- 🧍 **Fixed tall events flickering** over tiles set to priority 1.
- ↩️ **Fixed undoing a map resize leaving the events moved** in the saved file.
- ⌨️ **Fixed keyboard shortcuts firing while you were typing** in the event editor.
- 🖍️ **Fixed unreadable text selection** in the Scripts editor's dark theme.

### Changes
- 🖱️ **Events are created with a double-click** by default, matching RPG Maker — a single click selects the tile. Switch it back under **View → Create Events on Double-Click**.
- 🎚️ **Scrollbars are thicker and easier to grab**, and checkboxes, radios and sliders follow the theme instead of the system blue.
- 🗑️ **Deleting a layer asks first.**
- ⚠️ **"Don't warn me again" is gone from the already-running prompt** — launching a second copy of the game, or closing the one that is running, is worth confirming every time.
- 🐧 **Clear Proton Preference is only listed when there is a choice to forget.**

### Documentation
User guides and mod API reference: https://makerstudio.toskan.es/

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

## v1.4.0

Las páginas de evento dejan de ser una camisa de fuerza: las condiciones pueden ser un árbol de Y y O, un switch puede exigirse en OFF, y un evento puede bloquear el tile en el que está. Un gráfico puede ser un trozo de una imagen — elige tiles directamente de un tileset y dáselos a un evento. El editor de tilesets te deja escribir tus propios terrain tags, y los battlebacks por fin funcionan en Pokémon Essentials, bases incluidas.

### Novedades
- 🌳 **Condiciones avanzadas en las páginas de evento** — un *árbol* de condiciones en vez de las cuatro de siempre: tantos switches, variables y self switches como quieras, mezclando **Y / O**, anidados en grupos y cada uno negable. "Jefe derrotado **o** switch de trucos activo", "hablado con cualquiera de cinco NPC", "rival derrotado **y** no (medalla 3 **o** modo debug)". Necesita el plugin de MakerStudio en el juego; el simulador integrado siempre lo respeta.
- 🔀 **Las condiciones de switch pueden pedir OFF** — Switch 1, Switch 2 y Self Switch tienen ahora un desplegable ON / OFF, así que una página puede activarse justo cuando un switch se apaga.
- 🧱 **Bloquear** — una nueva opción de página que hace el evento infranqueable permita lo que permita el tile de debajo. Pensada para eventos dibujados con un tile de suelo transitable, que antes se atravesaban sin más.
- 🔻 **Siempre debajo** — el reflejo de Siempre encima: el evento se dibuja por debajo de todos los personajes, para calcomanías de suelo, alfombras, charcos y sombras hechas con eventos.
- 🖼️ **Usa parte de una imagen como gráfico** — elige un rectángulo, o haz clic y arrastra sobre **los tiles de un tileset**, y ese trozo pasa a ser el gráfico del evento (también sirve para imágenes y rutas de movimiento). Todo lo demás trata el trozo como si fuera la imagen entera, así que la rejilla de la hoja y los fotogramas de animación siguen funcionando.
- 🏷️ **Terrain tags y prioridades propios en el editor de tilesets** — ponle nombre a tus terrain tags en vez de apañarte con 0–7, y extrae los que tu juego ya define desde sus propios datos.
- 🖌️ **Sellos de varios tiles** — rellena un área con un patrón repetido, arrastra para sellar en continuo y convierte cualquier selección del mapa en un pincel.
- 🗺️ **Nuevo mapa, donde querías** — el diálogo de nuevo mapa te deja elegir el mapa padre, y el árbol de mapas tiene **Nuevo mapa aquí**.
- ↩️ **Añadir y borrar capas extendidas se puede deshacer.**
- 👁️ **La vista de celdas de evento se queda como la dejaste** entre sesiones, y un doble clic confirma tu elección en el selector de gráficos.
- 🐧 **Linux también tiene el aviso de juego en ejecución** — lanzar una segunda copia del juego pregunta antes, como en Windows.
- 🧩 **Para quien hace mods**: los paneles flotantes pueden fijar su propio tamaño, los mods pueden leer los eventos y reaccionar a ellos, los avisos pueden llevar hasta dos botones de acción, y un mod puede abrir el diálogo de atajos de teclado desplazado hasta una acción concreta.

### Correcciones
- ⚔️ **Corregido que el battleback se ignorara en Pokémon Essentials y La Base de Sky** — esos juegos leen el fondo de batalla desde los metadatos del mapa y nunca miraban el campo que escribía el editor. Ahora se aplica en todas las bases soportadas (Essentials 17.1, 19.1, 20.1, 21.1, LBDS y BES), y cada una guarda esos metadatos en un sitio distinto.
- 🪨 **Corregido que las bases no siguieran al battleback** — elegir `cave1` cambiaba el fondo pero dejaba a los combatientes sobre hierba, porque Essentials nombra las bases según el entorno. Ahora manda tu battleback, y el entorno solo lo afina (`cave1_water_base0` sobre agua, `cave1_ice_base0` sobre hielo).
- 💥 **Corregido que el plugin no cargara en Essentials 17.1 y BES** — una línea usaba sintaxis de Ruby que esos motores son demasiado antiguos para interpretar, y eso tumbaba el plugin entero al arrancar.
- 💾 **Corregido un cierre inesperado al cargar partida en Essentials 17.1 y BES** — la versión de un solo archivo del plugin se había quedado atrás y aún llamaba a un método que esos motores no tienen.
- 🔄 **Corregido que reordenar las capas extendidas no se viera en el juego en marcha.**
- 🧭 **Corregido que el selector de ubicación se abriera en blanco**, y su desplazamiento ahora es suave y con rejilla de tiles.
- 🖼️ **Corregido que los panoramas y battlebacks no se recargaran en caliente** en el juego que ya tuvieras abierto.
- 👀 **Los indicadores de evento se ven más claros** en el mapa.
- 🌍 **Corregidos textos sin traducir** en la exportación, las versiones de mapa, el menú contextual de tiles y las etiquetas ON/OFF.

### Cambios
- 📄 **El archivo de ajustes del editor por proyecto pasa a llamarse `ms-editor-config.json`.** Los proyectos existentes no se ven afectados — se vuelve a crear en el siguiente guardado.
- 📐 **El panel izquierdo del editor de eventos se puede redimensionar**, y la ventana se abre con un tamaño más sensato.
- 🔍 **La sección de información del tile se ha movido al final de la barra lateral del editor de tilesets.**

### Documentación
Guías de usuario y referencia de la API de mods: https://makerstudio.toskan.es/

## v1.3.0

Ahora la interfaz es tuya: elige un tema, recolorea lo que quieras y conserva tu sitio entre sesiones. Los gráficos que repintes en otro programa se recargan en el editor **y** en el juego que ya tengas abierto. El editor de tilesets se ha mudado a la base de datos y va mucho más rápido con hojas grandes.

### Novedades
- 🎨 **Deja el editor como te guste** — la nueva pestaña **Appearance** en **Help → Settings…** te deja elegir tema, cambiar entre claro y oscuro, y recolorear todo lo que dibuja el editor: fondos, texto, acentos, la lista de comandos de evento, los colores de sintaxis de Ruby. Cada color se guarda **por tema y por modo claro/oscuro**, así tu paleta oscura y la clara no se pisan, y los cambios sobre el tema de un mod se conservan para la próxima vez que lo actives. Los colores se aplican según los eliges y se guardan al pulsar Save.
- 🖌️ **Temas desde mods** — un mod puede traer un tema completo, incluido un fondo pintado detrás del mapa. Un tema puede ofrecer versión clara y oscura y seguir el conmutador de modo oscuro, o fijar el editor al modo para el que fue diseñado. Elígelo en **View → Theme** o en la nueva pestaña Appearance.
- ♻️ **Los gráficos se recargan en el juego en marcha** — repinta un tileset, un autotile o una hoja de personaje en otro programa y se actualiza en el editor y en la partida de prueba que ya tengas abierta, sin reiniciar ninguno de los dos. También se vigilan las hojas guardadas en subcarpetas. Puedes desactivarlo por proyecto, o para una sesión desde el menú de depuración del juego.
- 🧱 **El editor de tilesets vive en la base de datos** — ahora es la pestaña **Tilesets**: la lista, el nombre, el gráfico y la rejilla de propiedades en una sola pantalla. Cada nivel de prioridad tiene **su propio color**, así una hoja que mezcla varios se lee de un vistazo, y **Aplicar** guarda sin cerrar mientras que **Guardar** guarda y cierra. Si haces clic derecho en un tile de la paleta y eliges **Edit Properties…**, se abre desplazado justo hasta ese tile.
- 🎵 **Explorador de audio** — un selector de audio de solo escucha en **Tools** y en la barra de herramientas, con un deslizador de tono que remuestrea igual que el juego.
- ⚙️ **Ajustes del editor** — una nueva ventana **Help → Settings…**: elige el tamaño con el que se abre el editor (por defecto, recordar el último, maximizada, pantalla completa o un tamaño exacto) y en qué pantalla se abre, elegida por nombre para que sobreviva a desconectar un monitor. En Windows también puedes elegir **en qué pantalla se abre el juego**; por defecto sigue a la pantalla en la que estés trabajando.
- 🪟 **Los diálogos se pueden redimensionar** — arrastra cualquier borde o esquina de un diálogo para cambiar su tamaño, y cuando hay diálogos apilados, Escape cierra solo el de arriba.
- 🚶 **Autonomous Movement → Custom** ahora edita la ruta propia de la página del evento en vez de una en blanco, y **Wait for Move's Completion** puede esperar a un personaje concreto en vez de a todos los del mapa.
- 👁️ **Alt+clic en el ojo de una capa** para ver solo esa capa; otro Alt+clic devuelve exactamente lo que estaba visible antes.
- 🗂️ **El editor recuerda dónde estabas** — al reabrir un proyecto se recupera el último mapa que editabas y las carpetas del árbol que tenías plegadas.
- 📂 **File → Abrir carpeta del juego** y **Abrir carpeta de partidas guardadas** abren esas carpetas en tu gestor de archivos.
- 🖊️ **Resaltado de sintaxis en las cajas de script de los eventos**, y una biblioteca de **fragmentos** para el código que reescribes siempre.
- 🌍 **Set Move Route está totalmente traducido** — las opciones de ruta, las 45 acciones de movimiento y la sección Frame.
- ⌨️ **Atajos numéricos en el editor de tilesets** — en modo Prioridad y Terrain Tag, del 1 al 9 y el 0 eligen el valor a pintar. Reasignables.
- 🔍 **Un Marketplace pensado para muchos mods** — etiquetas en un desplegable con búsqueda, filtros Todos/Instalados/Actualizaciones, contador de resultados y vista de tarjetas o de lista.
- 🎯 **Sellos de varios tiles** — Ctrl+clic añade un tile al sello y Mayús+clic lo quita, tanto en la paleta como en el mapa.
- 🎮 **El Max FPS del simulador** es configurable, así que puede coincidir con la tasa de fotogramas de tu juego.
- 🔁 **Cerrar y volver a abrir** — cuando el juego ya está en marcha, Run puede cerrarlo y arrancar uno nuevo.

### Correcciones
- 🍎 **Corregido que el botón Saves no hiciera nada en macOS** — apuntaba a una carpeta en la que el juego nunca escribe, y fallaba en silencio. Ahora abre la carpeta de guardados dentro del prefijo de Wine en el que realmente se ejecutó el juego.
- 🎨 **Corregido que partes de la interfaz ignoraran el tema** — unos 130 sitios estaban clavados a un color fijo y nunca seguían el tema que hubieras elegido.
- ⌨️ **Corregidos los campos numéricos que no se podían borrar** — seleccionar el número y pulsar Retroceso lo devolvía al mínimo al instante. Ahora puedes dejar el campo vacío; se rellena con el mínimo al salir de él.
- 🧊 **Corregido que el editor se congelara al abrir un tileset muy grande** — una hoja de 500 filas ya no se dibuja entera de golpe.
- ⏱️ **Corregido que el simulador ejecutara cada Wait 1,65× más rápido**, y que una ruta de movimiento reemitida mientras seguía en marcha se saltara sus Wait.
- 🧍 **Corregido el parpadeo de los eventos altos** sobre tiles con prioridad 1.
- ↩️ **Corregido que deshacer una redimensión de mapa dejara los eventos movidos** en el archivo guardado.
- ⌨️ **Corregido que los atajos de teclado se dispararan mientras escribías** en el editor de eventos.
- 🖍️ **Corregida la selección de texto ilegible** en el tema oscuro del editor de scripts.

### Cambios
- 🖱️ **Los eventos se crean con doble clic** por defecto, como en RPG Maker — un solo clic selecciona el tile. Puedes volver atrás en **View → Crear eventos con doble clic**.
- 🎚️ **Las barras de desplazamiento son más gruesas y fáciles de agarrar**, y las casillas, radios y deslizadores siguen el tema en vez del azul del sistema.
- 🗑️ **Borrar una capa pregunta antes.**
- ⚠️ **Se ha quitado "No volver a avisar" del aviso de juego en ejecución** — lanzar una segunda copia del juego, o cerrar la que está abierta, merece confirmarse siempre.
- 🐧 **Clear Proton Preference solo aparece cuando hay una elección que olvidar.**

### Documentación
Guías de usuario y referencia de la API de mods: https://makerstudio.toskan.es/

## v1.2.1

Corrección urgente de la v1.2.0: la integración impedía que el juego arrancase.

### Correcciones
- 🚑 **Corregido que el juego no arrancaba tras instalar la integración v1.2.0** — fallaba al iniciar con un error de plugin sobre una clave de registro no válida (`Clave de registro de plugin no válida 'msintegration'` / `Invalid plugin registry key 'msintegration'`). La línea que usa el editor para reconocer qué integración tienes queda ahora oculta al motor, así que se sigue identificando igual que antes sin que el motor llegue a verla. Afectaba a todas las integraciones que se instalan como carpeta, en todos los motores; si instalaste la v1.2.0, actualiza a la v1.2.1.

### Documentación
Guías de usuario y referencia de la API de mods: https://makerstudio.toskan.es/

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
