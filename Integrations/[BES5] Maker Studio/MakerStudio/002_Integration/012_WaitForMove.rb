#===============================================================================
# MakerStudio - Wait for Move's Completion, scoped to this event
#
# Stock command 210 takes no parameters and sets @move_route_waiting, which the
# interpreter clears only once NO character on the map is forcing a move route.
# Two events running their own routes therefore wait for each other: an event
# that just wants to wait for what it started stalls until every other route on
# the map has finished.
#
# Maker Studio optionally stores a target in @parameters[0]:
#
#   absent / -2 (WAIT_TARGET_ANY)  every character — RPG Maker's own behaviour,
#                                  and the default
#             0                    the move routes THIS event set, whoever they
#                                  moved (its own movement is not the point: an
#                                  event that sends the player somewhere is
#                                  standing still itself)
#             N                    the route this event set on event N
#
# -3 was a separate "routes this event set" option before it merged into 0, and
# -1 (the player) was selectable; both are still accepted so older maps behave.
#
# A map saved with a target still runs without this plugin: RMXP ignores the
# extra parameter and waits for everyone, which is the old behaviour.
#
# Returning false from a command handler is the engine's own "not yet" idiom
# (command_101 does it while a message is up): @index is left alone, so the same
# command runs again next frame.
#===============================================================================

module MakerStudio
  WAIT_TARGET_ANY = -2
  WAIT_TARGET_THIS_EVENT = 0
end

class Interpreter
  # Characters this interpreter has sent on a forced route since its last wait.
  def ms_forced_route_targets
    @ms_forced_route_targets ||= []
  end

  def ms_character_by_id(id)
    return $game_player if id == -1
    return nil if id.nil? || id <= 0
    return nil unless $game_map && $game_map.events
    $game_map.events[id]
  end

  # Is anything this event sent moving still moving? `only` narrows it to one id.
  def ms_own_routes_moving?(only = nil)
    ms_forced_route_targets.each do |id|
      next if only && id != only
      character = ms_character_by_id(id)
      return true if character && character.move_route_forcing
    end
    false
  end

  unless method_defined?(:__mkst_wait__command_209) || private_method_defined?(:__mkst_wait__command_209)
    alias_method :__mkst_wait__command_209, :command_209
  end
  def command_209(*args)
    result = __mkst_wait__command_209(*args)
    target = @parameters[0]
    ms_forced_route_targets << ((target == 0) ? @event_id : target) if target.is_a?(Integer)
    result
  end

  def command_210
    return true if $game_temp.in_battle

    target = @parameters[0]
    unless target.is_a?(Integer) && target != MakerStudio::WAIT_TARGET_ANY
      @move_route_waiting = true
      return true
    end

    target = MakerStudio::WAIT_TARGET_THIS_EVENT if target == -3
    if target == MakerStudio::WAIT_TARGET_THIS_EVENT
      return false if ms_own_routes_moving?
      ms_forced_route_targets.clear
      return true
    end

    return false if ms_own_routes_moving?(target)
    ms_forced_route_targets.delete(target)
    true
  end
end
