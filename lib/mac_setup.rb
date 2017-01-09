require "mac_setup/version"
require "mac_setup/configuration"
require "mac_setup/system_status"
require "mac_setup/secrets"
require "mac_setup/command_line_tools_installer"
require "mac_setup/homebrew_installer"
require "mac_setup/git_repo_installer"
require "mac_setup/script_installer"
require "mac_setup/symlink_installer"
require "mac_setup/brewfile_installer"
require "mac_setup/services_installer"

module MacSetup
  DOTFILES_PATH = File.expand_path("~/.dotfiles")

  INSTALLERS = [
    GitRepoInstaller,
    BrewfileInstaller,
    ServicesInstaller,
    SymlinkInstaller,
    ScriptInstaller
  ]

  def self.install(config_path, _options)
    config = Configuration.new(File.expand_path(config_path))
    status = SystemStatus.new
    Secrets.decrypt(DOTFILES_PATH)

    INSTALLERS.each { |installer| installer.run(config, status) }
  end

  def self.bootstrap(dotfiles_repo)
    CommandLineToolsInstaller.run
    GitRepoInstaller.install_repo(dotfiles_repo, DOTFILES_PATH)
    HomebrewInstaller.run
  end

  def self.encrypt
    Secrets.encrypt(DOTFILES_PATH)
  end

  def self.shorten_path(path)
    path.sub(/#{ENV['HOME']}/, "~")
  end
end
