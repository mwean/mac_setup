module MacSetup
  class SecretsInstaller
    def self.run(_config, status)
      new(status).run
    end

    def initialize(status)
      @status = status
    end

    def run
      install_openssl
      Secrets.decrypt(DOTFILES_PATH)
    end

    def install_openssl
      # Needed for encrypted files
      Shell.run("brew install openssl") unless @status.installed_formulas.include?("openssl")
    end
  end
end
