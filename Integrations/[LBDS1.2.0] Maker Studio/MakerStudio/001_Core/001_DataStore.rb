#===============================================================================
# MakerStudio - Data Store
# Handles loading and managing extended layer data for maps.
#===============================================================================
module MakerStudio
  require 'json'
  module DataStore
    module_function

    #---------------------------------------------------------------------------
    # Extended layer data (custom layers beyond the 3 native ones)
    #---------------------------------------------------------------------------

    # Resolve the RPG::Map from the given object.
    # `obj` can be:
    #   - a Game_Map (has @map pointing to RPG::Map)
    #   - an RPG::Map directly (e.g. from on_game_map_setup)
    #   - nil
    def resolve_rpg_map(obj)
      return nil unless obj
      # Game_Map stores the RPG::Map in @map
      rpg = obj.instance_variable_get(:@map)
      return rpg if rpg
      # If @map is nil, obj might itself be the RPG::Map
      return obj if obj.instance_variable_defined?(:@extended_layers) ||
                    obj.instance_variable_defined?(:@tileset_id)
      nil
    end

    # Load extended data from @extended_layers in the RPG::Map object embedded
    # in the .rxdata.
    def load_extended_data(map_id, game_map = nil)
      rpg_map = resolve_rpg_map(game_map)
      return nil unless rpg_map
      embedded = rpg_map.instance_variable_get(:@extended_layers)
      return nil unless embedded && !embedded.empty?
      begin
        return JSON.parse(embedded)
      rescue => e
        Console.echo_error("MakerStudio: Failed to parse embedded extended data for map #{map_id}: #{e.message}") if defined?(Console)
        return nil
      end
    end

    def create_default_extended_data(map_id, map_width, map_height)
      layers = []
      DEFAULT_EXT_LAYERS.times do |i|
        layer_index = NATIVE_LAYERS + i
        layers << {
          "id"       => layer_index,
          "name"     => "Extended #{layer_index + 1}",
          "visible"  => true,
          "opacity"  => EFFECT_RANGES[:opacity][:default],
          "tiles"    => {}
        }
      end
      return {
        "map_id"     => map_id,
        "map_width"  => map_width,
        "map_height" => map_height,
        "layers"     => layers
      }
    end

    def get_extended_data(map_id, map_width = nil, map_height = nil, game_map = nil)
      data = load_extended_data(map_id, game_map)
      if data.nil?
        map_width  ||= game_map&.width  || $game_map&.width  || 20
        map_height ||= game_map&.height || $game_map&.height || 15
        data = create_default_extended_data(map_id, map_width, map_height)
      end
      return data
    end

    #---------------------------------------------------------------------------
    # Expanded autotile lookup (from @expanded_autotiles JSON on tileset objects)
    # Returns the matching entry hash or nil if not found.
    #---------------------------------------------------------------------------
    #---------------------------------------------------------------------------
    # Expanded autotile config, parsed ONCE into { name => entry }.
    #
    # The raw JSON lives on the tileset objects and only changes when the tilesets
    # are reloaded, but passable? / bush? / deepBush? / terrain_tag ask for it on
    # every step of every character. Re-parsing every tileset's config on each of
    # those calls cost ~1.1 ms per lookup (vs 0.002 ms on a plain cell), so walking
    # on a Maker Studio autotile — grass, most visibly — dropped the frame rate.
    #---------------------------------------------------------------------------
    def expanded_autotile_index
      return @expanded_autotile_index if @expanded_autotile_index
      index = {}
      ($data_tilesets || []).each do |ts|
        next unless ts
        raw = ts.instance_variable_get(:@expanded_autotiles)
        next unless raw.is_a?(String) && !raw.empty?
        begin
          parsed = JSON.parse(raw)
          next unless parsed.is_a?(Array)
          parsed.each do |e|
            next unless e.is_a?(Hash) && e["name"]
            # First tileset wins, matching the old first-match-scan behaviour.
            index[e["name"]] = e unless index[e["name"]]
          end
        rescue
        end
      end
      @expanded_autotile_index = index
    end

    # Call whenever the tilesets are reloaded (editor hot-reload).
    def clear_expanded_autotile_index
      @expanded_autotile_index = nil
    end

    def get_expanded_autotile(autotile_name)
      return nil unless autotile_name && $data_tilesets
      expanded_autotile_index[autotile_name]
    end
  end
end
