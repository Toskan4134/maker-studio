# Editor de eventos

## Ver eventos

Activa los marcadores de evento desde el botón **Events** de la barra de herramientas (o **View → Show Events**). Los eventos aparecen como marcadores de color en el lienzo. Cuando pasas el cursor sobre un evento, la barra de estado de abajo muestra el nombre del evento. (Pulsar **V** selecciona la *capa* de eventos para editar — no alterna la visibilidad de los marcadores.)

## Crear eventos

- Haz clic en el botón + del panel Events.
- O, con la herramienta **Paint (Brush)** en la capa de eventos, **haz clic en una celda vacía** — se crea ahí un evento nuevo con ajustes por defecto y queda seleccionado. Haz doble clic en él (o en cualquier evento) para abrir el editor.

Una vista previa de una celda sigue al cursor mostrando dónde caerá el evento.

## Herramientas en la capa de eventos

Con la **capa de eventos** activa, solo cuatro herramientas hacen algo; el resto aparece atenuado en la barra:

- **Paint (Brush)** — **haz clic en una celda vacía para crear un evento**; haz clic en un evento existente para seleccionarlo, luego arrastra para moverlo.
- **Erase** — haz clic en un evento para borrarlo, o **arrastra por el mapa para borrar todos los eventos por los que pases** (eliminados juntos en un solo paso de deshacer).
- **Select** — selección de caja de eventos (ver abajo).
- **Pan** — mueve la vista.

Hacer doble clic en un evento abre el editor; el doble clic **no** crea eventos (usa el Brush). **Fill**, **Rectangle** y **Eyedropper** están desactivados aquí — colocas un evento por celda, no tiles. Cambiar a la capa de eventos mientras una de ellas está activa vuelve al Brush automáticamente. El **tamaño de pincel** no tiene efecto en esta capa, y la vista previa del cursor muestra un **solo tile** (el primero seleccionado), nunca un grupo multi-tile — creas un evento a la vez. El evento creado usa ajustes por defecto independientemente del tile previsualizado.

## Seleccionar y mover eventos

Elige la herramienta **Select**, luego en la capa de eventos:

- **Arrastra una caja** para seleccionar cada evento dentro de ella.
- **Ctrl+arrastrar** añade eventos a la selección; **Shift+arrastrar** los quita.
- **Arrastra** un evento seleccionado para **mover toda la selección** junta (un paso de deshacer). Los movimientos que saldrían del mapa o caerían sobre otro evento se bloquean con un aviso.
- **Supr** quita todos los eventos seleccionados a la vez.
- **Ctrl+D** (o **Esc**) deselecciona.

## Copiar eventos

Con la **capa de eventos** activa, puedes duplicar eventos enteros (todas las páginas y ajustes) en el mapa:

- **Clic derecho** en un evento para **Cut**, **Copy** y **Paste** (pega en la celda en la que hiciste clic).
- O usa **Ctrl+C** (copiar) y **Ctrl+X** (cortar) sobre el evento seleccionado, luego **Ctrl+V** para pegar — sin necesidad del menú.

**Pegar con Ctrl+V** muestra una *vista previa*: un fantasma del evento copiado sigue a tu cursor. **Haz clic** donde quieras soltar la copia; pulsa **Escape** para cancelar. Cortar copia el evento y luego lo quita. El evento pegado conserva cada página, condición, gráfico y comando del original; solo cambian su ID y su posición.

> **Un evento por tile.** Dos eventos no pueden compartir una celda — el juego trata los eventos solapados como un único ocupante. Pegar sobre un tile que ya tiene un evento, o arrastrar un evento sobre otro, se bloquea con un aviso *"Tile already has an event"*. Elige un tile vacío (o borra/mueve primero el evento existente).

## Diálogo del editor de eventos

Haz doble clic en un evento existente (o selecciónalo y haz clic en Edit) para abrir el editor de eventos.

La ventana del diálogo se puede redimensionar — arrastra su esquina inferior derecha para agrandarla, lo que ayuda cuando un evento tiene muchas páginas o una lista de comandos larga.

### General

- **Name**: el nombre visible del evento.
- **Position**: coordenadas X e Y, ambas editables.

### Páginas

Los eventos pueden tener varias páginas, cada una con sus propias condiciones, gráfico y lista de comandos.

- Haz clic en + para añadir una página.
- Haz clic en x para quitar una página. Siempre se requiere al menos una página.

