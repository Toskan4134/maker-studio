# Marketplace de mods

El Marketplace es donde descubres, instalas y actualizas mods de la comunidad sin salir del editor. Los mods son extensiones JS que añaden herramientas, paneles, exportadores, elementos de menú y más — consulta la [documentación de desarrollo de mods](https://github.com/Toskan4134/maker-studio-mods) para ver lo que pueden hacer, o [Publicar un mod](https://github.com/Toskan4134/maker-studio-mods/blob/main/PUBLISHING.md) si quieres compartir uno.

## Abrir el Marketplace

Abre el menú **Mods** y haz clic en **Mod Manager**. La ventana tiene dos pestañas arriba:

- **Installed** — los mods cargados actualmente en tu editor.
- **Marketplace** — el catálogo de mods disponibles.

Cambia a **Marketplace** para explorar.

## Explorar

El Marketplace muestra una tarjeta por cada mod disponible con un icono, nombre, autor, número de estrellas, descripción corta y etiquetas. Usa el cuadro de búsqueda para filtrar por nombre, autor o descripción. Haz clic en cualquier chip de etiqueta para filtrar por esa etiqueta; haz clic de nuevo para limpiarlo.

Haz clic en **Changelog** en una tarjeta para abrir las notas de la versión más reciente de ese mod en un diálogo. Las notas se muestran como Markdown formateado (encabezados, listas, enlaces y código se renderizan como en GitHub).

## Mods Verified vs Tampered vs Unverified

Cada tarjeta muestra un chip junto al nombre del mod que refleja la comprobación de integridad SHA-256 contra el hash fijado en el registro:

- **Verified** (verde) — el SHA-256 del asset de la release coincide con el hash fijado en el registro. Los bytes que descargarías son exactamente lo que se revisó.
- **Tampered** (rojo) — los bytes de la release no coinciden con el SHA-256 fijado en el registro. Los **botones Install y Update están desactivados** y no se pueden pulsar. Un tooltip en el botón atenuado explica por qué.
- **Unverified** (amarillo) — el hash aún no se pudo comprobar (error de red, asset aún no obtenido). Aún puedes instalar, pero el diálogo de consentimiento muestra la ruta no verificada con un paso de confirmación extra.
- **Checking...** — el asset se está descargando y hasheando. El botón se activa o desactiva una vez que se conoce el resultado.

Verified no significa que el mod sea seguro de ejecutar; significa que los bytes coinciden con lo que el mantenedor del registro fijó. Lee siempre la descripción y comprueba el autor antes de instalar.

## Instalar un mod

Haz clic en **Install** en una tarjeta. Aparece un diálogo de consentimiento que muestra:

- El nombre del mod y su estado de verificación.
- La lista de capacidades que solicita (leer/escribir dentro de su propia carpeta, acceder a archivos del proyecto, mostrar diálogos, etc.).
- Botones Cancel / Install.

Si aceptas, el editor descarga la release, verifica el hash SHA-256 contra el valor fijado en el registro, descomprime el mod en tu carpeta de mods y lo activa al instante. Un toast confirma la instalación. El mod aparece ahora en la pestaña **Installed**.

### Dónde se instala el mod

Dos destinos:

- **Global** (por defecto) — `%APPDATA%/maker-studio/Mods/`. Disponible en todos los proyectos.
- **Project** — `<tu-proyecto>/Plugins/MakerStudio/003_Editor/Mods/`. Solo disponible cuando este proyecto está abierto. Útil si un colaborador debería obtener automáticamente el mod al abrir el proyecto.

Cambia el predeterminado con el conmutador **Global / Project** en lo alto del Marketplace. La instalación en proyecto está desactivada hasta que abres un proyecto.

## Actualizar mods

El editor comprueba si hay actualizaciones de mods:

- Cada vez que abres un proyecto (justo después de que carguen los mods).
- Una vez por hora mientras la app está abierta.
- Cuando haces clic en **Refresh** en la cabecera del Marketplace.

Cuando hay una actualización disponible recibes un toast que dice "N mod updates available" con un botón **Open Mods**. Abre la ventana de Mods — la pestaña **Installed** muestra una insignia naranja **Update** junto a cada mod afectado. Haz clic en el botón **Update** para instalar la nueva versión. Tus ajustes y cualquier dato almacenado por mod permanecen intactos.

## Desinstalar

En la pestaña **Installed**, expande cualquier mod que se instaló desde el Marketplace y haz clic en **Uninstall**. La carpeta del mod se borra y el editor se recarga. La tarjeta del Marketplace vuelve al estado **Install**.

También puedes desinstalar desde la pestaña Marketplace — mismo botón en la tarjeta.

## Leer la insignia de estado

Cada fila de la pestaña **Installed** muestra un estado de color:

- **active** (verde) — cargado y funcionando sin errores registrados.
- **load error** (rojo) — el mod no se pudo cargar (error de sintaxis, manifest erróneo, import lanzó). Expande la fila para ver el mensaje de error.
- **runtime errors** (rojo) — el mod cargó bien pero registró errores tras iniciar. Expande la fila y abre **Logs** para ver qué fue mal.
- **disabled** (gris) — apagado con el botón **Disable**. Reactívalo para cargarlo.
- **blocked** (rojo) — instalación bloqueada por un plugin requerido de Pokémon Essentials (falta o discrepancia de versión). El motivo explica qué plugin.

Puedes seleccionar y copiar cualquier texto dentro de una fila expandida — id, ruta de carpeta, mensaje de error, líneas de log — útil al reportar un bug de un mod. Lo mismo vale para las tarjetas del Marketplace y el diálogo Changelog: selecciona la descripción, el autor o las notas de la release para copiar.

## ¿Y si no hay internet?

El Marketplace cachea todo durante 1 hora. Si tu conexión está caída, la exploración recurre al último catálogo e info de release conocidos. Instalar requiere descargas frescas.

## Privacidad y red

Tres hosts a los que el Marketplace contacta:

- `raw.githubusercontent.com` — para obtener el índice del registro.
- `api.github.com` — para metadatos de release y conteos de estrellas.
- `objects.githubusercontent.com` (y CDN relacionado de GitHub) — para descargar assets de release.

No se envían datos de vuelta. El editor se identifica con un user-agent `Maker-Studio-Marketplace`.

## Resolución de problemas

**"Could not load registry"** — GitHub está inaccesible o limitado por rate-limit. Espera un minuto y haz clic en Refresh.

**Chip "Tampered" (rojo)** — el SHA-256 del asset de la release no coincide con el hash fijado en el registro. Install y Update están bloqueados (los botones están desactivados). Significa que el asset fue reemplazado o corrompido después de crear la entrada del registro. Reporta el mod para que el mantenedor del registro pueda investigar.

**"manifest id mismatch"** — el `manifest.json` del zip declara un id distinto al de la entrada del registro. Probablemente se subió el asset equivocado. Reporta el mod.

**Botón Install/Update atenuado** — o hay una instalación en curso (pasa el ratón sobre el botón para ver el paso actual: Downloading, Verifying, Installing), o la tarjeta muestra un chip rojo **Tampered** que significa que la release falló su comprobación SHA-256 y la instalación está bloqueada.

**Instalación en proyecto desactivada** — abre un proyecto primero. La ruta de instalación en proyecto necesita una carpeta `Plugins/MakerStudio/003_Editor/Mods/`, que solo existe dentro de un proyecto real.
