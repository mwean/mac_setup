describe MacSetup::CommandLineToolsInstaller do
  let(:clt_bin_path) { File.expand_path('spec/sandbox/clt_bin') }
  let(:tmp_path) { File.expand_path('spec/sandbox/tmp_install') }

  before(:each) do
    stub_const('MacSetup::CommandLineToolsInstaller::BIN_PATH', "#{clt_bin_path}/clang")
    stub_const('MacSetup::CommandLineToolsInstaller::TMP_FILE', "#{tmp_path}/file")

    FileUtils.mkdir_p(tmp_path)

    response = File.read('spec/support/softwareupdate_response.txt')
    FakeShell.stub(/softwareupdate -l/, with: response)
  end

  after(:each) do
    FileUtils.rm_rf(clt_bin_path)
    FileUtils.rm_rf(tmp_path)
  end

  context 'CLTs are not already installed' do
    it 'installs CLTs' do
      run_installer

      expect(/softwareupdate -l/).to have_been_run
      package_name = Regexp.escape('Command Line Tools (OS X 10.10) for Xcode-7.0')
      expect(/softwareupdate -i "#{package_name}"/).to have_been_run
    end
  end

  context 'CLTs are already installed' do
    before(:each) do
      FileUtils.mkdir_p(clt_bin_path)
      FileUtils.touch("#{clt_bin_path}/clang")
    end

    it 'does not install CLTs' do
      run_installer

      expect(/softwareupdate -l/).not_to have_been_run
      expect(/softwareupdate -i/).not_to have_been_run
    end
  end

  def run_installer
    quiet { MacSetup::CommandLineToolsInstaller.run }
  end
end