### Condiciones

Controlan cuándo se activa una página:

- **Switch 1 / Switch 2**: requieren que switches concretos estén ON.
- **Variable**: compara una variable de juego con un valor.
- **Self Switch**: comprueba un self switch (A a Z — A–D son el estándar de RPG Maker XP; E–Z funcionan en tiempo de ejecución en Pokémon Essentials).

### Gráfico

Define la apariencia visual del evento:

- Gráfico de personaje o gráfico de tile.
- **Row** y **Col** — qué celda de la hoja mostrar. **Col** es el frame horizontal (1…número de columnas). **Row** es el frame vertical (1…número de filas): las filas 1–4 son las direcciones estándar (**1 – Abajo, 2 – Izquierda, 3 – Derecha, 4 – Arriba**) y cualquier fila más allá son números normales, así que un sprite puede empezar en *cualquier* fila de una hoja alta.
- **Sheet Cols / Sheet Rows** — el número de columnas y filas en la cuadrícula de la hoja de personaje (1 o más cada uno, sin límite superior; por defecto 4). Las hojas de personaje estándar de RPG Maker XP son 4x4 (4 direcciones, 4 frames de animación). Cámbialos al usar disposiciones no estándar: un icono de un solo frame 1x1, una hoja 3x2, una hoja extendida 8x8, una tira larga de efecto, etc. Los desplegables Col y Row se adaptan a la cuadrícula automáticamente.
- Opacidad y modo de mezcla.

La vista previa funciona como el mapa: **Ctrl+rueda** para hacer zoom hacia el cursor, **rueda / Shift+rueda** para desplazar arriba-abajo / izquierda-derecha, y **arrastrar con botón central** o **Espacio+arrastrar** para desplazar (la imagen siempre queda a la vista). Haz clic en una celda para elegir su Row/Col; el botón **Fit** restablece la vista. Útil para alinear celdas en hojas grandes o densas.

### Movimiento autónomo

- **Type**: Fixed, Random, Approach o ruta Custom.
- Deslizadores de **Speed** y **Frequency** para controlar el comportamiento de movimiento.

### Options

Activa banderas individuales: Walk Animation, Step Animation, Direction Fix, Through (atravesar paredes) y Always on Top.

### Trigger

Elige qué activa el evento: Action Button, Player Touch, Event Touch, Autorun o Parallel Process.

## Lista de comandos

La lista de comandos es donde construyes la lógica del evento. Puedes añadir, editar, borrar y reordenar comandos.

### Añadir comandos

Haz clic en Insert (o pulsa Insert / Enter) para abrir el Command Picker. El selector ordena los comandos en varias categorías con nombre específicas, cada una con una descripción de una línea bajo la pestaña activa:

- **Mensajes** — mostrar texto, opciones y demás comandos de mensaje.
- **Lógica** — condiciones, switches, variables, bucles, etiquetas y control de flujo.
- **Grupo y objetos** — oro, items, armas, armaduras y miembros del party.
- **Movimiento** — trasladar al jugador, fijar/desplazar y rutas de movimiento.
- **Pantalla e imágenes** — tonos de pantalla, destellos, temblores, clima e imágenes.
- **Audio** — música de fondo, efectos de sonido y demás audio.
- **Héroes** — stats, habilidades, equipo, nombre, clase y gráficos de actor.
- **Combate** — procesamiento de batalla, tienda y comandos de enemigo.
- **Sistema** — windowskin, acceso a menú/guardado/encuentros, scripts y ajustes de sistema.

Un cuadro de búsqueda en la parte superior filtra entre todas las categorías. La lista de comandos mantiene una **altura fija** —la mayor que necesita cualquier categoría—, así que el diálogo ya no crece ni se encoge al cambiar de pestaña; una pestaña con más comandos (como Favoritos) se desplaza arriba y abajo dentro de esa área fija. Si tienes suficientes categorías o mods como para que no quepan todas las pestañas, aparecen botones de flecha en los extremos de la barra para desplazarte entre ellas — también puedes desplazarla con la rueda del ratón, y la pestaña activa siempre se mantiene a la vista.

El selector **recuerda la última pestaña en la que estuviste**, así que si estabas mirando Combate (o una pestaña de mod), ahí es donde se abre la próxima vez.

### Favoritos

