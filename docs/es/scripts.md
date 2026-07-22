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

## Guardar

Haz clic en **Save** (o pulsa `Ctrl+S`) para escribir todo de vuelta en `Data/Scripts.rxdata`. Tu archivo anterior se respalda primero en `Data/Scripts.rxdata.bak`, así que siempre puedes revertir. Cerrar la ventana con cambios sin guardar te pide confirmar.

> **Consejo:** tras guardar, ejecuta tu juego para asegurarte de que tus ediciones compilan — un error de sintaxis en un script impedirá que el juego arranque, igual que en RPG Maker XP.

## Abrir en VS Code

Si prefieres un editor externo completo, haz clic en **Open in VSC**. Esto abre la carpeta `Data/Scripts` en [Visual Studio Code](https://code.visualstudio.com/).

Este botón es para proyectos que han **extraído** sus scripts en archivos `.rb` separados en `Data/Scripts/` (por ejemplo con un script `scripts_extract.rb`). Si esa carpeta aún no existe, Maker Studio te dice que extraigas primero. VS Code debe estar instalado con su comando `code` disponible en tu PATH (en VS Code: **Command Palette → "Shell Command: Install 'code' command in PATH"**).

> Si los scripts de un proyecto ya están extraídos, `Scripts.rxdata` solo contiene un pequeño cargador, así que la lista en el editor mostrará solo una entrada (`Main`). Edita los archivos reales en `Data/Scripts/` con el botón de VS Code en su lugar.
