require_relative 'shell'

module MacSetup
  class SystemStatus
    def installed_formulas
      @installed_formulas ||= get_formulas
    end

    def outdated_formulas
      @outdated_formulas ||= get_outdated_formulas
    end

    def installed_taps
      @installed_taps ||= get_taps
    end

    def installed_casks
      @installed_casks ||= get_casks
    end

    def loaded_agents
      @loaded_agents ||= get_loaded_agents
    end

    private

    def get_formulas
      Shell.run('brew list -1').split("\n")
    end

    def get_taps
      Shell.run('brew tap').split("\n")
    end

    def get_casks
      Shell.run('brew cask list -1').split("\n")
    end

    def get_outdated_formulas
      Shell.run('brew outdated --quiet').split("\n")
    end

    def get_loaded_agents
      Shell.run('launchctl list | grep homebrew').split("\n").map do |line|
        line.split(/\s/)[-1]
      end
    end
  end
end
