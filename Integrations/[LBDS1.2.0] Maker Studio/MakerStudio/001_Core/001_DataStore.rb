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
    def get_expanded_autotile(autotile_name)
      return nil unless autotile_name && $data_tilesets
      $data_tilesets.each do |ts|
        next unless ts
        raw = ts.instance_variable_get(:@expanded_autotiles)
        next unless raw.is_a?(String) && !raw.empty?
        begin
          expanded = JSON.parse(raw)
          entry = expanded.find { |e| e.is_a?(Hash) && e["name"] == autotile_name }
          return entry if entry
        rescue; end
      end
      nil
    end
  end
end
