# Registro de cambios

Cambios de cara al usuario en la app de Maker Studio y su plugin del lado del juego.

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
