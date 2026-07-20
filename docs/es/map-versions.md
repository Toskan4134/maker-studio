# Versiones de mapa

Las **versiones de mapa** permiten que un mapa albergue varios estados distintos de sí mismo — por ejemplo un pueblo **normal**, una variante **cinemática** y una versión **destruida** tras un evento de la historia — sin crear mapas separados. En el juego cambias entre versiones con un solo **switch o variable**, y todo el mapa (tiles, eventos, fog, panoramas, sombras) cambia **en el sitio**: el jugador se queda exactamente donde está, y el mundo se transforma a su alrededor. Sin Transfer Player, sin cargar un mapa paralelo.

Todo se guarda **dentro del mismo archivo de mapa** (`MapXXX.rxdata`), como adiciones puras, así que el mapa sigue abriéndose en RPG Maker XP estándar y la versión base nunca se modifica.

## Cuándo usarlas

- Una localización que cambia tras un momento de la historia (intacta → en ruinas, día → festival, sellada → abierta).
- Una decoración cinemática / de cutscene de un mapa normal.
- Re-decoraciones estacionales o por hora del día del mismo lugar.

Las versiones comparten el **ancho y alto** del mapa (son el mismo mapa), y comparten el mismo `map_id`, así que los comandos Transfer Player, las quests y las conexiones que apuntan a este mapa siguen funcionando en cada versión.

## Dónde gestionar las versiones

Puedes llegar a las versiones de mapa desde varios sitios — todos ejecutan las mismas acciones:

- Botón **Versions** en la **barra de herramientas** — muestra la versión actual como una insignia (p. ej. `V2/3`) y abre el **Version Manager**.
- **Map → Map Versions…** en la barra de menús.
- El control **Version** en el extremo derecho de la **barra de estado** (cambio rápido + menú).
- **Clic derecho en un mapa** del árbol de mapas → **Versions** (cambio rápido) o **Manage Versions…**.

### El Version Manager

El Version Manager lista cada versión — **Version 1 (Base)** más tus versiones extra — con el switch/variable que activa cada una. **Haz clic en cualquier parte de la fila de una versión para cambiar el lienzo a ella.** La fila de cada versión no base también tiene botones para **Set Selector**, **Rename** y **Delete**, y el botón **New Version** añade una. La versión que estás editando actualmente está marcada como *editing*, y cualquier solape de selectores se señala con un icono de advertencia.

### Crear una versión

1. Abre el mapa que quieras versionar.
2. Haz clic en **New Version**. Un diálogo pregunta dos cosas:
   - **Name** para la versión.
   - **Start from** — o **Duplicate an existing version** (elige **Version 1 (Base)** o cualquier otra versión para copiar sus tiles, eventos y capas) o **Blank (empty map)** para empezar desde cero al tamaño del mapa base.
3. El lienzo cambia a la nueva versión — pinta tiles, coloca eventos, añade capas de fog/panorama/sombras, luego **Ctrl+S** para guardar. Las ediciones de una versión solo afectan a esa versión; el mapa base queda intacto.
4. Cambia entre **Version 1 (Base)** y tus versiones en cualquier momento desde cualquiera de los controles de arriba. Las ediciones sin guardar se guardan automáticamente antes de cambiar.

> **La numeración se mantiene ordenada:** las versiones se numeran **Version 1 (Base), Version 2, Version 3 …**. Si borras una versión del medio, las posteriores se **renumeran hacia abajo** para que nunca haya un hueco.

## Elegir qué activa una versión

Haz clic en **⚙** (Selector) para vincular la versión activa al estado del juego:

- **Variable equals value** — la versión está activa mientras la variable elegida sea igual al valor que pongas (p. ej. *Variable 0027 = 4*).
- **Switch is ON** — la versión está activa mientras el switch elegido esté ON (p. ej. *Switch 0088*).

En el juego, ajusta ese switch/variable como quieras (un comando de evento Control Switches / Control Variables, un script, etc.). En cuanto su valor coincide, el mapa cambia a esa versión al instante.

**Orden de resolución:** las versiones se comprueban por número (v1, v2, v3 …) y **gana la primera cuyo selector coincida**. Si ninguna coincide, se muestra el **mapa base (v0)**. Si dos versiones pueden estar activas a la vez, el conmutador muestra una advertencia **⚠ selector overlap** para que arregles la ambigüedad.

El estado vive en la variable/switch, así que se guarda con el archivo de guardado del jugador automáticamente — carga una partida que estaba en la versión "destruida" y el mapa vuelve destruido.

## Cosas que saber

- **Mismo tamaño:** todas las versiones comparten las dimensiones del mapa base. Redimensiona el mapa base antes de añadir muchas versiones.
- **Los self-switches se comparten:** como cada versión es el mismo `map_id`, el self-switch de un evento (A/B/C/D) se comparte entre versiones. Útil para estado persistente de puertas/cofres, pero tenlo en cuenta.
- **Los eventos en marcha se detienen al cambiar:** cuando el mapa cambia de versión, cualquier evento autorun/parallel de la versión antigua se detiene para que no siga corriendo sobre un evento que ya no existe.
- **Quedarse atascado:** si una nueva versión añade una pared donde está el jugador, podría quedar atrapado — diseña las transiciones para que el tile del jugador siga siendo transitable, o muévelo con el evento que dispara el cambio.
- **Tamaño de archivo:** cada versión guarda una copia completa del mapa dentro del archivo, así que un mapa con muchas versiones grandes hace un `.rxdata` mayor. Es normal.

## Requisitos

Las versiones de mapa necesitan el **plugin de juego de Maker Studio** instalado (viene con la integración). El cambio en tiempo de ejecución está soportado en todas las builds salvo las de pegado directo para los motores más antiguos — Pokémon Essentials BES v5 y v17.1 (es decir: LBDS 1.1/1.2 y Pokémon Essentials vanilla v21.1, v20.1 y v19.1). Editar versiones en el editor funciona independientemente de qué build distribuyas.
