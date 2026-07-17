#===============================================================================
# MakerStudio - Map Versioning (Pokémon Essentials v19.1)
#
# One logical map (map_id) can hold multiple full "versions" of its content
# (tiles + events + extended layers), all stored INSIDE the same MapXXX.rxdata
# under a native @map_versions instance variable on the RPG::Map. Vanilla RPG
# Maker XP ignores unknown ivars, so the base map (version 0) is untouched and
# still loads in stock RMXP. No sidecar files.
#
# A version is selected in-game by a switch or variable chosen in the editor.
# When the selector's state changes, the WHOLE current map swaps in place with
# no Transfer Player / map change: the player stays put and the world changes
# around them. This reuses the same live-swap mechanics as pbRefreshLiveMapData
# (002_Integration/001_Hooks.rb).
#
# Storage (@map_versions ivar on the base RPG::Map):
#   [ { "index"    => 1,
#       "name"     => "Cinematic",
#       "selector" => { "kind" => "variable", "id" => 27, "value" => 4 },
#       "map"      => <a full nested RPG::Map> },
#     { "index"    => 2,
#       "name"     => "Destroyed",
#       "selector" => { "kind" => "switch", "id" => 88 },
#       "map"      => <RPG::Map> } ]
#
# Active-version rule: evaluate entries by ASCENDING index; the FIRST whose
# selector matches wins (variable == value, or switch ON); none match => version
# 0 (the base map on disk).
#
# v19.1 differences from the v21.1 build:
#   * No EventHandlers — the "forget applied version on map setup" trigger is a
#     second Game_Map#setup alias instead of :on_game_map_setup/:on_leave_map.
#   * No TilemapRenderer — v19.1 draws through CustomTilemap, so there is no
#     TileSprite#set_bitmap transform-reset patch (that stale-transform bug is
#     specific to the v21.1 per-tile sprite pool) and no map_renderer.refresh.
#     The swap rebuilds the spritesets, which recreates the Maker Studio overlay
#     (002_OverlayRenderer) and re-blanks/redraws every cell from scratch.
#===============================================================================
module MakerStudio
  @active_version    = {}  # map_id => last applied version index
  @pending_version   = {}  # map_id => version index queued for the next safe-point swap
  @base_map_cache    = {}  # map_id => base RPG::Map loaded from disk (manifest source)
  @versions_cache    = {}  # map_id => index-sorted Array of version entry hashes

  #---------------------------------------------------------------------------
  # Load (and cache) the base map from disk. The base map carries @map_versions;
  # we read it from disk (not $game_map.@map) because after a swap @map points at
  # a version map that has no @map_versions of its own.
  #---------------------------------------------------------------------------
  def self.base_map_for(map_id)
    @base_map_cache ||= {}
    return @base_map_cache[map_id] if @base_map_cache.has_key?(map_id)
    rpg = (load_data(sprintf("Data/Map%03d.rxdata", map_id)) rescue nil)
    @base_map_cache[map_id] = rpg
  end

  #---------------------------------------------------------------------------
  # Index-sorted version manifest for a map (empty array when the map has none).
  #---------------------------------------------------------------------------
  def self.versions_manifest(map_id)
    @versions_cache ||= {}
    return @versions_cache[map_id] if @versions_cache.has_key?(map_id)
    base = base_map_for(map_id)
    arr  = base ? (base.instance_variable_get(:@map_versions) rescue nil) : nil
    sorted = arr.is_a?(Array) ? arr.sort_by { |v| (v["index"] || 0).to_i } : []
    @versions_cache[map_id] = sorted
  end

  #---------------------------------------------------------------------------
  # Resolve the active version index from current switch/variable state.
  # Returns 0 (base) when nothing matches.
  #---------------------------------------------------------------------------
  def self.active_version_index(map_id)
    versions_manifest(map_id).each do |v|
      sel = v["selector"]
      next unless sel.is_a?(Hash)
      case sel["kind"]
      when "variable"
        cur  = $game_variables[sel["id"].to_i]
        want = sel["value"]
        return v["index"].to_i if cur == want || cur.to_s == want.to_s
      when "switch"
        return v["index"].to_i if $game_switches[sel["id"].to_i] == true
      end
    end
    0
  end

  #---------------------------------------------------------------------------
  # The RPG::Map for a version index. Index 0 => the base map (from disk); else
  # the nested RPG::Map stored in the matching @map_versions entry. nil if absent.
  #---------------------------------------------------------------------------
  def self.version_map(map_id, index)
    return base_map_for(map_id) if index == 0
    entry = versions_manifest(map_id).find { |v| v["index"].to_i == index }
    entry ? entry["map"] : nil
  end

  #---------------------------------------------------------------------------
  # Currently-applied version index for a map (0 = base / unversioned).
  #---------------------------------------------------------------------------
  def self.active_version_for(map_id)
    (@active_version && @active_version[map_id]) || 0
  end

  #---------------------------------------------------------------------------
  # Namespace a self-switch key per active version.
  #
  # Self-switch keys are [map_id, event_id, letter]. Versions share map_id, so
  # without this the SAME key is used by what are really DIFFERENT events across
  # versions — toggling one wrongly affects the other. Non-base versions rebase to
  # a 4-element key ["mkstv<N>", map_id, event_id, letter], which can never
  # collide with a vanilla 3-element key. Base (version 0) / unversioned maps are
  # untouched, so existing saves behave exactly as before.
  #---------------------------------------------------------------------------
  def self.versioned_self_switch_key(key)
    return key unless key.is_a?(Array) && key.size == 3
    v = active_version_for(key[0])
    return key if v == 0
    ["mkstv#{v}", key[0], key[1], key[2]]
  end

  #---------------------------------------------------------------------------
  # Swap the live $game_map to the given version, IN PLACE (no Transfer Player).
  # Models 002_Integration/001_Hooks.rb#pbRefreshLiveMapData.
  #---------------------------------------------------------------------------
  def self.apply_map_version(map_id, index)
    return unless $game_map && $game_map.map_id == map_id
    fresh = version_map(map_id, index)
    return unless fresh && fresh.respond_to?(:data) && fresh.data

    # Different tileset per version: reload tilesets so the new graphic / passage
    # data is available (Game_Map reads its tileset via @map.tileset_id).
    fresh_tilesets = (load_data("Data/Tilesets.rxdata") rescue nil)
    if fresh_tilesets
      $data_tilesets = fresh_tilesets
      RPG::Cache.clear if defined?(RPG::Cache)
    end

    # Point Game_Map at the version's RPG::Map (carries @tileset_id, @data,
    # @events and the version's own @extended_layers). Game_Map#data/#width/etc
    # all delegate to @map, so the live map now reads from `fresh` directly.
    $game_map.instance_variable_set(:@map, fresh)

    # CRITICAL: mirror Game_Map#setup — rebuild @tileset_name / @autotile_names /
    # @passages / @priorities / @terrain_tags from the (possibly different)
    # version tileset. The renderer reads map.autotile_names/priorities and
    # collision reads @passages; without this they stay on the previous version's
    # tileset and tiles + collision break.
    $game_map.send(:updateTileset) if $game_map.respond_to?(:updateTileset, true)

    # Mark the active version NOW — before rebuilding events — so each new
    # Game_Event's internal refresh reads self-switches from THIS version's
    # namespace (see versioned_self_switch_key).
    @active_version[map_id] = index

    # Rebuild events from the version's event hash (3rd arg required for moveto).
    if fresh.events
      new_events = {}
      fresh.events.each do |key, rpg_event|
        new_events[key] = Game_Event.new(map_id, rpg_event, $game_map)
      end
      $game_map.instance_variable_set(:@events, new_events)
    end

    # Rebuild common-event objects too (setup does this; harmless to refresh).
    if defined?($data_common_events) && $data_common_events
      new_common = {}
      (1...$data_common_events.size).each do |i|
        new_common[i] = Game_CommonEvent.new(i)
      end
      $game_map.instance_variable_set(:@common_events, new_common)
    end

    # Kill any running map interpreter so an autorun / parallel process from the
    # previous version can't keep executing against an event that no longer
    # exists. Fresh Game_Event objects re-arm their own parallel pages on refresh.
    mi = ($game_system.map_interpreter rescue nil)
    if mi
      if mi.respond_to?(:clear)
        mi.clear
      elsif mi.respond_to?(:setup)
        mi.setup(nil, 0)
      end
    end
    $game_map.refresh if $game_map.respond_to?(:refresh)

    # Reload MakerStudio extended layers (fog / shadow / extended / native props)
    # from the swapped @map's @extended_layers, busting per-map caches first.
    clear_all_caches if respond_to?(:clear_all_caches)
    MakerStudio::TileEffects.clear_cache if defined?(MakerStudio::TileEffects)
    load_extended_layers_for_map(map_id, $game_map)
    # Re-apply this version's per-map panorama / battleback + native-fog
    # suppression (the version's own @extended_layers mapSettings / fogLayers).
    if respond_to?(:apply_map_background_overrides)
      apply_map_background_overrides($game_map, map_id)
    end

    # Rebuild the spritesets: this recreates each Spriteset_Map (fresh CustomTilemap
    # bound to the version's map data + fresh character sprites) and, through
    # Events.onSpritesetCreate, a fresh Maker Studio Overlay that re-blanks and
    # redraws every cell for the new version.
    if $scene.respond_to?(:disposeSpritesets) && $scene.respond_to?(:createSpritesets)
      $scene.disposeSpritesets
      $scene.createSpritesets
    end

    # Re-point the native CustomTilemap at the (freshly blanked) map data.
    sp = MakerStudio.instance_variable_get(:@current_spriteset)
    if sp
      tm = (sp.instance_variable_get(:@tilemap) rescue nil)
      begin
        if tm
          tm.tileset = pbGetTileset($game_map.tileset_name)
          tm.priorities = $game_map.priorities
          tm.map_data = $game_map.data
        end
      rescue
      end
    end

    @active_version[map_id] = index
  end

  #---------------------------------------------------------------------------
  # Per-frame DETECT (cheap): if the selector now resolves to a different version
  # than the one applied, record it as pending. The actual swap is applied later
  # by apply_pending_version at a SAFE point (Scene_Map#update, before the frame
  # loop) — NOT here. apply_map_version calls disposeSpritesets/createSpritesets
  # + Game_Event.new, which corrupt the scene if run from inside Game_Map#update
  # (deep in Scene_Map's updateMaps loop): events stop rendering and lose
  # collision/triggers, tiles glitch. The engine itself only does dispose/create
  # at safe points (transfer_player runs after the update loop breaks).
  #---------------------------------------------------------------------------
  def self.check_version_swap(map_id)
    return unless $game_map && $game_map.map_id == map_id
    return if versions_manifest(map_id).empty?
    want = active_version_index(map_id)
    cur  = @active_version[map_id]
    if cur.nil?
      # Fresh setup: the engine already loaded the base (v0). Mark v0 applied;
      # only queue a swap if a non-base version is active right now.
      @active_version[map_id] = 0
      @pending_version[map_id] = want if want != 0
    elsif cur != want && @pending_version[map_id] != want
      @pending_version[map_id] = want
    end
  end

  #---------------------------------------------------------------------------
  # Apply any queued version swap for the current map. Called from the aliased
  # Scene_Map#update at the top of the frame, BEFORE the update loop — the same
  # safe point the engine uses for player transfers. No-op when nothing pending.
  #---------------------------------------------------------------------------
  def self.apply_pending_version
    return unless $game_map
    map_id = $game_map.map_id
    want = @pending_version[map_id]
    return if want.nil?
    @pending_version.delete(map_id)
    return if @active_version[map_id] == want
    apply_map_version(map_id, want)
  end

  #---------------------------------------------------------------------------
  # Optional explicit API for map makers. Forces a version now; does NOT change
  # the bound selector (use Control Switch / Variable for persistent changes).
  #---------------------------------------------------------------------------
  def self.set_map_version(map_id, index)
    apply_map_version(map_id, index)
  end

  #---------------------------------------------------------------------------
  # Drop per-map applied marker + manifest memo so the next setup re-evaluates
  # against a freshly loaded base map (picks up editor hot-reloads).
  #---------------------------------------------------------------------------
  def self.reset_version_state(map_id)
    @active_version.delete(map_id) if @active_version
    @pending_version.delete(map_id) if @pending_version
    @versions_cache.delete(map_id) if @versions_cache
    @base_map_cache.delete(map_id) if @base_map_cache
  end

  #---------------------------------------------------------------------------
  # Drop all applied-version markers (e.g. on save -> Continue / new game).
  #---------------------------------------------------------------------------
  def self.reset_all_version_state
    @active_version  = {}
    @pending_version = {}
  end
