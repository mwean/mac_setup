require 'mac_setup/version'
require 'mac_setup/configuration'
require 'mac_setup/system_status'
require 'mac_setup/homebrew_installer'
require 'mac_setup/tap_installer'
require 'mac_setup/formula_installer'
require 'mac_setup/cask_installer'
require 'mac_setup/launch_agent_installer'
require 'mac_setup/git_repo_installer'

module MacSetup
  def self.install(config_path, options)
    config = Configuration.new(File.expand_path(config_path))
    status = SystemStatus.new

    HomebrewInstaller.run(options)
    TapInstaller.run(config, status)
    FormulaInstaller.run(config, status)
    CaskInstaller.run(config, status)
    LaunchAgentInstaller.run(config, status)
    GitRepoInstaller.run(config)
  end
end
