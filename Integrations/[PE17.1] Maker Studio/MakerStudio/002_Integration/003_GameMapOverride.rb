#===============================================================================
# MakerStudio - Game Map Override (Essentials v17.1)
#
# Patches Game_Map collision + terrain so they account for Maker Studio's
# extended layers and native-layer "extra" tiles (extra autotiles, cross-tileset
# tiles). Each Maker Studio tile is checked BEFORE deferring to the engine's own native
# logic (which still handles plain native tiles, events, surf/ice/ledge, etc.).
#
# v17.1 has NO GameData::TerrainTag — terrain is the integer PBTerrain system, and
# Game_Map#terrain_tag returns an Integer. So this is a full reimplementation of
# the v21.1 override against PBTerrain predicates:
#
#   GameData::TerrainTag           ->  PBTerrain integer + predicate
#   terrain.bridge                 ->  PBTerrain.isBridge?(tag)
#   terrain.can_surf (passable)    ->  PBTerrain.isPassableWater?(tag)
#   terrain.waterfall              ->  PBTerrain.isWaterfall?(tag)
#   terrain.must_walk(_or_run)     ->  PBTerrain.onlyWalk?(tag)   (TallGrass/Ice)
#   terrain.deep_bush              ->  tag == PBTerrain::TallGrass
#   terrain.ignore_passability     ->  (no equivalent on v17.1 — dropped)
#   terrain.id != :None            ->  tag != 0 && tag != PBTerrain::Neutral
#
# Cross-tileset native cells are blanked in the Table by the renderer; their
# original tile id is recovered via MakerStudio.each_native_extra_tile_at, so
# collision still resolves from the referenced tileset's tables.
#
# NOTE (documented limitation): pure per-tile passage/priority/terrain OVERRIDES
# painted on the NATIVE layers (without an autotile_name or tileset_id) are not
# applied here — the engine's untouched native logic is used for those cells. Overrides
# on extended layers, extra autotiles and cross-tileset tiles work fully.
#===============================================================================
class Game_Map
  NEUTRAL_TT = (defined?(PBTerrain) ? PBTerrain::Neutral : 13)

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
    entry = MakerStudio::DataStore.get_expanded_autotile(name)
    return [entry["passage"].to_i, entry["priority"].to_i, entry["terrain_tag"].to_i] if entry
    # Game_Map (self) carries autotile_names on v17.1; the RPG::Map (@map) does not.
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

  # Integer terrain tag for a Maker Studio tile.
  def ms_tile_terrain(tid, td)
    # An editor-set per-tile terrain_tag override wins for any tile type.
    tt = td["terrain_tag"]
    return tt.to_i if tt && tt.to_i != 0
    if td["autotile_name"]
      resolved = ms_extra_autotile_data(td)
      return resolved ? resolved[2] : 0
    elsif td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.terrain_tags[tid] || 0) : 0
    else
      return @terrain_tags[tid] || 0
    end
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

  # Yield [tid, td, native_extra] for every Maker Studio tile at (x,y):
  # extended FIRST (extended layers sit above every native layer), then
  # native-extra (top layer down). Uses THIS map's id (not $game_map) so
  # collision works on connected maps too. The native_extra flag lets the
  # passability checks refuse to let a ground native-layer tile DECIDE the
  # cell (see playerPassable?).
  def ms_each_tile_at(x, y)
    mid = map_id
    MakerStudio.each_extended_tile_at(mid, x, y) { |tid, td| yield tid, td, false }
    MakerStudio.each_native_extra_tile_at(mid, x, y) { |tid, td| yield tid, td, true }
    # Plain native tiles blanked by the overlay renderer because an extra
    # autotile sits below them (blank_covered_plain_tiles) — the Table reads 0
    # there, so the engine's native scan can't see them anymore. Keep honouring their
    # passage here (block-only, like other native-layer extras).
    if MakerStudio.respond_to?(:each_covered_plain_tile_at)
      MakerStudio.each_covered_plain_tile_at(mid, x, y) { |tid, td| yield tid, td, true }
    end
  end
  private :ms_each_tile_at

  #---------------------------------------------------------------------------
  # playerPassable? — terrain-aware (bridge / surf / cycling), mirrors the engine.
  #---------------------------------------------------------------------------
  alias __mkst__playerPassable playerPassable? unless method_defined?(:__mkst__playerPassable)
  def playerPassable?(x, y, d, self_event = nil)
    return __mkst__playerPassable(x, y, d, self_event) unless MakerStudio::ENABLED
    bit = (1 << (d / 2 - 1)) & 0x0f
    ms_each_tile_at(x, y) do |tid, td, native_extra|
      terrain = ms_tile_terrain(tid, td)
      if terrain != 0 && terrain != NEUTRAL_TT
        if PBTerrain.isBridge?(terrain)
          if $PokemonGlobal && $PokemonGlobal.bridge == 0
            next
          else
            passage = ms_tile_passage(tid, td)
            return (passage & bit == 0 && passage & 0x0f != 0x0f)
          end
        end
        if $PokemonGlobal && $PokemonGlobal.surfing && PBTerrain.isPassableWater?(terrain)
          return true
        end
        if $PokemonGlobal && $PokemonGlobal.bicycle && PBTerrain.onlyWalk?(terrain)
          return false
        end
      end
      passage = ms_tile_passage(tid, td)
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      # A ground extended tile decides the cell (extended sits above every
      # native layer). A ground NATIVE-layer extra tile must NOT decide:
      # plain native tiles on layers above it are only checked by the engine
      # fallback (bitmap-composited CustomTilemap — no per-layer interleave
      # here), so deciding would erase their impassability.
      return true if ms_tile_priority(tid, td) == 0 && !native_extra
      # else: fall through to the next Maker Studio tile / engine native logic
    end
    __mkst__playerPassable(x, y, d, self_event)
  end

  #---------------------------------------------------------------------------
  # passable? — for the player defer to playerPassable? (v17.1 does too); for
  # other events do a basic passage/priority check on Maker Studio tiles, then
  # fall back to the engine's native event logic.
  #---------------------------------------------------------------------------
  alias __mkst__passable passable? unless method_defined?(:__mkst__passable)
  def passable?(x, y, d, self_event = nil)
    return __mkst__passable(x, y, d, self_event) unless MakerStudio::ENABLED
    return playerPassable?(x, y, d, self_event) if self_event == $game_player
    bit = (1 << (d / 2 - 1)) & 0x0f
    ms_each_tile_at(x, y) do |tid, td, native_extra|
      passage = ms_tile_passage(tid, td)
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      # Ground native-layer extras must not decide — see playerPassable?.
      return true if ms_tile_priority(tid, td) == 0 && !native_extra
    end
    __mkst__passable(x, y, d, self_event)
  end

  #---------------------------------------------------------------------------
  # passableStrict?
  #---------------------------------------------------------------------------
  alias __mkst__passableStrict passableStrict? unless method_defined?(:__mkst__passableStrict)
  def passableStrict?(x, y, d, self_event = nil)
    return __mkst__passableStrict(x, y, d, self_event) unless MakerStudio::ENABLED
    ms_each_tile_at(x, y) do |tid, td, native_extra|
      passage = ms_tile_passage(tid, td)
      return false if passage & 0x0f != 0
      # Ground native-layer extras must not decide — see playerPassable?.
      return true if ms_tile_priority(tid, td) == 0 && !native_extra
    end
    __mkst__passableStrict(x, y, d, self_event)
  end

  #---------------------------------------------------------------------------
  # terrain_tag — returns an Integer (v17.1 convention). Extended/native-extra
  # tiles take priority; fall back to the engine's native terrain_tag.
  #---------------------------------------------------------------------------
  alias __mkst__terrain_tag terrain_tag unless method_defined?(:__mkst__terrain_tag)
  def terrain_tag(x, y, countBridge = false)
    return __mkst__terrain_tag(x, y, countBridge) unless MakerStudio::ENABLED
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      next if terrain == 0 || terrain == NEUTRAL_TT
      next if !countBridge && PBTerrain.isBridge?(terrain) && $PokemonGlobal && $PokemonGlobal.bridge == 0
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
    return true if result
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      return false if PBTerrain.isBridge?(terrain) && $PokemonGlobal && $PokemonGlobal.bridge > 0
      return true if ms_tile_passage(tid, td) & 0x40 == 0x40
    end
    false
  end

  #---------------------------------------------------------------------------
  # deepBush? — passage bit 0x40 AND TallGrass terrain.
  #---------------------------------------------------------------------------
  alias __mkst__deepBush deepBush? unless method_defined?(:__mkst__deepBush)
  def deepBush?(x, y)
    result = __mkst__deepBush(x, y)
    return result unless MakerStudio::ENABLED
    return true if result
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      return false if PBTerrain.isBridge?(terrain) && $PokemonGlobal && $PokemonGlobal.bridge > 0
      return true if ms_tile_passage(tid, td) & 0x40 == 0x40 && terrain == PBTerrain::TallGrass
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
    return true if result
    ms_each_tile_at(x, y) do |tid, td|
      return true if ms_tile_passage(tid, td) & 0x80 == 0x80
    end
    false
  end
end
