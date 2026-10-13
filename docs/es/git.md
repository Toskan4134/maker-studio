# Integración con Git

El botón **Git** de la barra de menús abre el control de versiones del proyecto. Maker Studio usa el ejecutable de Git instalado en tu ordenador. Si el proyecto aún no es un repositorio, puedes inicializarlo desde esta ventana.

## Cambios

La pestaña **Changes (Cambios)** muestra los archivos del proyecto que Git detecta como modificados. Selecciona cuáles incluir, escribe un mensaje y crea el commit. Maker Studio incluye los archivos guardados en disco, así que guarda primero los cambios del editor; las ediciones sin guardar bloquean las acciones de Git que podrían sobrescribirlas.

Puedes descartar los cambios de un archivo seleccionado. Los archivos versionados vuelven a su último commit; los archivos nuevos seleccionados se eliminan. El editor vuelve a cargar los datos afectados cuando es posible. Si no puede recargar un cambio de forma segura, te pedirá que vuelvas a abrir el proyecto.

## Historial de commits

Abre **Commit history (Historial de commits)** para ver en un grafo los commits de las ramas y referencias del repositorio. Cada fila muestra el asunto del commit, sus etiquetas de rama o referencia, autor, fecha y hash corto. Los commits aparecen primero con la fecha de autor más reciente siempre que lo permitan las relaciones entre ellos. Junto al título aparece un indicador mientras se carga una página. El grafo carga los primeros 100 commits y después carga automáticamente otros 100 al llegar al final de la lista, hasta un máximo de 1.000. Al alcanzar el límite, un aviso indica que se muestran los 1.000 commits más recientes.

Al abrir la pestaña, se selecciona el commit de la rama actual si está entre los commits cargados; si no, se selecciona el primero.

Con el diálogo ancho, el grafo queda arriba y la lista de **Changed files (Archivos modificados)** y la vista previa aparecen en paralelo debajo. Las filas compactas alinean en columnas el grafo, el asunto y las referencias, el autor, la fecha y el hash para mostrar más historial. Arrastra los separadores entre columnas para cambiar su ancho o enfoca uno y pulsa **← / →** (mantén **Shift** para un ajuste mayor). La columna del grafo se puede estrechar hasta 40 px; los anchos mínimos mantienen legibles el asunto, el autor, la fecha y el hash. Al estrechar el diálogo, el grafo, la lista y la vista previa se apilan en vertical; cada panel tiene su propio desplazamiento y el diálogo no añade una barra vertical. En el ancho mínimo se ocultan el autor y la fecha para dar sitio al asunto, las referencias y el hash.

Las fechas de los commits usan el formato **DD/MM/YYYY**. Arrastra el separador horizontal entre el grafo y los paneles inferiores para ajustar la altura del grafo entre el 20 % y el 80 % del espacio flexible (50 % por defecto); los paneles inferiores comparten el espacio restante y pueden ocupar hasta el 80 %. Ambas áreas cambian de tamaño mientras arrastras. También puedes enfocar el separador y pulsar **↑ / ↓** para cambiarlo en pasos del 5 %, o **Home / End** para ir a los límites.

Usa **↑ / ↓** para moverte por los commits y **Home / End** para saltar al primero o al último. Tab solo enfoca el commit activo del grafo.

Selecciona un commit para ver sus archivos modificados y el estado de cada uno. La lista solo incluye archivos dentro de la carpeta del proyecto, aunque el repositorio de Git también contenga otros. Selecciona un archivo para comparar ese commit con su primer padre en la vista previa situada junto a la lista. El control **Styled / Raw text** solo aparece para JSON, XML y Markdown. Markdown en modo Styled se muestra renderizado como Markdown; JSON y XML mantienen el resaltado de sintaxis. Los demás lenguajes de código compatibles conservan siempre el resaltado y no muestran este control. El lenguaje se deduce de la extensión (las entradas de Scripts usan Ruby); el estilo no afecta a las marcas de cambios y se restablece al seleccionar otro archivo. Cuando existen las dos versiones, el encabezado también ofrece **Side by side (Lado a lado)** y **Unified (Unificado)**. El modo lado a lado muestra paneles alineados antes/después; el unificado intercala el contexto y los cambios en un solo panel. Los archivos de texto y las entradas de Scripts añadidos o eliminados muestran solo la versión existente; un archivo vacío existente se distingue de uno ausente. El resaltado admite Ruby, JavaScript/JSX, TypeScript/TSX, JSON, Markdown, CSS, HTML, XML, YAML, TOML, Python, shell y SQL; los demás textos se muestran sin resaltado. Scripts, registros de base de datos y mapas conservan sus vistas estructuradas; los mapas también tienen una comparación visual lado a lado.

Los archivos de imagen (PNG, JPEG, BMP, GIF y WebP) muestran una vista previa de ambos lados. Haz clic en una imagen para abrir un visor ampliado, donde puedes acercarla y arrastrarla. Ogg, MP3 y WAV usan controles con el estilo de la aplicación si el navegador admite el códec: reproducir/pausar, posición y duración con una barra de búsqueda, y volumen. MIDI tiene un botón equivalente para reproducir/detener. Cada lado tiene un límite de 16 MiB; los archivos multimedia más grandes no se pueden previsualizar. Si se añadió o eliminó un archivo, solo aparece el lado existente; los archivos multimedia modificados conservan la vista lado a lado.

## Ramas y remotos

Elige una rama local y cámbiala desde los controles de ramas. Pull descarga cambios remotos; Push envía los commits locales al remoto configurado. Pull y el cambio de rama requieren que todo el repositorio esté limpio. Cambiar de rama recarga el proyecto, y Pull lo vuelve a abrir si ha recibido cambios. Configura un remoto y una rama upstream en Git antes de usar Pull o Push.
