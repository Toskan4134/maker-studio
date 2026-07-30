# Simulador de juego

El Simulador de juego te permite probar eventos y rutas de movimiento sin salir del editor. Interpreta comandos de evento, anima sprites y muestra diálogos/imágenes en tiempo real.

## Abrir el simulador

Hay tres formas de abrir el simulador:

1. **Simulate Map** — haz clic en el botón **Sim Map** de la barra principal para probar todo el mapa con todos los eventos activos.
2. **Simulate Event Page** — en el editor de eventos, haz clic en el botón **▶ Simulate** para probar una sola página de evento de forma aislada.
3. **Test Move Route** — en el editor del comando Set Move Route, haz clic en **▶ Test Move Route** para probar una ruta de movimiento personalizada.

## Panel del simulador

El panel del simulador contiene:

- **Canvas** — muestra el mapa, los eventos, el jugador y los efectos (diálogo, imágenes, tono de pantalla, clima). Arrastra con clic izquierdo para desplazar; clic derecho para el menú de posición del jugador.
- **Toolbar** — Play/Pause, Step, Restart, controles de velocidad, conmutador Fixed Camera.
- **Event Log** — registra cada comando de evento ejecutado y cada paso de ruta de movimiento (info / warn / unsupported).
- **Dialogue Overlay** — muestra Show Text y Show Choices.

## Tipos de escenario

### Simulación de mapa

- **Entrada del jugador**: activada — usa las flechas para moverte, C para interactuar.
- **Cámara**: sigue al jugador.
- **Eventos**: todos los eventos parallel y autorun se ejecutan normalmente.
- **Loop**: no disponible (usa Restart para reproducir de nuevo).

### Simulación de página de evento

- **Entrada del jugador**: desactivada — observa cómo corre el evento.
- **Cámara**: sigue al evento que se está probando.
- **Eventos**: solo corre el evento probado.
- **Loop**: cuando está activado, se reinicia automáticamente al terminar el evento.

### Simulación de ruta de movimiento

- **Entrada del jugador**: desactivada — observa cómo se ejecuta la ruta.
- **Cámara**: sigue al evento objetivo (o al jugador si está seleccionado).
- **Eventos**: solo corre la ruta de movimiento.
- **Loop**: cuando está activado, se reinicia automáticamente al terminar la ruta.

## Controles

| Acción | Tecla | Descripción |
|--------|-----|-------------|
| Play/Pause | Espacio | Alterna la reproducción de la simulación |
| Step | . (punto) | Avanza un frame mientras está en pausa |
| Restart | R | Restablece al estado inicial |
| Close | Esc | Cierra el simulador |

### Controles del jugador (solo simulación de mapa)

| Acción | Tecla | Descripción |
|--------|-----|-------------|
| Andar | Mantener flechas | Movimiento fluido continuo; pulsa otra flecha para girar primero |
| Botón de acción | C | Interactuar con el evento de enfrente |
| Cancelar | X | Cancelar / atrás (solo se registra) |

El jugador anda de forma continua mientras se mantiene una tecla de dirección — sin necesidad de re-pulsar por tile. Pulsar brevemente otra dirección gira en el sitio; mantenerla tras girar empieza a moverse. La animación de caminar recorre todo el charset de RMXP (frames 0→1→2→3→0), igual que la animación del personaje en el juego.

### Controles de cámara

| Acción | Entrada | Descripción |
|--------|-------|-------------|
| Pan | Arrastrar con clic izquierdo en el lienzo | Desplaza la cámara; desactiva el seguimiento hasta que reactives Fixed Camera |
| Alternar modo de cámara | Tecla Y o botón 📷 Fixed Camera | Por defecto ON: la cámara sigue al jugador/evento. OFF: cámara libre, arrastra para desplazar |
| Pan | Arrastrar ratón / Rueda | Arrastra o rueda para desplazar. Shift+Rueda para horizontal |
| Establecer posición del jugador | Clic derecho en el lienzo | Abre el menú contextual, haz clic en "Set Player Position Here" |

## Funciones admitidas

El simulador admite muchos comandos de evento de RPG Maker XP:

- **Message**: Show Text, Show Choices, Input Number.
- **Flow Control**: Conditional Branch, Loop, Break Loop, Label, Exit Event Processing.
- **Game Data**: Control Switches, Control Variables, Control Self Switches, Control Timer.
- **Movement**: Set Move Route (los 45 comandos de movimiento completos), Wait for Move's Completion.
- **Map**: Transfer Player, Set Event Location, Scroll Map.
- **Screen**: Show/Move/Erase Pictures, Change Screen Color Tone, Screen Flash, Screen Shake, Set Weather Effects.
- **Audio**: Play BGM / BGS / ME / SE, Fade Out BGM / BGS, Memorize & Restore BGM/BGS, Stop SE — los archivos suenan directamente desde la carpeta `Audio/` de tu proyecto (`.ogg`/`.mp3`/`.wav`; `.mid`/`.midi` mediante el sintetizador integrado). Se aplican volumen y pitch. BGM/BGS hacen loop y se pausan con el sim; reiniciar o cerrar el simulador detiene todo el audio.
- **Character**: Change Transparent Flag, Change Graphic.

