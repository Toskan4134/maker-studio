#===============================================================================
# MakerStudio - Game Map Override
# Patches Game_Map collision and terrain methods to include extended layers.
# The each_extended_tile_at helper is defined in 002_RendererOverride.rb
# and iterates all cached maps' extended data.
#
# Now also checks native layer properties for extra autotiles and cross-tileset
# tiles. Scan order is strictly top-down: extended layers (top id first) →
# native layers [2,1,0], where each native layer resolves its extra-autotile /
# cross-tileset / plain tile INLINE (native_layer_* helpers) — a ground tile
# only decides the cell for everything BELOW its own layer.
#
# Cross-tileset tiles: use that tileset's passages/priorities/terrain_tags.
# Extra autotiles: use per-tile passage/priority/terrain_tag from tile_data,
#   falling back to tileset lookup by autotile name, then expanded_autotiles.
#
# Terrain-based passability mirrors native playerPassable? logic exactly:
#   - bridge terrain: skip if not on bridge; use passage check if on bridge
#   - can_surf (Water/etc.): passable if $PokemonGlobal.surfing, blocked otherwise
#   - must_walk (TallGrass/Ice): blocks cycling. v20.1's GameData::TerrainTag has
#     no must_walk_or_run (v21.1 added it), so only must_walk is checked — same as
#     v20.1's own Game_Map#playerPassable?.
#   - deep_bush terrain (TallGrass): deepBush? returns true automatically
#
# passable? note: for the player, native passable? delegates to playerPassable?
# (which is also patched). To avoid double-checking extended layers, passable?
# skips the extended loop when self_event == $game_player.
#===============================================================================
class Game_Map
  #---------------------------------------------------------------------------
  # Resolve passage/priority/terrain for an extra autotile from tile_data.
  # Falls back to expanded_autotiles, then any tileset that includes this
  # autotile in its autotile_names array.
  # Returns [passage, priority, terrain_tag] or nil if unknown.
  #---------------------------------------------------------------------------
  def resolve_extra_autotile_data(tile_data)
    passage = tile_data["passage"]
    if passage
      return [passage.to_i, (tile_data["priority"] || 0).to_i, (tile_data["terrain_tag"] || 0).to_i]
    end
    # Fallback: check if this autotile appears in any tileset
    auto_name = tile_data["autotile_name"]
    return nil unless auto_name
    # Check expanded_autotiles config first
    entry = MakerStudio::DataStore.get_expanded_autotile(auto_name)
    if entry
      return [entry["passage"].to_i, entry["priority"].to_i, entry["terrain_tag"].to_i]
    end
    # Check current map's tileset native autotile slots, then all tilesets
    if @map && @map.respond_to?(:autotile_names) && @map.autotile_names
      idx = @map.autotile_names.index(auto_name)
      if idx
        base = (idx + 1) * 48
        return [@passages[base] || 0, @priorities[base] || 0, @terrain_tags[base] || 0]
      end
    end
    if $data_tilesets
      $data_tilesets.each do |ts|
        next unless ts && ts.autotile_names
        idx = ts.autotile_names.index(auto_name)
        next unless idx
        base = (idx + 1) * 48
        return [ts.passages[base] || 0, ts.priorities[base] || 0, ts.terrain_tags[base] || 0]
      end
    end
    return nil
  end
  private :resolve_extra_autotile_data

  #---------------------------------------------------------------------------
  # Get the terrain for an extended tile.
  # For extra autotiles: checks tile_data["terrain_tag"] directly first
  # (set via editor GamePropertiesPopup), then falls back to tileset lookup.
  # Returns a GameData::TerrainTag or nil if completely unknown.
  #---------------------------------------------------------------------------
  def extended_tile_terrain(tile_id, tile_data)
    return nil unless tile_data
    if tile_data["autotile_name"]
      # Direct check: editor-set terrain_tag (independent of passage)
      tt = tile_data["terrain_tag"]
      return GameData::TerrainTag.try_get(tt.to_i) if tt && tt.to_i != 0
      # Fall back to tileset / expanded_autotiles lookup
      resolved = resolve_extra_autotile_data(tile_data)
      return GameData::TerrainTag.try_get(resolved[2]) if resolved
      return nil
    elsif tile_data["tileset_id"]
      ts = $data_tilesets[tile_data["tileset_id"].to_i]
      return ts ? GameData::TerrainTag.try_get(ts.terrain_tags[tile_id]) : nil
    else
      return GameData::TerrainTag.try_get(@terrain_tags[tile_id])
    end
  end
  private :extended_tile_terrain

  #---------------------------------------------------------------------------
  # Resolve passage for a tile, checking per-tile override first.
  # Per-tile passage is set at paint time when tile has rotation/flip,
  # so passage direction bits match the tile's visual orientation.
  #---------------------------------------------------------------------------
  def resolve_tile_passage(tid, td, default_passages)
    return td["passage"].to_i if td && td["passage"]
    if td && td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.passages[tid] || 0) : 0
    end
    return default_passages[tid] || 0
  end
  private :resolve_tile_passage

  #---------------------------------------------------------------------------
  # Does this cell carry a CROSS-TILESET tile on a native layer?
  #
  # Such a tile keeps the FOREIGN tileset's tile id in the map Table, so every
  # engine method that indexes the MAP's own tileset with that id (bush?,
  # deepBush?, counter?) answers about a completely unrelated tile that happens
  # to share the number — e.g. tile 391 is a shop shelf in "Mart interior" but
  # tall grass (passage 0x40) in "Outside", so standing behind the shelf made the
  # player render as if he were in grass (bush depth), fading out his lower half.
  # Those methods must therefore ignore the engine's answer here and resolve the
  # cell against the tileset the tile actually came from.
  #---------------------------------------------------------------------------
  def ms_cross_tileset_cell?(x, y)
    found = false
    MakerStudio.each_native_extra_tile_at(x, y) do |_tile_id, tile_data|
      found = true if tile_data && tile_data["tileset_id"]
    end
    found
  end
  private :ms_cross_tileset_cell?

  def resolve_tile_priority(tid, td, default_priorities)
    return td["priority"].to_i if td && td["priority"]
    if td && td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.priorities[tid] || 0) : 0
    end
    return default_priorities[tid] || 0
  end
  private :resolve_tile_priority

  #---------------------------------------------------------------------------
  # Resolve terrain_tag for a tile, respecting cross-tileset references.
  # Editor-set tile_data["terrain_tag"] wins, then cross-tileset's table,
  # then map's default terrain_tags. Returns 0 when no source is available.
  #---------------------------------------------------------------------------
  def resolve_tile_terrain_tag(tid, td, default_terrain_tags)
    return td["terrain_tag"].to_i if td && td["terrain_tag"]
    if td && td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.terrain_tags[tid] || 0) : 0
    end
    return default_terrain_tags ? (default_terrain_tags[tid] || 0) : 0
  end
  private :resolve_tile_terrain_tag

  #---------------------------------------------------------------------------
  # passable?
  #
  # For the player (self_event == $game_player), native passable? delegates to
  # playerPassable? (line: "return playerPassable? if self_event == $game_player").
  # Our patched playerPassable? already handles extended layers. Skip the
  # extended loop here to avoid double-checking and conflicting results.
  #
  # For non-player events, run the original extended passage checks.
  #---------------------------------------------------------------------------
  alias __mkst__passable passable? unless method_defined?(:__mkst__passable)
  def passable?(x, y, dir, self_event = nil)
    return __mkst__passable(x, y, dir, self_event) unless MakerStudio::ENABLED
    # Player delegates to patched playerPassable? (which also handles native extras)
    return playerPassable?(x, y, dir, self_event) if self_event == $game_player
    bit = (1 << ((dir / 2) - 1)) & 0x0f
    # Extended layer tiles
    MakerStudio.each_extended_tile_at(x, y) do |tile_id, tile_data|
      # Extra autotiles: explicit passage data only for non-player events
      if tile_data && tile_data["autotile_name"]
        resolved = resolve_extra_autotile_data(tile_data)
        if resolved
          passage, priority, terrain_tag = resolved
          terrain = GameData::TerrainTag.try_get(terrain_tag)
          next if terrain&.ignore_passability
          return false if passage & bit != 0 || passage & 0x0f == 0x0f
          return true if priority == 0
          next
        end
        next
      end
      # Cross-tileset: use referenced tileset's passage data
      if tile_data && tile_data["tileset_id"]
        ts = $data_tilesets[tile_data["tileset_id"].to_i]
        next unless ts
        terrain = GameData::TerrainTag.try_get(ts.terrain_tags[tile_id])
        next if terrain&.ignore_passability
        passage = tile_data["passage"] ? tile_data["passage"].to_i : (ts.passages[tile_id] || 0)
        return false if passage & bit != 0 || passage & 0x0f == 0x0f
        return true if (tile_data["priority"] ? tile_data["priority"].to_i : (ts.priorities[tile_id] || 0)) == 0
        next
      end
      # Default: map's passage data
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      next if terrain&.ignore_passability
      passage = tile_data["passage"] ? tile_data["passage"].to_i : (@passages[tile_id] || 0)
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if (tile_data["priority"] ? tile_data["priority"].to_i : (@priorities[tile_id] || 0)) == 0
    end
    # Fallback: native layers with per-layer tileset awareness
    return native_layer_passable(x, y, dir, self_event)
  end

  #---------------------------------------------------------------------------
  # playerPassable?
  #
  # Mirrors every terrain-based check in native playerPassable? for extended
  # layer tiles. Order matches native exactly:
  #   1. bridge  → skip if not on bridge; use passage check if on bridge
  #   2. can_surf (and not waterfall) → allow if surfing, block otherwise
  #   3. bicycle + must_walk → block
  #   4. ignore_passability → skip tile
  #   5. Regular passage bits
  #---------------------------------------------------------------------------
  alias __mkst__playerPassable playerPassable? unless method_defined?(:__mkst__playerPassable)
  def playerPassable?(x, y, dir, self_event = nil)
    return __mkst__playerPassable(x, y, dir, self_event) unless MakerStudio::ENABLED
    bit = (1 << ((dir / 2) - 1)) & 0x0f
    # Extended layer tiles
    MakerStudio.each_extended_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        terrain = extended_tile_terrain(tile_id, tile_data)
        if terrain && terrain.id != :None
          # 1. Bridge: skip if not on bridge; passage-check if on bridge
          if terrain.bridge
            if $PokemonGlobal.bridge == 0
              next
            else
              resolved = resolve_extra_autotile_data(tile_data)
              passage_val = resolved ? resolved[0] : 0
              return (passage_val & bit == 0 && passage_val & 0x0f != 0x0f)
            end
          end
          # 2. Surf: allow if surfing (matches native: can_surf && !waterfall)
          if terrain.can_surf && !terrain.waterfall
            return $PokemonGlobal.surfing
          end
          # 3. Cycling restrictions
          if $PokemonGlobal.bicycle && terrain.must_walk
            return false
          end
          # 4. ignore_passability
          next if terrain.ignore_passability
        end
        # 5. Explicit passage data
        resolved = resolve_extra_autotile_data(tile_data)
        if resolved
          passage, priority, terrain_tag = resolved
          terrain2 = GameData::TerrainTag.try_get(terrain_tag)
          next if terrain2&.ignore_passability
          return false if passage & bit != 0 || passage & 0x0f == 0x0f
          return true if priority == 0
          next
        end
        next
      end
      if tile_data && tile_data["tileset_id"]
        ts = $data_tilesets[tile_data["tileset_id"].to_i]
        next unless ts
        terrain = GameData::TerrainTag.try_get(ts.terrain_tags[tile_id])
        if terrain && terrain.id != :None
          # Bridge
          if terrain.bridge
            if $PokemonGlobal.bridge == 0
              next
            else
              passage = tile_data["passage"] ? tile_data["passage"].to_i : (ts.passages[tile_id] || 0)
              return (passage & bit == 0 && passage & 0x0f != 0x0f)
            end
          end
          # Surf
          if terrain.can_surf && !terrain.waterfall
            return $PokemonGlobal.surfing
          end
          # Cycling
          if $PokemonGlobal.bicycle && terrain.must_walk
            return false
          end
          next if terrain.ignore_passability
        end
        passage = tile_data["passage"] ? tile_data["passage"].to_i : (ts.passages[tile_id] || 0)
        return false if passage & bit != 0 || passage & 0x0f == 0x0f
        return true if (tile_data["priority"] ? tile_data["priority"].to_i : (ts.priorities[tile_id] || 0)) == 0
        next
      end
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      if terrain && terrain.id != :None
        if terrain.bridge
          next if $PokemonGlobal.bridge == 0
          passage = tile_data["passage"] ? tile_data["passage"].to_i : (@passages[tile_id] || 0)
          return (passage & bit == 0 && passage & 0x0f != 0x0f) if $PokemonGlobal.bridge > 0
        end
        if terrain.can_surf && !terrain.waterfall
          return $PokemonGlobal.surfing
        end
        if $PokemonGlobal.bicycle && terrain.must_walk
          return false
        end
        next if terrain.ignore_passability
      end
      passage = tile_data["passage"] ? tile_data["passage"].to_i : (@passages[tile_id] || 0)
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if (tile_data["priority"] ? tile_data["priority"].to_i : (@priorities[tile_id] || 0)) == 0
    end
    # Fallback: native layers with terrain checks + per-layer tileset awareness
    return native_layer_player_passable(x, y, dir)
  end

  #---------------------------------------------------------------------------
  # passableStrict?
  #---------------------------------------------------------------------------
  alias __mkst__passableStrict passableStrict? unless method_defined?(:__mkst__passableStrict)
  def passableStrict?(x, y, dir, self_event = nil)
    return __mkst__passableStrict(x, y, dir, self_event) unless MakerStudio::ENABLED
    # Extended layer tiles
    MakerStudio.each_extended_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        resolved = resolve_extra_autotile_data(tile_data)
        if resolved
          passage, priority, terrain_tag = resolved
          terrain = GameData::TerrainTag.try_get(terrain_tag)
          next if terrain&.ignore_passability
          return false if passage & 0x0f != 0
          return true if priority == 0
          next
        end
        next
      end
      if tile_data && tile_data["tileset_id"]
        ts = $data_tilesets[tile_data["tileset_id"].to_i]
        next unless ts
        terrain = GameData::TerrainTag.try_get(ts.terrain_tags[tile_id])
        next if terrain&.ignore_passability
        passage = tile_data["passage"] ? tile_data["passage"].to_i : (ts.passages[tile_id] || 0)
        return false if passage & 0x0f != 0
        return true if (tile_data["priority"] ? tile_data["priority"].to_i : (ts.priorities[tile_id] || 0)) == 0
        next
      end
      next if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).ignore_passability
      passage = tile_data["passage"] ? tile_data["passage"].to_i : (@passages[tile_id] || 0)
      return false if passage & 0x0f != 0
      return true if (tile_data["priority"] ? tile_data["priority"].to_i : (@priorities[tile_id] || 0)) == 0
    end
    # Fallback: native layers with per-layer tileset awareness
    return native_layer_passable_strict(x, y, self_event)
  end

  #---------------------------------------------------------------------------
  # terrain_tag
  #
  # Extended layers render on top of native layers, so their terrain should
  # take priority. Check extended layers FIRST; fall back to native if no
  # extended tile has non-None terrain at (x,y).
  #
  # For extra autotiles: check tile_data["terrain_tag"] directly first
  # (editor-set value, independent of passage), then tileset/expanded lookup.
  #---------------------------------------------------------------------------
  alias __mkst__terrain_tag terrain_tag unless method_defined?(:__mkst__terrain_tag)
  def terrain_tag(x, y, countBridge = false)
    return __mkst__terrain_tag(x, y, countBridge) unless MakerStudio::ENABLED
    # Extended layer tiles
    MakerStudio.each_extended_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        # Direct tile_data["terrain_tag"] check (editor-set, independent of passage)
        tt = tile_data["terrain_tag"]
        if tt && tt.to_i != 0
          terrain = GameData::TerrainTag.try_get(tt.to_i)
          next if terrain.id == :None || terrain.ignore_passability
          next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
          return terrain
        end
        # Tileset / expanded_autotiles lookup
        resolved = resolve_extra_autotile_data(tile_data)
        if resolved
          terrain = GameData::TerrainTag.try_get(resolved[2])
          next if terrain.id == :None || terrain.ignore_passability
          next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
          return terrain
        end
        next
      end
      terrain_tags = @terrain_tags
      next unless terrain_tags
      if tile_data && tile_data["tileset_id"]
        ts = $data_tilesets[tile_data["tileset_id"].to_i]
        next unless ts
        terrain_tags = ts.terrain_tags
      end
      terrain = GameData::TerrainTag.try_get(terrain_tags[tile_id])
      next if terrain.id == :None || terrain.ignore_passability
      next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
      return terrain
    end
    # Fall back to native terrain — check each layer with correct tileset
    return native_layer_terrain_tag(x, y, countBridge)
  end

  #---------------------------------------------------------------------------
  # Resolve terrain_tag for native layers, respecting cross-tileset tiles.
  # Iterates layers top-to-bottom, returns first non-None terrain.
  #---------------------------------------------------------------------------
  def native_layer_terrain_tag(x, y, countBridge = false)
    return GameData::TerrainTag.try_get(0) unless @terrain_tags && @map && @map.data
    ext_data = MakerStudio.get_extended_data_for(@map_id)
    native_props = ext_data ? ext_data["nativeProperties"] : nil
    key = "#{x},#{y}"
    [2, 1, 0].each do |layer|
      tid = @map.data[x, y, layer]
      next if tid.nil?
      td = native_props ? (native_props[layer] || {})[key] : nil
      # Extra autotile stored as tile_id=0 — resolve inline at ITS layer so its
      # terrain can't beat (or be beaten by) tiles on the wrong layer.
      if td && td["autotile_name"]
        tt = td["terrain_tag"]
        if tt && tt.to_i != 0
          terrain = GameData::TerrainTag.try_get(tt.to_i)
          next if terrain.id == :None || terrain.ignore_passability
          next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
          return terrain
        end
        resolved = resolve_extra_autotile_data(td)
        if resolved
          terrain = GameData::TerrainTag.try_get(resolved[2])
          next if terrain.id == :None || terrain.ignore_passability
          next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
          return terrain
        end
        next
      end
      next if tid == 0
      if td && td["tileset_id"]
        ts = $data_tilesets[td["tileset_id"].to_i]
        next unless ts
        terrain = GameData::TerrainTag.try_get(ts.terrain_tags[tid])
      else
        terrain = GameData::TerrainTag.try_get(@terrain_tags[tid])
      end
      next if terrain.id == :None || terrain.ignore_passability
      next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
      return terrain
    end
    return GameData::TerrainTag.try_get(0)
  end
  private :native_layer_terrain_tag

  #---------------------------------------------------------------------------
  # bush?
  #---------------------------------------------------------------------------
  alias __mkst__bush bush? unless method_defined?(:__mkst__bush)
  def bush?(x, y)
    result = __mkst__bush(x, y)
    return result unless MakerStudio::ENABLED
    # The engine answered from the map Table read against the MAP's own tileset —
    # meaningless on a cross-tileset cell (see ms_cross_tileset_cell?), so re-resolve.
    return result if result == true && !ms_cross_tileset_cell?(x, y)
    # Extended layer tiles
    MakerStudio.each_extended_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        resolved = resolve_extra_autotile_data(tile_data)
        if resolved
          passage, priority, terrain_tag = resolved
          terrain = GameData::TerrainTag.try_get(terrain_tag)
          return false if terrain&.bridge && $PokemonGlobal.bridge > 0
          return true if passage & 0x40 == 0x40
        end
        next
      end
      passage = resolve_tile_passage(tile_id, tile_data, @passages)
      terrain = GameData::TerrainTag.try_get(resolve_tile_terrain_tag(tile_id, tile_data, @terrain_tags))
      return false if terrain&.bridge && $PokemonGlobal.bridge > 0
      return true if passage & 0x40 == 0x40
    end
    # Native layer extra tiles
    MakerStudio.each_native_extra_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        resolved = resolve_extra_autotile_data(tile_data)
        if resolved
          passage, priority, terrain_tag = resolved
          terrain = GameData::TerrainTag.try_get(terrain_tag)
          return false if terrain&.bridge && $PokemonGlobal.bridge > 0
          return true if passage & 0x40 == 0x40
        end
        next
      end
      passage = resolve_tile_passage(tile_id, tile_data, @passages)
      terrain = GameData::TerrainTag.try_get(resolve_tile_terrain_tag(tile_id, tile_data, @terrain_tags))
      return false if terrain&.bridge && $PokemonGlobal.bridge > 0
      return true if passage & 0x40 == 0x40
    end
    # Fallback: check native layers with correct tileset per layer
    return native_layer_bush(x, y)
  end

  def native_layer_bush(x, y)
    ext_data = MakerStudio.get_extended_data_for(@map_id)
    native_props = ext_data ? ext_data["nativeProperties"] : nil
    [2, 1, 0].each do |layer|
      tid = @map.data[x, y, layer]
      next if tid.nil? || tid == 0   # tid is nil for out-of-bounds (x,y) — e.g. Debug Passability scans border tiles
      key = "#{x},#{y}"
      td = native_props ? (native_props[layer] || {})[key] : nil
      passage = resolve_tile_passage(tid, td, @passages)
      if td && td["tileset_id"]
        ts = $data_tilesets[td["tileset_id"].to_i]
        terrain = ts ? GameData::TerrainTag.try_get(ts.terrain_tags[tid]) : nil
      else
        terrain = GameData::TerrainTag.try_get(@terrain_tags[tid])
      end
      return false if terrain&.bridge && $PokemonGlobal.bridge > 0
      return true if passage & 0x40 == 0x40
    end
    return false
  end
  private :native_layer_bush

  #---------------------------------------------------------------------------
  # deepBush?
  # TallGrass (deep_bush) terrain on extended tiles counts as deep bush
  # without requiring explicit passage 0x40.
  #---------------------------------------------------------------------------
  alias __mkst__deepBush deepBush? unless method_defined?(:__mkst__deepBush)
  def deepBush?(x, y)
    result = __mkst__deepBush(x, y)
    return result unless MakerStudio::ENABLED
    # The engine answered from the map Table read against the MAP's own tileset —
    # meaningless on a cross-tileset cell (see ms_cross_tileset_cell?), so re-resolve.
    return result if result == true && !ms_cross_tileset_cell?(x, y)
    # Extended layer tiles
    MakerStudio.each_extended_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        terrain = extended_tile_terrain(tile_id, tile_data)
        if terrain && terrain.id != :None
          return false if terrain.bridge && $PokemonGlobal.bridge > 0
          # deep_bush terrain (TallGrass) → deep bush without needing passage 0x40
          return true if terrain.deep_bush
        else
          resolved = resolve_extra_autotile_data(tile_data)
          if resolved
            passage, _priority, terrain_tag = resolved
            terrain2 = GameData::TerrainTag.try_get(terrain_tag)
            return false if terrain2&.bridge && $PokemonGlobal.bridge > 0
            return true if terrain2&.deep_bush && passage & 0x40 == 0x40
          end
        end
        next
      end
      passage = resolve_tile_passage(tile_id, tile_data, @passages)
      terrain = GameData::TerrainTag.try_get(resolve_tile_terrain_tag(tile_id, tile_data, @terrain_tags))
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.deep_bush && passage & 0x40 == 0x40
    end
    # Native layer extra tiles
    MakerStudio.each_native_extra_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        terrain = extended_tile_terrain(tile_id, tile_data)
        if terrain && terrain.id != :None
          return false if terrain.bridge && $PokemonGlobal.bridge > 0
          return true if terrain.deep_bush
        else
          resolved = resolve_extra_autotile_data(tile_data)
          if resolved
            passage, _priority, terrain_tag = resolved
            terrain2 = GameData::TerrainTag.try_get(terrain_tag)
            return false if terrain2&.bridge && $PokemonGlobal.bridge > 0
            return true if terrain2&.deep_bush && passage & 0x40 == 0x40
          end
        end
        next
      end
      passage = resolve_tile_passage(tile_id, tile_data, @passages)
      terrain = GameData::TerrainTag.try_get(resolve_tile_terrain_tag(tile_id, tile_data, @terrain_tags))
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.deep_bush && passage & 0x40 == 0x40
    end
    # Fallback: check native layers with correct tileset per layer
    return native_layer_deep_bush(x, y)
  end

  def native_layer_deep_bush(x, y)
    ext_data = MakerStudio.get_extended_data_for(@map_id)
    native_props = ext_data ? ext_data["nativeProperties"] : nil
    [2, 1, 0].each do |layer|
      tid = @map.data[x, y, layer]
      next if tid.nil? || tid == 0   # tid is nil for out-of-bounds (x,y) — e.g. Debug Passability scans border tiles
      key = "#{x},#{y}"
      td = native_props ? (native_props[layer] || {})[key] : nil
      passage = resolve_tile_passage(tid, td, @passages)
      if td && td["tileset_id"]
        ts = $data_tilesets[td["tileset_id"].to_i]
        next unless ts
        terrain = GameData::TerrainTag.try_get(ts.terrain_tags[tid])
      else
        terrain = GameData::TerrainTag.try_get(@terrain_tags[tid])
      end
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.deep_bush && passage & 0x40 == 0x40
    end
    return false
  end
  private :native_layer_deep_bush
  #---------------------------------------------------------------------------
  alias __mkst__counter counter? unless method_defined?(:__mkst__counter)
  def counter?(x, y)
    result = __mkst__counter(x, y)
    return result unless MakerStudio::ENABLED
    # The engine answered from the map Table read against the MAP's own tileset —
    # meaningless on a cross-tileset cell (see ms_cross_tileset_cell?), so re-resolve.
    return result if result == true && !ms_cross_tileset_cell?(x, y)
    # Extended layer tiles
    MakerStudio.each_extended_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        resolved = resolve_extra_autotile_data(tile_data)
        if resolved
          return true if resolved[0] & 0x80 == 0x80
        end
        next
      end
      passage = resolve_tile_passage(tile_id, tile_data, @passages)
      return true if passage & 0x80 == 0x80
    end
    # Native layer extra tiles
    MakerStudio.each_native_extra_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        resolved = resolve_extra_autotile_data(tile_data)
        if resolved
          return true if resolved[0] & 0x80 == 0x80
        end
        next
      end
      passage = resolve_tile_passage(tile_id, tile_data, @passages)
      return true if passage & 0x80 == 0x80
    end
    # Fallback: check native layers with correct tileset per layer
    return native_layer_counter(x, y)
  end

  def native_layer_counter(x, y)
    ext_data = MakerStudio.get_extended_data_for(@map_id)
    native_props = ext_data ? ext_data["nativeProperties"] : nil
    [2, 1, 0].each do |layer|
      tid = @map.data[x, y, layer]
      next if tid.nil? || tid == 0   # tid is nil for out-of-bounds (x,y) — e.g. Debug Passability scans border tiles
      key = "#{x},#{y}"
      td = native_props ? (native_props[layer] || {})[key] : nil
      passage = resolve_tile_passage(tid, td, @passages)
      return true if passage & 0x80 == 0x80
    end
    return false
  end
  private :native_layer_counter

  #---------------------------------------------------------------------------
  # Native layer passable? fallback — respects per-layer cross-tileset passages.
  # Replicates native passable? logic: iterate [2,1,0], check passages.
  #---------------------------------------------------------------------------
  def native_layer_passable(x, y, dir, self_event = nil)
    ext_data = MakerStudio.get_extended_data_for(@map_id)
    native_props = ext_data ? ext_data["nativeProperties"] : nil
    bit = (1 << ((dir / 2) - 1)) & 0x0f
    key = "#{x},#{y}"
    [2, 1, 0].each do |layer|
      tid = @map.data[x, y, layer]
      next if tid.nil?   # tid is nil for out-of-bounds (x,y) — e.g. Debug Passability scans border tiles
      td = native_props ? (native_props[layer] || {})[key] : nil
      # Extra autotile stored as tile_id=0 — resolve inline at ITS layer so a
      # ground extra autotile can't short-circuit tiles on higher layers.
      if td && td["autotile_name"]
        resolved = resolve_extra_autotile_data(td)
        if resolved
          passage, priority, terrain_tag = resolved
          terrain = GameData::TerrainTag.try_get(terrain_tag)
          next if terrain&.ignore_passability
          return false if passage & bit != 0 || passage & 0x0f == 0x0f
          return true if priority == 0
        end
        next
      end
      next if tid == 0
      passage = resolve_tile_passage(tid, td, @passages)
      priority = resolve_tile_priority(tid, td, @priorities)
      return false if passage & bit != 0
      return false if passage & 0x0f == 0x0f
      return true if priority == 0
    end
    return true
  end
  private :native_layer_passable

  #---------------------------------------------------------------------------
  # Native layer playerPassable? fallback — terrain-aware, per-layer tileset.
  # Mirrors native playerPassable?: bridge, surf, bicycle, ignore_passability,
  # then passage bits.
  #---------------------------------------------------------------------------
  def native_layer_player_passable(x, y, dir)
    ext_data = MakerStudio.get_extended_data_for(@map_id)
    native_props = ext_data ? ext_data["nativeProperties"] : nil
    bit = (1 << ((dir / 2) - 1)) & 0x0f
    key = "#{x},#{y}"
    [2, 1, 0].each do |layer|
      tid = @map.data[x, y, layer]
      next if tid.nil?   # tid is nil for out-of-bounds (x,y) — e.g. Debug Passability scans border tiles
      td = native_props ? (native_props[layer] || {})[key] : nil
      # Extra autotile stored as tile_id=0 — resolve inline at ITS layer so a
      # ground extra autotile can't short-circuit tiles on higher layers.
      if td && td["autotile_name"]
        terrain = extended_tile_terrain(tid, td)
        if terrain && terrain.id != :None
          if terrain.bridge
            if $PokemonGlobal.bridge == 0
              next
            else
              resolved = resolve_extra_autotile_data(td)
              passage_val = resolved ? resolved[0] : 0
              return (passage_val & bit == 0 && passage_val & 0x0f != 0x0f)
            end
          end
          if terrain.can_surf && !terrain.waterfall
            return $PokemonGlobal.surfing
          end
          if $PokemonGlobal.bicycle && terrain.must_walk
            return false
          end
          next if terrain.ignore_passability
        end
        resolved = resolve_extra_autotile_data(td)
        if resolved
          passage, priority, terrain_tag = resolved
          terrain2 = GameData::TerrainTag.try_get(terrain_tag)
          next if terrain2&.ignore_passability
          return false if passage & bit != 0 || passage & 0x0f == 0x0f
          return true if priority == 0
        end
        next
      end
      next if tid == 0
      if td && td["tileset_id"]
        ts = $data_tilesets[td["tileset_id"].to_i]
        next unless ts
        terrain_tags = ts.terrain_tags
      else
        terrain_tags = @terrain_tags
      end
      terrain = GameData::TerrainTag.try_get(terrain_tags[tid])
      if terrain && terrain.id != :None
        if terrain.bridge
          if $PokemonGlobal.bridge == 0
            next
          else
            passage = resolve_tile_passage(tid, td, @passages)
            return (passage & bit == 0 && passage & 0x0f != 0x0f)
          end
        end
        if terrain.can_surf && !terrain.waterfall
          return $PokemonGlobal.surfing
        end
        if $PokemonGlobal.bicycle && terrain.must_walk
          return false
        end
        next if terrain.ignore_passability
      end
      passage = resolve_tile_passage(tid, td, @passages)
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if resolve_tile_priority(tid, td, @priorities) == 0
    end
    return true
  end
  private :native_layer_player_passable

  #---------------------------------------------------------------------------
  # Native layer passableStrict? fallback — per-layer tileset.
  #---------------------------------------------------------------------------
  def native_layer_passable_strict(x, y, self_event = nil)
    ext_data = MakerStudio.get_extended_data_for(@map_id)
    native_props = ext_data ? ext_data["nativeProperties"] : nil
    key = "#{x},#{y}"
    [2, 1, 0].each do |layer|
      tid = @map.data[x, y, layer]
      next if tid.nil?   # tid is nil for out-of-bounds (x,y) — e.g. Debug Passability scans border tiles
      td = native_props ? (native_props[layer] || {})[key] : nil
      # Extra autotile stored as tile_id=0 — resolve inline at ITS layer so a
      # ground extra autotile can't short-circuit tiles on higher layers.
      if td && td["autotile_name"]
        resolved = resolve_extra_autotile_data(td)
        if resolved
          passage, priority, terrain_tag = resolved
          terrain = GameData::TerrainTag.try_get(terrain_tag)
          next if terrain&.ignore_passability
          return false if passage & 0x0f != 0
          return true if priority == 0
        end
        next
      end
      next if tid == 0
      passage = resolve_tile_passage(tid, td, @passages)
      priority = resolve_tile_priority(tid, td, @priorities)
      return false if passage & 0x0f != 0
      return true if priority == 0
    end
    return true
  end
  private :native_layer_passable_strict
