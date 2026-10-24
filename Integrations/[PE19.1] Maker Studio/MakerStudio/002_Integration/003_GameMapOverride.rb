#===============================================================================
# MakerStudio - Game Map Override (Pokémon Essentials v19.1)
#
# Patches Game_Map collision + terrain so they account for Maker Studio's
# extended layers and native-layer "extra" tiles (extra autotiles, cross-tileset
# tiles). Each Maker Studio tile is checked BEFORE deferring to v19.1's own
# native logic (which still handles plain native tiles, events, surf/ice/ledge).
#
# v19.1 already has GameData::TerrainTag (objects, like v21.1) — Game_Map#terrain_tag
# returns a TerrainTag, not the Integer BES returns. So the terrain chain here
# mirrors v19.1's own Game_Map#playerPassable? exactly:
#
#   bridge             -> skipped while off-bridge, decides by passage while on one
#   can_surf           -> passable while surfing (unless waterfall)
#   must_walk          -> blocks cycling (v19.1 has no must_walk_or_run; v21.1 added it)
#   ignore_passability -> tile takes no part in the passage/priority check
#
# The overlay renderer can blank native Table cells, so collision restores their
# original ids before resolving passage and terrain.
#===============================================================================
class Game_Map
  def ms_event_tile_passable(x, y, bit, self_event, strict)
    return nil unless @events
    @events.each_value do |event|
      next if event == self_event || !event.at_coordinate?(x, y) || event.through
      tile_id = event.tile_id
      region = MakerStudio.region_tile(event)
      next if !region && (strict ? tile_id < 0 : tile_id <= 0)
      tileset, tile_id = region if region
      passages = region ? tileset.passages : @passages
      priorities = region ? tileset.priorities : @priorities
      terrain_tags = region ? tileset.terrain_tags : @terrain_tags
      terrain = GameData::TerrainTag.try_get(terrain_tags[tile_id])
      passage = passages[tile_id] || 0
      if region && !strict && self_event == $game_player
        terrain = terrain.id == :None ? GameData::TerrainTag.try_get(terrain_tag(x, y, true)) : terrain
        next if terrain.bridge && $PokemonGlobal.bridge == 0
        return true if $PokemonGlobal.surfing && terrain.can_surf && !terrain.waterfall
        return false if $PokemonGlobal.bicycle && (terrain.must_walk || terrain.must_walk_or_run)
        return (passage & bit == 0 && passage & 0x0f != 0x0f) if terrain.bridge && $PokemonGlobal.bridge > 0
      end
      next if !strict && terrain.ignore_passability
      return false if strict ? (passage & 0x0f != 0) : (passage & bit != 0 || passage & 0x0f == 0x0f)
      return true if priorities[tile_id] == 0
    end
    nil
  end
  private :ms_event_tile_passable

  def ms_each_region_event_tile(x, y)
    return unless @events
    @events.each_value do |event|
      next unless event.at_coordinate?(x, y)
      tile = MakerStudio.region_tile(event)
      yield tile[0], tile[1] if tile
    end
  end
  private :ms_each_region_event_tile

  #---------------------------------------------------------------------------
  # Resolve [passage, priority, terrain] for an extra autotile from tile_data,
  # falling back to expanded_autotiles config, then any tileset that lists the
  # autotile by name. Returns nil if nothing is known.
  #---------------------------------------------------------------------------
  def ms_extra_autotile_data(td)
    if td["passage"]
      return [td["passage"].to_i, (td["priority"] || 0).to_i, (td["terrain_tag"] || 0).to_i]
    end
    name = td["autotile_name"]
    return nil unless name
    if td["tileset_id"]
      source_id = td["tileset_id"].to_i
      entry = MakerStudio::DataStore.get_expanded_autotile(name, source_id)
      return [entry["passage"].to_i, entry["priority"].to_i, entry["terrain_tag"].to_i] if entry
      ts = $data_tilesets[source_id]
      return nil unless ts && ts.autotile_names
      idx = ts.autotile_names.index(name)
      return nil unless idx
      base = (idx + 1) * 48
      return [ts.passages[base] || 0, ts.priorities[base] || 0, ts.terrain_tags[base] || 0]
    end
    entry = MakerStudio::DataStore.get_expanded_autotile(name)
    return [entry["passage"].to_i, entry["priority"].to_i, entry["terrain_tag"].to_i] if entry
    if autotile_names
      idx = autotile_names.index(name)
      if idx
        base = (idx + 1) * 48
        return [@passages[base] || 0, @priorities[base] || 0, @terrain_tags[base] || 0]
      end
    end
    if $data_tilesets
      $data_tilesets.each do |ts|
        next unless ts && ts.autotile_names
        idx = ts.autotile_names.index(name)
        next unless idx
        base = (idx + 1) * 48
        return [ts.passages[base] || 0, ts.priorities[base] || 0, ts.terrain_tags[base] || 0]
      end
    end
    nil
  end
  private :ms_extra_autotile_data

  # Raw integer terrain tag for a Maker Studio tile.
  def ms_tile_terrain_id(tid, td)
    # An editor-set per-tile terrain_tag override wins for any tile type.
    tt = td["terrain_tag"]
    return tt.to_i if tt && tt.to_i != 0
    if td["autotile_name"]
      resolved = ms_extra_autotile_data(td)
      return resolved ? resolved[2] : 0
    elsif td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.terrain_tags[tid] || 0) : 0
    end
    @terrain_tags[tid] || 0
  end
  private :ms_tile_terrain_id

  # GameData::TerrainTag object for a Maker Studio tile (nil when unknown).
  def ms_tile_terrain(tid, td)
    GameData::TerrainTag.try_get(ms_tile_terrain_id(tid, td))
  end
  private :ms_tile_terrain

  def ms_tile_passage(tid, td)
    return td["passage"].to_i if td["passage"]
    if td["autotile_name"]
      resolved = ms_extra_autotile_data(td)
      return resolved ? resolved[0] : 0
    elsif td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.passages[tid] || 0) : 0
    end
    @passages[tid] || 0
  end
  private :ms_tile_passage

  def ms_tile_priority(tid, td)
    return td["priority"].to_i if td["priority"]
    if td["autotile_name"]
      resolved = ms_extra_autotile_data(td)
      return resolved ? resolved[1] : 0
    elsif td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.priorities[tid] || 0) : 0
    end
    @priorities[tid] || 0
  end
  private :ms_tile_priority

  # Yield visible extended tiles, then native tiles top-down on this map.
  def ms_each_tile_at(x, y)
    mid = map_id
    MakerStudio.each_extended_tile_at(mid, x, y) { |tid, td| yield tid, td }
    return unless @map && @map.data
    ext = MakerStudio.get_extended_data_for(mid)
    native_props = ext ? ext["nativeProperties"] : nil
    key = "#{x},#{y}"
    (MakerStudio::NATIVE_LAYERS - 1).downto(0) do |layer|
      tid = @map.data[x, y, layer]
      next if tid.nil?
      if MakerStudio.respond_to?(:original_native_tile_id)
        tid = MakerStudio.original_native_tile_id(mid, x, y, layer, tid)
      end
      td = native_props && native_props[layer] ? native_props[layer][key] : nil
      td = {} unless td
      next if tid == 0 && !td["autotile_name"]
      yield tid, td
    end
  end
  private :ms_each_tile_at

  #---------------------------------------------------------------------------
  # playerPassable? — terrain-aware (bridge / surf / cycling), mirrors v19.1.
  #---------------------------------------------------------------------------
  alias __mkst__playerPassable playerPassable? unless method_defined?(:__mkst__playerPassable)
  def playerPassable?(x, y, d, self_event = nil)
    return __mkst__playerPassable(x, y, d, self_event) unless MakerStudio::ENABLED
    bit = (1 << (d / 2 - 1)) & 0x0f
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      passage = ms_tile_passage(tid, td)
      if terrain
        # Ignore bridge tiles if not on a bridge
        next if terrain.bridge && $PokemonGlobal.bridge == 0
        # Make water tiles passable if the player is surfing
        return true if $PokemonGlobal.surfing && terrain.can_surf && !terrain.waterfall
        # Prevent cycling in really tall grass / on ice
        return false if $PokemonGlobal.bicycle && terrain.must_walk
        # Depend on the passability of the bridge tile if on a bridge
        if terrain.bridge && $PokemonGlobal.bridge > 0
          return (passage & bit == 0 && passage & 0x0f != 0x0f)
        end
      end
      next if terrain && terrain.ignore_passability
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if ms_tile_priority(tid, td) == 0
    end
    __mkst__playerPassable(x, y, d, self_event)
  end

  #---------------------------------------------------------------------------
  # passable? — for the player defer to playerPassable? (v19.1 does too); for
  # other events do a basic passage/priority check on Maker Studio tiles, then
  # fall back to the engine's native event logic.
  #---------------------------------------------------------------------------
  alias __mkst__passable passable? unless method_defined?(:__mkst__passable)
  def passable?(x, y, d, self_event = nil)
    return __mkst__passable(x, y, d, self_event) unless MakerStudio::ENABLED
    event_result = ms_event_tile_passable(x, y, (1 << (d / 2 - 1)) & 0x0f, self_event, false)
    return event_result unless event_result.nil?
    return playerPassable?(x, y, d, self_event) if self_event == $game_player
    bit = (1 << (d / 2 - 1)) & 0x0f
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      next if terrain && terrain.ignore_passability
      passage = ms_tile_passage(tid, td)
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if ms_tile_priority(tid, td) == 0
    end
    __mkst__passable(x, y, d, self_event)
  end

  #---------------------------------------------------------------------------
  # passableStrict?
  #---------------------------------------------------------------------------
  alias __mkst__passableStrict passableStrict? unless method_defined?(:__mkst__passableStrict)
  def passableStrict?(x, y, d, self_event = nil)
    return __mkst__passableStrict(x, y, d, self_event) unless MakerStudio::ENABLED
    event_result = ms_event_tile_passable(x, y, 0, self_event, true)
    return event_result unless event_result.nil?
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      next if terrain && terrain.ignore_passability
      return false if ms_tile_passage(tid, td) & 0x0f != 0
      return true if ms_tile_priority(tid, td) == 0
    end
    __mkst__passableStrict(x, y, d, self_event)
  end

  #---------------------------------------------------------------------------
  # terrain_tag — returns a GameData::TerrainTag (v19.1 convention). Extended /
  # native-extra tiles take priority; fall back to the engine's native scan.
  #---------------------------------------------------------------------------
  alias __mkst__terrain_tag terrain_tag unless method_defined?(:__mkst__terrain_tag)
  def terrain_tag(x, y, countBridge = false)
    return __mkst__terrain_tag(x, y, countBridge) unless MakerStudio::ENABLED
    ms_each_region_event_tile(x, y) do |tileset, tile_id|
      terrain = GameData::TerrainTag.try_get(tileset.terrain_tags[tile_id])
      next if terrain.id == :None || terrain.ignore_passability
      next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
      return terrain
    end
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      next if !terrain || terrain.id == :None || terrain.ignore_passability
      next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
      return terrain
    end
    __mkst__terrain_tag(x, y, countBridge)
  end

  #---------------------------------------------------------------------------
  # bush? — passage bit 0x40 (and not a bridge tile while on a bridge).
  #---------------------------------------------------------------------------
  alias __mkst__bush bush? unless method_defined?(:__mkst__bush)
  def bush?(x, y)
    result = __mkst__bush(x, y)
    return result unless MakerStudio::ENABLED
    ms_each_region_event_tile(x, y) do |tileset, tile_id|
      terrain = GameData::TerrainTag.try_get(tileset.terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if (tileset.passages[tile_id] || 0) & 0x40 == 0x40
    end
    return true if result
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      return false if terrain && terrain.bridge && $PokemonGlobal.bridge > 0
      return true if ms_tile_passage(tid, td) & 0x40 == 0x40
    end
    false
  end

  #---------------------------------------------------------------------------
  # deepBush? — passage bit 0x40 AND a deep_bush terrain.
  #---------------------------------------------------------------------------
  alias __mkst__deepBush deepBush? unless method_defined?(:__mkst__deepBush)
  def deepBush?(x, y)
    result = __mkst__deepBush(x, y)
    return result unless MakerStudio::ENABLED
    ms_each_region_event_tile(x, y) do |tileset, tile_id|
      terrain = GameData::TerrainTag.try_get(tileset.terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.deep_bush && (tileset.passages[tile_id] || 0) & 0x40 == 0x40
    end
    return true if result
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      next unless terrain
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.deep_bush && ms_tile_passage(tid, td) & 0x40 == 0x40
    end
    false
  end

  #---------------------------------------------------------------------------
  # counter? — passage bit 0x80.
  #---------------------------------------------------------------------------
  alias __mkst__counter counter? unless method_defined?(:__mkst__counter)
  def counter?(x, y)
    result = __mkst__counter(x, y)
    return result unless MakerStudio::ENABLED
    ms_each_region_event_tile(x, y) do |tileset, tile_id|
      return true if (tileset.passages[tile_id] || 0) & 0x80 == 0x80
    end
    return true if result
    ms_each_tile_at(x, y) do |tid, td|
      return true if ms_tile_passage(tid, td) & 0x80 == 0x80
    end
    false
  end
end
