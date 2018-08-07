require "shellwords"
require "io/console"

module MacSetup
  class Shell
    class << self
      def run(command)
        `#{sanitize_command(command)}`
      end

      def raw(command)
        system(command)
      end

      def ask(question)
        puts question
        STDIN.gets.strip
      end

      def password
        puts "Enter Password"
        STDIN.noecho(&:gets).strip
      end

      def success?(command)
        system(sanitize_command(command))
      end

      def command_present?(command)
        success?("command -v #{command} >/dev/null 2>&1")
      end

      def sanitize_command(command)
        if command.respond_to?(:each)
          Shellwords.join(command)
        else
          command
        end
      end
    end
  end
end
