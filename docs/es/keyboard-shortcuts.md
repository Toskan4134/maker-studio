# Atajos de teclado

Todos los atajos son personalizables en **Help → Keyboard Shortcuts...**. A continuación se listan los valores por defecto.

## Herramientas

| Tecla por defecto | Herramienta |
|-------------|------|
| B | Brush |
| E | Eraser |
| F | Fill |
| R | Rectangle |
| I | Eyedropper |
| S | Select |
| Espacio (mantener) | Modo Pan |

## Conmutadores de vista

| Tecla por defecto | Conmutador |
|-------------|--------|
| G | Grid |
| C | Overlay de colisión |
| D | Modo Dim |

## Brush

| Tecla por defecto | Acción |
|-------------|--------|
| [ | Reducir tamaño de pincel/borrador |
| ] | Aumentar tamaño de pincel/borrador |
| Alt + rueda | Ajustar tamaño de pincel/borrador |
| Q | Rotar pincel en sentido antihorario |
| W | Rotar pincel en sentido horario |
| A | Alternar pincel personalizado — cambia entre tu último [pincel personalizado](tools.md#custom-shape-brush) usado y el pincel cuadrado por defecto |
| Shift + clic | Dibujar línea desde la última posición pintada |

## Eraser

| Tecla por defecto | Acción |
|-------------|--------|
| [ | Reducir tamaño de borrador |
| ] | Aumentar tamaño de borrador |
| Shift + clic | Dibujar línea desde la última posición borrada |

## Capas

| Tecla por defecto | Acción |
|-------------|--------|
| 1–9 | Seleccionar la 1.ª–9.ª capa de tiles (contadas de arriba a abajo, saltando las filas de grupo Shadows/Fog/Panorama — así **4** siempre selecciona la capa mostrada como "Layer 4") |
| V | Seleccionar la capa de eventos |
| ↑ | Capa anterior (salta las sombras) |
| ↓ | Capa siguiente (salta las sombras) |
| Alt+1–9 | Alternar visibilidad de capa |
| Alt+V | Alternar visibilidad de la capa de eventos |

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

## Zoom

| Tecla por defecto | Acción |
|-------------|--------|
| + | Acercar |
| - | Alejar |
| Ctrl + rueda | Zoom |

## Archivo

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+S | Guardar el mapa actual |
| Ctrl+Shift+S | Guardar todos los mapas abiertos |
| Ctrl+Alt+S | Crear sombra a partir de la selección |
| Ctrl+Z | Deshacer |
| Ctrl+Y | Rehacer |
| Ctrl+Enter | Ejecutar el juego |
| Ctrl+R | Reset App — recarga el editor (se conserva la disposición de paneles; para restaurar la disposición por defecto usa **View → Layout → Refresh Layout** en su lugar) |

## Selección

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+A | Seleccionar todo |
| Ctrl+D | Deseleccionar (tiles, cualquier sombra seleccionada y evento[s] seleccionado[s]) |
| Ctrl+C | Copiar selección (capa activa) |
| Ctrl+V | Pegar (modo vista previa — clic para confirmar) |
| Ctrl+X | Cortar selección |

En la **capa de eventos**, Ctrl+C / Ctrl+V / Ctrl+X actúan sobre el evento seleccionado en su lugar — copia o corta un evento entero. Ctrl+V muestra un fantasma de vista previa que sigue al cursor; haz clic para soltar la copia (Escape para cancelar). Consulta [Editor de eventos](events-editor.md#copying-events).

| Ctrl+Shift+C | Copiar todas las capas |
| Ctrl+Shift+V | Pegar en las capas originales |
| Ctrl+Shift+X | Cortar todas las capas |
| Ctrl + clic/arrastrar | Añadir tiles a la selección |
| Shift + clic/arrastrar | Quitar tiles de la selección |
| Delete | Borrar selección |
| Escape | Cancelar selección / cancelar vista previa de pegado |

## Navegación

| Tecla | Acción |
|-----|--------|
| Espacio (mantener) + arrastrar | Pan |
| Arrastrar con clic central | Pan |
| Rueda del ratón | Desplazar viewport |
| Shift + rueda | Desplazar en horizontal |
| Ctrl + rueda | Zoom |
| Alt + clic | Eyedropper (sin cambiar de herramienta) |

## Editor de propiedades de tileset

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+S | Guardar tileset (mantiene el editor abierto) |
| Ctrl+Z | Deshacer edición de tileset |
| Ctrl+Y | Rehacer edición de tileset |
| Ctrl+A | Seleccionar todos los tiles |
| Escape | Deseleccionar tiles |

## Editor de eventos (lista de comandos)

| Tecla por defecto | Acción |
|-------------|--------|
| Space | Editar el comando seleccionado |
| Delete | Borrar comando |
| Insert | Insertar nuevo comando |
| Ctrl+C | Copiar comando |
| Ctrl+V | Pegar comando |
| Ctrl+X | Cortar comando |
| Ctrl+A | Seleccionar todos los comandos de la lista (la fila End final de la página queda fuera) |
| Escape | Cancelar el Command Picker o el formulario de parámetros abierto — desde un formulario vuelve al selector, en la página desde la que elegiste |
| Alt + ↑ | Mover comando arriba |
| Alt + ↓ | Mover comando abajo |
| ↑ | Comando anterior (salta las líneas extra de un Show Text / Comment / Script multilínea) |
| ↓ | Comando siguiente (igual) |

## Editor de eventos (ruta de movimiento)

La lista de acciones de movimiento en **Set Move Route** admite las mismas teclas de edición que la lista de comandos principal. Un clic selecciona una sola acción; **Shift+clic** extiende la selección y **Ctrl+clic** alterna — copiar, cortar, borrar y arrastrar actúan todos sobre toda la selección.

| Tecla por defecto | Acción |
|-------------|--------|
| Space / Enter | Editar la acción de movimiento seleccionada |
| Ctrl+C / Ctrl+V / Ctrl+X | Copiar / Pegar / Cortar acciones de movimiento (portapapeles separado de los comandos de evento) |
| Ctrl+Z | Deshacer edición de ruta de movimiento |
| Ctrl+Y | Rehacer edición de ruta de movimiento |
| Delete | Borrar comando de movimiento |
| ↑ / ↓ | Acción de movimiento anterior / siguiente |
| Alt + ↑ / ↓ | Mover la acción seleccionada arriba / abajo |

## Editor de scripts

| Tecla por defecto | Acción |
|-------------|--------|
| Ctrl+F | Buscar (y reemplazar) en el script actual |
| Ctrl+Shift+F | Buscar en todos los scripts |
| Ctrl+S | Guardar todos los scripts en Scripts.rxdata |

Consulta la [guía del editor de scripts](scripts.md#finding-things) para más detalles.

## Panel de eventos

| Tecla por defecto | Acción |
|-------------|--------|
| Delete | Borrar el evento seleccionado (o todos los eventos seleccionados por caja) |
| Ctrl+D / Escape | Deseleccionar evento(s) |

En la **capa de eventos**, la herramienta **Select** hace selección de caja de eventos: arrastra un marco (Ctrl+arrastrar añade, Shift+arrastrar quita), arrastra la selección para mover el grupo, Delete los quita todos. Consulta [Editor de eventos](events-editor.md#selecting-and-moving-events).

## Simulador de juego

| Tecla por defecto | Acción |
|-------------|--------|
| Space | Play / Pause |
| . | Avanzar un frame |
| R | Reiniciar |
| Esc | Cerrar el simulador |
| C | Botón OK / acción |
| X | Cancelar |
| Y | Alternar modo de cámara |
| Flechas | Mover al jugador (simulación de mapa) |

## Pestañas

| Tecla | Acción |
|-----|--------|
| Alt + clic en pestaña | Cerrar pestaña |
| Clic central en pestaña | Cerrar pestaña |
| Doble clic en pestaña de vista previa | Promover a pestaña permanente |

## Personalizar atajos

Abre **Help → Keyboard Shortcuts...** para reasignar cualquier acción. Haz clic en una fila, luego pulsa la nueva combinación de teclas. Si la tecla ya está en uso, puedes intercambiar o cancelar.

Los atajos específicos de contexto (Tileset, editor de eventos) comparten algunas teclas por defecto con atajos globales (p. ej. Ctrl+Z para deshacer). Funcionan según qué panel tiene el foco. Reasignar un atajo específico de contexto solo afecta a ese contexto.

## Atajos de mods

Los mods instalados pueden añadir sus propios elementos de menú con atajos de teclado. Aparecen en el diálogo de Keyboard Shortcuts bajo una sección **Mods**, y puedes reasignarlos igual que los atajos integrados. Los conflictos entre un atajo de mod y uno integrado (u otro mod) se detectan al asignar la tecla, así que puedes intercambiar o cancelar. Tus asignaciones personalizadas de atajos de mod persisten entre sesiones, y **Reset All** las restaura a los valores por defecto del mod junto con todo lo demás.
