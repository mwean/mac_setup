describe MacSetup do
  describe '.install' do
    let(:config_path) { 'spec/support/config.yml' }
    let(:fake_config) { double(:fake_config) }
    let(:fake_status) { double(:fake_status) }

    before(:each) do
      allow(MacSetup::Configuration).to receive(:new).and_return(fake_config)
      allow(MacSetup::SystemStatus).to receive(:new).and_return(fake_status)

      allow(MacSetup::HomebrewInstaller).to receive(:run)
      allow(MacSetup::TapInstaller).to receive(:run)
      allow(MacSetup::FormulaInstaller).to receive(:run)
      allow(MacSetup::CaskInstaller).to receive(:run)
      allow(MacSetup::LaunchAgentInstaller).to receive(:run)

      MacSetup.install(config_path)
    end

    it 'builds a configuration object with the config path' do
      expect(MacSetup::Configuration).to have_received(:new).with(File.expand_path(config_path))
    end

    it 'installs homebrew' do
      expect(MacSetup::HomebrewInstaller).to have_received(:run)
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
  end
end
