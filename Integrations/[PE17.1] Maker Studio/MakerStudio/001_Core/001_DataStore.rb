#===============================================================================
# MakerStudio - Data Store (Essentials v17.1)
#
# Maker Studio embeds extended-layer data as a JSON string inside the .rxdata.
# v17.1 runs on the original RGSS runtime (Game.exe, Ruby 1.8.1), which has no
# `json` library and lacks several modern syntax features. So this file:
#   * bundles a small pure-Ruby, 1.8-safe JSON parser (MakerStudio::JSON), and
#   * avoids 1.9+ syntax (symbol-key hashes, &., String#each_char, byte vs char
#     indexing) so the same code also loads on modern Ruby (mkxp ports).
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

    # Read @extended_layers straight from the map file on disk.
    #
    # Needed because v17.1 Marshals the ENTIRE $MapFactory into the save file
    # (156_PScreen_Save.rb) and restores it wholesale (155_PScreen_Load.rb) — so
    # a Continue-d game carries the RPG::Map exactly as it was when the player
    # saved, and Game_Map#setup (where the plugin hooks the load) never runs for
    # that map. Any map painted AFTER that save then shows nothing at all.
    # The editor writes to the .rxdata, so disk is the authority.
    def disk_extended_layers(map_id)
      fresh = (load_data(sprintf("Data/Map%03d.rxdata", map_id)) rescue nil)
      fresh ? fresh.instance_variable_get(:@extended_layers) : nil
    end

    # Load + parse the embedded @extended_layers JSON. Prefers the in-memory
    # RPG::Map (no I/O on the normal path) and falls back to disk when it has no
    # Maker Studio data — see disk_extended_layers for why that happens.
    def load_extended_data(map_id, game_map = nil)
      rpg_map = resolve_rpg_map(game_map)
      embedded = rpg_map ? rpg_map.instance_variable_get(:@extended_layers) : nil
      embedded = disk_extended_layers(map_id) if embedded.nil? || embedded.empty?
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
          parsed = MakerStudio::JSON.parse(raw)
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