end

#===============================================================================
# Monkey-patch Debug_Passability to include extended layers in collision checks.
# Mirrors ALL terrain logic from Game_Map#playerPassable? so the debug overlay
# correctly shows water tiles as open when surfing (and closed when not).
# passability_needs_update? already tracks $PokemonGlobal.surfing, so the
# overlay auto-refreshes on surf state changes without extra work here.
#
# Guard: Debug_Passability is an LBDS class — vanilla v21.1 and some v21.1
# bases (v21.1 Hotfixes / Grand Order) DON'T define it. Reopening a missing
# class + aliasing playerPassable? raises NameError and aborts plugin load
# (LBDS pluginErrorMsg then crashes formatting it). Skip the patch when absent.
#===============================================================================
if defined?(Debug_Passability)
class Debug_Passability
  alias __mkst__dp_playerPassable playerPassable? unless method_defined?(:__mkst__dp_playerPassable)
  def playerPassable?(x, y, d, self_event = nil)
    return __mkst__dp_playerPassable(x, y, d, self_event) unless MakerStudio::ENABLED
    bit = (1 << ((d / 2) - 1)) & 0x0f
    # Extended layer tiles
    MakerStudio.each_extended_tile_at(x, y) do |tile_id, tile_data|
      if tile_data && tile_data["autotile_name"]
        terrain = $game_map.send(:extended_tile_terrain, tile_id, tile_data)
        if terrain && terrain.id != :None
          # Bridge: skip if not on bridge; passage-check if on bridge
          if terrain.bridge
            if $PokemonGlobal.bridge == 0
              next
            else
              resolved = $game_map.send(:resolve_extra_autotile_data, tile_data)
              passage_val = resolved ? resolved[0] : 0
              return (passage_val & bit == 0 && passage_val & 0x0f != 0x0f)
            end
          end
          # Surf: water tiles passable when surfing, blocked otherwise
          if terrain.can_surf && !terrain.waterfall
            return $PokemonGlobal.surfing
          end
          # Cycling restrictions
          if $PokemonGlobal.bicycle && terrain.must_walk
            return false
          end
          next if terrain.ignore_passability
        end
        resolved = $game_map.send(:resolve_extra_autotile_data, tile_data)
        if resolved
          passage, priority, terrain_tag = resolved
          terrain2 = GameData::TerrainTag.try_get(terrain_tag)
          next if terrain2&.ignore_passability
          return false if passage & bit != 0 || passage & 0x0f == 0x0f
          return true if priority == 0
          next
        end
        next
      end
      if tile_data && tile_data["tileset_id"]
        ts = $data_tilesets[tile_data["tileset_id"].to_i]
        next unless ts
        terrain = GameData::TerrainTag.try_get(ts.terrain_tags[tile_id])
        if terrain && terrain.id != :None
          if terrain.bridge
            next if $PokemonGlobal.bridge == 0
            passage = tile_data["passage"] ? tile_data["passage"].to_i : (ts.passages[tile_id] || 0)
            return (passage & bit == 0 && passage & 0x0f != 0x0f)
          end
          if terrain.can_surf && !terrain.waterfall
            return $PokemonGlobal.surfing
          end
          if $PokemonGlobal.bicycle && terrain.must_walk
            return false
          end
          next if terrain.ignore_passability
        end
        passage = tile_data["passage"] ? tile_data["passage"].to_i : (ts.passages[tile_id] || 0)
        return false if passage & bit != 0 || passage & 0x0f == 0x0f
        return true if (tile_data["priority"] ? tile_data["priority"].to_i : (ts.priorities[tile_id] || 0)) == 0
        next
      end
      terrain = GameData::TerrainTag.try_get($game_map.terrain_tags[tile_id])
      if terrain && terrain.id != :None
        if terrain.bridge
          next if $PokemonGlobal.bridge == 0
          passage = tile_data["passage"] ? tile_data["passage"].to_i : ($game_map.passages[tile_id] || 0)
          return (passage & bit == 0 && passage & 0x0f != 0x0f) if $PokemonGlobal.bridge > 0
        end
        if terrain.can_surf && !terrain.waterfall
          return $PokemonGlobal.surfing
        end
        if $PokemonGlobal.bicycle && terrain.must_walk
          return false
        end
        next if terrain.ignore_passability
      end
      passage = tile_data["passage"] ? tile_data["passage"].to_i : ($game_map.passages[tile_id] || 0)
      next if passage.nil?
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if (tile_data["priority"] ? tile_data["priority"].to_i : ($game_map.priorities[tile_id] || 0)) == 0
    end
    # Fallback: native layers with terrain checks + per-layer tileset awareness
    return $game_map.send(:native_layer_player_passable, x, y, d)
  end
end
end # if defined?(Debug_Passability)
