# Atajos de teclado

Pulsa el botón de teclado de la barra de herramientas, los paneles y los diálogos para ver sus atajos y las teclas configuradas. La lista se abre junto al botón y puede extenderse fuera de un panel estrecho.

Abre **Ayuda → Atajos de teclado** para consultar y reasignar las acciones integradas. Puedes buscar por acción, categoría o atajo actual. En las tablas, `Ctrl` también admite `Comando` en macOS para las acciones reasignables. Los controles fijos y los gestos del ratón se indican donde corresponden.

Cuando hay un diálogo abierto, sus atajos tienen prioridad sobre los del espacio de trabajo. **Reiniciar aplicación** (Ctrl+R) y **Alternar DevTools** (F12) siguen disponibles en diálogos, campos de texto y el simulador. **Cerrar diálogo** (Escape) se puede reasignar en **Aplicación** y cierra el diálogo o la ventana superpuesta que esté encima. **Ctrl/Comando+Enter** es un atajo fijo que confirma el diálogo superior cuando ofrece una acción de confirmación. Enter puede enviar un diálogo de una sola línea y añade un salto de línea en un campo multilínea. Los formularios de comandos de evento con cambios sin guardar piden confirmación al cerrarse. Consulta el [Editor de eventos](events-editor.md).

## Herramientas

| Tecla por defecto | Herramienta |
|-------------|------|
| B | Brush |
| E | Eraser |
| F | Fill |
| R | Rectangle |
| O | Elipse |
| L | Línea |
| I | Eyedropper |
| S | Select |
| Shift+S | Wand |
| Shift+E | Borrador mágico |
| Espacio (mantener) | Modo Pan |

## Conmutadores de vista

| Tecla por defecto | Conmutador |
|-------------|--------|
| G | Grid |
| Ctrl+G | Mostrar u ocultar mapas vecinos |
| C | Overlay de colisión |
| D | Modo Dim |
| Shift+C | Alternar la visualización de las casillas de eventos |

## Brush