end

#-------------------------------------------------------------------------------
# Per-version self-switch namespacing.
#
# Self-switch keys are [map_id, event_id, letter]. Map Versioning reuses one
# map_id for multiple versions whose events differ, so a vanilla key collides
# across versions. Keys are rebased to the active version at the single choke
# point — the Game_SelfSwitches accessors — so EVERY reader/writer (page
# conditions, command 123 Control Self Switch, Game_Event#refresh) is covered.
# Base / unversioned maps keep their 3-element key, so saves are unchanged.
# Pattern A (alias once, def unconditionally) for F12 soft-reset survival.
#-------------------------------------------------------------------------------
class Game_SelfSwitches
  unless method_defined?(:__mkst_ver__get) || private_method_defined?(:__mkst_ver__get)
    alias_method :__mkst_ver__get, :[]
  end
  def [](key)
    return __mkst_ver__get(key) unless MakerStudio::ENABLED
    __mkst_ver__get(MakerStudio.versioned_self_switch_key(key))
  end

  unless method_defined?(:__mkst_ver__set) || private_method_defined?(:__mkst_ver__set)
    alias_method :__mkst_ver__set, :[]=
  end
  def []=(key, value)
    return __mkst_ver__set(key, value) unless MakerStudio::ENABLED
    __mkst_ver__set(MakerStudio.versioned_self_switch_key(key), value)
  end
