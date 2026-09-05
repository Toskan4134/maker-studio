# Registro de cambios

Cambios de cara al usuario en la app de Maker Studio y su plugin del lado del juego.

## v1.6.0

Cada comando de evento se describe ahora en la lista, con su propio color — incluidos los comandos de batalla. La ventana de Scripts edita cualquier fuente de scripts que tenga el proyecto, los registros enteros se copian y pegan por todo el editor, y los preajustes aprenden multiselección y una importación que pregunta antes de sobrescribir.

### Novedades
- 🎨 **Un color por comando** — cada comando de evento pinta ahora su fila con su propio color, y las filas de continuación (líneas de texto, else de ramas, pasos de ruta) siguen al comando al que pertenecen. Ajustes → Apariencia estrena un grupo **Comandos individuales** con una fila por comando, y un botón **Paleta RPG Maker XP** que rellena el conjunto entero de golpe, claro y oscuro.
- ⚔️ **Los comandos de batalla se suman al editor** — **If Win / If Escape / If Lose / Battle End / Shop Goods** eran desconocidos para el editor: formularios en JSON crudo, sin color y sin estructura de bloque. Ahora son comandos de verdad, **Battle Processing** construye y sincroniza su esqueleto de ramas igual que Show Choices, las tiendas guardadas con el formato antiguo se adoptan al abrir, y el Simulador de juego se salta el bloque de batalla entero en vez de ejecutar seguidos los cuerpos de victoria, huida y derrota.
- 📝 **Cada fila de comando se describe a sí misma** — el texto tras el nombre de un comando está escrito ya para todos los códigos, no solo para unos pocos: opciones por nombre ("Scroll Map: Down, 3 tiles, speed 4"), objetos, héroes y habilidades por nombre, y las filas de imagen posteriores dicen su archivo.
- 📜 **La ventana de Scripts edita cualquier fuente de scripts** — la lista estaba atada a Scripts.rxdata; ahora edita la fuente que tenga el proyecto: Scripts.rxdata, Data/Scripts si el proyecto extrajo sus scripts, y cada carpeta de Plugins/. Las carpetas se muestran como árbol real, y los archivos se gestionan ahí mismo: nuevo archivo o carpeta, renombrar, borrar (con multiselección), arrastrar a una carpeta para mover. La barra lateral se redimensiona, pliegues y ancho se recuerdan, y la ventana vuelve donde la dejaste. Los fragmentos se insertan ahora en el cursor.
- 🗂️ **Copiar, cortar, pegar y duplicar registros enteros** — toda lista que guarda un registro comparte ahora un portapapeles: una página de evento, un tileset, una animación, un evento común, el nombre de un switch o variable, una capa entera del mapa — copia de un sitio, pega en otro, o en otra ventana de Maker Studio con el portapapeles entre proyectos activado. **Ctrl+J** duplica lo que esté seleccionado, y cada lista mantiene su propia historia de Ctrl+Z.
- 🧩 **Los preajustes maduran** — selecciona varios preajustes o carpetas con Ctrl/Shift y muévelos, expórtalos o bórralos de una acción; el panel de detalle edita el código de un fragmento en el sitio; un fragmento nuevo puede salir de la selección del editor; y la importación pregunta antes de sobrescribir — una lista de conflictos muestra lo tuyo contra lo importado, con las diferencias, y tú marcas qué reemplazar.
- 👆 **Doble clic en la fila vacía del final de la lista de comandos** para añadir un comando — igual que el doble clic en el hueco de abajo.
- 🧩 **Para quien hace mods**: Mod API **1.0.2** — los colores de los comandos de evento son públicos: el tema de un mod puede recolorear un solo comando sin abandonar su categoría, y `commandSchemas()` informa de la categoría de color de cada comando y del código que lo pinta.

### Correcciones
- 🌉 **Las sombras ya no se dibujan sobre un puente activo** — al cruzar un puente el motor fuerza sus tiles a z=0, lo que hundía los tiles de origen de la sombra por debajo de la propia sombra.
- 💥 **La vista previa del Destello de pantalla muestra el color configurado** — el recuadro salía blanco eligieras lo que eligieras; ahora mezcla el color según la fuerza.
- ⏱️ **Corregido que Control Timer durara un segundo por minuto** — el editor guardaba fotogramas donde RPG Maker XP guarda segundos, así que un temporizador de un minuto duraba un segundo en el juego.
- 🔢 **Corregidas las filas de Change HP / SP / EXP / Level**, que leían todas las opciones posteriores al héroe desplazadas en uno — un parámetro que faltaba recorría el resto.
- 🔥 **Corregido un cuelgue del juego (NoMethodError) en proyectos de La Base de Sky y Pokémon Essentials** cuando un seguidor pisaba un tile que ninguna capa decidía — el plugin pedía al motor una API que RPG Maker XP no tiene.
- 💧 **Corregido el cuentagotas / ALT+clic sin desplazamiento de la paleta** después de un clic en la propia paleta.
- 🧱 **Corregido que pintar un autotile nativo sobre uno extra resucitara el nombre antiguo** — la celda conservaba el nombre del autotile desplazado y dibujaba el gráfico viejo con el patrón nuevo.
- 🖼️ **Corregidas las vistas previas de autotiles en el editor de tilesets**, que mostraban el último fotograma de animación en vez del primero.
- 🗑️ **Corregido que los mapas borrados dejaran sus cachés de render**, así el siguiente mapa que tomaba el ID libre se renderizaba con el tileset del mapa borrado hasta re-elegirlo. **Escape en la capa de eventos** suelta ahora también la selección de tiles.
- 💾 **Corregido el guardado de un tileset tras pintar más allá del final de una tabla corta de terrain tags / prioridades / pasajes** — el guardado fallaba con error.
- 🗺️ **Corregido el selector de mapa de Transfer Player atascándose en tiles de relleno.**
- ↩️ **El deshacer se pone serio** — cancelar un evento recién creado lo borra de nuevo en vez de dejar uno vacío en el mapa; crear uno es un solo Ctrl+Z; duplicar o pegar una capa es un deshacer, no dos; y reordenar capas, que nunca se pudo deshacer, ahora sí.

