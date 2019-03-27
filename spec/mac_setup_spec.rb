describe MacSetup do
  describe ".bootstrap" do
    let(:dotfiles_repo) { "username/dotfiles" }

    before(:each) do
      allow(MacSetup::HomebrewInstaller).to receive(:run)
      allow(MacSetup::GitRepoInstaller).to receive(:install_repo)

      plugins = [
        MacSetup::Plugins::MacAppStore,
        MacSetup::Plugins::Keybase,
        MacSetup::Plugins::Dotfiles,
        MacSetup::Plugins::Asdf
      ]

      plugins.each { |plugin| allow(plugin).to receive(:bootstrap) }

      described_class.bootstrap(dotfiles_repo)
    end

    it "clones the dotfiles repo" do
      expected_args = [dotfiles_repo, MacSetup.dotfiles_path]
      expect(MacSetup::GitRepoInstaller).to have_received(:install_repo).with(*expected_args)
    end

    it "installs homebrew" do
      expect(MacSetup::HomebrewInstaller).to have_received(:run)
    end
  end

  describe ".install" do
    let(:config_path) { "spec/support/config.yml" }
    let(:fake_config) { double(:fake_config, plugins: []).as_null_object }
    let(:fake_status) { double(:fake_status) }

    before(:each) do
      allow(MacSetup::Configuration).to receive(:new).and_return(fake_config)
      allow(MacSetup::SystemStatus).to receive(:new).and_return(fake_status)
      allow(MacSetup::GitRepoInstaller).to receive(:install_repo)

      (MacSetup::INSTALLERS + MacSetup::DEFAULT_PLUGINS).each do |installer|
        allow(installer).to receive(:run)
      end

      described_class.install
    end

    xit "builds a configuration object with the config path" do
      expect(MacSetup::Configuration).to have_received(:new).with(File.expand_path(config_path))
    end

    expected_installers = [
      MacSetup::GitRepoInstaller,
      MacSetup::SymlinkInstaller,
      MacSetup::HomebrewRunner,
      MacSetup::ScriptInstaller,
      MacSetup::DefaultsInstaller,
      MacSetup::Plugins::MacAppStore,
      MacSetup::Plugins::Keybase,
      MacSetup::Plugins::Dotfiles,
      MacSetup::Plugins::Asdf
    ]

    it "runs the installers" do
      expected_installers.each do |installer|
        expect(installer).to have_received(:run).with(fake_config, fake_status)
      end
    end
  end
end