| Tecla por defecto | Acción |
|-------------|--------|
| [ | Reducir tamaño de pincel/borrador |
| ] | Aumentar tamaño de pincel/borrador |
| Alt + rueda | Ajustar tamaño de pincel/borrador (gesto fijo) |
| Q | Rotar pincel en sentido antihorario |
| W | Rotar pincel en sentido horario |
| A | Alternar pincel personalizado — cambia entre tu último [pincel personalizado](tools.md#custom-shape-brush) usado y el pincel cuadrado por defecto |
| Ctrl + B | [Usar la selección del mapa como pincel](tools.md#convertir-una-selección-en-tu-pincel) |
| Shift + pintar | Pintar sin cambiar los autotiles vecinos (gesto fijo) |
| Shift + arrastrar (Rectángulo / Elipse) | Mantener ancho y alto iguales (gesto fijo) |
| Ctrl + arrastrar | Bloquear el pintado a un eje (gesto fijo) |

## Eraser

| Tecla por defecto | Acción |
|-------------|--------|
| [ | Reducir tamaño de borrador |
| ] | Aumentar tamaño de borrador |
| Ctrl + arrastrar | Bloquear el borrado a un eje (gesto fijo) |

## Capas

| Tecla por defecto | Acción |
|-------------|--------|
| 1–9 | Seleccionar la 1.ª–9.ª capa de tiles por orden de capa, empezando por la inferior |
| V | Seleccionar la capa de eventos |
| ↑ / ↓ | Seleccionar la capa de tiles anterior o siguiente, con vuelta al llegar al extremo |
| Alt+1–9 | Alternar la visibilidad por índice de capa (1 para el índice 0 y así hasta 9 para el índice 8) |
| Alt+V | Alternar visibilidad de la capa de eventos |
| Alt + clic en el icono de ojo de una capa | Mostrar solo esa capa. Alt+clic de nuevo restaura las demás (gesto fijo). |

La navegación entre capas de tiles omite Eventos, Sombras, Niebla, Panorama y grupos gráficos personalizados. Al borrar capas extendidas pueden quedar huecos entre sus índices, así que los números seleccionan por orden de capa y las combinaciones con Alt usan el índice. Consulta [Capas](layers.md#panel-de-capas).

## Editor de tilesets

Solo mientras el editor de tilesets (Database → Tilesets) está abierto, y solo en los modos
**Priority** y **Terrain Tag**.

| Tecla por defecto | Acción |
|-------------|--------|
| 1–9, 0 | Elegir el 1.º–10.º valor de la lista — **1** es la prioridad / terrain tag **0**, **2** es el 1, y así hasta **0**, que es el décimo |

Comparten las teclas con los atajos de capas a propósito: nunca están activos a la vez, y manda la
pantalla que esté abierta. Un dígito más allá del final de la lista (un tileset tiene como mucho seis
prioridades) simplemente no hace nada. Los diez se pueden reasignar en Ayuda → Atajos de teclado, en
*Editor de tilesets*.

## Crear y reabrir

| Atajo | Acción |
|---|---|
| Ctrl+T | Abrir el diálogo Nuevo mapa en la raíz del proyecto |
| Ctrl+Shift+T | Reabrir el último mapa cerrado en esta sesión del proyecto. Repite para recuperar cierres anteriores. |
| Ctrl+W | Cerrar la pestaña del mapa activo. Pide confirmación si hay cambios sin guardar. |
| Ctrl+Tab / Ctrl+Shift+Tab | Ir a la pestaña de mapa siguiente / anterior, recorriendo la lista de forma circular. |
| Ctrl+N | Añadir una capa extendida al mapa activo |

**Ctrl+Tab / Ctrl+Shift+Tab** recorren las páginas de eventos, las secciones que se muestran en la Base de datos o las pestañas de Detalles de autotiles cuando este panel tiene el foco. En la Base de datos incluyen las pestañas ocultas que hayas revelado y funcionan desde un campo. **Cerrar diálogo** (**Escape** por defecto) cierra el Editor de eventos o la Base de datos. **Ctrl+W** cierra la pestaña activa de autotiles mientras ese panel tiene el foco.

## Zoom

| Tecla por defecto | Acción |
|-------------|--------|
| + | Acercar |
| - | Alejar |
| Ctrl + rueda | Zoom (gesto fijo) |
| Ctrl+0 | Restablecer el zoom del mapa activo al 100 % |

El atajo predeterminado `+` reconoce una pulsación de más sin Shift. Si tu distribución usa Shift para escribir `+`, usa el `+` del teclado numérico, Ctrl+rueda o reasigna **Acercar**.

## Archivo

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+S | Guardar el mapa actual |
| Ctrl+Shift+S | Guardar todos los mapas abiertos con cambios sin guardar |
| Ctrl+Alt+S | Crear sombra a partir de la selección |
| Ctrl+Z | Deshacer |
| Ctrl+Y | Rehacer |
| Ctrl+Enter | Ejecutar el juego |
| Ctrl+R | Reset App — reinicia Maker Studio en la página de bienvenida (se conserva la disposición de paneles; elige allí un proyecto para volver a abrirlo; usa **View → Layout → Refresh Layout** para restaurar la disposición por defecto) |
| F12 | Alternar DevTools |

Si pulsas **Ctrl+R** mientras hay un diálogo o el simulador abierto, un aviso nativo explica que se perderán los cambios del diálogo aún sin aplicar. Si hay mapas sin guardar, puedes elegir **Guardar todo y reiniciar**, **Descartar y reiniciar** o **Cancelar**. Cancelar conserva el editor y los borradores abiertos; si falla el guardado, se detiene el reinicio. Si no hay mapas sin guardar, confirma **Reiniciar aplicación** o **Cancelar**.

## Selección

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+A | Seleccionar todo |
| Ctrl+D | Deseleccionar (tiles, cualquier sombra seleccionada y evento[s] seleccionado[s]) |
| Ctrl+Shift+D | Quitar la selección de la Paleta de tiles — descarta la estampa y el autotile actuales, dejando nada elegido. No toca la selección del mapa. |
| Ctrl+C | Copiar las casillas seleccionadas de las capas de tiles seleccionadas |
| Ctrl+V | Mostrar la vista previa de pegado en la capa de tiles activa. Haz clic para colocarla. |
| Ctrl+X | Cortar las casillas seleccionadas de las capas de tiles seleccionadas |
| Ctrl+J | Duplicar la selección y activar la vista previa de pegado. Haz clic para colocar la copia. |
| Ctrl+Shift+C | Copiar todas las capas |
| Ctrl+Shift+V | Pegar en las capas seleccionadas |
| Ctrl+Shift+X | Cortar todas las capas |
| Ctrl + clic/arrastrar | Añadir tiles a la selección (gesto fijo) |
| Shift + clic/arrastrar | Quitar tiles de la selección (gesto fijo) |
| Delete | Vaciar las casillas seleccionadas de las capas de tiles seleccionadas |
| Escape | Cancelar un arrastre de forma o selección, cancelar la vista previa de pegado o quitar la selección |

Puedes reasignar **Cancelar**. Escape también funciona como alternativa fija durante un arrastre de forma o selección. Si el portapapeles contiene varias capas de origen, Pegar usa la que coincide con el índice de la capa activa. Consulta [Herramientas](tools.md#copiar-y-pegar).

En la **capa de eventos**, Copiar, Pegar, Cortar y Duplicar actúan sobre los eventos seleccionados. Seleccionar todo selecciona cada evento del mapa. Pegar y Duplicar muestran una vista previa que sigue al cursor desde la esquina superior izquierda del grupo. Haz clic para colocarla o usa Cancelar para descartarla. Consulta el [Editor de eventos](events-editor.md#copiar-eventos).

## Navegación

Puedes reasignar **Desplazar (mantener)**. El lienzo del mapa usa la tecla principal asignada e ignora sus modificadores. Si cambias la tecla con el lienzo del mapa abierto, vuelve a abrir ese mapa para usar el nuevo atajo en su lienzo. La paleta de tiles y el editor de tilesets usan la combinación completa. Los demás gestos de esta tabla son fijos.

| Tecla | Acción |
|-----|--------|
| Espacio (mantener) + arrastrar | Desplazar |
| Arrastrar con clic central | Pan |
| Rueda del ratón | Desplazar viewport |
| Shift + rueda | Desplazar en horizontal |
| Ctrl + rueda | Zoom |
| Alt + clic | Cuentagotas y cambia a Pincel (Relleno, Rectángulo, Elipse y Línea se mantienen) |

## Editor de propiedades de tileset

En el editor y la paleta de tiles, mantén el atajo **Pan** (Espacio por defecto) o el botón central del ratón y arrastra. Funciona aunque otro control tenga el foco.

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+S | Guardar tileset (mantiene el editor abierto) |
| Ctrl+Z | Deshacer edición de tileset o cambio de selección |
| Ctrl+Y | Rehacer edición de tileset o cambio de selección |
| Ctrl+A | Seleccionar todos los tiles |
| Ctrl+D | Deseleccionar tiles |

## Editor de eventos (lista de comandos)

| Tecla por defecto | Acción |
|-------------|--------|
| Espacio | Editar el comando seleccionado |
| Delete | Borrar comando |
| Insert | Insertar nuevo comando |
| Ctrl+C | Copiar comando |
| Ctrl+V | Pegar comando |
| Ctrl+X | Cortar comando |
| Ctrl+J | Duplicar el/los comando(s) seleccionado(s) — pega una copia ahí mismo, sin tocar lo que tengas copiado |
| Ctrl+A | Seleccionar todos los comandos de la lista (la fila End final de la página queda fuera) |
| Ctrl+Z / Ctrl+Y | Deshacer o rehacer cambios en los comandos |
| Escape | Cerrar el selector de comandos o el formulario de parámetros con **Cerrar diálogo**. Al insertar un comando nuevo, cerrar el formulario vuelve al selector. |
| Alt + ↑ | Mover comando arriba |
| Alt + ↓ | Mover comando abajo |
| ↑ | Comando anterior (salta las líneas extra de un Show Text / Comment / Script multilínea) |
| ↓ | Comando siguiente (igual) |
| Shift+↑ / Shift+↓ | Ampliar la selección al comando anterior o siguiente (fijo) |

## Editor de eventos (pestañas de página)

Haz clic en una pestaña de página para dar el foco a la tira de pestañas; a partir de ahí estas
teclas actúan sobre toda la página — un historial de deshacer separado del de la lista de comandos
de abajo.

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+C | Copiar página |
| Ctrl+X | Cortar página |
| Ctrl+V | Pegar página (añade una página nueva tras la pestaña en la que estás) |
| Ctrl+J | Clonar la página actual (igual que el botón **+** de pestaña / clic derecho → Clonar página) |
| Ctrl+Z | Deshacer una edición de página, incluida la creación, eliminación o clonación de páginas |
| Ctrl+Y | Rehacer edición de página |

## Base de datos

Usa el atajo configurado para **Guardar**, **Ctrl+S** por defecto, para aplicar cambios en el editor activo de XP, Animaciones, Eventos comunes o tilesets.

Con una pestaña enfocada, pulsa **Alt+Shift+←** o **Alt+Shift+→** para moverla una posición. Estos controles son fijos.

En las listas de Actores, Clases, Habilidades, Objetos, Armas, Armaduras, Enemigos, Tropas y Estados, **F4** y **F5** son controles fijos para seleccionar el registro anterior o siguiente con el foco en la lista. En Windows, WebView2 puede interceptar F5 antes de que llegue a la lista. Si ocurre, haz clic en el registro para seleccionarlo. Con el foco en la lista funcionan los atajos configurados para Copiar, Cortar, Pegar, Duplicar y Eliminar. Deshacer y Rehacer, **Ctrl+Z** y **Ctrl+Y** de forma predeterminada, funcionan también en los formularios de las pestañas de XP, incluido Sistema. El buscador y el editor de comandos de evento conservan sus propios atajos.

En Tilesets, Eventos comunes, Animaciones, Interruptores y Variables, haz clic en una fila para darle el foco; a partir de ahí estas teclas
actúan sobre todo el registro — un historial de deshacer por lista. Consulta
[Database](database.md#copiar-cortar-y-pegar-registros).

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+C | Copiar el registro seleccionado (o el nombre, en Switches/Variables) |
| Ctrl+X | Cortar — copia y luego quita. Vacía la ranura en Common Events/Animations en vez de renumerar; abre la confirmación de borrado en Tilesets |
| Ctrl+V | Pegar (reemplazar) sobre el registro seleccionado |
| Ctrl+J | Duplicar el registro seleccionado — añade una copia en una ranura nueva al final de la lista |
| Ctrl+Z | Deshacer la última edición de esa lista — pegar, cortar, reemplazar, duplicar, añadir, borrar y Change Maximum cuentan todas, incluidas las escrituras a disco de Tilesets |
| Ctrl+Y | Rehacer la última edición de esa lista |

Fuera de la lista de registros de Animaciones, el editor usa Copiar, Pegar, Cortar, Deshacer y Rehacer para las celdas y los fotogramas. Usa **Delete** o la alternativa fija **Backspace** para borrar la celda seleccionada. En el selector de interruptores o variables, **↑ / ↓** seleccionan la entrada visible anterior o siguiente.

## Editor de eventos (ruta de movimiento)

En **Establecer ruta de movimiento**, haz clic para seleccionar una acción. **Shift+clic** amplía la selección y **Ctrl+clic** alterna una fila. Copiar, Cortar, Borrar y arrastrar actúan sobre las acciones seleccionadas.

| Tecla por defecto | Acción |
|-------------|--------|
| Espacio / Enter | Editar la acción seleccionada. Espacio es la tecla predeterminada de **Editar comando**. Enter es una alternativa fija. |
| Ctrl+C / Ctrl+V / Ctrl+X | Copiar / Pegar / Cortar acciones de movimiento (portapapeles separado de los comandos de evento) |
| Ctrl+Z | Deshacer edición de ruta de movimiento |
| Ctrl+Y | Rehacer edición de ruta de movimiento |
| Delete | Borrar comando de movimiento |
| ↑ / ↓ | Acción de movimiento anterior / siguiente |
| Alt + ↑ / ↓ | Mover la acción seleccionada arriba / abajo |
| ← / → (con el separador de secuencia enfocado) | Cambiar el ancho del panel de secuencia de la ruta (fijo) |

## Editor de rutas de movimiento (Dibujar ruta)

Solo se aplican mientras el editor visual de rutas está abierto, por eso pueden usar las flechas a secas sin chocar con nada más. Todos son reasignables — mira [Set Move Route](events-editor.md#dibujar-ruta--el-editor-visual-de-rutas).

| Tecla por defecto | Acción |
|-------------|--------|
| ↑ / ↓ / ← / → | Añadir un paso en esa dirección |
| Ctrl + ↑ / ↓ / ← / → | Añadir un Turn en esa dirección |
| Backspace | Quitar último paso |
| Espacio (mantener) + arrastrar | Desplazar el mapa con **Desplazar (mantener)** |
| Delete | Eliminar los pasos seleccionados |
| Ctrl+Z / Ctrl+Y | Deshacer / rehacer cualquier edición en el editor de rutas (un trazo completo de arrastre cuenta como un paso) |

El botón **Controles** de la barra de herramientas del editor muestra todos los controles.

## Editor de scripts

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+F | Buscar (y reemplazar) en el script actual |
| Ctrl+Shift+F | Buscar en todos los scripts |
| Ctrl+S | Guardar en la fuente de scripts actual. Si es un archivo de scripts, escribe en `Scripts.rxdata`. |
| Ctrl+Z / Ctrl+Y | Deshacer o rehacer dentro del editor de código |

Escape cierra el panel de búsqueda en todos los scripts cuando tiene el foco. Con la búsqueda del script actual abierta, CodeMirror usa **F3 / Shift+F3** para ir al resultado siguiente o anterior y Escape para cerrar la búsqueda. **Tab / Shift+Tab** cambian la sangría en el editor de código. Estos controles son fijos. Consulta la [guía del editor de scripts](scripts.md#encontrar-cosas).

## Panel de eventos

| Tecla por defecto | Acción |
|-------------|--------|
| Delete | Borrar el evento seleccionado (o todos los eventos seleccionados por caja) |
| Ctrl+D | Deseleccionar evento(s) |
| Escape | Deseleccionar los eventos y quitar su resaltado del mapa con la lista de Eventos enfocada (fijo) |
| F2 | Renombrar el único evento seleccionado |

F2 requiere un solo evento seleccionado y el foco en la lista fuera de un campo editable. Usa el botón **Deseleccionar** del panel para limpiar la selección con el ratón.

En la **capa de eventos**, la herramienta **Select** hace selección de caja de eventos: arrastra un marco (Ctrl+arrastrar añade, Shift+arrastrar quita), arrastra la selección para mover el grupo, Delete los quita todos. Consulta [Editor de eventos](events-editor.md#seleccionar-y-mover-eventos).

## Panel Mapas (lista de mapas)

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+C | Copiar el mapa seleccionado |
| Ctrl+X | Cortar el mapa seleccionado (pide confirmación) |
| Ctrl+V | Pegar los últimos tiles o el último mapa copiado o cortado |
| Ctrl+J | Duplicar el mapa seleccionado (igual que clic derecho → Duplicate Map) |
| Delete | Borrar el mapa seleccionado (pide confirmación, igual que clic derecho → Delete Map) |
| F2 | Renombrar en línea el único mapa seleccionado o el mapa activo si no hay filas seleccionadas |

En el panel Mapas, **Ctrl+clic** alterna filas y **Shift+clic** selecciona el rango visible. Arrastra una fila seleccionada para mover juntas todas las raíces seleccionadas con sus descendientes. Delete permite conservar los descendientes en las posiciones de los mapas borrados o borrarlos también; la confirmación avisa de mapas abiertos con cambios sin guardar. F2 renombra el único mapa seleccionado o, si no hay filas seleccionadas, el mapa activo. No hace nada si hay varios mapas seleccionados, si no hay selección ni mapa activo o si se está editando el filtro. Ctrl+C y Ctrl+X actúan sobre el único mapa seleccionado o sobre el mapa activo si no hay filas seleccionadas. El menú contextual ofrece las mismas acciones **Copiar mapa** y **Cortar mapa**. **Pegar mapa** en ese menú siempre busca un mapa entero, aunque la última copia haya sido de tiles. Consulta [Gestión de mapas](map-management.md#copiar-un-mapa-entre-proyectos).


## Panel de capas (lista de capas)

Haz clic en una fila del panel de capas para darle el foco. **Ctrl/Meta+clic** alterna filas y **Shift+clic** selecciona el rango visible sin cambiar la capa activa. Las herramientas del lienzo editan juntas las capas de tiles seleccionadas; un trazo se deshace de una vez.

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+C | Copiar la capa activa, tiles y ajustes por tile incluidos (igual que clic derecho → Copiar capa) |
| Ctrl+X | Cortar la capa activa — la copia y luego la vacía (igual que clic derecho → Cortar capa) |
| Ctrl+V | Pegar la capa copiada — siempre pregunta si quieres reemplazar la capa activa o pegar en una capa nueva (igual que clic derecho → Pegar capa) |
| Ctrl+J | Duplicar la capa activa, tiles incluidos — también funciona en capas nativas, y la copia siempre se convierte en una capa extendida nueva (igual que clic derecho → Duplicar capa) |
| Delete | Borrar las capas extendidas de tiles seleccionadas si todas se pueden eliminar |
| F2 | Renombrar en línea la única capa seleccionada |

Estas acciones usan la selección o la capa activa del panel de capas cuando tiene el foco. El portapapeles funciona con capas de tiles nativas y extendidas. F2 requiere una sola capa de tiles seleccionada y el foco fuera de un campo editable. Delete requiere que todas las filas seleccionadas sean capas de tiles extendidas que se puedan borrar. Con el foco en la lista, Shift+↑ y Shift+↓ amplían la selección de filas visibles. Consulta [Capas](layers.md#panel-de-capas).

## Simulador de juego

| Tecla por defecto | Acción |
|-------------|--------|
| Espacio | Reproducir o pausar |
| . | Avanzar un frame |
| R | Reiniciar |
| Escape | Cerrar el simulador con **Cerrar diálogo**. Si están abiertos los ajustes del simulador, la primera pulsación cierra los ajustes. |
| C | Botón OK / acción |
| X | Cancelar |
| Y | Alternar modo de cámara |
| Flechas | Mover al jugador en la simulación de mapas. Arriba y Abajo también recorren las opciones o ajustan un valor numérico. |

## Pestañas

En Fragmentos y Mods, **Siguiente pestaña** (Ctrl+Tab) y **Anterior pestaña** (Ctrl+Shift+Tab) usan la misma asignación que en las pestañas de mapa. En Fragmentos, **← / →** también cambian de biblioteca con el foco en una pestaña de biblioteca. Estas flechas y los gestos de pestañas del mapa son fijos.

| Tecla | Acción |
|-----|--------|
| Alt + clic en pestaña | Cerrar pestaña |
| Clic central en pestaña | Cerrar pestaña |
| Doble clic en pestaña de vista previa | Promover a pestaña permanente |

## Otros controles fijos

| Pantalla | Teclas y acciones |
|----------|------------------|
| Pantalla de bienvenida | **← / →** cambian de pestaña con el foco en la barra. **Alt+↑ / Alt+↓** mueven el proyecto enfocado en una lista que admite reordenación. |
| Ajustes de la aplicación | En la lista de funciones de Supporter, **↑ / ↓** recorren las funciones. **Inicio / Fin** van a la primera o la última. |
| Paleta de tiles | En la búsqueda de tilesets, **↑ / ↓** recorren las opciones, **Enter** elige la resaltada y **Escape** cierra la lista. |
| Selector de gráficos | En la lista, **↑ / ↓** recorren los gráficos. En la vista previa, **Espacio+arrastrar** desplaza y **Ctrl+rueda** cambia el zoom. |
| Selector de ubicación | **Espacio+arrastrar**, **Shift+arrastrar** y arrastrar con el botón central desplazan. **Ctrl+rueda** cambia el zoom. |
| Códigos de texto de eventos | Con las sugerencias abiertas, **↑ / ↓** recorren la lista, **Enter / Tab** insertan la sugerencia y **Escape** cierra la lista. |
| Campos en línea | En los campos compatibles, **Enter** confirma y **Escape** cancela la edición en curso. |
| Diálogo de Git | Con el foco en un separador de columnas del gráfico, **← / →** ajustan el ancho y **Shift** amplía el ajuste. El separador del historial usa **↑ / ↓ / Inicio / Fin**. **Shift+F10** o la tecla Menú abren el menú de un archivo del commit. |
| Vista previa de imágenes de Git | **Inicio** restablece la vista, **+ / −** cambian el zoom y las flechas desplazan la imagen. |
| Diagnóstico del lienzo | **Ctrl+Alt+Shift+P** alterna el diagnóstico de renderizado con el lienzo visible y sin diálogos modales abiertos. |

## Personalizar atajos

Haz clic en una acción de **Ayuda → Atajos de teclado** y pulsa la nueva combinación. Si ya está en uso, **Mantener** comparte la nueva tecla, **Intercambiar** asigna tu tecla anterior a las otras acciones en conflicto y **Cancelar** recupera tu asignación anterior. Si otras acciones siguen usando la tecla anterior, **Actualizar todo** también las cambia y **Solo este** conserva sus asignaciones.

Dos acciones pueden compartir tecla cuando funcionan en contextos distintos. Por ejemplo, `1` selecciona una capa del mapa o un valor del tileset. Acciones compartidas como **Deshacer** tienen una única asignación que se usa en todos los editores compatibles. Usa el botón de restablecer de cada fila para recuperar su valor predeterminado o **Restablecer todo** para recuperar los de las acciones integradas y los menús de mods. Las asignaciones se conservan entre sesiones.

## Atajos de mods

Los mods instalados pueden añadir atajos de menú. Reasígnalos en la sección **Mods** de **Atajos de teclado**, con las mismas opciones en caso de conflicto que las acciones integradas. Un mod también puede definir controles para su propio panel o diálogo. Consulta esos controles en la ayuda contextual del botón de teclado.
