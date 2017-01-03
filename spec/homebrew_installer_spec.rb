describe MacSetup::HomebrewInstaller do
  context 'homebrew is not already installed' do
    before(:each) { FakeShell.stub(/which brew/, with: '') }

    it 'installs homebrew' do
      run_installer

      expect(/curl .*Homebrew/).to have_been_run
    end
  end

  context 'homebrew is already installed' do
    before(:each) { FakeShell.stub(/which brew/, with: '/usr/local/bin/brew') }

    it 'does not install homebrew' do
      run_installer

      expect(/curl .*Homebrew/).not_to have_been_run
    end

    it 'updates homebrew' do
      run_installer

      expect(/brew update/).to have_been_run
    end
  end

  def run_installer
    quiet { MacSetup::HomebrewInstaller.run }
  end
end
