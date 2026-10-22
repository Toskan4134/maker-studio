# Guía de la interfaz

## Barra de menús

Cuando hay un proyecto abierto, el botón independiente **Git** abre la [integración con Git](git.md) para revisar cambios, explorar el grafo de commits, comparar archivos y gestionar ramas.

Cada elemento de menú muestra ahora un pequeño icono junto a su etiqueta para localizar comandos más rápido. Los menús, de izquierda a derecha, son **File, Edit, View, Map, Tools, Mods, Help**.

- **File**: Open Project, **Open Recent** (proyectos abiertos recientemente, más Clear Recent Projects), **Cerrar proyecto** (vuelve a la página de bienvenida), **Abrir carpeta del juego** (abre la carpeta de tu proyecto en el Explorador de Windows / Finder / tu gestor de archivos — práctico para meter gráficos o comprobar qué ha escrito el editor), **Abrir carpeta de partidas guardadas** (abre la carpeta donde el juego escribe sus archivos de guardado — ver [Gestión de mapas](map-management.md#abrir-la-carpeta-de-guardados)), Save, Save All, **Crear archivo de proyecto…** (crea un archivo `.mkst`; los archivos `.makerstudio` anteriores siguen siendo compatibles), Run Game, **Clear Proton Preference** (solo Linux — olvida tu elección recordada de lanzamiento Proton/Wine para que el diálogo de selección vuelva a aparecer la próxima vez que pulses Run; solo se muestra cuando hay una elección así que olvidar)
- **Edit**: Undo, Redo, Cut, Copy, Paste, **Advanced Clipboard** (Copy All Layers, Cut All Layers, Paste in Selected Layers, conmutador **Cross-Project Clipboard** — ver abajo), Select All, Deselect, **Shadows** (Generate from Selection, Delete All Shadows)
  - El **Cross-Project Clipboard** está desactivado por defecto. Cuando está marcado, copiar tiles, eventos o comandos de evento también los coloca en el portapapeles del sistema para que una **segunda ventana de Maker Studio abierta** pueda pegarlos. Actívalo en *cada* ventana entre las que quieras compartir. (Borrar una selección de tiles sigue funcionando con la tecla **Supr**; solo se reemplazó la antigua entrada de menú por este conmutador.)
- **View**: submenú **Panels** (Maps, Tile Palette, Layers, Tile Properties, Tile Info, Events, Minimap — al hacer clic en una entrada se **enfoca** ese panel, trayéndolo al frente o reabriéndolo como ventana flotante si estaba cerrado; nunca cierra un panel, y la marca de verificación sigue indicando qué paneles están abiertos), Show Grid, Show Collision, Show Events, **Mostrar casilla de los eventos** (ver abajo), **Crear eventos con doble clic** (ver abajo), Dim Inactive Layers, **Show MS-Exclusive Indicators** (ver abajo), Zoom In/Out/100%, Dark Mode, submenú **Language** (ver abajo), submenú **Layout** (Refresh Layout, Import/Export Configuration)
  - **Crear eventos con doble clic** está activado por defecto, igual que en RPG Maker: con el Brush en la capa de eventos, un clic en un tile vacío lo selecciona y el **doble clic** crea ahí el evento. Desactívalo si prefieres que un solo clic cree el evento directamente.
  - **Mostrar casilla de los eventos** está desactivado por defecto. Los eventos sin gráfico siempre muestran un recuadro en su tile; con esto activado, los eventos que **sí** tienen gráfico también se marcan — un borde fino alrededor de su casilla más un cuadradito en la esquina —, así se ve exactamente en qué tile está cada evento sin tapar su sprite. Se deshabilita mientras Show Events esté apagado. Tu elección se recuerda entre sesiones.
- **Map**: New Map, **Duplicate Map**, **Map Versions…**, Resize / Shift Map, Change Tileset, **Change Battleback…**, **Map Audio…**, Import Map from JSON, submenú **Export Map** (Export as JSON / PNG / GIF / WebP)
- **Tools**: selección de herramienta (Brush/Eraser/Borrador mágico/Fill/Rectangle/Eyedropper/Select/Varita/Pan), Rotate CW/CCW, Flip Horizontal/Vertical, **Brush Editor…**, Database, Scripts
- **Mods**: Mod Manager (+ cualquier elemento de menú y panel aportado por mods)
- **Help**: **Ajustes...** (ver [Ajustes](#ajustes-ayuda--ajustes)), **Documentation** (abre esta documentación en línea en tu navegador), Keyboard Shortcuts, **Reset App** (reinicia Maker Studio en la página de bienvenida — se conserva la disposición de paneles; `Ctrl+R`), **Volver a mostrar los avisos de la aplicación** (reactivar todos los avisos o elegir por separado tilesets grandes, integración del juego o Proton), Check for Updates (muestra la versión que tienes junto a la última publicada), Stats, About Maker Studio, **Alternar diagnóstico de renderizado** (superposición temporal del mapa con tiempos de renderizado; vuelve a pulsarlo para cerrarla), Toggle DevTools
  - **Reactivar todos los avisos de la aplicación** restablece las tres categorías. El submenú también ofrece **Reactivar avisos de tilesets grandes**, **Reactivar avisos de integración del juego** y **Volver a preguntar la elección de Proton** por separado; las tres acciones se aplican a todos los proyectos. **Mods → Show Dependency Warnings Again** sigue siendo independiente y solo controla los avisos de dependencias de mods. **File → Clear Proton Preference** continúa borrando la elección guardada del proyecto abierto.

## Idioma

La interfaz está disponible en **English** y **Español**, y los [mods](marketplace.md) instalados pueden añadir más idiomas — cualquier idioma que aporte un mod aparece automáticamente en el mismo menú (si el mod que aporta tu idioma elegido está desactivado, el editor vuelve a su idioma por defecto y cambia de nuevo cuando el mod regresa). Cambia en **View → Language** — el cambio se aplica al instante y se recuerda entre sesiones. En el primer arranque el editor elige el idioma de tu sistema (los sistemas en español empiezan en Español; el resto usa English por defecto). Toda la interfaz está traducida — menús, paneles, diálogos, el editor de eventos y sus formularios de comandos, el simulador y las notificaciones. Algunos términos técnicos se mantienen en inglés a propósito (por ejemplo *tile*, *tileset*, *autotile*, *script*, *mod*, y los tipos de audio como *BGM*/*SE*) para que coincidan con RPG Maker y la API de modding.

## Indicadores de funciones exclusivas de MS

Algunas funciones del editor van más allá de lo que admite RPG Maker XP estándar — solo funcionan en el juego en ejecución si tu proyecto tiene instalado el **plugin MakerStudio** (la integración que viene con el editor). Una pequeña insignia **MS** marca esas funciones por toda la interfaz para que siempre sepas cuáles dependen del plugin. Pasa el ratón sobre una insignia para recordar el motivo — la mayoría dice *"Maker Studio exclusive — requires the MakerStudio plugin in-game"*, mientras que algunas explican su razón concreta.

Verás la insignia, por ejemplo, en:

- Elementos de menú como **Edit → Shadows** y **Map → Map Versions…** (también en las entradas correspondientes del menú contextual del Árbol de mapas).
- **Map → Change Battleback…** — el battleback se guarda en el mapa (no en su tileset), y el plugin es lo que lo aplica en el juego, así que tanto este elemento como la entrada "(this version)" del submenú de versión llevan la insignia. (Los panoramas ya no se cambian desde un menú — se editan como el grupo **Panorama Layers** en el panel de capas; consulta la [Guía de capas](layers.md#fog-panorama-and-custom-layer-groups).)
- Las filas del panel de capas para los grupos de capa de fog/panorama (y cualquier grupo añadido por mods), los grupos de sombras y las capas de tiles extra (no nativas).
- La sección **Autotiles** de la Paleta de tiles — Maker Studio usa su propio sistema de autotiles que no está atado al tileset de un mapa, así que **todos** los autotiles pintados necesitan el plugin en el juego (el tooltip de la insignia lo indica). También una pequeña insignia sobre el cuadro de búsqueda de tilesets mientras exploras un tileset distinto al propio del mapa (pintado entre tilesets).
- La cabecera del panel **Tile Properties**, y los formularios de comandos de evento que dependen del plugin (Change Map Settings cuando su tipo es **Fog** o **Panorama**, color/opacidad de fog, la sección **Set Frame** de la ruta de movimiento). En espacios reducidos —como los campos Sheet Cols/Rows del selector de gráficos— la insignia aparece como un pequeño punto.

Si usas estas funciones en un juego que no tiene el plugin, el juego simplemente las ignora (o no están disponibles) en tiempo de ejecución — tus mapas siguen cargando bien en RPG Maker XP estándar.

Las insignias están activadas por defecto. Ocúltalas o muéstralas con **View → Show MS-Exclusive Indicators**; tu elección se recuerda entre sesiones.

## Barra de herramientas

La barra de herramientas está en la parte superior de la ventana y da acceso rápido a las acciones comunes:

De izquierda a derecha, los grupos de la barra son:

`Save · Run · Saves · Sim Map` | `Brush · Eraser/Borrador mágico · Fill · Rectangle · Eyedropper · Select/Wand · Pan` | `opciones de herramienta` | `Zoom` | `Database · Scripts` | `Versions` | `Grid · Col · Dim` | `Theme`

- **Save, Run** — **Save** escribe el mapa actual (Shift+Click guarda todos los mapas abiertos); **Run** lanza el juego (en Linux, Shift+Click te deja elegir el prefijo Proton/Wine o, si está disponible, una build nativa de Linux). (Crear un mapa nuevo ahora está en la cabecera del panel Maps — ver el Árbol de mapas más abajo.)
- **Saves** — aparece tras el primer Run; abre la carpeta donde el juego guarda sus partidas. En Windows es la carpeta de guardado nativa; en macOS y Linux es la carpeta dentro del prefijo Wine/Proton en el que se ejecutó el juego, o — tras una ejecución con la build nativa de Linux — la propia carpeta de guardado de Linux del juego. Consulta [Ejecutar el juego](map-management.md#running-the-game).
- **Sim Map** — abre el [Simulador de juego](game-simulator.md) en el mapa actual con la entrada del jugador activada.
- **Tools** — las herramientas de dibujo aparecen en botones del mismo ancho, con el icono centrado. Select/Wand y Eraser/Borrador mágico comparten un botón que conserva el icono de la herramienta elegida; un chevrón enmarcado junto al icono indica que hay más herramientas. Al pasar el cursor se abre un menú con el icono, nombre y atajo de cada opción. Brush también muestra un chevrón enmarcado para indicar sus opciones. El tamaño y las demás opciones aparecen junto a la herramienta activa. **Continuo** solo aparece con Fill, Wand y Borrador mágico.
- **Herramienta Brush** — su popover tiene un **conmutador rápido de pinceles** (presets guardados de Custom Shape Brush más Default/Custom) y un acceso **Brush Editor…**. El control de tamaño de la herramienta activa aparece junto a las herramientas. Cuando hay un pincel personalizado activo, un indicador compacto junto a las herramientas muestra el nombre del pincel con una ✕ para limpiarlo. Consulta [Custom Shape Brush](tools.md#custom-shape-brush).
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
- Usa **Ctrl+clic** para alternar filas del mapa o **Shift+clic** para seleccionar un rango visible. Arrastra una fila seleccionada para mover juntas todas las raíces seleccionadas y sus descendientes, conservando el orden.
- Borra los mapas seleccionados con Delete o desde el menú contextual. Si tienen descendientes, elige colocarlos en las posiciones de los mapas borrados o eliminar también los subárboles. La confirmación avisa de mapas abiertos con cambios sin guardar y se hacen copias de seguridad de los archivos borrados.
- Hacer clic en la flecha de un mapa con hijos para plegarlo. **Las carpetas plegadas siguen plegadas** la próxima vez que abras el proyecto, y el mapa que estabas editando se vuelve a abrir con él — consulta [Abrir mapas](map-management.md#abrir-mapas).

## Barra de pestañas

Cada mapa abierto tiene su propia pestaña en la parte superior del área del editor.

- Un punto indicador significa que el mapa tiene cambios sin guardar.
- El texto en cursiva significa que es una pestaña de vista previa que se cierra sola al abrir otro mapa.
- Haz doble clic en una pestaña de vista previa para hacerla permanente.
- Haz clic derecho en una pestaña para fijarla o desfijarla, o para usar las opciones de cierre. Las pestañas fijadas muestran una chincheta y se colocan al principio; puedes arrastrarlas para reordenar dentro del grupo fijado o normal. Fijar una vista previa la convierte en permanente.
- El menú contextual permite cerrar la pestaña pulsada, las demás, las pestañas a su derecha, las guardadas o todas las normales. Los cierres en grupo conservan las fijadas; puedes cerrar una fijada desde su propia pestaña.
- Haz clic en el botón x o clic central en una pestaña para cerrarla.
- **Arrastra una pestaña para reordenarla.** Una línea marca dónde va a caer, y la pestaña se coloca en esa posición.
- Al volver a abrir un proyecto, **vuelven todos los mapas que tenías abiertos**, incluidas las pestañas fijadas, y el mapa que estabas editando se vuelve el activo. Una barra de pestañas que dejaste vacía sigue vacía. (Abrir un archivo de mapa directamente —con doble clic desde el explorador de archivos— sigue abriendo solo ese mapa.) Esto se recuerda por proyecto y solo en este ordenador.

## Barra de estado (inferior)

La barra de estado muestra contexto útil de un vistazo: coordenadas del cursor (X, Y), el nombre del evento bajo el cursor, la herramienta actual, el tamaño del pincel, el nombre de la capa activa, el nivel de zoom y si hay historial de deshacer disponible.

En mapas muy grandes o con muchas animaciones, los autotiles pueden bajar a 2 o 1 actualizaciones por segundo en zoom intermedio para mantener la respuesta del editor. Se mantienen a 4 actualizaciones por segundo con un zoom del 10% o menos y a partir del 200%. Si dibujar tiles directamente o reconstruir la imagen en caché tarda más de 20ms, la animación se pausa hasta que un repintado posterior tarde 10ms o menos; entonces la barra de estado muestra **"⏸ Animations paused (performance)"**. Se puede seguir desplazando, pintando y cambiando el zoom. (Las animaciones también se pausan, sin el indicador, mientras hay un diálogo abierto o el simulador en marcha.)

Al dibujar un mapa cuyo tileset supera los 16.064 píxeles de alto, aparece un diálogo con su nombre y altura. Pulsa **Ver tileset** para abrir ese registro en **Database → Tilesets**. **No volver a mostrar este aviso** silencia estos diálogos en todos los proyectos hasta que los reactives en **Help → Volver a mostrar los avisos de la aplicación → Reactivar avisos de tilesets grandes**. Si varios mapas generan el aviso, los diálogos aparecen uno por uno.

Elige **Help → Alternar diagnóstico de renderizado** para ver la frecuencia de repintado, las dimensiones del atlas y los tiempos de renderizado de JavaScript. Esos tiempos no incluyen el trabajo gráfico/compositor de macOS.

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

Preferencias del editor, aparte de todo lo que se guarda en tu proyecto. Están repartidas en cuatro
pestañas: **Editor** (cómo se abre la ventana de Maker Studio), **Apariencia** (tema y colores),
**Juego** (dónde se abre la ventana del juego) y **Supporter** (tu licencia y los extras que desbloquea).

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

**Mostrar mi actividad en Discord** — activado por defecto. Mientras esté activado y la aplicación de
Discord está abierta, tu estado de Discord muestra el proyecto y el mapa que tengas abiertos. Con una
[licencia de Supporter](#pestaña-supporter) lleva además una pequeña insignia. La actividad también
está disponible durante el Plan gratuito. Sustituye al mod de ejemplo *Discord Rich Presence*; si lo
tenías instalado, desactívalo, porque los dos se sobrescriben entre sí.

### Pestaña Apariencia

**Tema** — **Por defecto** (el aspecto propio de Maker Studio) o cualquier tema añadido por un [mod](marketplace.md) instalado. La misma lista está en **Vista → Tema**; esta pestaña solo la pone al lado de los colores.

**Modo oscuro** — el mismo interruptor que el sol/luna de la barra de herramientas. Un tema que solo existe en un tono lo bloquea, y la pestaña te lo indica.

**Colores** — todos los colores que usa el editor, agrupados por lo que pintan: **Superficies** (fondos, paneles, bordes), **Texto**, **Acento**, **Estado** (peligro/aviso/éxito), **Lienzo del mapa**, **Comandos de evento** (el código de colores de la lista de comandos del editor de eventos), **Editor de scripts** (resaltado de sintaxis Ruby) y **Comandos individuales** (una fila por comando de evento).

- **Paleta RPG Maker XP**, el botón bajo **Comandos individuales**, pinta todos los comandos con la tinta clásica de RPG Maker XP: condiciones en azul marino, variables en verde azulado, comentarios en verde, comandos de batalla en granate. Viste el modo claro *y* el oscuro de una sola pulsación (los mismos colores, aclarados para que se lean sobre fondo oscuro), y todo lo que escribe son colores normales que luego puedes cambiar o restablecer fila a fila.
- **Comandos de evento** da un color por *tipo* de comando (todos los condicionales, todos los de audio…), y **Comandos individuales**, justo debajo, tiene una fila por cada comando concreto: Mostrar texto, Condiciones, Reproducir SE y los demás. Una fila que no toques muestra el color que hereda de su categoría, así que cambiar la categoría los sigue moviendo todos; cambia una fila y ese comando se sale del grupo él solo.
- Haz clic en una muestra para elegir un color, o escribe un valor en el campo de al lado: acepta cualquier cosa que entienda CSS, incluido `rgba(...)` si lo quieres semitransparente. (El selector de la muestra no tiene control de transparencia, y por eso está el campo de texto.)
- La flecha circular al final de una fila devuelve ese color al del tema; **Restablecer N cambios**, arriba, los devuelve todos. El campo de filtro acorta la lista cuando ya sabes más o menos qué buscas.
- **Los colores se guardan por tema y por modo claro/oscuro.** Retocar el tema oscuro no toca el claro, y cada tema de mod conserva los suyos: cambia de tema y vuelve, y tus colores siguen ahí. La cabecera sobre la lista te dice qué combinación estás editando.
- Tus colores se guardan en este ordenador, no en el proyecto, así que te acompañan entre proyectos y nunca acaban dentro de tu juego.

### Pestaña Juego

**Nombres del juego** — las dos únicas opciones de aquí que pertenecen al **proyecto** y no al
editor, así que cambian con el proyecto que tengas abierto y *Restaurar valores por defecto* no las
toca.

- **Nombre de la carpeta de partidas guardadas** — el título del juego en `Game.ini`. RPG Maker crea
  con él la carpeta de partidas guardadas (`%AppData%\<nombre>` en Windows), que es la que abre el
  botón **Partidas** de la barra de herramientas. Al cambiarlo, las partidas pasan a guardarse en
  otro sitio. No puede estar vacío ni contener `\ / : * ? " < > |`, porque tiene que valer como
  nombre de carpeta.
- **Título de la ventana** — el `windowTitle` de `mkxp.json`, el título de la ventana del juego. Es
  puramente estético: no afecta a las partidas guardadas y, a diferencia del nombre anterior, admite
  cualquier cosa, acentos incluidos. El campo aparece deshabilitado con *"(este proyecto no tiene
  mkxp.json)"* cuando el proyecto no incluye ese archivo.

Ambos se escriben directamente en `Game.ini` / `mkxp.json` al pulsar **Save**, dejando el resto de
esos archivos — comentarios incluidos — tal cual estaban. Se aplican en tu próximo Run.

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

### Pestaña Supporter

Funciones como conectar un cliente de IA mediante MCP requieren una licencia. Sin ella, la pestaña
muestra el cuadro de activación: pega tu **Clave de licencia** y pulsa **Activar**, o usa **Probar
gratis 7 días** / **Comprar licencia de por vida**. Debajo, **Qué obtienes como supporter** enumera
todas las funciones con su descripción y estado de acceso. El Plan gratuito incluye MCP, icono de
ventana, barra de título coloreada, personalización de la pantalla de inicio y proyectos favoritos.

Durante la prueba, la parte superior muestra **Plan gratuito**, los días que quedan y la fecha de fin.
Una licencia de pago muestra la insignia **Supporter**, el plan con su fecha de caducidad (o **De por vida**)
al lado y tu correo. **Desactivar este equipo** libera la
activación para usar la clave en otro ordenador; el número de equipos por clave es limitado.

La activación necesita conexión a Internet una vez. Después el pase se renueva solo en segundo plano,
y las funciones incluidas en tu licencia siguen funcionando sin conexión hasta una semana entre
renovaciones. Si no puede renovarse a tiempo, conéctate a Internet y vuelve a abrir esta pestaña.

Debajo del estado, una lista vertical compacta mantiene visibles todas las funciones, incluidas las que
no incluye tu licencia. Selecciona una para ver su explicación y sus ajustes en el panel contiguo; la
lista indica si está **Incluida en esta licencia**, **No tienes acceso a esta función con esta licencia**
o **No disponible temporalmente**. Los estados incluidos aparecen en verde, la falta de acceso en rojo,
el acceso parcial en ámbar y los estados no disponibles quedan atenuados. Las flechas arriba y abajo
cambian de función. Discord muestra por
separado el acceso al rol del servidor y a la insignia Supporter de Rich Presence. Las opciones para
iniciar sesión y gestionar el rol solo aparecen si la licencia incluye esa función. El título y las
insignias Supporter comparten una entrada con sus estados de acceso por separado; el orden también se
usa en la lista de beneficios sin licencia. El panel de cada función mantiene el mismo encabezado,
descripción y tarjeta de acceso antes de mostrar sus controles; las funciones con varias prestaciones
también muestran el estado de cada una. La lista y el panel se desplazan por separado cuando su contenido
supera el alto disponible.

- **Discord** — añade el rol de Supporter en el servidor de Discord de Maker Studio; los supporters
  tienen prioridad al pedir ayuda allí. **Vincular cuenta de Discord** abre el navegador para que
  inicies sesión solo si tu licencia incluye el rol; si no, la pestaña muestra su descripción y estado de acceso.
  Una vez vinculada, el panel muestra tu nombre de Discord y si estás
  **En el servidor** (o **Unirse al servidor**) y tienes el **Rol de Supporter** (o **Obtener el
  rol**); el botón de actualizar vuelve a comprobarlo. Solo se puede vincular una cuenta de Discord
  por licencia: para usar otra, pulsa antes **Desvincular** (también retira el rol). El rol se retira
  además si la licencia se revoca o caduca.
- **Pantalla de inicio** — desmarca **Usar la pantalla de inicio personalizada** para volver a la pantalla de inicio normal. **Elegir fondo…** pone una imagen detrás de la pantalla de inicio (la de
  **Abrir carpeta del juego** y los proyectos recientes); **Oscurecimiento del fondo** la oscurece para
  que el texto se siga leyendo y **Desenfoque** la suaviza. **Quitar** la elimina. La vista previa de
  encima de los botones muestra el resultado mientras mueves los controles, o *Sin fondo* si no hay
  ninguno.
- **Icono de ventana** — elige una de las variantes (Maker Studio, con los colores de acento de tu
  tema, y después Oro, Esmeralda, Zafiro, Rubí, Amatista y Escarcha), o **Elegir imagen…** para
  usar cualquier imagen tuya; **Restablecer** vuelve al icono normal. Cambia a la vez el icono de la ventana y el de la barra de tareas, y la pantalla de inicio
  también lo muestra.
- **Barra de título coloreada** — **Colorear la barra de título con el tema** (Windows 11) hace que la
  barra de título de la ventana tome el color de los paneles de tu tema y lo siga al cambiar de tema o
  de modo claro/oscuro.
- **Título e insignias Supporter** — añade Supporter al título de la ventana de Maker Studio y a la
  pantalla de inicio, y muestra una insignia en la pantalla de inicio y en el cuadro Acerca de.
- **Proyectos favoritos** — marca proyectos en la pantalla de inicio con una estrella, arrástralos
  desde el tirador de seis puntos para ordenarlos y ábrelos desde la barra de tareas o Inicio de
  Windows, el menú de aplicaciones de Linux o el Dock de macOS. Está incluido tanto en Free Tier como
  en Supporter.
- **Servidor MCP** — funciona con cualquier aplicación de IA compatible con MCP. El panel muestra el
  **Proyecto actual** (o **No hay un proyecto abierto**) junto a **Copiar configuración MCP**; el botón
  se activa al abrir un proyecto. Después, pega la configuración en los ajustes MCP de tu aplicación de
  IA y reiníciala. Mientras Maker Studio tenga el proyecto abierto, los cambios aparecen al instante;
  si no, se escriben en los archivos del proyecto.
- **Acceso anticipado** — actualmente no está disponible. La pestaña muestra **No disponible
  temporalmente**; las preferencias guardadas no seleccionan versiones anticipadas y las actualizaciones
  siguen por el canal estable.

El Plan gratuito permite personalizar la pantalla de inicio y, cuando hay proyectos, usar el panel
**Continuar**, **Recientes** y **Más usados**. La función **Proyectos favoritos** está incluida tanto
en Free Tier como en Supporter: marca proyectos, arrástralos desde el tirador de seis puntos para
ordenarlos y ábrelos desde la Jump List de Windows (clic derecho en el icono de Maker Studio de la
barra de tareas o su entrada en Inicio), las acciones de la aplicación en Linux o el menú del Dock de
macOS. En Windows, cada
favorito usa el icono del launcher del proyecto si está disponible. Activa **Mostrar elementos
abiertos recientemente en Inicio, Jump Lists y el Explorador de archivos** en **Configuración →
Personalización → Inicio** para que aparezcan los favoritos. Las funciones de Supporter añaden el
título **Maker Studio Supporter** y sus insignias en la pantalla de inicio, **Acerca de** y el estado
de Discord.
