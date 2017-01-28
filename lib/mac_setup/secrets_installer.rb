module MacSetup
  class SecretsInstaller
    def self.run(_config, status)
      new(status).run
    end

    def initialize(status)
      @status = status
    end

    def run
      install_crypto
      Secrets.decrypt(@status.git_changes(:dotfiles))
    end

    def install_crypto
      Shell.run("brew install #{SECRETS::CRYPTO_LIB}") unless @status.installed_formulas.include?(CRYPTO_LIB)
    end
  end
end