Haz clic en la estrella junto a cualquier comando para añadirlo a tu pestaña **Favoritos**, que aparece antes de las pestañas de categoría en cuanto tienes al menos uno. Para reordenarlos, abre la pestaña Favoritos y haz clic en el **lápiz** de la franja de descripción para entrar en modo de reordenación: arrastra un comando y los demás se apartan para mostrar dónde va a caer; suéltalo y haz clic en la marca de verificación para terminar. Mientras la reordenación está activa, hacer clic en un comando lo mueve en vez de insertarlo; desactívala para elegir comandos con normalidad de nuevo. Tu orden se recuerda entre sesiones.

Pulsa **Escape** en cualquier momento para retroceder un paso: desde el formulario de parámetros de un comando cancela la inserción y te devuelve al Command Picker — **en la página desde la que elegiste el comando** — y desde el selector cierra el selector. Escape ya no cierra el editor de eventos entero desde dentro de estos formularios, así que equivocarte al elegir cuesta una pulsación en vez de tus cambios sin guardar.

Si tienes mods instalados que añaden sus propios comandos de evento, aparecen pestañas extra marcadas con un icono de puzle tras las pestañas de categoría. Cada mod nombra su propia pestaña (y puede darle su propia descripción), de modo que los comandos de mod relacionados se agrupan juntos. Elige uno igual que un comando integrado; se edita con su propio formulario (o un cuadro de script si el mod no definió campos). Por debajo, el formulario simplemente escribe un comando Script normal, así que corre en el juego como cualquier otro script de evento. Los comandos de mod se pueden añadir a Favoritos igual que los integrados.

### Editar comandos

Haz doble clic en un comando para editar sus parámetros. Muchos comandos tienen formularios tipados dedicados (Show Text, Control Switches, Conditional Branch, etc.). Los comandos que aún no tienen un formulario tipado muestran un editor JSON en bruto en su lugar.

**Seleccionar varios comandos con el teclado**: mantén **Shift** y pulsa ↑ / ↓ para
ampliar o reducir la selección desde donde empezaste, igual que con Shift+clic. Copiar,
cortar, pegar, borrar y reordenar con Alt+↑/↓ actúan entonces sobre todo el bloque.

### Comandos multilínea (Show Text, Comment, Script)

**Show Text**, **Comment** y **Script** pueden contener tantas líneas como necesites — escríbelas en el cuadro de texto del comando, una por línea. En la lista de comandos, **cada línea tiene su propia fila**, igual que en RPG Maker XP: la fila del comando muestra la primera línea, y cada línea extra aparece debajo en una fila que empieza por `:`.

```
@>Text: "¡Hola!"
:       "Hoy hace buen tiempo."
:       "¿Vas al gimnasio?"
```

Cada línea extra se indenta para quedar justo debajo de la primera, así que un mensaje largo se lee como un bloque alineado en vez de una escalera irregular. La indentación se mide a partir del nombre del propio comando, por lo que sigue siendo correcta para cualquier comando y en cualquier idioma de la interfaz.

Esas filas extra son *líneas del comando*, no comandos propios:

- **Haz doble clic en cualquiera de ellas** (o selecciónala y pulsa Space) — el formulario del comando se abre con el texto **completo**, así que siempre lo editas como un bloque. Pulsa OK y las líneas se reescriben.
- **Seleccionar, arrastrar, copiar, cortar o borrar** cualquiera de las filas actúa sobre el **comando entero**, con todas sus líneas. No se puede soltar nada entre un comando y sus propias líneas.
- Las **flechas** saltan por encima de las líneas extra, así que la selección siempre cae sobre un comando completo.

Para partir un mensaje en varios cuadros de texto en el juego, inserta un *segundo* comando Show Text en vez de añadir más líneas al primero.

### Fragmentos de script

Todo cuadro de script del editor de eventos tiene un botón **Fragmentos…** junto a su título **Script** — úsalo para mantener una biblioteca del código Ruby que reutilizas, en vez de reescribir (o buscar) las mismas líneas cada vez.

Haz clic en **Fragmentos…** y se abre el gestor de fragmentos: escribe un nombre en **Guardar el actual como nuevo** abajo y pulsa **Guardar** para guardar lo que haya ahora en el cuadro; después elige un fragmento guardado y pulsa **Aplicar** (o haz doble clic en él) para volcar el código de vuelta. La lista muestra el código del fragmento resaltado en una vista previa con scroll, así que puedes comprobar que has elegido el correcto antes de aplicarlo. Renombrar, sobrescribir con el contenido actual del cuadro y borrar funcionan desde el mismo diálogo, y **Exportar…** / **Importar…** escriben y leen archivos de fragmentos para hacer copias de seguridad o compartirlos con otra persona.

