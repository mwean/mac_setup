module MacSetup
  module Plugins
    class Dotfiles < MacSetup::Plugin
      class << self
        def add_requirements(config)
          GitRepoInstaller.install_repo(config.dotfiles_repo, MacSetup.dotfiles_path)
          paths = [MacSetup.dotfiles_path]

          config.extra_dotfiles.each do |repo|
            path = File.expand_path("~/.#{repo.split('/').last}")
            paths << path
            GitRepoInstaller.install_repo(repo, path)
          end

          paths.each do |path|
            SymlinkPathBuilder.paths_for(path) do |source, target|
              config.add(:symlinks, source => target)
            end
          end
        end
      end
    end
  end
end
