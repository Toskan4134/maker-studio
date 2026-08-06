#===============================================================================
# MakerStudio - Fog Event Commands + Map Background Overrides
#
# 1. Per-map background overrides (applied right after Game_Map#setup, once the
#    map's extended layers are cached by 002_RendererOverride):
#      - Suppress the native tileset fog when the map carries Maker Studio fog
#        layers, so the engine's single tileset fog does not double-render over
#        the multi-fog planes created in 004_FogOverride.rb.
#      - Apply the per-map panorama / battleback stored in @extended_layers
#        "mapSettings" over the tileset defaults. Maker Studio stores these on
#        the map (and per map-version) instead of the shared tileset.
#
# 2. Fog event commands retargeted to a specific Maker Studio fog layer by id
#    (the editor picks the layer from a list; the id rides in the command
#    parameters). Falls back to the engine's native single-fog behaviour when
#    the map has no Maker Studio fog layer with that id.
#      - command_204 (Change Map Settings, type 1 = Fog): applies EVERY fog
#        property (graphic, hue, blend, zoom, scroll x/y, follow, opacity).
#      - command_205 (Change Fog Color Tone): tones that fog plane, optionally
#        animated over `frames`.
#      - command_206 (Change Fog Opacity): fades that fog plane's opacity,
#        optionally animated over `frames`.
#
# The `frames` transition is stepped once per fog update (update_fog_sprites is
# aliased below to advance in-progress tone/opacity fades each frame).
#
# Written to stay Ruby 1.8-compatible so the SAME file works in every framework
# build (BES5 / LBDS / PE21).
#===============================================================================
module MakerStudio
  module_function

  #---------------------------------------------------------------------------
  # Apply per-map panorama / battleback + native-fog suppression onto a
  # Game_Map. Reads the cached extended-layers hash (loaded during setup).
  # Idempotent; safe to call again after a map-version swap or hot-reload.
  #---------------------------------------------------------------------------
  def apply_map_background_overrides(game_map, map_id)
    return unless game_map
    ext = (respond_to?(:get_extended_data_for) ? get_extended_data_for(map_id) : nil)
    ms = ext ? ext["mapSettings"] : nil

    # Battleback. Pokémon Essentials / LBDS read the battle backdrop from
    # $game_map.metadata.battle_background (the map's "BattleBack" PBS field),
    # NOT from the stock @battleback_name ivar (dead code here). Bridge the
    # effective value onto the metadata so it shows in-game: the version's
    # mapSettings override if set, else @battleback_name (stock Game_Map#setup
    # copied it from the tileset, which the base-map "Change Battleback" picker
    # writes). Runs before the ext/ms guards so a base map that only changed its
    # tileset battleback (no @extended_layers) is still bridged. PE tilesets
    # default to "", so untouched maps no-op and never clobber the PBS value.
    bback = (ms && ms["battlebackName"]) || game_map.instance_variable_get(:@battleback_name)
    bback = bback.to_s
    __mkst_bridge_battleback(game_map, bback)
    game_map.instance_variable_set(:@battleback_name, bback) if !bback.empty?

    return unless ext

    # Suppress native tileset fog when Maker Studio fog layers exist here.
    fogs = ext["fogLayers"]
    if fogs && !fogs.empty?
      game_map.instance_variable_set(:@fog_name, "")
      game_map.instance_variable_set(:@fog_opacity, 0)
    end

    # Suppress the native panorama when Maker Studio panorama layers exist —
    # they are rendered as Planes by 004_FogOverride (multi-panorama), so the
    # engine's single panorama would double-render beneath them.
    panos = ext["panoramaLayers"]
    has_ms_panoramas = panos && !panos.empty?
    if has_ms_panoramas
      game_map.instance_variable_set(:@panorama_name, "")
      game_map.instance_variable_set(:@panorama_hue, 0)
    end

    return unless ms

    pano = ms["panoramaName"]
    if pano && !pano.empty? && !has_ms_panoramas
      game_map.instance_variable_set(:@panorama_name, pano)
      game_map.instance_variable_set(:@panorama_hue, (ms["panoramaHue"] || 0).to_i)
    end
  end

  # Ruby 1.8.1 (RGSS1) has no Object#instance_variable_defined?, and "read it
  # and test for nil" is a different question here: nil is a legitimate cached
  # PBS value. 1.8 yields strings from #instance_variables, 1.9+ symbols.
  def __mkst_ivar_defined?(obj, name)
    obj.instance_variables.any? { |v| v.to_s == name.to_s }
  end
  
  # Bridge the effective battleback onto whatever the running engine reads as
  # the map's "BattleBack" metadata, so its own battle scene resolves the WHOLE
  # family from it: `<p>_bg` + `<p>_<env>_base0/_base1` + `<p>_message` in
  # PE19+/LBDS, `battlebg<P>` + `playerbase<P><Env>` in PE17/BES. Three stores,
  # tried in order, because the engines disagree on where map metadata lives:
  #   * Game_Map#metadata          - PE20/21, LBDS
  #   * GameData::MapMetadata      - PE19 (no Game_Map#metadata at all); the
  #                                  record may not exist for this map, so
  #                                  register one rather than drop the value
  #   * pbLoadMetadata array       - PE17/BES ([map_id][MetadataBattleBack])
  # The original value is cached on the first write so clearing the battleback
  # restores it in-session. No-op where none of the three exist (stock RMXP,
  # which reads the @battleback_name ivar set by the caller).
  def __mkst_bridge_battleback(game_map, bback)
    map_id = game_map.respond_to?(:map_id) ? game_map.map_id : nil
    md = nil
    md = (game_map.metadata rescue nil) if game_map.respond_to?(:metadata)
    if md.nil? && map_id && defined?(GameData) && defined?(GameData::MapMetadata)
      md = (GameData::MapMetadata.try_get(map_id) rescue nil)
      if md.nil? && !bback.empty?
        (GameData::MapMetadata.register({:id => map_id, :battle_background => bback}) rescue nil)
        md = (GameData::MapMetadata.try_get(map_id) rescue nil)
      end
    end
    if md && md.respond_to?(:battle_background)
      if !bback.empty?
        unless __mkst_ivar_defined?(md, :@ms_bb_orig)
          md.instance_variable_set(:@ms_bb_orig, md.instance_variable_get(:@battle_background))
        end
        md.instance_variable_set(:@battle_background, bback)
      elsif __mkst_ivar_defined?(md, :@ms_bb_orig)
        md.instance_variable_set(:@battle_background, md.instance_variable_get(:@ms_bb_orig))
        md.send(:remove_instance_variable, :@ms_bb_orig)
      end
      return
    end
    __mkst_bridge_battleback_legacy(map_id, bback)
  end

  # PE17 / BES keep map metadata as a plain array cached in $PokemonTemp, read
  # by pbGetMetadata as meta[map_id][MetadataBattleBack]. Mutating that cached
  # array is what makes pbBackdrop pick the value up - it re-reads it on every
  # battle, and derives the bases from the same backdrop name.
  def __mkst_bridge_battleback_legacy(map_id, bback)
    return unless map_id && defined?(MetadataBattleBack)
    meta = (pbLoadMetadata rescue nil)
    return unless meta.is_a?(Array)
    @ms_bb_orig_legacy = {} if @ms_bb_orig_legacy.nil?
    entry = meta[map_id]
    if !bback.empty?
      if entry.nil?
        entry = []
        meta[map_id] = entry
      end
      unless @ms_bb_orig_legacy.has_key?(map_id)
        @ms_bb_orig_legacy[map_id] = entry[MetadataBattleBack]
      end
      entry[MetadataBattleBack] = bback
    elsif @ms_bb_orig_legacy.has_key?(map_id)
      entry[MetadataBattleBack] = @ms_bb_orig_legacy[map_id] if entry
      @ms_bb_orig_legacy.delete(map_id)
    end
  end

  #---------------------------------------------------------------------------
  # Maker Studio fog sprite accessors. Operate on the @fog_sprites_cache that
  # 004_FogOverride.rb builds (a module ivar shared on this same module object).
  #---------------------------------------------------------------------------
  def find_fog_sprite(map_id, fog_id)
    return nil unless @fog_sprites_cache
    sprites = @fog_sprites_cache[map_id]
    return nil unless sprites
    sprites.each do |sprite|
      next if sprite.nil? || sprite.disposed?
      # The cache now holds ALL graphic groups (fog/panorama/custom) — the fog
      # event commands must only retarget fog-group sprites.
      group = sprite.instance_variable_get(:@ms_group)
      next unless group.nil? || group == "fog"
      return sprite if sprite.instance_variable_get(:@fog_id) == fog_id
    end
    nil
  end

  # Coerce a command's tone parameter (an RPG::Tone at runtime, or a [r,g,b,gray]
  # array) into a fresh Tone. Returns nil when it is neither.
  def to_fog_tone(tone)
    if defined?(Tone) && tone.is_a?(Tone)
      Tone.new(tone.red, tone.green, tone.blue, tone.gray)
    elsif tone.is_a?(Array)
      Tone.new(tone[0] || 0, tone[1] || 0, tone[2] || 0, tone[3] || 0)
    else
      nil
    end
  end

  # Fade a fog layer's opacity to `opacity` over `frames` (instant when frames<=0).
  def set_fog_opacity(map_id, fog_id, opacity, frames = 0)
    sprite = find_fog_sprite(map_id, fog_id)
    return false unless sprite
    target = opacity.to_i
    if frames.to_i <= 0
      sprite.opacity = target
      sprite.instance_variable_set(:@ms_op_dur, 0)
    else
      sprite.instance_variable_set(:@ms_op_target, target)
      sprite.instance_variable_set(:@ms_op_dur, frames.to_i)
    end
    true
  end

  # Tone a fog layer to `tone` over `frames` (instant when frames<=0).
  def set_fog_tone(map_id, fog_id, tone, frames = 0)
    sprite = find_fog_sprite(map_id, fog_id)
    return false unless sprite
    return false unless sprite.respond_to?(:tone=)
    target = to_fog_tone(tone)
    return false unless target
    if frames.to_i <= 0
      sprite.tone = Tone.new(target.red, target.green, target.blue, target.gray)
      sprite.instance_variable_set(:@ms_tone_dur, 0)
    else
      sprite.instance_variable_set(:@ms_tone_target, target)
      sprite.instance_variable_set(:@ms_tone_dur, frames.to_i)
    end
    true
  end

  # Reload a fog layer's graphic (and re-apply hue). Empty name clears it.
  def set_fog_graphic(map_id, fog_id, name, hue)
    sprite = find_fog_sprite(map_id, fog_id)
    return false unless sprite
    apply_fog_graphic(sprite, name, hue)
    true
  end

  # Internal: swap a sprite's bitmap to graphic `name` (hue-rotated). Empty name
  # clears the bitmap. No-op (keeps current bitmap) when name is nil.
  def apply_fog_graphic(sprite, name, hue)
    return if name.nil?
    if name.empty?
      old = sprite.bitmap
      sprite.bitmap = nil
      old.dispose if old && !old.disposed?
      return
    end
    path = find_fog_graphic(name)
    return unless path
    begin
      bmp = Bitmap.new(path)
    rescue
      return
    end
    h = (hue || 0).to_i
    bmp.hue_change(h) if h != 0
    old = sprite.bitmap
    sprite.bitmap = bmp
    old.dispose if old && !old.disposed?
  end

  # Apply the Edit-Fog property set to a fog layer (command_204 / type 1).
  # Any nil argument is left unchanged. Opacity is NOT touched here — use the
  # Change Fog Opacity command (206) for that.
  def set_fog_properties(map_id, fog_id, name, hue, blend_type, zoom, sx, sy, follow)
    sprite = find_fog_sprite(map_id, fog_id)
    return false unless sprite
    apply_fog_graphic(sprite, name, hue)
    sprite.blend_type = blend_type.to_i unless blend_type.nil?
    unless zoom.nil?
      z = zoom.to_f
      z = 0.1 if z < 0.1
      sprite.zoom_x = z
      sprite.zoom_y = z
    end
    sprite.instance_variable_set(:@fog_sx, sx.to_f) unless sx.nil?
    sprite.instance_variable_set(:@fog_sy, sy.to_f) unless sy.nil?
    sprite.instance_variable_set(:@fog_follow, follow.to_i == 1) unless follow.nil?
    true
  end

  #---------------------------------------------------------------------------
  # Per-frame transition stepping for fog tone / opacity fades. Uses RPG Maker's
  # incremental-average interpolation so a fade reaches its target exactly on
  # the final frame. Called once per fog update (see the update_fog_sprites
  # alias below).
  #---------------------------------------------------------------------------
  def step_fog_transition(sprite)
    return if sprite.nil? || sprite.disposed?

    odur = sprite.instance_variable_get(:@ms_op_dur)
    if odur && odur >= 1
      target = sprite.instance_variable_get(:@ms_op_target) || sprite.opacity
      cur = sprite.opacity
      sprite.opacity = ((cur * (odur - 1) + target) / odur)
      odur -= 1
      sprite.opacity = target if odur == 0
      sprite.instance_variable_set(:@ms_op_dur, odur)
    end

    tdur = sprite.instance_variable_get(:@ms_tone_dur)
    if tdur && tdur >= 1 && sprite.respond_to?(:tone) && sprite.respond_to?(:tone=)
      tgt = sprite.instance_variable_get(:@ms_tone_target)
      if tgt
        cur = sprite.tone
        nr  = (cur.red   * (tdur - 1) + tgt.red)   / tdur
        ng  = (cur.green * (tdur - 1) + tgt.green) / tdur
        nb  = (cur.blue  * (tdur - 1) + tgt.blue)  / tdur
        ngr = (cur.gray  * (tdur - 1) + tgt.gray)  / tdur
        sprite.tone = Tone.new(nr, ng, nb, ngr)
        tdur -= 1
        sprite.tone = Tone.new(tgt.red, tgt.green, tgt.blue, tgt.gray) if tdur == 0
        sprite.instance_variable_set(:@ms_tone_dur, tdur)
      end
    end
  end

  def update_fog_transitions
    return unless @fog_sprites_cache
    @fog_sprites_cache.each do |map_id, sprites|
      next unless sprites
      sprites.each { |sprite| step_fog_transition(sprite) }
    end
  end