Tres sitios comparten **una misma** biblioteca de fragmentos, así que lo que guardes en uno aparece en los demás:

- el comando **Script**,
- la acción **Script** dentro de Set Move Route,
- el cuadro de script de un comando de mod que no define sus propios campos.

Aplicar un fragmento **reemplaza el cuadro entero**, no lo inserta en la posición del cursor. Si el cuadro ya tiene código, primero aparece una confirmación que te indica cuántas líneas vas a perder — así que pega tu fragmento en un comando vacío, o copia antes lo que quieras conservar. Si el cuadro está vacío, el fragmento se aplica directamente.

Los fragmentos se guardan por instalación (compartidos entre todos tus proyectos) y se recuerdan entre sesiones.

### Elegir un gráfico (Favoritos)

Cada selector de gráficos tiene vista previa en vivo y favoritos: el **Graphic** de la página de evento (hoja de personaje), **Show Picture**, **Execute Transition**, **Change Map Settings** (panorama / fog / battleback), la acción **Change Graphic** de la ruta de movimiento, el selector de Battleback del mapa y el popup de edición de capa de fog / panorama / personalizada del panel de capas.

- **Árbol de carpetas** — la lista es un árbol tipo explorador de archivos: las subcarpetas (p. ej. `Graphics/Characters/NPCs/`) se muestran como carpetas plegables que despliegas o pliegas con un clic, con sus imágenes anidadas e indentadas dentro. Las carpetas se ordenan arriba y todo se ordena por nombre. La carpeta que contiene tu gráfico actual se despliega automáticamente al abrir el selector, y el cuadro de búsqueda sigue encontrando cualquier gráfico en cualquier parte del árbol — así puedes elegir y marcar como favorito gráficos anidados directamente en vez de buscar con **Browse**.
- **Browse nunca duplica** — el botón **…** puede elegir cualquier imagen bajo la carpeta `Graphics/` de tu proyecto. Si está en otra subcarpeta, el editor guarda una referencia relativa `../Folder/name` en vez de copiar el archivo (solo se copia una imagen de *fuera* de `Graphics/`). La vista previa se actualiza al instante, y las vistas previas que ya has visto se cachean para que alternar entre la lista y la pestaña **★ Favourites** no las recargue.
- **Marca cualquier gráfico con estrella** — pasa sobre un nombre en la lista y haz clic en su estrella para marcarlo (estrella rellena = favorito). Los favoritos se recuerdan entre proyectos y sesiones.
- **La imagen actual siempre tiene estrella** — si la imagen seleccionada no está en la lista de la carpeta actual (llegaste a ella con **Browse**, o vive en otra carpeta), aparece como su propia fila justo debajo de **(None)**, etiquetada con su ruta de carpeta — márcala desde ahí.
- **Favoritos arriba** — los gráficos que has marcado en la carpeta actual saltan a lo alto de la lista.
- **Pestaña ★ Favourites** — en cuanto tienes algún favorito, aparece una pestaña que lista **cada** favorito, sin importar en qué carpeta viva. Un favorito de otra carpeta muestra su nombre de carpeta al lado; elígelo y el editor guarda la referencia correcta automáticamente, así puedes reutilizar un favorito entre distintos tipos de selector (incluido como gráfico de personaje de un evento).

La misma estrella funciona en todas partes, así que un personaje que marcas en la página de un evento también queda fijado la próxima vez que elijas un gráfico de ruta de movimiento.

### Comandos de fog y múltiples capas de fog

Como un mapa de Maker Studio puede tener **varias capas de fog** (no solo el fog único del tileset de RPG Maker XP estándar), los tres comandos de evento relacionados con fog te dejan elegir **qué capa de fog** afectar:

