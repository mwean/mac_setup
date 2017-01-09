require "shellwords"
require "io/console"

module MacSetup
  class Shell
    def self.run(command)
      `#{sanitize_command(command)}`
    end

    def self.ask(question)
      puts question
      gets.strip
    end

    def self.password
      puts "Enter Password"
      STDIN.noecho(&:gets).strip
    end

    def self.success?(command)
      system(sanitize_command(command))
    end

    def self.sanitize_command(command)
      if command.respond_to?(:each)
        Shellwords.join(command)
      else
        command
      end
    end
  end
end
