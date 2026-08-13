# Guía de la interfaz

## Barra de menús

Cada elemento de menú muestra ahora un pequeño icono junto a su etiqueta para localizar comandos más rápido. Los menús, de izquierda a derecha, son **File, Edit, View, Map, Tools, Mods, Help**.

- **File**: Open Project, **Open Recent** (proyectos abiertos recientemente, más Clear Recent Projects), **Abrir carpeta del juego** (abre la carpeta de tu proyecto en el Explorador de Windows / Finder / tu gestor de archivos — práctico para meter gráficos o comprobar qué ha escrito el editor), **Abrir carpeta de partidas guardadas** (abre la carpeta donde el juego escribe sus archivos de guardado — ver [Gestión de mapas](map-management.md#abrir-la-carpeta-de-guardados)), Save, Save All, Run Game, **Clear Proton Preference** (solo Linux — olvida tu elección recordada de lanzamiento Proton/Wine para que el diálogo de selección vuelva a aparecer la próxima vez que pulses Run; solo se muestra cuando hay una elección así que olvidar)
- **Edit**: Undo, Redo, Cut, Copy, Paste, **Advanced Clipboard** (Copy All Layers, Cut All Layers, Paste to Original Layers, conmutador **Cross-Project Clipboard** — ver abajo), Select All, Deselect, **Shadows** (Generate from Selection, Delete All Shadows)
  - El **Cross-Project Clipboard** está desactivado por defecto. Cuando está marcado, copiar tiles, eventos o comandos de evento también los coloca en el portapapeles del sistema para que una **segunda ventana de Maker Studio abierta** pueda pegarlos. Actívalo en *cada* ventana entre las que quieras compartir. (Borrar una selección de tiles sigue funcionando con la tecla **Supr**; solo se reemplazó la antigua entrada de menú por este conmutador.)
- **View**: submenú **Panels** (Maps, Tile Palette, Layers, Tile Properties, Tile Info, Events, Minimap — al hacer clic en una entrada se **enfoca** ese panel, trayéndolo al frente o reabriéndolo como ventana flotante si estaba cerrado; nunca cierra un panel, y la marca de verificación sigue indicando qué paneles están abiertos), Show Grid, Show Collision, Show Events, **Mostrar casilla de los eventos** (ver abajo), **Crear eventos con doble clic** (ver abajo), Dim Inactive Layers, **Show MS-Exclusive Indicators** (ver abajo), Zoom In/Out/100%, Dark Mode, submenú **Language** (ver abajo), submenú **Layout** (Refresh Layout, Import/Export Configuration)
  - **Crear eventos con doble clic** está activado por defecto, igual que en RPG Maker: con el Brush en la capa de eventos, un clic en un tile vacío lo selecciona y el **doble clic** crea ahí el evento. Desactívalo si prefieres que un solo clic cree el evento directamente.
  - **Mostrar casilla de los eventos** está desactivado por defecto. Los eventos sin gráfico siempre muestran un recuadro en su tile; con esto activado, los eventos que **sí** tienen gráfico también se marcan — un borde fino alrededor de su casilla más un cuadradito en la esquina —, así se ve exactamente en qué tile está cada evento sin tapar su sprite. Se deshabilita mientras Show Events esté apagado. Tu elección se recuerda entre sesiones.
- **Map**: New Map, **Duplicate Map**, **Map Versions…**, Resize / Shift Map, Change Tileset, **Change Battleback…**, **Map Audio…**, Import Map from JSON, submenú **Export Map** (Export as JSON / PNG / GIF / WebP)
- **Tools**: selección de herramienta (Brush/Eraser/Fill/Rectangle/Eyedropper/Select/Pan), Rotate CW/CCW, Flip Horizontal/Vertical, **Brush Editor…**, Database, Scripts
- **Mods**: Mod Manager (+ cualquier elemento de menú y panel aportado por mods)
- **Help**: **Documentation** (abre esta documentación en línea en tu navegador), Keyboard Shortcuts, **Reset App** (recarga el editor — se conserva la disposición de paneles; `Ctrl+R`), Check for Updates (muestra la versión que tienes junto a la última publicada), Stats, About Maker Studio, Toggle DevTools

## Idioma

La interfaz está disponible en **English** y **Español**, y los [mods](marketplace.md) instalados pueden añadir más idiomas — cualquier idioma que aporte un mod aparece automáticamente en el mismo menú (si el mod que aporta tu idioma elegido está desactivado, el editor vuelve a su idioma por defecto y cambia de nuevo cuando el mod regresa). Cambia en **View → Language** — el cambio se aplica al instante y se recuerda entre sesiones. En el primer arranque el editor elige el idioma de tu sistema (los sistemas en español empiezan en Español; el resto usa English por defecto). Toda la interfaz está traducida — menús, paneles, diálogos, el editor de eventos y sus formularios de comandos, el simulador y las notificaciones. Algunos términos técnicos se mantienen en inglés a propósito (por ejemplo *tile*, *tileset*, *autotile*, *script*, *mod*, y los tipos de audio como *BGM*/*SE*) para que coincidan con RPG Maker y la API de modding.

## Indicadores de funciones exclusivas de MS

Algunas funciones del editor van más allá de lo que admite RPG Maker XP estándar — solo funcionan en el juego en ejecución si tu proyecto tiene instalado el **plugin MakerStudio** (la integración que viene con el editor). Una pequeña insignia **MS** marca esas funciones por toda la interfaz para que siempre sepas cuáles dependen del plugin. Pasa el ratón sobre una insignia para recordar el motivo — la mayoría dice *"Maker Studio exclusive — requires the MakerStudio plugin in-game"*, mientras que algunas explican su razón concreta.

Verás la insignia, por ejemplo, en:

- Elementos de menú como **Edit → Shadows** y **Map → Map Versions…** (también en las entradas correspondientes del menú contextual del Árbol de mapas).
- **Map → Change Battleback…** — pero **solo mientras editas una [versión de mapa](map-versions.md)**. En el mapa base cambia el tileset exactamente igual que RPG Maker XP, así que no hace falta el plugin y no se muestra insignia; solo las sustituciones por versión necesitan el plugin (la entrada "(this version)" del submenú de versión siempre lleva la insignia). (Los panoramas ya no se cambian desde un menú — se editan como el grupo **Panorama Layers** en el panel de capas; consulta la [Guía de capas](layers.md#fog-panorama-and-custom-layer-groups).)
- Las filas del panel de capas para los grupos de capa de fog/panorama (y cualquier grupo añadido por mods), los grupos de sombras y las capas de tiles extra (no nativas).
- La sección **Autotiles** de la Paleta de tiles — Maker Studio usa su propio sistema de autotiles que no está atado al tileset de un mapa, así que **todos** los autotiles pintados necesitan el plugin en el juego (el tooltip de la insignia lo indica). También una pequeña insignia sobre el cuadro de búsqueda de tilesets mientras exploras un tileset distinto al propio del mapa (pintado entre tilesets).
- La cabecera del panel **Tile Properties**, y los formularios de comandos de evento que dependen del plugin (Change Map Settings cuando su tipo es **Fog**, color/opacidad de fog, la sección **Set Frame** de la ruta de movimiento). En espacios reducidos —como los campos Sheet Cols/Rows del selector de gráficos— la insignia aparece como un pequeño punto.

Si usas estas funciones en un juego que no tiene el plugin, el juego simplemente las ignora (o no están disponibles) en tiempo de ejecución — tus mapas siguen cargando bien en RPG Maker XP estándar.

Las insignias están activadas por defecto. Ocúltalas o muéstralas con **View → Show MS-Exclusive Indicators**; tu elección se recuerda entre sesiones.

## Barra de herramientas

La barra de herramientas está en la parte superior de la ventana y da acceso rápido a las acciones comunes:

De izquierda a derecha, los grupos de la barra son:

`Save · Run · Saves · Sim Map` | `Brush · Eraser · Fill · Rectangle · Eyedropper · Select · Pan` | `Zoom` | `Database · Scripts` | `Versions` | `Grid · Col · Dim` | `Theme`

- **Save, Run** — **Save** escribe el mapa actual (Shift+Click guarda todos los mapas abiertos); **Run** lanza el juego (en Linux, Shift+Click te deja elegir el prefijo Proton/Wine o, si está disponible, una build nativa de Linux). (Crear un mapa nuevo ahora está en la cabecera del panel Maps — ver el Árbol de mapas más abajo.)
- **Saves** — aparece tras el primer Run; abre la carpeta donde el juego guarda sus partidas. En Windows es la carpeta de guardado nativa; en macOS y Linux es la carpeta dentro del prefijo Wine/Proton en el que se ejecutó el juego, o — tras una ejecución con la build nativa de Linux — la propia carpeta de guardado de Linux del juego. Consulta [Ejecutar el juego](map-management.md#running-the-game).
- **Sim Map** — abre el [Simulador de juego](game-simulator.md) en el mapa actual con la entrada del jugador activada.
- **Tools** — las siete herramientas de dibujo (Brush, Eraser, Fill, Rectangle, Eyedropper, Select, Pan), mostradas como iconos. Pasa el ratón sobre cualquiera para ver su nombre y su atajo.
- **Herramienta Brush** — pasa el ratón para ver un popover con un deslizador de tamaño, un **conmutador rápido de pinceles** (tus presets de Custom Shape Brush guardados más Default/Custom) y un acceso **Brush Editor…**. Cuando hay un pincel personalizado activo, un indicador compacto junto a las herramientas muestra el nombre del pincel con una ✕ para limpiarlo. Consulta [Custom Shape Brush](tools.md#custom-shape-brush).
- **Zoom** — muestra el porcentaje de zoom actual; pasa el ratón para ver los controles de acercar/alejar.
- **Database / Scripts** — abren la ventana de [Database](database.md) y el [editor de Scripts](scripts.md). (También disponibles en el menú **Tools**.) Switches, Variables y Tilesets ya no tienen sus propios botones en la barra — ahora son pestañas **dentro de la Database** (donde aún puedes renombrar entradas en línea, añadir más ranuras y editar tilesets).
- **Versions** — muestra la [versión de mapa](map-versions.md) actual como una insignia (p. ej. `V2/3`) y abre el Version Manager. Relevante cuando un mapa tiene versiones extra.
- **Grid / Col / Dim** — botones conmutadores con icono + texto para Show Grid, Show Collision y Dim Inactive Layers.
- **Theme** — interruptor sol/luna. Pulgar a la izquierda = modo claro (☀ visible a la derecha); pulgar a la derecha = modo oscuro (☾ visible a la izquierda). Tu elección se recuerda entre sesiones. (Los temas y los colores individuales están en **Ayuda → Ajustes… → Apariencia**, más abajo.)
- **Refresh Layout** — disponible en View y luego Layout (restaura la disposición de paneles por defecto).

Si la ventana es demasiado estrecha para mostrar todos los grupos de la barra a la vez, los grupos que no caben se pliegan en un botón **"…" (More)** en el extremo derecho de la barra. Haz clic para revelar los grupos ocultos en un desplegable. Ensanchar la ventana los devuelve a la barra automáticamente.

## Árbol de mapas (panel izquierdo)

El Árbol de mapas muestra una vista jerárquica de todos los mapas de tu proyecto. La cabecera del panel tiene un botón **+** que crea un mapa nuevo en blanco. Puedes:

- Hacer doble clic en el nombre de un mapa para renombrarlo.
- Clic derecho para un menú contextual: Open, Rename, Change Tileset, Resize/Shift, Delete.
- Arrastrar y soltar mapas para reorganizar la jerarquía.
- Hacer clic en la flecha de un mapa con hijos para plegarlo. **Las carpetas plegadas siguen plegadas** la próxima vez que abras el proyecto, y el mapa que estabas editando se vuelve a abrir con él — consulta [Abrir mapas](map-management.md#abrir-mapas).

## Barra de pestañas

Cada mapa abierto tiene su propia pestaña en la parte superior del área del editor.

- Un punto indicador significa que el mapa tiene cambios sin guardar.
- El texto en cursiva significa que es una pestaña de vista previa que se cierra sola al abrir otro mapa.
- Haz doble clic en una pestaña de vista previa para hacerla permanente.
- Haz clic en el botón x o clic central en una pestaña para cerrarla.
- **Arrastra una pestaña para reordenarla.** Una línea marca dónde va a caer, y la pestaña se coloca en esa posición.
- Al volver a abrir un proyecto, **vuelven todos los mapas que tenías abiertos**, en el mismo orden de izquierda a derecha, y el mapa que estabas editando se vuelve el activo. (Abrir un archivo de mapa directamente —con doble clic desde el explorador de archivos— sigue abriendo solo ese mapa.) Esto se recuerda por proyecto y solo en este ordenador.

## Barra de estado (inferior)

La barra de estado muestra contexto útil de un vistazo: coordenadas del cursor (X, Y), el nombre del evento bajo el cursor, la herramienta actual, el tamaño del pincel, el nombre de la capa activa, el nivel de zoom y si hay historial de deshacer disponible.

En mapas muy grandes o pesados también puede mostrar **"⏸ Animations paused (performance)"**. Cuando hay muchos tiles visibles a la vez, el editor mantiene el desplazamiento fluido dibujando desde una imagen en caché — y pausa la animación de autotiles/fog cuando reconstruir esa caché tardaría más de 16ms (~60fps). Acerca el zoom (para que se vean menos tiles) y la animación se reanuda automáticamente. (Las animaciones también se pausan, sin el indicador, mientras hay un diálogo abierto o el simulador en marcha.)

## Paneles acoplables

Cada panel del editor se puede arrastrar, flotar como ventana aparte y reorganizar a tu gusto. Si alguna vez quieres empezar de cero, usa **View → Layout → Refresh Layout** para restaurar la disposición por defecto. (Para solo recargar el editor *conservando* tu disposición, usa **Help → Reset App** / `Ctrl+R`.)

- **Separar un panel**: clic derecho en una pestaña o en una zona vacía de la cabecera y elige **Detach to floating window**. El panel sale como una ventana flotante arrastrable y redimensionable dentro del editor.
- **Las ventanas flotantes se quedan en pantalla**: si una ventana flotante se arrastra o redimensiona más allá de los límites del editor, vuelve a encajar dentro al soltarla.
- **Reacoplar**: arrastra la pestaña de la ventana flotante de vuelta a una zona de acople, o cierra el panel.
- **Enfocar desde el menú**: **View → Panels** trae un panel al frente (o lo reabre flotando si lo cerraste) — nunca cierra paneles.

### Redimensionar diálogos

Todas las ventanas de diálogo — Event Editor, Database, Tileset Editor, los
selectores, todas — se pueden redimensionar arrastrando **cualquier borde o
esquina**, y mover arrastrando su barra de título. Hacer clic en la zona atenuada
de fuera cierra el diálogo, pero un clic que roza un borde cuenta como agarre de
redimensionado, no como cierre. **Esc** cierra solo el diálogo de encima, así que
cerrar un selector abierto sobre el Event Editor ya no cierra el editor de debajo.

### Campos numéricos

Todos los campos numéricos del editor — tamaños de mapa, valores de pincel, frames de animación,
ajustes del simulador — se pueden **dejar vacíos mientras escribes**. Selecciona el contenido,
bórralo, escribe el número que quieras y se aplica al salir del campo (o al pulsar Tab/Enter). Los
mínimos y máximos también se aplican en ese momento, así que escribir "160" en un campo cuyo mínimo
es 160 ya no te pelea desde el primer dígito. Un campo que se deja vacío cae al mínimo de ese campo.

### Paneles y disposiciones de mods

Los paneles añadidos por [mods](marketplace.md) mantienen su lugar en tu disposición. Si un mod está desactivado, desinstalado o recargándose, su hueco de panel se queda donde lo acoplaste y muestra un marcador de posición ("Panel provided by mod … — not loaded") hasta que el mod vuelva; cierra el marcador si no quieres conservar el hueco. Las configuraciones de disposición exportadas (**View → Layout → Export Configuration**) también registran qué mods aportaron qué paneles — importar una disposición que usa paneles de mods que no tienes instalados te avisa con la lista de mods que faltan y mantiene esos paneles como marcadores. Las configuraciones exportadas antiguas siguen importándose bien.

## Minimapa

Panel inferior derecho. Muestra una vista a escala de todo el mapa (todas las capas nativas + extendidas + sombras) con un rectángulo amarillo de viewport. Haz clic o arrastra para recentrar el lienzo principal.

- **Visualización de eventos**: cuando **View → Events** está activado, los eventos se dibujan en el minimapa con el gráfico de su página activa (personaje o tile). Los eventos sin gráfico en ninguna página se ocultan para que el minimapa quede limpio.

## Ajustes (Ayuda → Ajustes…)

Preferencias del editor, aparte de todo lo que se guarda en tu proyecto. Están repartidas en tres
pestañas: **Editor** (cómo se abre la ventana de Maker Studio), **Apariencia** (tema y colores) y
**Juego** (dónde se abre la ventana del juego).

Los cambios solo se conservan si pulsas **Guardar**. Si cierras el diálogo con cambios sin guardar
—Cancelar, la ×, Esc o un clic fuera— Maker Studio te pregunta antes y te ofrece **Descartar** o
**Guardar y cerrar**. Al descartar también se restauran el tema y el modo oscuro tal y como estaban,
así que probar un tema y cambiar de idea no cuesta nada.

### Pestaña Editor

**Tamaño de la ventana al arrancar** — déjalo en el valor por defecto (1400 × 900, centrada), recuerda
el tamaño y la posición de la última vez, ábrela siempre maximizada o en pantalla completa, o dale un
tamaño exacto.

**En qué pantalla** — en la que se lance Maker Studio (en la práctica, la pantalla donde está el
puntero), en la última en la que se cerró, o siempre en una concreta. Las pantallas se listan por
número y resolución, y se recuerdan por nombre: si esa no está conectada, la ventana se abre en la
que se lance en vez de aparecer en una pantalla que no existe.

Un tamaño concreto no puede bajar de **1280 × 720**, que es lo mínimo que mide la ventana.

Ambos se aplican la próxima vez que arranque Maker Studio.

### Pestaña Apariencia

**Tema** — **Por defecto** (el aspecto propio de Maker Studio) o cualquier tema añadido por un [mod](marketplace.md) instalado. La misma lista está en **Vista → Tema**; esta pestaña solo la pone al lado de los colores.

**Modo oscuro** — el mismo interruptor que el sol/luna de la barra de herramientas. Un tema que solo existe en un tono lo bloquea, y la pestaña te lo indica.

**Colores** — todos los colores que usa el editor, agrupados por lo que pintan: **Superficies** (fondos, paneles, bordes), **Texto**, **Acento**, **Estado** (peligro/aviso/éxito), **Lienzo del mapa**, **Comandos de evento** (el código de colores de la lista de comandos del editor de eventos) y **Editor de scripts** (resaltado de sintaxis Ruby).

- Haz clic en una muestra para elegir un color, o escribe un valor en el campo de al lado: acepta cualquier cosa que entienda CSS, incluido `rgba(...)` si lo quieres semitransparente. (El selector de la muestra no tiene control de transparencia, y por eso está el campo de texto.)
- La flecha circular al final de una fila devuelve ese color al del tema; **Restablecer N cambios**, arriba, los devuelve todos. El campo de filtro acorta la lista cuando ya sabes más o menos qué buscas.
- **Los colores se guardan por tema y por modo claro/oscuro.** Retocar el tema oscuro no toca el claro, y cada tema de mod conserva los suyos: cambia de tema y vuelve, y tus colores siguen ahí. La cabecera sobre la lista te dice qué combinación estás editando.
- Tus colores se guardan en este ordenador, no en el proyecto, así que te acompañan entre proyectos y nunca acaban dentro de tu juego.

### Pestaña Juego

**En qué pantalla se abre el juego** (solo Windows) — **La misma que el editor** (por defecto) abre
el juego en la pantalla en la que esté la ventana de Maker Studio al pulsar Run. Por su cuenta, RPG
Maker centra siempre el juego en la pantalla *principal*, trabajes donde trabajes: justo lo que esta
opción viene a arreglar. Elige **Siempre en esta pantalla** para fijarlo a una pantalla concreta
independientemente de dónde esté el editor. A diferencia de las dos opciones anteriores, esta se
aplica en tu **próximo Run Game**, no al siguiente arranque. Si la pantalla que elegiste no está
conectada, el juego se queda donde se haya abierto.

RPG Maker devuelve su propia ventana a la pantalla principal mientras el juego arranca, así que Maker
Studio la vuelve a colocar durante los primeros ~20 segundos. En un proyecto que tarde en cargar
puede que veas la ventana saltar de pantalla una o dos veces antes de asentarse: son los dos
peleándose, y gana Maker Studio mientras el juego termine de arrancar dentro de ese margen.

En macOS y en Linux la opción se muestra deshabilitada, y lo explica: ahí el juego se ejecuta a
través de Wine o Proton, que es quien controla su ventana, así que el editor no puede colocarla.
