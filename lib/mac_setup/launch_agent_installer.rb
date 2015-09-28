require 'fileutils'

require_relative 'shell'

module MacSetup
  class LaunchAgentInstaller
    BREW_OPT_PATH = '/usr/local/opt'
    LAUNCH_AGENTS_PATH = File.expand_path('~/Library/LaunchAgents')

    def self.run(config, status)
      launch_agents = config.launch_agents
      return if launch_agents.none?

      puts 'Installing launch agents...'

      FileUtils.mkdir_p(LAUNCH_AGENTS_PATH)

      launch_agents.each { |agent| install_launch_agent(agent, status) }
    end

    def self.install_launch_agent(agent, status)
      puts "Installing launch agent for #{agent}..."

      domain = "homebrew.mxcl.#{agent}"
      plist = "#{domain}.plist"
      FileUtils.ln_sf(File.join(BREW_OPT_PATH, agent, plist), LAUNCH_AGENTS_PATH)

      agent_plist_path = File.join(LAUNCH_AGENTS_PATH, plist)

      Shell.run("launchctl unload '#{agent_plist_path}'") if status.loaded_agents.include?(domain)

      Shell.run("launchctl load '#{agent_plist_path}'")
    end
  end
end
