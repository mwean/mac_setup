module MacSetup
  module Plugins
    class Keybase < MacSetup::Plugin
      class << self
        def bootstrap(config)
          add_requirements(config)
          install
          log_in(config.keybase)
        end

        def add_requirements(config)
          config.require_value(:keybase)
          config.add(:casks, :keybase)
        end

        private

        def install
          HomebrewRunner.install_cask(:keybase)
        end

        def log_in(username)
          # Using backticks doesn't work with the keybase login process
          Shell.raw("keybase login #{username}")
        end
      end
    end
  end
end
