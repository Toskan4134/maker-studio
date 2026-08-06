#===============================================================================
# MakerStudio - Event Editor Extensions
# Runtime support for Maker Studio-only event page fields that have no
# native RGSS equivalent:
#
#   Condition#switch1_negate / switch2_negate / self_switch_negate (bool)
#     Require the switch/self switch OFF instead of ON for this page.
#   Page#block (bool)
#     Page is always impassable, ignoring tile passage bits AND Through —
#     the gap Tile Graphic pages have today (a Tile Graphic event with
#     Through off still follows its underlying tile's passage, so an empty/
#     walkable tile lets the player through regardless).
#   Page#always_on_bottom (bool)
#     Maker Studio's mirror of always_on_top: the event draws BELOW every
#     character (screen_z = ALWAYS_ON_BOTTOM_Z — above the ground band and the
#     map's shadows). always_on_top wins when both are set.
#   Condition's @ms_condition_tree ivar (plain Hash/Array, no attr_accessor)
#     Unlimited switch/variable/self-switch checks with AND/OR nesting, ANDed
#     on top of the four checks above. Stored as a plain Ruby Hash/Array blob
#     (never a custom-classed object) so Marshal.load never needs a class this
#     plugin doesn't define — vanilla Essentials loads the file fine and simply
#     never reads the ivar. See ConditionTreeEditor.tsx / the ConditionNode
#     type / sim-conditions.ts on the editor side for the matching shape and
#     evaluator.
#
# These ivars are absent (nil) on any page/condition not edited through the
# editor's negate/Block toggles — nil reads as "off" everywhere below, so
# maps untouched by these toggles behave exactly like vanilla Essentials.
# The editor also writes .rxdata for projects WITHOUT this plugin installed;
# there the ivars just sit unused (same tolerance Marshal already gives
# @extended_layers on RPG::Map).
#
# Game_Event#refresh is an alias (NOT a full copy) that temporarily patches
# each page's condition objects so the base's own page-picking loop respects
# negate / condition-tree. This composes with ANY other script that also
# aliases refresh (Events Utilities, custom event systems, etc.) — the previous
# refresh runs inside ours with patched conditions, so its page-picking AND its
# post-processing (comment parsing, etc.) all execute against the right page.
#
# The patching is needed because negate flips the comparison INSIDE the loop's
# `next if` — an alias that just called the original would pick the wrong page
# whenever a page uses negate. Instead we rewrite each condition's switch_valid
# / switch_id / self_switch_ch in-place so the original loop's own logic yields
# the MS-correct result, then restore in `ensure`.
#
# Game_Map#passable? doesn't need that treatment: block only needs to be
# checked as a hard veto before whatever passability logic already runs, so
# it's a thin alias_method wrapper — composes with 003_GameMapOverride's own
# passable? redefinition (or vanilla, if that file isn't loaded) either way.
#
# NOTE: Essentials 20.1 has no variableIsLessThan?, so the condition tree's
# variable branch reads $game_variables directly (the same comparison the
# core refresh uses), not the helper the v21.1/LBDS builds use.
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
  # Nil-safe reader instead of an @block default in initialize (avoids
  # aliasing the constructor just for this). Untouched characters/events
  # simply read false, same as if the ivar were never involved.
  def block
    @block.nil? ? false : @block
  end
  attr_writer :block
end

class Game_Event
  # Recursively evaluates one @ms_condition_tree node (a plain Hash with
  # "kind" == "switch" | "variable" | "self_switch" | "group"). Mirrors
  # evalNode in the editor's sim-conditions.ts — keep both in sync.
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
# Always on Bottom — Maker Studio's mirror of always_on_top. The event draws
# below every character (z = ALWAYS_ON_BOTTOM_Z: above the ground band 0/2 and
# the map's shadows 1, below every character and overhead tile). always_on_top
# wins when both are set. Reads @always_on_bottom straight off the page ivar
# the editor writes, so it needs no refresh mirror of its own.
#===============================================================================
module MakerStudio
  # Above the ground band (0/2) and the map's shadows (1), below every character
  # (Game_Character#screen_z is a whole tile at minimum).
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