- **Change Map Settings** (cuando el tipo es **Fog**) — elige la capa de fog; el formulario se rellena previamente con las propiedades actuales de esa capa (gráfico, hue, tipo de mezcla, zoom, scroll X/Y, follow-camera), que luego puedes editar. (La opacidad la gestiona Change Fog Opacity, abajo.)
- **Change Fog Color Tone** — elige la capa de fog, luego define el tono. El campo **Frames** funde el tono gradualmente durante ese número de frames (0 = instantáneo).
- **Change Fog Opacity** — elige la capa de fog, luego define la opacidad. El campo **Frames** funde la opacidad gradualmente (0 = instantáneo).

El desplegable lista las capas de fog del mapa actual por nombre. En el juego el comando cambia esa capa concreta; si no encuentra la capa, vuelve al fog principal del mapa. Estos comandos solo afectan a capas de **fog** — no hay comandos de evento para panorama o grupos de capa personalizados (los panoramas se editan en el panel de capas, los battlebacks desde el menú Map — consulta [Gestión de mapas](map-management.md#panorama-layers-and-battleback)).

### Set Move Route

Editar un comando **Set Move Route** abre un editor de rutas: elige el objetivo (This Event, Player u otro evento), activa Repeat / Skip If Cannot Move y construye la lista de acciones de movimiento.

La lista de acciones de movimiento se edita igual que la lista de comandos principal:

- **Selecciona** con un clic; **Shift+clic** extiende la selección y **Ctrl+clic** añade o quita acciones individuales — todo lo de abajo actúa sobre toda la selección.
- **Copy / Cut / Paste** con `Ctrl+C` / `Ctrl+X` / `Ctrl+V` — las acciones de movimiento tienen su propio portapapeles, así que copiarlas nunca sobrescribe comandos de evento copiados (y viceversa). Las acciones pegadas caen tras la selección, siempre dentro de la ruta.
- **Undo / Redo** con `Ctrl+Z` / `Ctrl+Y`, limitado a la ruta que estás editando.
- **Edita** la acción seleccionada con `Space` o `Enter` (abre su formulario de parámetros), **Supr** la quita, las **flechas** mueven la selección, y `Alt+↑` / `Alt+↓` reordenan.
- **Arrastra y suelta** una acción — o toda una multiselección — para reordenar; una línea muestra dónde caerá.

El editor de rutas ya está traducido por completo, así que con el editor en español los
botones de acción, las opciones de la ruta y las filas también se leen en español. Cada
fila se dibuja con una guía de sangría, así que de un vistazo las acciones se leen como
parte de la ruta y no como comandos propios.

Las acciones que toman parámetros abren su propio formulario, usando los mismos selectores que el resto del editor en vez de texto en bruto:

- **Change Graphic** — selector de archivo de gráfico de personaje (con vista previa + hue) más Direction y Pattern.
- **Play SE** — selector de archivo de SE con volumen/pitch y un botón de prueba.
- **Script** — cuadro de código Ruby multilínea.
- **Change Speed / Change Freq** — desplegables etiquetados (Slowest…Fastest, Lowest…Highest), igual que RPG Maker XP.
- **Switch ON/OFF**, **Jump**, **Wait**, **Change Opacity**, **Change Blending** — campos dedicados.

#### Acciones de frame (Maker Studio)

Debajo de las acciones estándar hay un grupo **Frame** que avanza o establece qué celda de la hoja de personaje muestra el objetivo, usando la cuadrícula **Sheet Cols / Sheet Rows** de la página (consulta [Gráfico](#graphic)). Las **columnas de la hoja son los frames horizontales** y sus **filas son los frames verticales**.

- **Next Frame / Previous Frame** — avanza un frame por la fila; al final de una fila salta al inicio de la siguiente fila (y toda la hoja da la vuelta al final del todo).
- **Next / Previous Horizontal Frame** — avanza una columna, dando la vuelta solo dentro de la fila actual.
- **Next / Previous Vertical Frame** — avanza una fila, dando la vuelta solo dentro de la columna actual.
- **Set Frame…** — establece la columna y/o la fila directamente. Cada eje tiene su propia casilla, así que puedes cambiar solo la columna, solo la fila o ambas, dejando la otra sin cambios. Los números de frame empiezan en 1.

Estas te dejan controlar la animación de un sprite a mano — p. ej. el parpadeo escalonado de una antorcha, un retrato que cicla expresiones o una hoja de poses ancha. Como el frame se establece manualmente, desactiva la **Move Animation** y la **Stop Animation** del objetivo (acciones Move Animation OFF / Stop Animation OFF) para que el ciclo de caminar automático del motor no sobrescriba el frame que estableciste.

> El simulador **Test Move Route** del editor previsualiza esto de forma aproximada — solo las primeras cuatro filas se dibujan de forma distinta ahí. En el juego, todas las filas de la hoja son alcanzables.

**Test Move Route** arranca con **Loop** ya activado cuando la ruta tiene **Repeat
Action** marcado, así una ruta en bucle se previsualiza como se comportará realmente en
el juego en vez de pararse tras una pasada. Desactivar Loop en el simulador sigue
mandando a partir de ese momento.

Cada acción de movimiento también aparece como su propia fila de color bajo el comando Set Move Route en la lista principal. Para reeditar una, haz doble clic — o selecciónala y usa Edit (botón Edit / Space / clic derecho → Edit). Cualquiera salta directo al formulario de esa acción.

### Comandos de bloque

Algunos comandos crean bloques emparejados:

- **Conditional Branch** añade un Branch End correspondiente. Marca **Add Else Branch** en su formulario para insertar una sección **Else** (desmárcala para quitarla a ella y sus comandos).
- **Loop** añade un Repeat Above correspondiente.
- **Show Choices** construye un bloque completo: una rama **When** por cada elección más un **Choices End**. Editar las elecciones (renombrar, añadir o poner el comportamiento de cancelar en *Branch*) actualiza las ramas When / When Cancel automáticamente, conservando los comandos que ya pusiste dentro de cada una.

Borrar un comando de bloque (o su marcador de cierre) quita el **bloque entero**, incluido cada comando anidado dentro.

### Anidar comandos

Para poner comandos *dentro* de un bloque, selecciona la línea de apertura del bloque (p. ej. el Conditional Branch, una rama When o el Loop) e Insert — el nuevo comando cae indentado un nivel dentro. Insertar tras un comando que ya está dentro de un bloque lo mantiene en ese nivel. No hay control de indentación manual; el anidado sigue dónde insertas o sueltas un comando.

### Atajos de teclado en la lista de comandos

| Tecla | Acción |
|-----|--------|
| Space | Editar el comando seleccionado |
| Delete / Backspace | Borrar el comando seleccionado |
| Insert / Enter | Abrir el Command Picker |
| Ctrl+C / Ctrl+V / Ctrl+X | Copiar, Pegar o Cortar comandos |
| Ctrl+A | Seleccionar todos los comandos de la lista (la fila End final de la página queda fuera de la selección). Útil antes de copiar o borrar en bloque |
| Escape | Cancelar el Command Picker o el formulario de parámetros abierto (ver [Añadir comandos](#añadir-comandos)) |
| Flechas arriba / abajo | Mover la selección |
| Alt + Arriba / Abajo | Reordenar el comando seleccionado (o bloque entero) en uno, manteniéndose en su nivel actual. Para mover un comando *dentro* o *fuera* de una rama, arrástralo (ver abajo) o corta y pega. Un bloque entero (Conditional, Loop, Show Choices, Set Move Route) se mueve como una unidad. |

También puedes **copiar y pegar entre eventos**: copia comandos en un evento (un bloque se copia con todo lo de dentro), abre otro evento y pega — los comandos pegados conservan su anidado.

**Copiar entre dos proyectos abiertos:** activa **Edit → Advanced Clipboard → Cross-Project Clipboard** en ambas ventanas. Los comandos de evento copiados (y eventos enteros) viajan entonces por el portapapeles del sistema, así que puedes copiar en la ventana de un proyecto y pegar en la de otro. Está desactivado por defecto; el texto de portapapeles que no sea de Maker Studio se ignora.

### Reordenar arrastrando

Puedes arrastrar filas de comando para reordenarlas. Un bloque (Conditional, Loop, Show Choices, Set Move Route) se arrastra junto con todo lo de dentro. Mientras arrastras, una **línea azul** se ajusta al hueco más cercano a tu cursor y muestra exactamente dónde caerá el comando. El comando toma la indentación de la posición de la línea, así que:

- Suelta sobre una fila **Else** (o **When**) → el comando va *dentro* de esa rama.
- Suelta sobre una fila **Branch End** (o Repeat Above / Choices End) → el comando va *fuera, debajo del bloque entero*.
- Suelta la línea entre dos comandos → cae a su nivel.
- Suelta en el espacio vacío debajo de la lista → va al final.

### Código de color

Las filas de comando se colorean por categoría para que la lista se lea como código con resaltado de sintaxis. Categorías de un vistazo:

| Color | Categoría | Códigos |
|-------|----------|-------|
| Verde (cursiva) | Comentarios | Comment, Comment (cont.) |
| Crema / blanco roto | Texto y entrada | Show Text, Show Text (cont.), Input Number, Change Text Options, Button Input |
| Color de texto atenuado | Condicionales | Conditional Branch, Else, Branch End, Show Choices, When [**], When Cancel, Choices End |
| Ámbar | Otro flujo | Loop / Repeat Above, Break Loop, Wait, Label, Jump to Label, Exit Event, Erase Event, Call Common Event |
| Rosa | Variables | Control Switches, Control Variables, Control Self Switch, Control Timer |
| Naranja (intenso) | Party / Inventario | Change Gold, Items, Weapons, Armor, Party Member |
| Azul acero | Map / Screen | Transfer Player, Set Event Location, Scroll Map, Map Settings, Fog Tone/Opacity, Animation, Transparent, Transitions, Screen Tone/Flash/Shake, Weather |
| Menta | Movimiento | Set Move Route, Wait for Move's Completion |
| Menta tenue | Subcomandos de movimiento | Pasos de movimiento individuales bajo un Set Move Route |
| Periwinkle | Pictures | Show / Move / Rotate / Tone / Erase Picture |
| Cian | Audio | BGM, BGS, ME, SE (play / fade / stop / memorize / restore) |
| Rojo | Sistema | Battle / Shop / Name Input, Abort Battle, Menu / Save / Game Over / Title |
| Amarillo | Cambios de actor | HP, SP, State, Recover, EXP, Level, Parameters, Skills, Equipment, Name, Class, Graphic |
| Terracota | Cambios de enemigo | Enemy HP, SP, State, Recover, Appear, Transform, Battle Animation, Damage, Force Action |
| Magenta orquídea | Scripts | Script, Script (cont.) |
| Cursiva atenuada | End | Fila terminadora final de la página |

Los colores siguen el tema activo del editor — la misma familia de tonos en modo oscuro y claro, desplazada para legibilidad sobre cada fondo. Las filas seleccionadas siempre se dibujan en blanco sobre azul independientemente de la categoría.

## Limitaciones conocidas

- Quitar una elección del *centro* de una lista Show Choices puede desplazar los comandos de las ramas When de debajo (las ramas se emparejan por posición). Renombrar elecciones o añadir nuevas al final es seguro.
- Algunos comandos usan actualmente un editor JSON en bruto porque aún no hay un formulario tipado disponible.

## Esperar a que termine una ruta de movimiento

**Esperar fin del movimiento** pausa el evento hasta que una ruta forzada haya terminado. RPG Maker
espera a *todos* los personajes del mapa, así que la ruta de un evento que no tiene nada que ver
puede retener al tuyo. Maker Studio permite acotarlo:

| Opción | Espera a |
|--------|----------|
| **Cualquier evento (por defecto en RPG Maker)** | Todos los personajes — el comportamiento original. Es lo que se elige en comandos nuevos y lo que ocurre sin el plugin |
| **Este evento** | Las rutas que ha lanzado *este evento*, muevan a quien muevan — incluida una que le haya puesto al jugador |
| Un evento concreto | Solo la ruta que este evento le puso a ese |

"Este evento" es lo que quieres tras mover al jugador por una puerta: el propio evento está parado,
así que lo que importa es la ruta que lanzó, no su movimiento.

Cualquier opción distinta de *Cualquier evento* necesita el **plugin de Maker Studio** en tu juego
(el distintivo del formulario lo indica). Sin él, el juego vuelve a esperar a todos los personajes —
nunca falla, simplemente hace lo de siempre.

Un detalle que conviene saber: una ruta lanzada por un **script** (por ejemplo
`Followers.follow_into_door` de Essentials) no la ha lanzado el evento, así que solo *Cualquier
evento* la espera.

## Movimiento autónomo · Personalizado

Con **Tipo: Personalizado** en el recuadro de movimiento autónomo aparece un botón **Fijar ruta de
movimiento…**. Abre el mismo editor de rutas que el comando, y la ruta se guarda en la propia página
— la ruta que el evento recorre por su cuenta, sin necesidad de ningún comando. No hay selector de
objetivo: la ruta de una página siempre mueve a su propio evento.
