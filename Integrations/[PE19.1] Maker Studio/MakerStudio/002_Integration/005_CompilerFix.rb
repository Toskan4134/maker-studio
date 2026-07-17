#===============================================================================
# MakerStudio - Compiler Fix (Pokémon Essentials v19.1)
#
# Sanitizes nil event-command string parameters that Maker Studio can produce
# when saving maps, so a PBS recompile doesn't crash on them.
#
# v19.1's compiler is the OLD one — it has no Translator and no
# replace_scripts / fix_event_scripts (both arrived in v20/v21). The crash site
# here is Compiler#change_script: fix_event_use feeds it params[0] for every
# code-655 (Script continuation) command WITHOUT the is_a?(String) guard that
# code 355 gets, and change_script calls script[0].gsub — NoMethodError on nil.
#
# So this patches change_scripts (nil guard) and fix_event_use (sanitize the
# whole event first, covering the other string-param codes too).
#
# Pattern A everywhere: alias once, def unconditionally — mkxp's F12 soft-reset
# re-evals the engine scripts (restoring the originals) and then re-runs the
# plugins, so a def inside the alias guard would be dropped on that second pass.
#===============================================================================

module MakerStudio
  # Codes where specific parameter indices must be strings, not nil.
  STRING_PARAM_INDICES = {
    101 => [0],     # Show Text
    108 => [0],     # Comment
    355 => [0],     # Script
    655 => [0],     # Script (cont.)
    401 => [0],     # Show Text (cont.)
    408 => [0],     # Comment (cont.)
    111 => [1],     # Conditional Branch (params[1] when type 12)
  }.freeze

  def self.sanitize_command_list(list)
    return unless list
    list.each do |cmd|
      next unless cmd && cmd.parameters
      indices = STRING_PARAM_INDICES[cmd.code]
      next unless indices
      indices.each do |idx|
        cmd.parameters[idx] = "" if cmd.parameters[idx].nil?
      end
    end
  end

  def self.sanitize_event_commands_for_event(event)
    return unless event
    if event.respond_to?(:pages) && event.pages
      event.pages.each { |page| sanitize_command_list(page && page.list) }
    elsif event.respond_to?(:list)
      sanitize_command_list(event.list)
    end
  end

  def self.sanitize_event_commands(map)
    return unless map && map.events
    map.events.each_value { |event| sanitize_event_commands_for_event(event) }
  end
end

module Compiler
  class << self
    unless method_defined?(:__maker_studio__change_scripts)
      alias_method :__maker_studio__change_scripts, :change_scripts
    end
    def change_scripts(script)
      return false if script.nil? || script[0].nil?
      __maker_studio__change_scripts(script)
    end

    unless method_defined?(:__maker_studio__fix_event_use)
      alias_method :__maker_studio__fix_event_use, :fix_event_use
    end
    def fix_event_use(event, map_id, map_data)
      MakerStudio.sanitize_event_commands_for_event(event)
      __maker_studio__fix_event_use(event, map_id, map_data)
    end
  end
end
