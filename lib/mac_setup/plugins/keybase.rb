module MacSetup
  module Plugins
    class Keybase < MacSetup::Plugin
      def self.bootstrap(config)
        add_requirements(config)
        install
        login(config.keybase)
        install_volume
      end

      def self.add_requirements(config)
        config.require_value(:keybase)
        config.add(:casks, :keybase)
      end

      private

      def self.install
        HomebrewRunner.install_cask(:keybase)
      end

      def self.login(username)
        Shell.run("keybase login #{username}")
      end

      # TODO: Investigate making this work with kext permissions
      def self.install_volume
        Shell.run("keybase install --components=helper,fuse,mountdir,kbfs")
      end
    end
  end
end
