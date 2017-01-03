describe MacSetup do
  describe ".bootstrap" do
    let(:dotfiles_repo) { "username/dotfiles" }

    before(:each) do
      allow(MacSetup::GitRepoInstaller).to receive(:install_repo)
      allow(MacSetup::SymlinkInstaller).to receive(:install_dotfile)
      allow(MacSetup::HomebrewInstaller).to receive(:run)

      described_class.bootstrap(dotfiles_repo)
    end

    it "clones the dotfiles repo" do
      expected_args = [dotfiles_repo, MacSetup::DOTFILES_PATH]
      expect(MacSetup::GitRepoInstaller).to have_received(:install_repo).with(*expected_args)
    end

    it "installs the mac_setup dotfile symlinks" do
      expect(MacSetup::SymlinkInstaller).to have_received(:install_dotfile).with("mac_setup")
    end

    it "installs homebrew" do
      expect(MacSetup::HomebrewInstaller).to have_received(:run)
    end
  end

  describe ".install" do
    let(:config_path) { "spec/support/config.yml" }
    let(:options) { %w(option1 option2) }
    let(:fake_config) { double(:fake_config) }
    let(:fake_status) { double(:fake_status) }

    before(:each) do
      allow(MacSetup::Configuration).to receive(:new).and_return(fake_config)
      allow(MacSetup::SystemStatus).to receive(:new).and_return(fake_status)

      MacSetup::INSTALLERS.each do |installer|
        allow(installer).to receive(:run)
      end

      described_class.install(config_path, options)
    end

    it "builds a configuration object with the config path" do
      expect(MacSetup::Configuration).to have_received(:new).with(File.expand_path(config_path))
    end

    expected_installers = [
      MacSetup::SymlinkInstaller,
      MacSetup::BrewfileInstaller,
      MacSetup::ServicesInstaller,
      MacSetup::GitRepoInstaller,
      MacSetup::ScriptInstaller
    ]

    expected_installers.each do |installer|
      it "runs the #{installer}" do
        expect(installer).to have_received(:run).with(fake_config, fake_status)
      end
    end
  end
end
