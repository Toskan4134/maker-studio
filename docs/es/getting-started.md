# Primeros pasos

## Requisitos previos

Necesitas una carpeta de proyecto de RPG Maker XP — en concreto, un directorio que contenga `Game.exe` y una subcarpeta `Data/` con tus archivos de mapa y tileset. El editor lee y escribe los archivos `.rxdata` directamente, así que no hace falta ningún paso de exportación ni conversión.

## Arranque

Ejecuta el programa del editor. En el primer arranque verás una pantalla de bienvenida que te pide elegir una carpeta de juego. Haz clic en **Examinar** y navega hasta la raíz de tu proyecto de RPG Maker XP (la carpeta que contiene `Game.exe`).

El editor recuerda tu último proyecto abierto, así que en los siguientes arranques irá directo al árbol de mapas.

## Abrir un mapa

El panel del Árbol de mapas, a la izquierda, muestra todos los mapas de tu proyecto, organizados en la misma jerarquía que configuraste en RPG Maker XP. Haz doble clic en cualquier mapa para abrirlo en una pestaña nueva. Los mapas con un punto indicador junto a su nombre tienen cambios sin guardar.

Al abrir un proyecto aparece una tarjeta de "Cargando proyecto..." en el área del editor de mapas que lista cada paso de carga (mapas, tilesets, datos del sistema, apertura del primer mapa y gráficos de tileset) con un contador de progreso. El resto de la interfaz permanece visible alrededor, y la tarjeta desaparece cuando todo —incluidos todos los gráficos de tileset— ha terminado de cargar, dejando el primer mapa listo para editar.

## Navegación

Moverse por el lienzo es sencillo:

- **Desplazar (Pan)**: mantén Espacio y arrastra, o arrastra con el botón central, o con Shift y arrastra.
- **Zoom**: Ctrl + rueda del ratón, o usa los botones + / - de la barra de herramientas. El zoom va del 5% al 400% — el extremo bajo te deja ver un mapa grande entero de una vez.
- **Barra de estado**: muestra las coordenadas del cursor (X, Y) en el borde inferior de la ventana.

## Guardar

Pulsa Ctrl+S para guardar el mapa actual. Los cambios se escriben directamente en el archivo `.rxdata` correspondiente. Cada guardado primero respalda el archivo anterior en `Data/map-backups/` (se conservan las 10 copias más recientes por archivo), así que siempre puedes revertir si algo va mal, y las escrituras son a prueba de fallos — un cierre inesperado o un corte de luz a mitad de guardado nunca pueden dejar un archivo a medio escribir. El trabajo sin guardar también se autoguarda en segundo plano cada pocos minutos; consulta [Gestión de mapas → Autoguardado y recuperación tras fallos](map-management.md#autosave-and-crash-recovery).

## Compilar desde el código fuente

Si prefieres compilar el editor tú mismo:

```bash
npx tauri build              # Compilación de producción
npm run tauri:dev            # Modo desarrollo con recarga en caliente
```