## Funciones no admitidas

Los siguientes comandos se registran pero no se ejecutan (requieren Game.rxdata o PluginScripts.rxdata):

- **Battle Processing** (301) — requiere sistema de batalla.
- **Shop Processing** (302) — requiere sistema de tienda.
- **Name Input** (303) — requiere sistema de entrada de nombre.
- **Menu/Save/Game Over/Title** (351-354) — requiere scripts del sistema.
- **Script** (355/655) — el simulador no puede ejecutar Ruby, así que los scripts se registran en vez de ejecutarse — pero **ahora se muestra el texto completo del script en el log** (la primera línea en la fila del comando, cada línea restante como una fila `↳` indentada).

## Opciones de la barra de herramientas

- **Speed**: velocidad de reproducción 0,25×, 0,5×, 1×, 2× o 4×. Se conserva tras Restart para que los reinicios no te devuelvan a 1×.
- **Loop** (solo Event Page / Move Route): reinicio automático al terminar. Se conserva tras Restart.
- **Fixed Camera**: ON (por defecto) sigue al jugador/evento. OFF desacopla la cámara para que puedas arrastrar con clic izquierdo o desplazar con WASD. El conmutador se conserva tras Restart.

El antiguo botón "📍 Set Player" de la barra se ha reemplazado por el menú contextual de clic derecho en el lienzo. Haz clic derecho en cualquier tile y elige "Set Player Position Here".

## Event Log

Cada comando de evento ejecutado y cada paso de ruta de movimiento se registra en su propia línea para que puedas rastrear la ejecución turno a turno. Cada fila muestra el **frame**, la **fuente** que lo ejecutó (System / Player / nombre del evento), luego el **código** del comando, el **nombre** y un resumen de parámetros.

**El código de color** coincide con la lista de comandos del editor de eventos — toda la fila se tiñe por categoría (text, flow control, variables, pictures, audio, move route, …) para que puedas escanear el log igual que lees una página de evento.

**El nombre de la fuente se muestra una vez.** Cuando una serie de comandos viene del mismo evento, solo la primera fila muestra el frame y el nombre del evento; el resto se alinea debajo, así la lista queda limpia.

**El nivel de soporte** es una pista aparte — una franja izquierda de color más una etiqueta — para que veas tanto *de qué tipo* de comando se trata como *si el simulador lo ejecutó*:

- **Info** (sin etiqueta): los comandos implementados corren normalmente.
- **Unsupported** (franja roja + etiqueta `unsupported`): comandos que necesitan `scripts.rxdata` / `PluginScripts.rxdata` (batallas, tienda, common events, scripts) — registrados pero no ejecutados.
- **Warn** (franja ámbar + etiqueta `warn`): casos límite parcialmente admitidos (p. ej. tipos de fuente de variable que no están cargados).

**Show Text**, **Comment** y **Script** muestran cada línea: la primera línea en la fila del comando, cada línea extra como su propia fila `↳` indentada debajo.

Las entradas de ruta de movimiento llevan el prefijo `Move:` y el color de subcomandos de movimiento; el código mostrado es el código de movimiento subyacente (1–45).

**El log se queda quieto mientras lees.** El tamaño del panel es fijo, así que los logs en streaming nunca redimensionan la ventana del simulador ni cambian las alturas de fila. El autodesplazamiento solo sigue la entrada más nueva cuando ya estás abajo del todo — desplázate hacia arriba para inspeccionar una fila anterior y las nuevas entradas no te arrastrarán hacia abajo. Aparece un botón **↓ Latest** para volver al fondo.

Las entradas repetidas se colapsan con un contador `×N` en vez de inundar el log. Esto es consciente de los loops: un solo comando que se dispara 100× cuenta como una fila, y un **cuerpo de loop multi-comando** que se repite (p. ej. text → move → move → wait → move, una y otra vez) se colapsa en las filas de ese cuerpo, cada una mostrando cuántas veces corrió. Así un loop apretado cuenta como una pasada frente al límite del log y nunca expulsa tu historial anterior por arriba.

## Ajustes

Haz clic en ⚙ Settings para configurar:

- **Player Start Position**: coordenadas X/Y del spawn del jugador.
- **Player Character**: qué sprite de personaje usar.
- **Canvas Size**: tamaño del viewport del simulador (presets: Default 512×384, Amplified 640×440).
- **FPS máximos**: la tasa de frames de tu propio juego — 60 por defecto, que es a lo que corren Essentials v20/v21. El simulador hace tick a ese ritmo y todo lo anclado a tiempo real (velocidad de movimiento, Wait, Screen Shake) escala con él, así que si tu proyecto corre el motor a otra tasa, indicarla aquí mantiene la temporización de la vista previa igual a la del juego. Se guarda por proyecto.