end

#===============================================================================
# Triggers
#===============================================================================
#-------------------------------------------------------------------------------
# Fresh map setup loaded the base map -> forget any applied marker so the poll
# re-evaluates the selector (and re-reads the manifest in case it changed).
# v19.1 has no :on_game_map_setup event, so this is a second Game_Map#setup alias
# (001_Hooks.rb owns the first one, which loads the extended layers).
#-------------------------------------------------------------------------------
class Game_Map
  unless method_defined?(:__mkst_ver__setup) || private_method_defined?(:__mkst_ver__setup)
    alias_method :__mkst_ver__setup, :setup
  end
  def setup(map_id)
    __mkst_ver__setup(map_id)
    MakerStudio.reset_version_state(map_id) if MakerStudio::ENABLED
  end
end

#-------------------------------------------------------------------------------
# Save -> Continue refresh: 002_Integration/001_Hooks.rb already aliases
# Game.load_map to reload the BASE map. Chain a second alias so version markers
# are cleared afterward; the per-frame poll then re-applies the correct version
# for the loaded switch / variable state (which is saved in $game_switches /
# $game_variables). Pattern A so the override survives an mkxp F12 soft-reset.
#-------------------------------------------------------------------------------
module Game
  class << self
    unless method_defined?(:__mkst_ver__load_map) || private_method_defined?(:__mkst_ver__load_map)
      alias_method :__mkst_ver__load_map, :load_map
    end
    def load_map
      __mkst_ver__load_map
      return unless MakerStudio::ENABLED
      MakerStudio.reset_all_version_state
    end
  end
