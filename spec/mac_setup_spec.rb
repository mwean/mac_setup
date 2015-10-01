describe MacSetup do
  describe '.bootstrap' do
    let(:dotfiles_repo) { 'username/dotfiles' }

    before(:each) do
      allow(MacSetup::GitRepoInstaller).to receive(:install_repo)
      allow(MacSetup::CommandLineToolsInstaller).to receive(:run)

      MacSetup.bootstrap(dotfiles_repo)
    end

    it 'clones the dotfiles repo' do
      expected_args = [dotfiles_repo, MacSetup::DOTFILES_PATH]
      expect(MacSetup::GitRepoInstaller).to have_received(:install_repo).with(*expected_args)
    end

    it 'installs the command line tools' do
      expect(MacSetup::CommandLineToolsInstaller).to have_received(:run)
    end
  end

  describe '.install' do
    let(:config_path) { 'spec/support/config.yml' }
    let(:options) { %w(option1 option2) }
    let(:fake_config) { double(:fake_config) }
    let(:fake_status) { double(:fake_status) }

    before(:each) do
      allow(MacSetup::Configuration).to receive(:new).and_return(fake_config)
      allow(MacSetup::SystemStatus).to receive(:new).and_return(fake_status)

      allow(MacSetup::GitRepoInstaller).to receive(:install_repo)
      allow(MacSetup::HomebrewInstaller).to receive(:run)
      allow(MacSetup::TapInstaller).to receive(:run)
      allow(MacSetup::FormulaInstaller).to receive(:run)
      allow(MacSetup::CaskInstaller).to receive(:run)
      allow(MacSetup::LaunchAgentInstaller).to receive(:run)
      allow(MacSetup::GitRepoInstaller).to receive(:run)
      allow(MacSetup::ScriptInstaller).to receive(:run)

      MacSetup.install(config_path, options)
    end

    it 'builds a configuration object with the config path' do
      expect(MacSetup::Configuration).to have_received(:new).with(File.expand_path(config_path))
    end

    it 'installs homebrew' do
      expect(MacSetup::HomebrewInstaller).to have_received(:run).with(options)
    end

    it 'installs taps' do
      expect(MacSetup::TapInstaller).to have_received(:run).with(fake_config, fake_status)
    end

    it 'installs formulas' do
      expect(MacSetup::FormulaInstaller).to have_received(:run).with(fake_config, fake_status)
    end

    it 'installs casks' do
      expect(MacSetup::CaskInstaller).to have_received(:run).with(fake_config, fake_status)
    end

    it 'installs launch agents' do
      expect(MacSetup::LaunchAgentInstaller).to have_received(:run).with(fake_config, fake_status)
    end

    it 'installs git repos' do
      expect(MacSetup::GitRepoInstaller).to have_received(:run).with(fake_config)
    end

    it 'installs scripts' do
      expect(MacSetup::ScriptInstaller).to have_received(:run).with(fake_config)
    end
  end
end