end

#-------------------------------------------------------------------------------
# Advance in-progress fog tone/opacity fades each frame. update_fog_sprites is
# already called once per frame by the renderer; chain the transition stepper
# onto it so `frames`-based fades animate.
#-------------------------------------------------------------------------------
class << MakerStudio
  # Alias ONCE, but (re)define UNCONDITIONALLY so an mkxp F12 soft-reset (which
  # re-runs 004_FogOverride's original update_fog_sprites) can't drop the chain.
  unless method_defined?(:__mkst__update_fog_sprites) || private_method_defined?(:__mkst__update_fog_sprites)
    alias_method :__mkst__update_fog_sprites, :update_fog_sprites
  end
  def update_fog_sprites
    __mkst__update_fog_sprites
    update_fog_transitions
  end
end

#-------------------------------------------------------------------------------
# Re-apply per-map background overrides right after the engine finishes a normal
# Game_Map#setup. setup triggers :on_game_map_setup (002_RendererOverride loads
# the extended layers there), so by the time the alias returns the cache is warm.
#-------------------------------------------------------------------------------
class Game_Map
  unless method_defined?(:__mkst__setup_bg) || private_method_defined?(:__mkst__setup_bg)
    alias_method :__mkst__setup_bg, :setup
  end

  def setup(map_id)
    __mkst__setup_bg(map_id)
    if defined?(MakerStudio) && MakerStudio::ENABLED
      MakerStudio.apply_map_background_overrides(self, map_id)
    end
  end
