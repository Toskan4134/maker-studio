#===============================================================================
# MakerStudio - Footprints compatibility (LBDS 1.2.1+)
#
# LBDS 1.2.1 added sand footprints: FootprintsSettings +
# Sprite_Character#update_footsteps_aux / #update_footsteps. The base's
# terrain check reads the RAW Table (map.data + the map tileset's
# terrain_tags[tile_id] == 3), which can't see terrain from Maker Studio
# content — extra autotiles store tile_id=0 in the Table, cross-tileset tiles
# carry another tileset's terrain, and extended layers aren't in the Table at
# all — so sand painted with Maker Studio never produced footprints.
#
# This replaces update_footsteps_aux with the same logic, but the terrain
# check goes through Game_Map#terrain_tag — patched by 003_GameMapOverride to
# resolve extended layers / extra autotiles / cross-tileset top-down. The
# footprint sprite also gets z=1 (was 0) so it can't tie with Maker Studio's
# ground tile sprites at z=0 (a z tie leaves stacking to insertion order).
#
# GUARDED: the whole patch only applies when the base actually ships the
# feature, so this ONE integration covers the LBDS 1.2.x line — 1.2.0 (no
# footprints) and 1.2.1+ (footprints) — without per-version builds.
#===============================================================================
if defined?(FootprintsSettings) && Sprite_Character.method_defined?(:update_footsteps_aux)
  class Sprite_Character
    def update_footsteps_aux
      @old_x ||= @character.x
      @old_y ||= @character.y
      if (@character.x != @old_x || @character.y != @old_y) && !["", "nil"].include?(@character.character_name)
        if @character == $game_player && $game_temp.followers &&
           $game_temp.followers.respond_to?(:realEvents) &&
           $game_temp.followers.realEvents.select { |e| !["", "nil"].include?(e.character_name) }.size > 0 &&
           !FootprintsSettings::DUPLICATE_FOOTSTEPS_WITH_FOLLOWER
          if !FootprintsSettings::EVENTNAME_MAY_NOT_INCLUDE.include?($game_temp.followers.realEvents[0].name) &&
             !FootprintsSettings::FILENAME_MAY_NOT_INCLUDE.include?($game_temp.followers.realEvents[0].character_name)
            make_steps = false
          else
            make_steps = true
          end
        elsif (!@character.respond_to?(:name) || !FootprintsSettings::EVENTNAME_MAY_NOT_INCLUDE.include?(@character.name)) &&
               !FootprintsSettings::FILENAME_MAY_NOT_INCLUDE.include?(@character.character_name)
          # MakerStudio-aware terrain: Game_Map#terrain_tag (patched in
          # 003_GameMapOverride) resolves extended layers, extra autotiles and
          # cross-tileset tiles top-down — the base's raw Table scan
          # (terrain_tags[map.data[...]] == 3) can't see any of those.
          terrain = @character.map.terrain_tag(@old_x, @old_y)
          make_steps = !terrain.nil? && terrain.id_number == 3
        end
        if make_steps
          fstep = Sprite.new(self.viewport)
          # z=1: above Maker Studio ground tile sprites (z=0), below the
          # non-passable/shadow-source band (z=2). The base used z=0, which
          # tied with the ground tiles and could stack under them.
          fstep.z = 1
          dirs = [nil, "DownLeft", "Down", "DownRight", "Left", "Still", "Right", "UpLeft", "Up", "UpRight"]
          if @character == $game_player && $PokemonGlobal.bicycle
            fstep.bmp(File.join("Graphics", "Characters", "steps#{dirs[@character.direction]}Bike"))
          else
            fstep.bmp(File.join("Graphics", "Characters", "steps#{dirs[@character.direction]}"))
          end
          @steps ||= []
          if @character == $game_player && $PokemonGlobal.bicycle
            x = FootprintsSettings::BIKE_X_OFFSET
            y = FootprintsSettings::BIKE_Y_OFFSET
          else
            x = FootprintsSettings::WALK_X_OFFSET
            y = FootprintsSettings::WALK_Y_OFFSET
          end
          @steps << [fstep, @character.map, @old_x + x / Game_Map::TILE_WIDTH.to_f, @old_y + y / Game_Map::TILE_HEIGHT.to_f]
        end
      end
      @old_x = @character.x
      @old_y = @character.y
    end
  end
end
