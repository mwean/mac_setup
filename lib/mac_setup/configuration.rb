require 'yaml'

module MacSetup
  class Configuration
    CASK_TAP = 'caskroom/cask'

    attr_reader :config

    def initialize(config_path)
      @config = YAML.load_file(config_path)
    end

    def taps
      add_cask_tap(@config['taps'] || []).uniq
    end

    def formulas
      (@config['formulas'] || []).uniq
    end

    def casks
      (@config['casks'] || []).uniq
    end

    def launch_agents
      (@config['launch_agents'] || []).uniq
    end

    private

    def add_cask_tap(specified_taps)
      casks.any? ? specified_taps << CASK_TAP : specified_taps
    end
  end
end
