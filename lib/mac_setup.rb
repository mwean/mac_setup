require "pathname"

require "mac_setup/version"
require "mac_setup/configuration"
require "mac_setup/system_status"
require "mac_setup/shell"
require "mac_setup/homebrew_runner"
require "mac_setup/secrets"
require "mac_setup/homebrew_installer"
require "mac_setup/git_repo_installer"
require "mac_setup/symlink_installer"
require "mac_setup/plugin"
require "mac_setup/plugins/keybase"
require "mac_setup/plugins/mac_app_store"
require "mac_setup/plugins/dotfiles"

module MacSetup
  DEFAULT_DOTFILES_PATH = File.expand_path("~/.dotfiles")
  DEFAULT_CONFIG_PATH = File.join(DEFAULT_DOTFILES_PATH, "mac_setup/config.yml")

  INSTALLERS = [
    GitRepoInstaller,
    SymlinkInstaller,
    HomebrewRunner
  ]

  DEFAULT_PLUGINS = [
    Plugins::MacAppStore,
    Plugins::Keybase,
    Plugins::Dotfiles
  ]

  class << self
    def bootstrap(dotfiles_repo)
      GitRepoInstaller.install_repo(dotfiles_repo, dotfiles_path)
      HomebrewInstaller.run

      config = Configuration.new(DEFAULT_CONFIG_PATH)

      plugins(config).each { |plugin| plugin.bootstrap(config) }
    end

    def install # (config_path, _options)
      config = Configuration.new(DEFAULT_CONFIG_PATH)

      GitRepoInstaller.install_repo(config.dotfiles_repo, dotfiles_path)

      config = Configuration.new(DEFAULT_CONFIG_PATH)
      plugins(config).each { |plugin| plugin.add_requirements(config) }
      config.validate!
      status = SystemStatus.new

      INSTALLERS.each { |installer| installer.run(config, status) }
    end

    def encrypt
      Secrets.encrypt(dotfiles_path)
    end

    def shorten_path(path)
      path.to_s.sub(/#{ENV['HOME']}/, "~")
    end

    def log(message)
      if block_given?
        print "#{message}..."
        yield
        puts "Ok."
      else
        puts message
      end
    end

    def dotfiles_path
      DEFAULT_DOTFILES_PATH
    end

    # private

    def plugins(config)
      DEFAULT_PLUGINS + config.plugins.map { |plugin_name| Plugin.load(plugin_name) }
      # @plugins ||= (DEFAULT_PLUGINS + config.plugins).map { |plugin_name| Plugin.load(plugin) }
    end
  end
end
