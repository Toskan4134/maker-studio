#===============================================================================
# MakerStudio - Battleback bases follow the backdrop
#
# Stock PE19+ picks the battle bases from the ENVIRONMENT, not from the
# backdrop: Overworld_BattleStarting sets `battle.backdropBase` to the
# environment's `battle_base` ("grass" / "water" / "sand" / "ice" / "puddle"),
# and 003_Scene_Initialize builds `<backdrop>_<base>_base0`, falling back to
# `<base>_base0` when that file is missing — never to `<backdrop>_base0`. So a
# map whose battleback is `cave1` shows `grass_base0` while the player stands on
# grass, because `cave1_grass_base0` does not ship: the background changes with
# the map's battleback and the bases don't.
#
# Here the backdrop leads, which is what picking a battleback in the editor
# means: `cave1` gives `cave1_base0` / `cave1_base1`, and the environment only
# narrows that when the variant exists on disk (`cave1_water_base0` on water,
# `cave1_ice_base0` on ice). A backdrop that ships no bases of its own keeps the
# engine's environment base, so nothing is left without a base graphic.
#
# Hooking the `backdropBase=` writer instead of the battle scene keeps this
# compatible with bases that redefine the scene (DBK and friends) and with every
# caller that sets the ivar directly (Safari, recorded battles). It runs after
# `battle.backdrop` is assigned — the one thing it needs to test.
#
# PE17 / BES already work this way (`pbBackdrop` appends the environment suffix
# only when `playerbase<Backdrop><Env>` resolves), so this file is not part of
# those builds. Guarded by tests/integrations/battleback_bases_test.rb.
#===============================================================================

module MakerStudio
  # The base fragment the scene should use, given the map's backdrop and the
  # environment base the engine picked. nil means "the backdrop's own bases" —
  # the scene names them `<backdrop>_base0/1` when backdropBase is nil.
  def self.effective_backdrop_base(backdrop, base)
    return base unless ENABLED
    return base if base.nil? || backdrop.nil? || backdrop.to_s.empty?
    return base if pbResolveBitmap("Graphics/Battlebacks/#{backdrop}_#{base}_base0")
    return nil if pbResolveBitmap("Graphics/Battlebacks/#{backdrop}_base0")
    base
  end
end

# `Battle` in the v20/v21 family and LBDS, `PokeBattle_Battle` in v19.1 — pick
# whichever class actually carries the accessor rather than trusting the name.
ms_battle_class = [:Battle, :PokeBattle_Battle].map { |n|
  Object.const_defined?(n) ? Object.const_get(n) : nil
}.compact.find { |k| k.is_a?(Class) && k.method_defined?(:backdropBase=) }

if ms_battle_class
  ms_battle_class.class_eval do
    # A plain redefinition, not an alias: an mkxp soft reset re-runs this file
    # and an alias would stack onto the override.
    def backdropBase=(base)
      @backdropBase = MakerStudio.effective_backdrop_base(@backdrop, base)
    end
  end
end
