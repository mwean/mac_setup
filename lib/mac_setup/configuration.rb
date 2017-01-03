require "yaml"

module MacSetup
  class Configuration
    attr_reader :config

    def initialize(config_path)
      @config = YAML.load_file(config_path)
    end

    def services
      (@config["services"] || []).uniq
    end

    def git_repos
      (@config["git_repos"] || []).uniq
    end

    def symlinks
      (@config["symlinks"] || []).uniq
    end
  end
end
