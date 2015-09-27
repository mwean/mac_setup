describe MacSetup::TapInstaller do
  let(:config) { empty_config }
  let(:status) { instance_double(MacSetup::SystemStatus, installed_taps: []) }

  context 'taps are specified in the config' do
    let(:taps) { %w(TAP1 TAP2) }

    before(:each) { config.taps = taps }

    it 'installs the specified taps' do
      run_installer

      taps.each do |tap|
        expect(/brew tap #{tap}/).to have_been_run
      end
    end

    context 'taps are already installed' do
      let(:status) { instance_double(MacSetup::SystemStatus, installed_taps: [taps[0]]) }

      it "doesn't try to install taps that are already installed" do
        run_installer

        expect(/brew tap #{taps[0]}/).not_to have_been_run
        expect(/brew tap #{taps[1]}/).to have_been_run
      end
    end
  end

  def run_installer
    quiet { MacSetup::TapInstaller.run(config, status) }
  end
end
