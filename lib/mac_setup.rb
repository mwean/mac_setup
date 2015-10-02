require 'mac_setup/version'
require 'mac_setup/configuration'
require 'mac_setup/system_status'
require 'mac_setup/command_line_tools_installer'
require 'mac_setup/homebrew_installer'
require 'mac_setup/tap_installer'
require 'mac_setup/formula_installer'
require 'mac_setup/cask_installer'
require 'mac_setup/launch_agent_installer'
require 'mac_setup/git_repo_installer'
require 'mac_setup/script_installer'
require 'mac_setup/symlink_installer'

module MacSetup
  DOTFILES_PATH = File.expand_path('~/.dotfiles')

  def self.install(config_path, options)
    config = Configuration.new(File.expand_path(config_path))
    status = SystemStatus.new

    HomebrewInstaller.run(options)
    TapInstaller.run(config, status)
    FormulaInstaller.run(config, status)
    CaskInstaller.run(config, status)
    LaunchAgentInstaller.run(config, status)
    GitRepoInstaller.run(config)
    ScriptInstaller.run(config)
    SymlinkInstaller.run(config)
  end

  def self.bootstrap(dotfiles_repo)
    check_brew_install_path

    CommandLineToolsInstaller.run
    GitRepoInstaller.install_repo(dotfiles_repo, DOTFILES_PATH)
    SymlinkInstaller.install_dotfile('mac_setup')
  end

  def self.check_brew_install_path
    return if Dir.exist?('/usr/local')

    puts '/usr/local does not exist.'
    puts 'Read this to fix: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/El_Capitan_and_Homebrew.md#if-usrlocal-does-not-exist'
  end
end
