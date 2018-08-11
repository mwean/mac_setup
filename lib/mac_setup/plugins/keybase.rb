module MacSetup
  module Plugins
    class Keybase < MacSetup::Plugin
      class << self
        def bootstrap(config)
          add_requirements(config)
          install
          log_in(config.keybase)
          install_volume
        end

        def add_requirements(config)
          config.require_value(:keybase)
          config.add(:casks, :keybase)
          add_private_dotfiles(config)
        end

        private

        def install
          HomebrewRunner.install_cask(:keybase)
        end

        def log_in(username)
          # Using backticks doesn't work with the keybase login process
          Shell.raw("keybase login #{username}")
        end

        # TODO: Investigate making this work with kext permissions
        def install_volume
          Shell.run("keybase install --components=fuse")
          Shell.ask("Allow the extension in system preferences and then hit Return")
          Shell.run("keybase install --components=helper,fuse,mountdir,kbfs")
        end

        def add_private_dotfiles(config)
          keybase_dir = Dir.entries("/Volumes").find { |dir| dir.start_with?("Keybase") }
          dotfiles_dir = "/Volumes/#{keybase_dir}/private/#{config.keybase}/dotfiles"

          return unless Dir.exist?(dotfiles_dir)

          SymlinkPathBuilder.paths_for(dotfiles_dir) do |source, target|
            config.add(:symlinks, source => target)
          end
        end
      end
    end
  end
end
