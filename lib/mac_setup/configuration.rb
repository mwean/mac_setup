require 'yaml'

module MacSetup
  class Configuration
    CASK_FORMULA = 'caskroom/cask/brew-cask'

    attr_reader :config

    def initialize(config_path)
      @config = YAML.load_file(config_path)
    end

    def taps
      (@config['taps'] || []).uniq
    end

    def formulas
      add_cask(@config['formulas'] || []).uniq
    end

    def casks
      (@config['casks'] || []).uniq
    end

    def launch_agents
      (@config['launch_agents'] || []).uniq
    end

    def git_repos
      (@config['git_repos'] || []).uniq
    end

    private

    def add_cask(specified_formulas)
      casks.any? ? specified_formulas << CASK_FORMULA : specified_formulas
    end
  end
end
