describe MacSetup::SymlinkInstaller do
  let(:home_path) { File.expand_path('spec/sandbox/home') }
  let(:dotfiles_path) { File.expand_path('spec/sandbox/dotfiles') }
  let(:config) { empty_config }
  let(:options) { {} }

  before(:each) do
    @original_home = ENV['HOME']
    ENV['HOME'] = home_path
    stub_const('MacSetup::DOTFILES_PATH', dotfiles_path)

    FileUtils.mkdir_p(dotfiles_path)
    FileUtils.mkdir_p(home_path)
  end

  after(:each) do
    FileUtils.rm_rf(dotfiles_path)
    FileUtils.rm_rf(home_path)
    ENV['HOME'] = @original_home
  end

  describe '.run' do
    it 'symlinks everything in the dotfiles directory' do
      dotfiles = %w(dotfile1 dotfile2)
      dotfiles.each { |dotfile| FileUtils.touch(File.join(dotfiles_path, dotfile)) }

      run_installer

      dotfiles.each do |dotfile|
        expect(File.symlink?(File.join(home_path, ".#{dotfile}"))).to be(true)
      end
    end

    it 'symlinks files specified in config' do
      config.symlinks = ['~/somewhere/symlink1']

      run_installer

      expect(File.symlink?(File.join(home_path, '.symlink1'))).to be(true)
    end

    it 'does not re-link files that are already correctly linked' do
      source = File.join(dotfiles_path, 'dotfile1')
      target = File.join(home_path, '.dotfile1')

      FileUtils.touch(source)
      FileUtils.ln_s(source, target)
      original_mtime = File.mtime(target)

      run_installer

      expect(File.mtime(target)).to eq(original_mtime)
    end

    it 'overwrites existing symlinks that have different sources' do
      source = File.join(dotfiles_path, 'dotfile1')
      other_source = File.join(dotfiles_path, 'different_file')
      target = File.join(home_path, '.dotfile1')

      FileUtils.touch(source)
      FileUtils.touch(other_source)

      FileUtils.ln_s(other_source, target)

      run_installer

      expect(File.readlink(target)).to eq(source)
    end

    it 'does not overwrite existing real files' do
      source = File.join(dotfiles_path, 'dotfile1')
      target = File.join(home_path, '.dotfile1')
      FileUtils.touch(source)
      FileUtils.touch(target)

      run_installer

      expect(File.symlink?(target)).to be(false)
    end

    it 'handles directories' do
      source_dir = File.join(dotfiles_path, 'some_dir')
      source = File.join(source_dir, 'some_file')

      FileUtils.mkdir_p(source_dir)
      FileUtils.touch(source)

      run_installer

      expect(File.symlink?("#{home_path}/.some_dir")).to be(true)
      expect(File.exist?("#{home_path}/.some_dir/some_file")).to be(true)
    end
  end

  describe '.install_dotfile' do
    it 'only symlinks the matching dotfiles' do
      dotfiles = %w(dotfile1 dotfile2)
      dotfiles.each { |dotfile| FileUtils.touch(File.join(dotfiles_path, dotfile)) }

      MacSetup::SymlinkInstaller.install_dotfile('dotfile1')

      expect(File.symlink?(File.join(home_path, '.dotfile1'))).to be(true)
      expect(File.symlink?(File.join(home_path, '.dotfile2'))).to be(false)
    end
  end

  def run_installer
    quiet { MacSetup::SymlinkInstaller.run(config) }
  end
end
