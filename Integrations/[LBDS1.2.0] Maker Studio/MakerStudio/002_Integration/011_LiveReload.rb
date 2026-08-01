#===============================================================================
# MakerStudio - Live map reload
#
# The editor drops a sentinel file after every successful map save. While
# playtesting in debug, the running game notices it and re-applies the map in
# place — the same reload the "Reload Map Data" debug command performs, minus
# the confirmation message — so an edit is visible without leaving the map.
#
# Cost is one File.mtime per second, and only in $DEBUG: the file is stat'ed,
# never read, until its timestamp actually moves.
#===============================================================================

module MakerStudio
  # Written by the editor: "<map_id> <epoch_millis>".
  LIVE_RELOAD_FILE = "Plugins/MakerStudio/003_Editor/.live-reload"

  @live_reload_next_frame = 0
  @live_reload_seen = nil

  # Session override set from the debug menu; nil = follow the setting.
  @live_reload_override = nil

  def self.live_reload_enabled?
    return false unless defined?(ENABLED) && ENABLED
    return @live_reload_override unless @live_reload_override.nil?
    # Deliberately not $DEBUG: RGSS leaves it false for a plain Game.exe run on
    # the older engines, which is where playtesting actually happens. The
    # LIVE_RELOAD setting is the switch; a build without it stays on.
    return LIVE_RELOAD if defined?(LIVE_RELOAD)
    true
  end

  # Flip it for this session only — the setting still decides the next launch.
  # Returns the new state.
  def self.live_reload_toggle
    @live_reload_override = !live_reload_enabled?
    # A reload queued while it was off is not news; start from what is on disk.
    @live_reload_seen = nil unless @live_reload_override
    @live_reload_override
  end

  def self.live_reload_state_text
    live_reload_enabled? ? "ON" : "OFF"
  end

  # Polled from Scene_Map#update. Returns true when a reload was applied.
  def self.check_live_reload
    return false unless live_reload_enabled?
    return false if Graphics.frame_count < @live_reload_next_frame
    # One check a second, whatever the frame rate the build runs at.
    rate = (Graphics.frame_rate rescue 40)
    rate = 40 if !rate.is_a?(Integer) || rate <= 0
    @live_reload_next_frame = Graphics.frame_count + rate

    return false unless File.file?(LIVE_RELOAD_FILE)
    stamp = (File.mtime(LIVE_RELOAD_FILE).to_f rescue nil)
    return false if stamp.nil? || stamp == @live_reload_seen

    first_sighting = @live_reload_seen.nil?
    @live_reload_seen = stamp
    # A sentinel written before this session started describes a save already on
    # disk — the map was loaded from it. Nothing to re-apply.
    return false if first_sighting

    # 0 means "whatever map is loaded": a tileset, database or map-tree edit
    # is not tied to one map, so it applies wherever the player is standing.
    map_id = (File.read(LIVE_RELOAD_FILE).to_s.split(" ").first.to_i rescue 0)
    return false unless $game_map
    return false unless map_id == 0 || map_id == $game_map.map_id
    map_id = $game_map.map_id

    clear_all_caches if respond_to?(:clear_all_caches)
    MakerStudio::TileEffects.clear_cache if defined?(MakerStudio::TileEffects)
    pbRefreshLiveMapData(map_id)
    true
  end
end

#-------------------------------------------------------------------------------
# Poll at the top of the frame, the same safe point map versioning swaps at:
# before the interpreter, the player and the map update. Pattern A (alias once,
# def unconditionally so an mkxp soft-reset re-applies the override).
#-------------------------------------------------------------------------------
class Scene_Map
  unless method_defined?(:__mkst_live__update) || private_method_defined?(:__mkst_live__update)
    alias_method :__mkst_live__update, :update
  end
  def update(*args)
    MakerStudio.check_live_reload
    __mkst_live__update(*args)
  end
end
