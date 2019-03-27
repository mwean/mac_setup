require "rspec/mocks"

class FakeShell
  extend RSpec::Mocks::ExampleMethods

  class << self
    def stub(pattern, options = {}, &block)
      return_val = if block_given?
                     block
                   else
                     options[:with] || ""
                   end

      @stubs.unshift(pattern: pattern, return_val: return_val)
    end

    def result(*command)
      run(*command).output
    end

    def run(*command)
      cmd = command.first
      matching_stub = @stubs.find { |stub| cmd =~ stub[:pattern] }
      @calls << { command: cmd, pwd: Dir.pwd }

      MacSetup::Result.new(return_value(matching_stub, cmd), "", instance_double(Process::Status, success?: true))
    end

    def raw(command)
      @calls << { command: command, pwd: Dir.pwd }
      nil
    end

    def success?(command)
      run(command).success?
    end

    def called?(pattern)
      !find_matching_call(pattern).nil?
    end

    def command_present!(command)
      @known_commands << command
    end

    def command_present?(command)
      @known_commands.include?(command)
    end

    def reset!
      @stubs = []
      @calls = []
      @known_commands = []
    end

    def pwd(pattern)
      find_matching_call(pattern)[:pwd]
    end

    private

    def return_value(matching_stub, command)
      return "" unless matching_stub

      return_val = matching_stub[:return_val]
      return_val.respond_to?(:call) ? return_val.call(command) : return_val.to_s
    end

    def find_matching_call(pattern)
      matcher = case pattern
                when String
                  ->(call) { call[:command] == pattern }
                when Regexp
                  ->(call) { call[:command] =~ pattern }
                else
                  raise "Invalid pattern type: #{pattern.class}"
                end

      @calls.find { |call| matcher[call] }
    end
  end
end