end

#-------------------------------------------------------------------------------
# DETECT each frame: Game_Map#update only records a pending swap (cheap selector
# compare) — it must NOT swap here. Only the active $game_map is polled (connected
# maps in $MapFactory also receive update); versioning is current-map only.
#-------------------------------------------------------------------------------
class Game_Map
  unless method_defined?(:__mkst_ver__update) || private_method_defined?(:__mkst_ver__update)
    alias_method :__mkst_ver__update, :update
  end
  def update(*args)
    __mkst_ver__update(*args)
    return unless MakerStudio::ENABLED
    MakerStudio.check_version_swap(@map_id) if $game_map && $game_map.equal?(self)
  end
end

#-------------------------------------------------------------------------------
# APPLY at a safe point: Scene_Map#update runs the queued swap at the TOP of the
# frame, before the interpreter / player / map updates — the same safe point the
# engine uses for transfer_player. Swapping here (vs. inside Game_Map#update)
# means disposeSpritesets/createSpritesets + Game_Event.new run between frames,
# so the new version's events render and keep collision/triggers.
#-------------------------------------------------------------------------------
class Scene_Map
  unless method_defined?(:__mkst_ver__scene_update) || private_method_defined?(:__mkst_ver__scene_update)
    alias_method :__mkst_ver__scene_update, :update
  end
  def update(*args)
    MakerStudio.apply_pending_version if MakerStudio::ENABLED
    __mkst_ver__scene_update(*args)
  end
end

#-------------------------------------------------------------------------------
# "Reload Map Data" (debug menu) re-applies the active version.
#
# pbReloadCurrentMapData (002_Integration/001_Hooks.rb) reloads the BASE map into
# $game_map but leaves @active_version untouched — so after a reload the live map
# is the base while @active_version still says e.g. v2, and the per-frame poll
# sees cur == want and never re-applies, leaving you stuck on the wrong version.
# Fix: drop the version state and re-resolve + apply for the CURRENT selector
# state. Pattern A.
#-------------------------------------------------------------------------------
if defined?(pbReloadCurrentMapData)
  unless defined?(__mkst_ver__pbReloadCurrentMapData)
    alias __mkst_ver__pbReloadCurrentMapData pbReloadCurrentMapData
  end
  def pbReloadCurrentMapData
    __mkst_ver__pbReloadCurrentMapData
    return unless MakerStudio::ENABLED
    return unless $game_map
    map_id = $game_map.map_id
    # Forget cached version state so the manifest + active index are recomputed
    # from the freshly reloaded base map and the CURRENT selector values.
    MakerStudio.reset_version_state(map_id)
    next_index = MakerStudio.active_version_index(map_id)
    MakerStudio.instance_variable_get(:@active_version)[map_id] = 0
    MakerStudio.apply_map_version(map_id, next_index) if next_index != 0
  end
end
