describe MacSetup::HomebrewInstaller do
  let(:options) { [] }

  context 'homebrew is not already installed' do
    before(:each) { FakeShell.stub(/which brew/, with: '') }

    it 'installs homebrew' do
      run_installer

      expect(/curl .*Homebrew.* | ruby/).to have_been_run
    end

    it 'updates homebrew' do
      run_installer

      expect(/brew update/).to have_been_run
    end
  end

  context 'homebrew is already installed' do
    before(:each) { FakeShell.stub(/which brew/, with: '/usr/local/bin/brew') }

    it 'does not install homebrew' do
      run_installer

      expect(/curl .*Homebrew.* | ruby/).not_to have_been_run
    end

    it 'updates homebrew' do
      run_installer

      expect(/brew update/).to have_been_run
    end

    context '--skip-brew-update option is passed' do
      let(:options) { ['--skip-brew-update'] }

      it 'does not update homebrew' do
        run_installer

        expect(/brew update/).not_to have_been_run
      end
    end
  end

  def run_installer
    quiet { MacSetup::HomebrewInstaller.run(options) }
  end
end
