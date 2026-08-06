#===============================================================================
# MakerStudio - Event Editor Extensions
# Runtime support for Maker Studio-only event page fields that have no
# native RGSS equivalent (switch negate, Block, Always on Bottom, and the
# @ms_condition_tree advanced-conditions blob). See the PE21.1 build's header
# for the full rationale; this file is the same logic against the LBDS 1.1 /
# Essentials 21.1 core.
#
# Game_Event#refresh is a full copy of the LBDS 1.1 core method with the
# negate checks, the @block mirror and the @ms_condition_tree check inlined
# into the page-picking loop. If that core method changes upstream, resync
# this copy. LBDS 1.1 has no variableIsLessThan?, so the condition tree's
# variable branch reads $game_variables directly.
#===============================================================================
class RPG::Event::Page::Condition
  attr_accessor :switch1_negate      # true: page requires Switch 1 OFF instead of ON
  attr_accessor :switch2_negate      # true: page requires Switch 2 OFF instead of ON
  attr_accessor :self_switch_negate  # true: page requires Self Switch OFF instead of ON
end

class RPG::Event::Page
  attr_accessor :block   # true: page is always impassable, ignoring tile passage/Through
end

class Game_Character
  def block
    @block.nil? ? false : @block
  end
  attr_writer :block
end

class Game_Event
  # Recursively evaluates one @ms_condition_tree node. Mirrors evalNode in the
  # editor's sim-conditions.ts — keep both in sync.
  def eval_condition_node(node)
    case node["kind"]
    when "switch"
      switchIsOn?(node["id"]) != !!node["negate"]
    when "variable"
      lt = $game_variables[node["id"]] < node["value"]
      node["negate"] ? lt : !lt
    when "self_switch"
      key = [@map_id, @event.id, node["ch"]]
      ($game_self_switches[key] == true) != !!node["negate"]
    when "group"
      children = node["children"] || []
      node["op"] == "or" ? children.any? { |c| eval_condition_node(c) } : children.all? { |c| eval_condition_node(c) }
    else
      true
    end
  end

  MS_SKIP_SWITCH = 0   # switch ID 0 is never used in RMXP -> always off

  unless method_defined?(:__mkst_evtext_refresh)
    alias_method :__mkst_evtext_refresh, :refresh
  end

  def refresh
    patches = []   # [condition, attr, old_val]

    unless @erased
      @event.pages.each do |page|
        c = page.condition

        # switch1 negate
        if c.switch1_valid && c.instance_variable_get(:@switch1_negate)
          if switchIsOn?(c.switch1_id)
            patches << [c, :switch1_id, c.switch1_id]
            c.switch1_id = MS_SKIP_SWITCH
          else
            patches << [c, :switch1_valid, c.switch1_valid]
            c.switch1_valid = false
          end
        end

        # switch2 negate
        if c.switch2_valid && c.instance_variable_get(:@switch2_negate)
          if switchIsOn?(c.switch2_id)
            patches << [c, :switch2_id, c.switch2_id]
            c.switch2_id = MS_SKIP_SWITCH
          else
            patches << [c, :switch2_valid, c.switch2_valid]
            c.switch2_valid = false
          end
        end

        # self_switch negate
        if c.self_switch_valid && c.instance_variable_get(:@self_switch_negate)
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] == true
            patches << [c, :self_switch_valid, c.self_switch_valid]
            c.self_switch_valid = true
            patches << [c, :self_switch_ch, c.self_switch_ch]
            c.self_switch_ch = "Z"
          else
            patches << [c, :self_switch_valid, c.self_switch_valid]
            c.self_switch_valid = false
          end
        end

        # condition tree: if it fails, force the page to be skipped
        tree = c.instance_variable_get(:@ms_condition_tree)
        if tree && !eval_condition_node(tree)
          unless c.switch1_valid && c.switch1_id == MS_SKIP_SWITCH
            patches << [c, :switch1_valid, c.switch1_valid]
            c.switch1_valid = true
            patches << [c, :switch1_id, c.switch1_id]
            c.switch1_id = MS_SKIP_SWITCH
          end
        end
      end
    end

    __mkst_evtext_refresh   # base + any chained alias (Events Utilities, ...)

    # MS-only page fields the base refresh doesn't set
    @block = @page ? !!@page.instance_variable_get(:@block) : false

  ensure
    patches.each { |c, attr, val| c.send("#{attr}=", val) }
  end
end

class Game_Map
  unless method_defined?(:__mkst_evtext__passable?)
    alias_method :__mkst_evtext__passable?, :passable?
  end

  def passable?(x, y, d, self_event = nil)
    return false if !valid?(x, y)
    events.each_value do |event|
      next if event == self_event
      next if !event.at_coordinate?(x, y)
      return false if event.block
    end
    __mkst_evtext__passable?(x, y, d, self_event)
  end
end

#===============================================================================
# Always on Bottom — mirror of always_on_top (z = ALWAYS_ON_BOTTOM_Z, above
# the ground band 0/2 and the map's shadows 1). always_on_top wins when both
# are set.
#===============================================================================
module MakerStudio
  ALWAYS_ON_BOTTOM_Z = 3 unless defined?(ALWAYS_ON_BOTTOM_Z)
end

class Game_Event
  def ms_always_on_bottom?
    return false if @always_on_top || @page.nil?
    @page.instance_variable_get(:@always_on_bottom) ? true : false
  end

  unless method_defined?(:__mkst_evtext__screen_z)
    alias_method :__mkst_evtext__screen_z, :screen_z
  end
  def screen_z(*args)
    return MakerStudio::ALWAYS_ON_BOTTOM_Z if ms_always_on_bottom?
    __mkst_evtext__screen_z(*args)
  end
end
