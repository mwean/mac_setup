describe MacSetup::SymlinkInstaller do
  let(:home_path) { File.expand_path("spec/sandbox/home") }
  let(:dotfiles_path) { File.expand_path("spec/sandbox/dotfiles") }
  let(:config) { empty_config }
  let(:options) { {} }

  before do
    @original_home = ENV["HOME"]
    ENV["HOME"] = home_path
    allow(MacSetup).to receive(:dotfiles_path).and_return(dotfiles_path)

    FileUtils.mkdir_p(dotfiles_path)
    FileUtils.mkdir_p(home_path)
  end

  after do
    FileUtils.rm_rf(dotfiles_path)
    FileUtils.rm_rf(home_path)
    ENV["HOME"] = @original_home
  end

  xdescribe ".run" do
    it "symlinks everything in the dotfiles directory" do
      dotfiles = %w[dotfile1 dotfile2]
      dotfiles.each { |dotfile| FileUtils.touch(File.join(dotfiles_path, dotfile)) }

      run_installer

      dotfiles.each do |dotfile|
        expect(File.symlink?(File.join(home_path, ".#{dotfile}"))).to be(true)
      end
    end

    it "symlinks files specified in config" do
      config.symlinks = ["~/somewhere/symlink1"]
      source = File.join(home_path, "somewhere/symlink1")
      FileUtils.mkdir_p(File.dirname(source))
      FileUtils.touch(source)

      run_installer

      expect(File.symlink?(File.join(home_path, ".symlink1"))).to be(true)
    end

    context "source doesn't exist" do
      it "skips the file" do
        config.symlinks = ["~/somewhere/symlink1"]

        run_installer

        expect(File.symlink?(File.join(home_path, ".symlink1"))).to be(false)
      end
    end

    it "does not re-link files that are already correctly linked" do
      source = File.join(dotfiles_path, "dotfile1")
      target = File.join(home_path, ".dotfile1")

      FileUtils.touch(source)
      FileUtils.ln_s(source, target)
      original_mtime = File.mtime(target)

      run_installer

      expect(File.mtime(target)).to eq(original_mtime)
    end

    it "overwrites existing symlinks that have different sources" do
      source = File.join(dotfiles_path, "dotfile1")
      other_source = File.join(dotfiles_path, "different_file")
      target = File.join(home_path, ".dotfile1")

      FileUtils.touch(source)
      FileUtils.touch(other_source)

      FileUtils.ln_s(other_source, target)

      run_installer

      expect(File.readlink(target)).to eq(source)
    end

    it "does not overwrite existing real files" do
      source = File.join(dotfiles_path, "dotfile1")
      target = File.join(home_path, ".dotfile1")
      FileUtils.touch(source)
      FileUtils.touch(target)

      run_installer

      expect(File.symlink?(target)).to be(false)
    end

    it "handles directories" do
      source_dir = File.join(dotfiles_path, "some_dir")
      source = File.join(source_dir, "some_file")

      FileUtils.mkdir_p(source_dir)
      FileUtils.touch(source)

      run_installer

      expect(File.symlink?("#{home_path}/.some_dir")).to be(true)
      expect(File.exist?("#{home_path}/.some_dir/some_file")).to be(true)
    end

    it "symlinks children if the target directory already exists" do
      source_dir = File.join(dotfiles_path, "some_dir")
      source = File.join(source_dir, "some_file")
      target_dir = File.join(home_path, ".some_dir")

      FileUtils.mkdir_p(source_dir)
      FileUtils.touch(source)
      FileUtils.mkdir_p(target_dir)

      run_installer

      expect(File.symlink?("#{home_path}/.some_dir")).to be(false)
      expect(File.directory?("#{home_path}/.some_dir")).to be(true)
      expect(File.symlink?("#{home_path}/.some_dir/some_file")).to be(true)
    end
  end

  def run_installer
    quiet { MacSetup::SymlinkInstaller.run(config, instance_double(MacSetup::SystemStatus)) }
  end
end
