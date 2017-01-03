require 'mac_setup/version'
require 'mac_setup/configuration'
require 'mac_setup/system_status'
require 'mac_setup/homebrew_installer'
require 'mac_setup/git_repo_installer'
require 'mac_setup/script_installer'
require 'mac_setup/symlink_installer'
require 'mac_setup/brewfile_installer'
require 'mac_setup/services_installer'

module MacSetup
  DOTFILES_PATH = File.expand_path('~/.dotfiles')

  INSTALLERS = [
    SymlinkInstaller,
    BrewfileInstaller,
    ServicesInstaller,
    GitRepoInstaller,
    ScriptInstaller
  ]

  def self.install(config_path, options)
    config = Configuration.new(File.expand_path(config_path))
    status = SystemStatus.new

    INSTALLERS.each { |installer| installer.run(config, status) }
  end

  def self.bootstrap(dotfiles_repo)
    GitRepoInstaller.install_repo(dotfiles_repo, DOTFILES_PATH)
    SymlinkInstaller.install_dotfile('mac_setup')
    HomebrewInstaller.run
  end

  def self.shorten_path(path)
    path.sub(/#{ENV['HOME']}/, '~')
  end
end