end

#-------------------------------------------------------------------------------
# Fog event commands retargeted to a Maker Studio fog layer by id.
#-------------------------------------------------------------------------------
if defined?(Interpreter)
class Interpreter
  unless method_defined?(:__mkst__command_204) || private_method_defined?(:__mkst__command_204)
    alias_method :__mkst__command_204, :command_204
  end
  def command_204
    if defined?(MakerStudio) && MakerStudio::ENABLED && @parameters[0] == 1 && $game_map
      fog_id = @parameters[3]
      if MakerStudio.find_fog_sprite($game_map.map_id, fog_id)
        MakerStudio.set_fog_properties($game_map.map_id, fog_id,
          @parameters[1], @parameters[2], @parameters[4], @parameters[5],
          @parameters[6], @parameters[7], @parameters[8])
        return true
      end
    end
    __mkst__command_204
  end

  unless method_defined?(:__mkst__command_205) || private_method_defined?(:__mkst__command_205)
    alias_method :__mkst__command_205, :command_205
  end
  def command_205
    if defined?(MakerStudio) && MakerStudio::ENABLED && $game_map
      fog_id = @parameters[2]
      return true if MakerStudio.set_fog_tone($game_map.map_id, fog_id, @parameters[0], @parameters[1])
    end
    __mkst__command_205
  end

  unless method_defined?(:__mkst__command_206) || private_method_defined?(:__mkst__command_206)
    alias_method :__mkst__command_206, :command_206
  end
  def command_206
    if defined?(MakerStudio) && MakerStudio::ENABLED && $game_map
      fog_id = @parameters[2]
      return true if MakerStudio.set_fog_opacity($game_map.map_id, fog_id, @parameters[0], @parameters[1])
    end
    __mkst__command_206
  end
end
end
