module MacSetup
  module Plugins
    class Dotfiles < MacSetup::Plugin
      class << self
        def add_requirements(config)
          SymlinkPathBuilder.paths_for(MacSetup.dotfiles_path) do |source, target|
            config.add(:symlinks, source => target)
          end
        end
      end
    end
  end
end
