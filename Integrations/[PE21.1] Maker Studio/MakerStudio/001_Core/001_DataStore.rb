#===============================================================================
# MakerStudio - Data Store
# Handles loading and managing extended layer data for maps.
#===============================================================================
module MakerStudio
  #---------------------------------------------------------------------------
  # Minimal JSON parser (objects, arrays, strings, numbers, true/false/null).
  # mkxp-z (Essentials v21.1 runtime) ships a Ruby with no `json` stdlib, so
  # `require 'json'` raises LoadError. This hand-rolled parser avoids that
  # dependency. Uses str[pos, 1] (always returns a String) for char access.
  #---------------------------------------------------------------------------
  module JSON
    def self.parse(str)
      Parser.new(str).parse
    end

    class Parser
      def initialize(str)
        @str = str.to_s
        @len = @str.length
        @pos = 0
      end

      def parse
        skip_ws
        v = parse_value
        skip_ws
        v
      end

      private

      def cur
        @pos < @len ? @str[@pos, 1] : nil
      end

      def skip_ws
        while @pos < @len
          c = @str[@pos, 1]
          break if c != " " && c != "\t" && c != "\n" && c != "\r"
          @pos += 1
        end
      end

      def parse_value
        c = cur
        case c
        when "{" then parse_object
        when "[" then parse_array
        when '"' then parse_string
        when "t" then parse_literal("true", true)
        when "f" then parse_literal("false", false)
        when "n" then parse_literal("null", nil)
        else          parse_number
        end
      end

      def parse_literal(lit, val)
        if @str[@pos, lit.length] == lit
          @pos += lit.length
          return val
        end
        raise "MakerStudio::JSON: expected '#{lit}' at #{@pos}"
      end

      def parse_object
        obj = {}
        @pos += 1 # consume {
        skip_ws
        if cur == "}"
          @pos += 1
          return obj
        end
        loop do
          skip_ws
          key = parse_string
          skip_ws
          raise "MakerStudio::JSON: expected ':' at #{@pos}" if cur != ":"
          @pos += 1
          skip_ws
          obj[key] = parse_value
          skip_ws
          c = cur
          if c == ","
            @pos += 1
            next
          elsif c == "}"
            @pos += 1
            break
          else
            raise "MakerStudio::JSON: expected ',' or '}' at #{@pos}"
          end
        end
        obj
      end

      def parse_array
        arr = []
        @pos += 1 # consume [
        skip_ws
        if cur == "]"
          @pos += 1
          return arr
        end
        loop do
          skip_ws
          arr.push(parse_value)
          skip_ws
          c = cur
          if c == ","
            @pos += 1
            next
          elsif c == "]"
            @pos += 1
            break
          else
            raise "MakerStudio::JSON: expected ',' or ']' at #{@pos}"
          end
        end
        arr
      end

      def parse_string
        raise "MakerStudio::JSON: expected string at #{@pos}" if cur != '"'
        @pos += 1
        result = ""
        while @pos < @len
          c = @str[@pos, 1]
          @pos += 1
          if c == '"'
            return result
          elsif c == "\\"
            e = @str[@pos, 1]
            @pos += 1
            case e
            when '"'  then result << '"'
            when "\\" then result << "\\"
            when "/"  then result << "/"
            when "n"  then result << "\n"
            when "t"  then result << "\t"
            when "r"  then result << "\r"
            when "b"  then result << "\b"
            when "f"  then result << "\f"
            when "u"
              hex = @str[@pos, 4]
              @pos += 4
              begin
                result << [hex.to_i(16)].pack("U")
              rescue
                result << "?"
              end
            else
              result << e.to_s
            end
          else
            result << c
          end
        end
        raise "MakerStudio::JSON: unterminated string"
      end

      def parse_number
        start = @pos
        while @pos < @len
          c = @str[@pos, 1]
          break if !(c =~ /[-+0-9.eE]/)
          @pos += 1
        end
        num = @str[start, @pos - start]
        raise "MakerStudio::JSON: invalid number at #{start}" if num == ""
        (num =~ /[.eE]/) ? num.to_f : num.to_i
      end
    end
  end

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
        return MakerStudio::JSON.parse(embedded)
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
          expanded = MakerStudio::JSON.parse(raw)
          entry = expanded.find { |e| e.is_a?(Hash) && e["name"] == autotile_name }
          return entry if entry
        rescue; end
      end
      nil
    end
  end
end