### Cambios
- ✂️ **Las filas de Show / Move Picture se recortan a nombre + opacidad** — origen, xy, zoom y mezcla casi siempre son los de por defecto y enterraban los dos datos que merece la pena ver; Move Picture añade la duración de la transición.

## v1.5.0

Las rutas de movimiento ahora se dibujan sobre el mapa, en vez de montarse a base de pulsar **Move Up** doce veces. El editor instala el plugin del juego él solo, los mapas enteros viajan de un proyecto a otro con Ctrl+C / Ctrl+V, cualquier mapa puede cambiar de ID sin romper los transfers que apuntan a él, y el cuadro de Show Text por fin te dice qué hacen todos esos códigos `\c[…]`.

### Novedades
- 🚶 **Dibujar ruta… — el editor visual de rutas de movimiento** — un botón **Dibujar ruta…** junto a Test Move Route abre el mapa y te deja trazar la ruta encima en vez de apilar Move Up doce veces. Extiende el camino con las flechas, gira en el sitio con Ctrl+flechas, deshaz con Retroceso, borra varios pasos de golpe, y **Aplicar como ruta de movimiento** la escribe de vuelta. Si el comando ya tenía ruta, se abre mostrándola, así que la extiendes o la recortas en vez de empezar de cero — y una ruta que va detrás de un **Wait for Move's Completion** empieza donde acabó la anterior. Todas las teclas del editor son reasignables.
- 🧩 **El editor instala el plugin del juego por ti** — cuando un proyecto no tiene integración, el diálogo ofrece un desplegable **Integración** con todos los motores soportados: elige el tuyo, pulsa **Instalar**, y descarga el zip correcto y monta `Plugins/MakerStudio/` él solo. Las dos integraciones que se pegan a mano (Essentials v17.1 y BES v5) convierten el botón en **Descargar** y luego **Abrir carpeta**, porque son un único script que pegas tú en el Editor de scripts.
- 🔤 **Códigos de texto, dentro del cuadro de Show Text** — un botón **Códigos de texto** abre una referencia de todos los códigos de mensaje que entiende tu juego, agrupados en Sustitución, Estilo y Flujo; haz clic en uno y aparece donde tenías el cursor. Al escribir `\` esa misma lista se filtra en un autocompletado que eliges con las flechas. Los proyectos de La Base de Sky reciben además los códigos extra de esa base, incluidos los de **NameBox**, que se copian al portapapeles para un comando Script.
- 📋 **Copia un mapa entero a otro proyecto** — **Ctrl+C** en la lista de mapas copia el mapa con todas sus capas, eventos y versiones, y **Ctrl+V** lo pega en el árbol, igual que en RPG Maker XP. Activa **Portapapeles entre proyectos** en el menú Edit para que funcione entre dos ventanas de Maker Studio. **Supr** también borra el mapa seleccionado desde el teclado.
- 🗂️ **Pestañas de mapa reordenables, y una sesión que vuelve entera** — arrastra las pestañas al orden que quieras, y al reabrir el proyecto vuelve el conjunto completo de pestañas en ese orden, con el mapa que estabas editando como activo, en vez del primero de la lista.
- 🔢 **Cambiar el ID de un mapa** — **Cambiar ID…** en el árbol de mapas mueve un mapa a cualquier número libre y reescribe **todos los comandos Transfer Player del proyecto** que apuntaban a él, sigue la posición inicial del jugador y renombra sus sombras generadas; el aviso te dice cuántos comandos se han actualizado. Los mapas nuevos además reaprovechan los IDs libres que dejaron los borrados en vez de coger siempre el siguiente número.
- ⚔️ **El battleback es del mapa, no del tileset** — un mapa en el que nunca hayas puesto uno sigue mostrando el del tileset, así que un proyecto recién abierto se ve como en RPG Maker XP; en cuanto eliges uno, ese mapa se queda con el suyo y los demás mapas del mismo tileset no se tocan. Cada versión de mapa tiene la suya.
- 🏷️ **Nombres del juego en Ajustes** — cambia el nombre de la carpeta donde el juego guarda las partidas (el título de `Game.ini`) y el título de la ventana del juego (`mkxp.json`) sin salir del editor ni tocar nada más de esos archivos.
- 🖼️ **Tileset actual en el selector de gráficos** — la lista de gráficos de un evento empieza por una fila **Tileset actual**, así coges tiles del propio tileset del mapa sin tener que buscarlo.
- 👀 **Las filas de comando cuentan más sin abrirlas** — los resúmenes llevan valores de verdad en vez de ids sueltos, las filas de Transfer Player dicen a dónde van (`007: Ciudad Plateada (12,8)`), las filas largas se desplazan al pasar el ratón en vez de quedarse cortadas, y las líneas de Text, Comment y Script se muestran sin las comillas que las envolvían.
- 🎚️ **Todos los sliders aceptan un valor escrito** — haz doble clic en el número de un slider y escribe el valor exacto que quieres, en cualquier parte del editor.
- 🔄 **Las dos comprobaciones de actualización muestran dos versiones** — la que tienes y la más nueva disponible, tanto para el editor como para el plugin del juego.
- 🖌️ **Los trazos de pincel pueden empezar fuera del mapa** — empieza un trazo por encima o a la izquierda del borde y se pinta la parte que cae dentro, en vez de no pasar nada.
- 🧩 **Para quien hace mods**: Mod API **1.0.1** — los mods pueden reestilizar cualquier parte de la interfaz del editor (`ui.decorate`), añadir contenido propio en zonas con nombre, enseñar al **Simulador de juego** a ejecutar comandos y condiciones Script, preguntar si el proyecto es de LBDS, y saber dónde se colocó su comando de evento. Los mods que necesitan un editor más nuevo que el tuyo se frenan con una etiqueta **Necesita un editor más nuevo** en vez de fallar a medias.

### Correcciones
- 🧱 **Corregido que un autotile cogido con el cuentagotas se convirtiera en otro tile** en un mapa con otro tileset — ahora la elección viaja por nombre, no por posición.
- 🖌️ **Corregidos los autotiles extra que no se unían durante el trazo** — un trazo dibujado con uno de los autotiles del propio juego ahora se conecta mientras dibujas, en vez de quedarse con la primera forma.
- 👻 **Corregida la vista previa de pintado de un autotile cogido con el cuentagotas**, que mostraba la pieza equivocada.
- 🎨 **Corregida la paleta mostrando el tileset de otro mapa** cuando varios mapas volvían a la vez al reabrir un proyecto.
- 🏃 **Corregido que la frecuencia de los eventos tuviera cinco niveles en vez de seis** — el desplegable de la página, Change Freq y el simulador se quedaban en *Higher* y bajaban en silencio los eventos puestos en *Highest*.

### Cambios
- ⬆️ **Insert y Pegar ahora caen encima de la fila seleccionada**, como hermanos, en vez de dentro del bloque que estuviera seleccionado. Para meter un comando dentro de un bloque, insértalo sobre una fila que ya esté dentro.
- ▶️ **Run ya no guarda tus mapas por ti** — si hay algo sin guardar pregunta antes, y si no hay nada pendiente lanza directamente.
- 🧩 **Comprobar integración del juego tiene su propio icono** en el menú Help.

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

## v1.2.1

Corrección urgente de la v1.2.0: la integración impedía que el juego arrancase.

### Correcciones
- 🚑 **Corregido que el juego no arrancaba tras instalar la integración v1.2.0** — fallaba al iniciar con un error de plugin sobre una clave de registro no válida (`Clave de registro de plugin no válida 'msintegration'` / `Invalid plugin registry key 'msintegration'`). La línea que usa el editor para reconocer qué integración tienes queda ahora oculta al motor, así que se sigue identificando igual que antes sin que el motor llegue a verla. Afectaba a todas las integraciones que se instalan como carpeta, en todos los motores; si instalaste la v1.2.0, actualiza a la v1.2.1.

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

## v1.1.1

Actualización pequeña: una forma más rápida de abrir proyectos, más correcciones de rendimiento en el editor y las previsualizaciones dentro del juego.

### Novedades
- 📂 **Abrir un proyecto con doble clic** — crea un archivo `.makerstudio` para tu proyecto (**Archivo → Crear archivo de proyecto…**) y haz doble clic sobre él en tu explorador de archivos para abrir Maker Studio directamente en ese proyecto, igual que el archivo de proyecto de RPG Maker XP. (En el AppImage de Linux, regístralo una vez con **Ayuda → Instalar asociación de archivo en Linux…**.)

### Correcciones
- ⚡ **Rendimiento del editor** — el lienzo del mapa ya no va lento al pintar muchos tiles, tiles con propiedades de color o rotación, o autotiles, ni al trabajar en mapas muy grandes.
- 🗺️ **Previsualizaciones de mapa más rápidas en el juego** — las pantallas de depuración "saltar a mapa" y el editor de conexiones de mapa ya no se congelan en mapas con muchos tiles con efectos.

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

## v1.0.0

Primera versión pública. Consulta las [notas de la release en GitHub](https://github.com/Toskan4134/maker-studio/releases/tag/v1.0.0) para más detalles.
