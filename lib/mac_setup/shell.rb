require "shellwords"
require "io/console"
require "open3"

module MacSetup
  class Shell
    class << self
      def result(*command)
        run(*command).output
      end

      def run(*command)
        Result.new(*Open3.capture3(*command))
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
        run(command).success?
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
