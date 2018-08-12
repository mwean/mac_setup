require_relative "shell"

module MacSetup
  class SystemStatus
    def initialize
      @git_changes = Hash.new { |hash, key| hash[key] = [] }
      @defaults = Hash.new { |hash, key| hash[key] = {} }
    end

    def installed_taps
      @installed_taps ||= get_taps
    end

    def installed_formulas
      @installed_formulas ||= get_formulas
    end

    def git_changes(key, changes = nil)
      if changes
        @git_changes[key] = changes
      else
        @git_changes[key]
      end
    end

    def defaults_value(domain, key)
      @defaults[domain][key] ||= read_defaults_value(domain, key)
    end

    private

    def get_taps
      Shell.run("brew tap").split("\n")
    end

    def get_formulas
      Shell.run("brew list -1").split("\n")
    end

    def read_defaults_value(domain, key)
      result = Shell.run("defaults read #{domain} #{key}")

      result unless result =~ /The domain.*does not exist/
    end
  end
end
