describe MacSetup::LaunchAgentInstaller do
  let(:config) { empty_config }
  let(:status) { instance_double(MacSetup::SystemStatus, loaded_agents: loaded_agents) }
  let(:sandbox_path) { Pathname.new('spec/sandbox').expand_path }
  let(:opt_path) { sandbox_path.join('opt').to_s }
  let(:launch_agents_path) { sandbox_path.join('LaunchAgents').to_s }

  before(:each) do
    stub_const('MacSetup::LaunchAgentInstaller::BREW_OPT_PATH', opt_path)
    stub_const('MacSetup::LaunchAgentInstaller::LAUNCH_AGENTS_PATH', launch_agents_path)

    config.launch_agents = launch_agents
  end

  after(:each) do
    FileUtils.rm_rf(launch_agents_path)
    FileUtils.rm_rf(opt_path)
  end

  context 'no launch agents are specified' do
    let(:launch_agents) { [] }
    let(:loaded_agents) { [] }

    it 'does not create the LaunchAgents directory' do
      FileUtils.rmdir(launch_agents_path)

      run_installer

      expect(Pathname.new(launch_agents_path)).not_to exist
    end
  end

  context 'launch agents are specified' do
    let(:launch_agents) { %w(AGENT1 AGENT2) }
    let(:loaded_agents) { [] }

    let(:status) do
      instance_double(MacSetup::SystemStatus, loaded_agents: loaded_agents)
    end

    before(:each) do
      launch_agents.each do |agent|
        domain = "homebrew.mxcl.#{agent}"
        opt_agent_path = File.join(opt_path, agent)
        FileUtils.mkdir_p(opt_agent_path)
        plist_path = File.join(opt_agent_path, "#{domain}.plist")
        FileUtils.touch(plist_path)
      end
    end

    it 'creates the LaunchAgents directory' do
      FileUtils.rmdir(launch_agents_path)

      run_installer

      expect(Pathname.new(launch_agents_path)).to exist
    end

    it 'symlinks the plists to the LaunchAgents directory' do
      run_installer

      launch_agents.each do |agent|
        expected_symlink = Pathname.new(launch_agents_path).join("homebrew.mxcl.#{agent}.plist")
        expect(expected_symlink.symlink?).to be(true)
      end
    end

    it 'loads the plists with launchctl' do
      run_installer

      expect(/launchctl load.*homebrew\.mxcl\.AGENT1\.plist/).to have_been_run
      expect(/launchctl load.*homebrew\.mxcl\.AGENT2\.plist/).to have_been_run
    end

    context 'agents are already loaded' do
      let(:loaded_agents) { ['homebrew.mxcl.AGENT1'] }

      it 'unloads the agent first' do
        run_installer

        expect(/launchctl unload.*homebrew\.mxcl\.AGENT1\.plist/).to have_been_run
        expect(/launchctl unload.*homebrew\.mxcl\.AGENT2\.plist/).not_to have_been_run
      end
    end
  end

  def run_installer
    quiet { MacSetup::LaunchAgentInstaller.run(config, status) }
  end
end
