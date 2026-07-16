# Editor de tilesets

## Abrir el editor de tilesets

Abre el **Tileset Manager** desde la pestaña **Tilesets** de la Database (**Tools → Database…**, o el botón **Database** de la barra de herramientas). El gestor lista cada tileset (con una lista con búsqueda); selecciona uno y haz clic en **Edit Properties...** para abrir el editor de tilesets para él.

(El comando aparte **Map → Change Tileset...** es distinto — intercambia qué tileset usa un *mapa* para sus capas nativas; consulta [Gestión de mapas](map-management.md). No edita las propiedades de los tiles.)

## Resumen

El editor de tilesets te permite modificar las propiedades base de cada tile de un tileset. Son los mismos ajustes que encuentras en RPG Maker XP bajo Database y luego Tilesets. Los cambios hechos aquí se aplican a todos los mapas que usan este tileset.

## Modos de edición

### Passage (paso)

Haz clic en un tile para alternar entre totalmente transitable (todas las direcciones abiertas) y totalmente bloqueado (mostrado como una x roja). Haz clic derecho para restablecer un tile a su ajuste de paso por defecto.

### Passage (4 direcciones)

Haz clic en uno de los cuatro cuadrantes dentro de un tile para bloquear o desbloquear esa dirección concreta (Arriba, Abajo, Izquierda, Derecha). Cada dirección se puede alternar de forma independiente, dándote control fino sobre exactamente cómo puede moverse el jugador a través de un tile.

### Priority (prioridad)

Haz clic para recorrer los niveles de prioridad 0 a 5:

- **0** = Suelo. El jugador camina por delante del tile.
- **1–5** = Por encima. El jugador camina por detrás del tile (p. ej. copas de árboles), en el juego y en el Simulador.

La prioridad controla la **oclusión del jugador en el juego**, no el orden de dibujo del editor — en el lienzo del editor los tiles siempre se dibujan en orden de capa (ver [Capas](layers.md)). En el juego, la prioridad que se aplica en una casilla viene del tile superior colocado ahí.

### Bush Flag

Activa o desactiva la bandera de matorral (bush). Cuando está activada, los tiles bajo un overlay de matorral aparecen parcialmente ocultos, simulando hierba alta o follaje.

### Counter Flag

Activa la bandera de mostrador (counter). Permite la interacción a través del tile — útil para cosas como mostradores de tienda donde el jugador habla con un evento al otro lado.

### Terrain Tag

Elige un terrain tag del desplegable con búsqueda, luego haz clic en un tile (o selecciona una región arrastrando y pulsa **Apply**) para asignarlo. La lista incluye tags con nombre 0–17 (los valores por defecto de Pokémon Essentials), y puedes filtrar por nombre o número. Los mods instalados pueden añadir sus propios tags con nombre a este mismo desplegable. Los terrain tags los usan eventos y scripts para comportamientos específicos del terreno, como cambiar la velocidad de movimiento en arena frente a carretera, y se leen en el juego a través del terrain tag del motor.

**Sonido de la hierba (grass rustle).** Cuando el jugador pisa un tile cuyo terrain tag hace crujir la hierba (como **Grass**), es el motor —no Maker Studio— quien reproduce la **animación 1** ("Grass rustle") de la base de datos de Animaciones de tu proyecto. En un proyecto de Pokémon Essentials sin modificar esa animación no tiene ningún timing de SE, así que el crujido se reproduce sin sonido; algunos kits (La Base de Sky, por ejemplo) sí traen un sonido en ella. Para añadirlo, dale a la animación 1 un timing de SE en la pestaña **Animations** de la [Base de datos](database.md). El terrain tag funciona correctamente — el sonido vive en la animación.

## Editar propiedades de autotiles

El paso/prioridad/terreno de los autotiles se edita por separado de los tilesets normales. En el Tileset Manager, elige la entrada **Autotiles** (mostrada como `000: Autotiles` en lo alto de la lista) y haz clic en **Edit Properties...**. Esto abre una cuadrícula dedicada de cada autotile (ranuras nativas + autotiles extra con nombre). Editar una propiedad para un autotile la aplica a los 48 tiles de patrón de ese autotile a la vez.

Las propiedades de autotile son **por gráfico**: la cuadrícula muestra los valores actuales de cada autotile leídos del tileset que lo contiene de forma nativa, y al guardar esos valores se aplican a todos los tilesets que usan ese gráfico (emparejado por su nombre de archivo). Los tilesets que no contienen el gráfico no se tocan, así que el resto de ajustes de autotiles de cada tileset se conservan.

## Guardar

Haz clic en **Save** para escribir tus cambios en `Tilesets.rxdata`. Se crea una copia de seguridad del archivo original automáticamente en el primer guardado. El editor permanece abierto tras guardar, así que puedes seguir ajustando propiedades — pulsa **Ctrl+S** (o **Cmd+S** en macOS) para guardar de nuevo sin cerrar, o usa **Close** cuando termines. Si cierras con cambios sin guardar, se te preguntará si guardar, descartar o cancelar.

Tras guardar, los overlays de colisión y prioridad se actualizan al instante en todos los mapas abiertos que usan el tileset — incluidos los tiles que colocaste antes. Esto se aplica a cada tile colocado: tiles normales, tiles pintados desde otro tileset, autotiles extra (con nombre) y tiles que rotaste o volteaste. Los tiles rotados y volteados reaplican automáticamente el nuevo paso en la orientación correcta, en el editor y en el juego.
