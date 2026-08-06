# Loads one integration's 013_EventExtensions.rb TWICE against engine stubs.
#
# An mkxp soft reset (F12) re-runs every plugin file, so an unguarded
# `alias_method :__mkst_x, :x` re-aliases onto the override and every call
# recurses until "stack level too deep". Guarded aliases survive the reload.
#
#   ruby 013_double_load_test.rb "[PE21.1] Maker Studio/MakerStudio/002_Integration/013_EventExtensions.rb"
#
# Run it for every variant from this folder:
#   for f in */MakerStudio/002_Integration/013_EventExtensions.rb; do ruby 013_double_load_test.rb "$f"; done

module RPG
  class Event
    class Page
      class Condition; end
      def condition; @condition ||= Condition.new; end
    end
  end
end

class Game_Character
  def screen_z(height = 0); 100; end
end

class Game_Event < Game_Character
  def initialize; @erased = true; @page = nil; end
  def map; nil; end
  def refresh; @refreshed = true; end
  def refreshed?; @refreshed; end
end

class Game_Map
  def valid?(x, y); true; end
  def events; {}; end
  def passable?(x, y, dir, self_event = nil); :base_passable; end
end

file = ARGV[0] or abort "usage: ruby 013_double_load_test.rb <013_EventExtensions.rb>"
2.times { load file }

event = Game_Event.new
map = Game_Map.new

raise "screen_z recursed" unless event.screen_z == 100
raise "passable? recursed" unless map.passable?(0, 0, 2) == :base_passable
event.refresh
raise "refresh did not reach the base" unless event.refreshed?
raise "block mirror left @block set with no page" if event.block

puts "OK  #{file}"
