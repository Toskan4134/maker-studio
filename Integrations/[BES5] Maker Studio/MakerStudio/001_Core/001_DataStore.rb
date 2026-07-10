#===============================================================================
# MakerStudio - Data Store (Essentials BES v5 / v16.2)
#
# Maker Studio embeds extended-layer data as a JSON string inside the .rxdata.
# BES targets the original RGSS runtime (Ruby 1.8.1), which has no `json`
# library and lacks several modern syntax features. So this file:
#   * bundles a small pure-Ruby, 1.8-safe JSON parser (MakerStudio::JSON), and
#   * avoids 1.9+ syntax (symbol-key hashes, &., String#each_char, byte vs char
#     indexing) so it loads on both RGSS (Ruby 1.8) and mkxp (Ruby 3).
#===============================================================================
module MakerStudio
  #---------------------------------------------------------------------------
  # Minimal JSON parser (objects, arrays, strings, numbers, true/false/null).
  # Hand-rolled and 1.8-safe: uses str[pos, 1] (returns a String in 1.8 AND
  # 1.9+, unlike str[pos] which returns a Fixnum byte in 1.8).
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

  #---------------------------------------------------------------------------
  # Extended layer data store
  #---------------------------------------------------------------------------
  module DataStore
    module_function

    # Resolve the RPG::Map from a Game_Map (has @map) or an RPG::Map directly.
    # Avoids instance_variable_defined? (absent on Ruby 1.8.1).
    def resolve_rpg_map(obj)
      return nil unless obj
      rpg = obj.instance_variable_get(:@map)
      return rpg if rpg
      return obj if !obj.instance_variable_get(:@extended_layers).nil? ||
                    !obj.instance_variable_get(:@tileset_id).nil?
      nil
    end

    # Load + parse the embedded @extended_layers JSON.
    def load_extended_data(map_id, game_map = nil)
      rpg_map = resolve_rpg_map(game_map)
      return nil unless rpg_map
      embedded = rpg_map.instance_variable_get(:@extended_layers)
      return nil unless embedded && !embedded.empty?
      begin
        return MakerStudio::JSON.parse(embedded)
      rescue => e
        echoln("MakerStudio ERROR: failed to parse extended data for map #{map_id}: #{e.message}")
        return nil
      end
    end

    def create_default_extended_data(map_id, map_width, map_height)
      layers = []
      DEFAULT_EXT_LAYERS.times do |i|
        layer_index = NATIVE_LAYERS + i
        layers.push({
          "id"      => layer_index,
          "name"    => "Extended #{layer_index + 1}",
          "visible" => true,
          "opacity" => EFFECT_RANGES[:opacity][:default],
          "tiles"   => {}
        })
      end
      {
        "map_id"     => map_id,
        "map_width"  => map_width,
        "map_height" => map_height,
        "layers"     => layers
      }
    end

    def get_extended_data(map_id, map_width = nil, map_height = nil, game_map = nil)
      data = load_extended_data(map_id, game_map)
      if data.nil?
        map_width  ||= (game_map && game_map.width)  || ($game_map && $game_map.width)  || 20
        map_height ||= (game_map && game_map.height) || ($game_map && $game_map.height) || 15
        data = create_default_extended_data(map_id, map_width, map_height)
      end
      data
    end

    # Expanded autotile lookup (from @expanded_autotiles JSON on tileset objects).
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
        rescue
        end
      end
      nil
    end
  end
end
