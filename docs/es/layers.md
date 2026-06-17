# Guía de capas

## Capas nativas (0–2)

El editor ofrece tres capas nativas totalmente compatibles con RPG Maker XP. Estas capas usan el tileset asignado al mapa y los IDs de tile estándar. Las capas nativas son exactamente lo que RMXP lee y renderiza, así que cualquier cosa que pintes aquí aparecerá correctamente cuando el juego corra solo en RMXP.

## Capas extendidas (3+)

Más allá de las tres capas nativas, el editor admite capas extendidas ilimitadas. Las capas extendidas ofrecen varias funciones no disponibles en RMXP:

- **Tiles entre tilesets**: pinta tiles de cualquier tileset, no solo del predeterminado del mapa.
- **Autotiles extra**: usa autotiles con nombre más allá del límite de ocho ranuras de RMXP.
- **Efectos por tile**: define opacidad, rotación, hue, saturación, iluminación y volteo individuales para cada tile.
- **Paso, prioridad y terreno por tile**: sustituye las propiedades de juego tile a tile.

Los datos de capa extendida se incrustan dentro del archivo `.rxdata` del mapa. Son invisibles para RMXP en sí, pero el plugin de runtime del editor los lee y los renderiza en el juego.

## Panel de capas

El panel de capas lista cada capa — nativas, extendidas y de sombra por igual, más los grupos de capa de fog / panorama / personalizados descritos abajo.

- **Insignia MS**: las filas de capa extendida, las filas de grupo de fog/panorama (y cualquier grupo añadido por mods) y la fila de grupo de sombras llevan una pequeña insignia **MS** — estas funciones requieren el plugin MakerStudio en el juego (consulta [Indicadores de funciones exclusivas de MS](interface-guide.md#ms-exclusive-feature-indicators)). Las filas de capa nativa no llevan insignia porque funcionan en RMXP estándar. Oculta las insignias con **View → Show MS-Exclusive Indicators**.
- **Icono de ojo**: activa y desactiva la visibilidad de la capa.
- **Deslizador de opacidad**: ajusta la transparencia general de la capa. Arrastrar el deslizador ajusta solo la opacidad — ya no reordena la capa.
- **Arrastrar una fila de capa**: arrastra una capa extendida por su nombre para reordenarla. (Arrastrar desde el icono de ojo, el deslizador de opacidad o el botón de borrar no hace nada, así que puedes usar esos controles libremente.)
- **Clic derecho**: renombra una capa.
- **Clic en una sub-fila de sombra**: selecciona esa sombra — su sub-fila se resalta, se dibuja un contorno cian en el lienzo y (en modo Dim) solo esa sombra recupera la opacidad completa mientras las demás siguen atenuadas. Pulsa `Ctrl+D` para deseleccionar.

## Grupos de capa de fog, panorama y personalizados

Además de las capas de tiles, el panel de capas alberga **grupos de capa de imagen** — gráficos a pantalla completa dibujados encima o debajo de tus tiles. Dos grupos siempre están presentes:

- **Fog Layers** — dibujados *encima* de todos los tiles, como el fog de RPG Maker XP, pero puedes apilar tantos como quieras. Las imágenes vienen de `Graphics/Fogs/`. Las nuevas capas de fog empiezan al 20% de opacidad.
- **Panorama Layers** — dibujados *debajo* de todos los tiles, reemplazando el panorama único del tileset. Las imágenes vienen de `Graphics/Panoramas/`. Las nuevas capas de panorama empiezan a opacidad completa. Consulta [Gestión de mapas](map-management.md#panorama-layers-and-battleback) para saber cómo se captan automáticamente los panoramas de tileset existentes.

Ambos grupos funcionan igual:

- **+** en la fila del grupo añade una capa; cada capa tiene su propia sub-fila con botones de editar y borrar.
- El **icono de ojo del grupo** muestra/oculta todas las capas del grupo a la vez; la opacidad se configura por capa en el popup de edición.
- El **popup de edición** elige la imagen con el selector de imágenes estándar (vista previa en vivo, favoritos, Examinar) y ofrece por capa **hue**, **opacidad**, **modo de mezcla** (normal/add/subtract/multiply), **zoom**, velocidades **scroll X/Y**, **Follow camera** (fija la imagen a la pantalla) y — para capas ancladas al mundo — un deslizador **Parallax** (0–1): `1` se mueve con el mapa, `0.5` es la clásica media velocidad del panorama de RMXP, `0` queda fijo en pantalla.
- Todo se renderiza en vivo en el lienzo del editor (desplazamiento incluido) y en el juego por el plugin MakerStudio, recortado por mapa para que los mapas conectados no se mezclen.

**Grupos de capa personalizados**: los mods pueden registrar grupos extra del mismo tipo, cada uno con su propia subcarpeta `Graphics/` y su propia prioridad de dibujo (debajo o encima de los tiles). Aparecen como filas de grupo adicionales en el panel de capas y se guardan dentro del archivo del mapa, así que siguen renderizándose en el juego incluso cuando el mod no está instalado.

Los grupos por encima de los tiles (fog y grupos personalizados con prioridad ≥ 0) se listan cerca de la parte superior del panel; los grupos por debajo (panorama y grupos personalizados de prioridad negativa) van al fondo, reflejando su orden de dibujo.

## Overlay de colisión

Pulsa C para alternar el overlay de colisión. Muestra las banderas de paso directamente en el lienzo como flechas direccionales e indicadores de bloqueado/abierto. El overlay lee de los valores base del tileset combinados con cualquier sustitución por tile en las capas extendidas.

## Renderizado por prioridad

Los tiles con prioridad 1 o superior se renderizan por encima de los eventos y se desplazan hacia arriba en pantalla, igual que el comportamiento estándar de RPG Maker XP. Los tiles de suelo (prioridad 0) se renderizan por debajo de los eventos.
