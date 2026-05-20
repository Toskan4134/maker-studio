#===============================================================================
# MakerStudio - Compiler Fix
# Sanitizes nil event command string parameters that Maker Studio can produce
# when saving maps. Patches both the Translator (Intl_Messages) and Compiler
# paths that read event data directly from .rxdata files.
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

  def self.sanitize_event_commands(map)
    return unless map&.events
    map.events.each_value do |event|
      next unless event&.pages
      event.pages.each do |page|
        next unless page&.list
        page.list.each do |cmd|
          next unless cmd.parameters
          indices = STRING_PARAM_INDICES[cmd.code]
          next unless indices
          indices.each do |idx|
            cmd.parameters[idx] = "" if cmd.parameters[idx].nil?
          end
        end
      end
    end
  end
end

# Patch Translator to sanitize maps before processing event text
module Translator
  class << self
    unless method_defined?(:__maker_studio__find_translatable_text_from_event_script)
      alias_method :__maker_studio__find_translatable_text_from_event_script, :find_translatable_text_from_event_script

      def find_translatable_text_from_event_script(items, script)
        return if script.nil?
        __maker_studio__find_translatable_text_from_event_script(items, script)
      end
    end
  end
end

# Patch Compiler to sanitize events before fix_event_scripts runs
module Compiler
  class << self
    unless method_defined?(:__maker_studio__replace_scripts)
      alias_method :__maker_studio__replace_scripts, :replace_scripts

      def replace_scripts(script)
        return false if script.nil?
        __maker_studio__replace_scripts(script)
      end
    end

    unless method_defined?(:__maker_studio__fix_event_scripts)
      alias_method :__maker_studio__fix_event_scripts, :fix_event_scripts

      def fix_event_scripts(event)
        return false if event_is_empty?(event)
        MakerStudio.sanitize_event_commands_for_event(event)
        __maker_studio__fix_event_scripts(event)
      end
    end
  end
end

module MakerStudio
  def self.sanitize_command_list(list)
    return unless list
    list.each do |cmd|
      next unless cmd.parameters
      indices = STRING_PARAM_INDICES[cmd.code]
      next unless indices
      indices.each do |idx|
        cmd.parameters[idx] = "" if cmd.parameters[idx].nil?
      end
    end
  end

  def self.sanitize_event_commands_for_event(event)
    return unless event
    if event.respond_to?(:pages)
      event.pages.each { |page| sanitize_command_list(page&.list) }
    elsif event.respond_to?(:list)
      sanitize_command_list(event.list)
    end
  end
end
