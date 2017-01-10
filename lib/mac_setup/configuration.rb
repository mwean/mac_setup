require "yaml"

module MacSetup
  class Configuration
    attr_reader :config

    def initialize(config_path)
      @config_path = config_path
      load_config
    end

    def reload!
      load_config
    end

    def dotfiles_repo
      @config.fetch("repo")
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

    private

    def load_config
      @config = YAML.load_file(@config_path)
    end
  end
end
