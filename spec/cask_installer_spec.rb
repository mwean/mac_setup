describe MacSetup::CaskInstaller do
  let(:config) { empty_config }
  let(:status) { instance_double(MacSetup::SystemStatus, installed_casks: []) }

  before(:each) { config.casks = casks }

  context 'no casks are specified' do
    let(:casks) { [] }

    it 'does not try to install anything' do
      run_installer

      expect(/brew cask install/).not_to have_been_run
    end
  end

  context 'casks are specified' do
    let(:casks) { %w(CASK1 CASK2) }
    context 'casks are not installed' do
      let(:status) { instance_double(MacSetup::SystemStatus, installed_casks: []) }

      it 'installs the casks' do
        run_installer

        casks.each do |cask|
          expect(/brew cask install #{cask}/).to have_been_run
        end
      end
    end

    context 'casks are already installed' do
      let(:status) { instance_double(MacSetup::SystemStatus, installed_casks: [casks[0]]) }

      it 'does not install the installed casks' do
        run_installer

        expect(/brew cask install #{casks[0]}/).not_to have_been_run
        expect(/brew cask install #{casks[1]}/).to have_been_run
      end
    end
  end

  def run_installer
    quiet { MacSetup::CaskInstaller.run(config, status) }
  end
end
