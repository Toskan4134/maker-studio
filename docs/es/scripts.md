# Editor de scripts

El editor de **Scripts** te permite ver, reordenar, renombrar, añadir, borrar y editar los scripts Ruby de tu proyecto directamente desde Maker Studio — los mismos scripts que RPG Maker XP guarda en `Data/Scripts.rxdata`. Es útil en bases que no incluyen un `scripts_extract.rb`, para que puedas trabajar con el código sin salir del editor.

Ábrelo desde el botón **Scripts** de la barra de herramientas (junto a **Database**) o **Tools → Scripts…**.

## La ventana

- **Izquierda:** la lista de scripts, en el orden en que RPG Maker XP los ejecuta. Los divisores de sección (títulos hechos de signos `=`) aparecen atenuados.
- **Derecha:** el código del script seleccionado, con resaltado de sintaxis Ruby, números de línea y buscar y reemplazar (`Ctrl+F` — consulta [Encontrar cosas](#finding-things)). Edítalo como cualquier editor de código; el deshacer/rehacer estándar `Ctrl+Z` / `Ctrl+Y` funciona dentro de él.

## Gestionar scripts

Usa los botones pequeños encima de la lista:

- **＋** — añade un script nuevo debajo del seleccionado (escribe su nombre, luego empieza a editar a la derecha).
- **🗑** — borra el script seleccionado.
- **▲ / ▼** — mueve el script seleccionado arriba o abajo. El orden importa: los scripts se ejecutan de arriba a abajo.
- **Arrastra** un script arriba o abajo en la lista para reordenarlo — una línea muestra dónde caerá.
- **Doble clic** en el nombre de un script para renombrarlo.

Un punto (•) en la barra de título significa que tienes cambios sin guardar.

## Encontrar cosas

- **Buscar en el script actual** — pulsa `Ctrl+F` para abrir una barra de buscar y reemplazar en lo alto del editor de código. Admite distinguir mayúsculas, expresiones regulares, coincidencia de palabra completa y reemplazar / reemplazar todo, y sigue el idioma y tema del editor.
- **Buscar en todos los scripts** — pulsa `Ctrl+Shift+F` para abrir un panel de búsqueda que recorre el título y el código de **cada** script a la vez. Los resultados aparecen agrupados por script con números de línea y la coincidencia resaltada; haz clic en un resultado para saltar directo a esa línea, incluso en otro script. Activa **Aa** para coincidencia sensible a mayúsculas o **.*** para expresiones regulares (un patrón inválido simplemente no muestra resultados). Las búsquedas muy amplias se detienen en 500 resultados — acota la consulta para ver el resto.

Ambos atajos son reasignables en **Help → Keyboard Shortcuts...** (la sección "Scripts").

## De dónde sale el código

El selector que hay encima de la lista de scripts elige **qué está editando esta ventana**:

- **Scripts.rxdata** — los scripts empaquetados, tal como los guarda RPG Maker XP. Es lo normal.
- **Data/Scripts** — tus archivos `.rb` extraídos, disponible siempre que esa carpeta exista. Si tu
  proyecto está extraído (su `Scripts.rxdata` es solo el cargador de una línea), la ventana se abre
  aquí sola en vez de enseñarte ese archivo vacío.
- **Plugins** — una entrada por cada carpeta dentro del `Plugins/` de tu proyecto, así puedes leer y
  arreglar un plugin sin salir del editor.

El selector solo lista lo que tu proyecto tiene de verdad, así que nunca te manda a una carpeta
inexistente. El título de la ventana te dice dónde estás (`Scripts · MakerStudio`), y **Open in VSC**
abre la carpeta que estés mirando.

Arrastra la línea entre la lista y el código para ensanchar la lista — los nombres largos caben, y el ancho se recuerda la próxima vez. En una carpeta, la lista muestra sus archivos `.rb` agrupados por subcarpeta — haz clic en una
carpeta para plegarla, y seguirá plegada la próxima vez que vuelvas. Los archivos se editan y se
guardan igual que los scripts empaquetados; **Save** escribe solo los archivos que hayas cambiado de
verdad.

La ventana también recuerda dónde estabas: al reabrirla vuelve al archivo que tenías abierto, con el
cursor y la lista donde los dejaste — y cada sitio (`Scripts.rxdata`, `Data/Scripts`, cada plugin)
guarda su propio lugar, así que cambiar entre ellos no pierde nada.

Desde aquí también puedes gestionar la carpeta:

- **+** crea un **archivo nuevo** o una **carpeta nueva** — junto al archivo que tengas abierto, o en
  el nivel superior.
- **Clic derecho en una carpeta** para crear un archivo o una carpeta *dentro de ella*, renombrarla o
  borrarla (al borrarla te dice cuántos archivos se van con ella).
- **Clic derecho en un archivo** para renombrarlo o borrarlo. Doble clic en su nombre también lo
  renombra.
- Un clic izquierdo en una carpeta simplemente la abre o la cierra.
- **Elige varios a la vez**: Ctrl+clic en archivos (o carpetas) para ir sumándolos, Mayús+clic para un
  rango de archivos, y bórralos todos de una vez.
- **Arrastra para mover**: suelta un archivo o una carpeta sobre otra carpeta para meterlo dentro, o
  **en cualquier sitio fuera de la lista** para sacarlo al nivel superior — la lista se marca con un
  borde mientras ese sea el destino. Para subirlo *un solo* nivel, suéltalo sobre la cabecera de la
  carpeta padre, o haz clic derecho y elige *Mover a "<carpeta>"*. La carpeta que va a recibir el arrastre se marca con un
  borde, y si arrastras uno de varios elementos seleccionados se mueven todos.

Lo único que se queda en `Scripts.rxdata` es el **orden**: en disco los archivos se ordenan solos.

## Fragmentos (Snippets)

El botón **Snippets…** de la barra abre la misma biblioteca de fragmentos que usan los cuadros de
script del editor de eventos, así que un ayudante que guardaste escribiendo un evento está aquí a un
clic — y lo que guardes aquí aparece allí. Un fragmento nuevo se recorta de lo que tengas
**seleccionado** en el código (o del script entero si no hay nada seleccionado), y al usar uno se te
pregunta si **Insertar en el cursor** — dejándolo donde está el cursor, sobre la selección si la hay
— o **Reemplazar** el script entero. Las carpetas, la importación y la exportación funcionan tal
como se describe en la [guía del editor de eventos](events-editor.md#fragmentos-de-script).

## Guardar

Haz clic en **Save** (o pulsa `Ctrl+S`) para escribir todo de vuelta en `Data/Scripts.rxdata`. Tu archivo anterior se respalda primero en `Data/Scripts.rxdata.bak`, así que siempre puedes revertir. Cerrar la ventana con cambios sin guardar te pide confirmar.

> **Consejo:** tras guardar, ejecuta tu juego para asegurarte de que tus ediciones compilan — un error de sintaxis en un script impedirá que el juego arranque, igual que en RPG Maker XP.

## Abrir en VS Code

Si prefieres un editor externo completo, haz clic en **Open in VSC**. Esto abre la carpeta que estés mirando — la del propio plugin si tienes uno seleccionado, si no `Data/Scripts` — en [Visual Studio Code](https://code.visualstudio.com/).

Este botón es para proyectos que han **extraído** sus scripts en archivos `.rb` separados en `Data/Scripts/` (por ejemplo con un script `scripts_extract.rb`). Si esa carpeta aún no existe, Maker Studio te dice que extraigas primero. VS Code debe estar instalado con su comando `code` disponible en tu PATH (en VS Code: **Command Palette → "Shell Command: Install 'code' command in PATH"**).

> Si los scripts de un proyecto ya están extraídos, `Scripts.rxdata` solo contiene un pequeño cargador, así que ahí no hay nada útil que editar. Maker Studio se da cuenta y abre **Data/Scripts** por ti — este botón solo hace falta si prefieres trabajar en VS Code.
