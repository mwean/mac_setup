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
          Shell.run("keybase login #{username}")
        end

        # TODO: Investigate making this work with kext permissions
        def install_volume
          Shell.run("keybase install --components=helper,fuse,mountdir,kbfs")
        end

        def add_private_dotfiles(config)
          dotfiles_dir = Pathname.new("/keybase/private/#{config.keybase}/dotfiles")

          return unless dotfiles_dir.exist?

          SymlinkPathBuilder.paths_for(dotfiles_dir) do |source, target|
            config.add(:symlinks, source => target)
          end
        end
      end
    end
  end
end
