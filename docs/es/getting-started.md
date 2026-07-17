# Primeros pasos

## Requisitos previos

Necesitas una carpeta de proyecto de RPG Maker XP — en concreto, un directorio que contenga `Game.exe` y una subcarpeta `Data/` con tus archivos de mapa y tileset. El editor lee y escribe los archivos `.rxdata` directamente, así que no hace falta ningún paso de exportación ni conversión.

## Instalación

Maker Studio tiene dos partes, y te interesan las dos:

1. **La app del editor** — el programa de escritorio (Windows / macOS / Linux) con el que haces los mapas.
2. **Un plugin del lado del juego ("integración")** — un pequeño plugin en Ruby que copias en tu proyecto de juego. Es lo que hace que tu *juego* muestre el contenido de Maker Studio que RPG Maker XP no soporta de serie (capas extendidas, sombras, autotiles extra…), y añade una entrada **Maker Studio** al menú Debug del juego para lanzar el editor. El editor funciona sin él, pero el juego ignorará el contenido extendido hasta que instales el plugin.

### Paso 1 — Instala la app del editor

Descarga la versión para tu sistema (estos enlaces siempre apuntan a la última versión):

| Plataforma | Descarga directa |
|------------|------------------|
| **Windows** | [Instalador `.exe`](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_x64-setup.exe) (recomendado) · [`.msi`](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_x64_en-US.msi) (alternativa) |
| **macOS** | [`.dmg`](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_aarch64.dmg) (Apple Silicon) |
| **Linux** | [`.AppImage`](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_x86_64.AppImage) (universal) · [`.deb`](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_amd64.deb) (Debian/Ubuntu) |

Todas las versiones (la actual y las anteriores) están también en la página de [Releases](https://github.com/Toskan4134/maker-studio/releases). Una vez instalada, la app se mantiene actualizada sola.

Los instaladores **aún no están firmados digitalmente**, así que tu sistema muestra un aviso único durante la instalación:

- **Windows** — ejecuta el `.exe` y, cuando SmartScreen diga "Windows protegió su PC", haz clic en **Más información → Ejecutar de todas formas** y sigue el instalador.
- **macOS** — abre el `.dmg` y arrastra Maker Studio a **Aplicaciones**. Gatekeeper bloquea el primer arranque: haz clic derecho en la app y elige **Abrir**, o en macOS 15+ ve a **Ajustes del Sistema → Privacidad y seguridad** y pulsa **Abrir igualmente**.
- **Linux** — haz ejecutable el AppImage (`chmod +x Maker.Studio_x86_64.AppImage`) y ejecútalo. Usa el WebKit de tu sistema: si no arranca, instala `webkit2gtk-4.1` y `gtk3` (Arch) o `libwebkit2gtk-4.1-0` y `libgtk-3-0` (Debian/Ubuntu). El `.deb` se instala con `sudo apt install ./Maker.Studio_amd64.deb`. En Linux el AppImage no se actualiza solo — usa [**Gear Lever**](https://flathub.org/en/apps/it.mijorus.gearlever) para gestionar actualizaciones (puede actualizar AppImages automáticamente desde GitHub releases).

### Paso 2 — Instala el plugin del lado del juego

Descarga la integración que corresponde a tu proyecto:

| Tu proyecto | Descarga directa |
|-------------|------------------|
| Pokémon Essentials **v21.1** (vanilla) | [`PE21.1.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.1.0/PE21.1.Maker.Studio.v1.1.0.zip) |
| Pokémon Essentials **v20.1** (vanilla) | [`PE20.1.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.1.0/PE20.1.Maker.Studio.v1.1.0.zip) |
| Pokémon Essentials **v19.1** (vanilla) | [`PE19.1.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.1.0/PE19.1.Maker.Studio.v1.1.0.zip) |
| La Base de Sky **1.1.x** | [`LBDS1.1.0.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.1.0/LBDS1.1.0.Maker.Studio.v1.1.0.zip) |
| La Base de Sky **1.2.x** | [`LBDS1.2.0.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.1.0/LBDS1.2.0.Maker.Studio.v1.1.0.zip) |
| Pokémon Essentials **BES v5** | [`BES5.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.1.0/BES5.Maker.Studio.v1.1.0.zip) |

> **Nota sobre v19.1:** el renderizado de tiles más antiguo de este motor hace que las sustituciones de paso/prioridad/terreno por tile en un tile normal (no de capa extendida) no afecten a la colisión dentro del juego. Las capas extendidas, los autotiles extra y los tiles cross-tileset funcionan con normalidad.

Después:

1. Descomprime el zip.
2. Copia la carpeta **`MakerStudio`** de su interior a la carpeta **`Plugins/`** de tu juego, de modo que la ruta final sea `<tu juego>/Plugins/MakerStudio/`. No renombres la carpeta — el editor lee los mods de proyecto, la configuración y las estadísticas desde `Plugins/MakerStudio/003_Editor/`.
3. **Solo BES v5:** ese motor no tiene autocarga de `Plugins/`, así que en vez de copiar una carpeta se pega un único `.rb` combinado en el Editor de Scripts — sigue el `README.md` que va dentro del zip.

Cada zip incluye además su propio `README.md` con notas específicas del motor, por si algo difiere en tu instalación.

Para comprobar que funcionó: arranca tu juego en **modo Debug**, abre el menú Debug (F9) y busca **Maker Studio…** — desde ahí puedes lanzar el editor directamente (si la app aún no está instalada, ese menú muestra el enlace de descarga).

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
