describe MacSetup::GitRepoInstaller do
  let(:config) { empty_config }

  before(:each) { config.git_repos = git_repos }

  context 'repos are from github' do
    let(:git_repos) { [{ 'username/repo' => 'some/install/path' }] }

    it 'installs the repo at the given path' do
      run_installer

      github_url = 'https://github.com/username/repo.git'
      full_install_path = File.expand_path('some/install/path')
      expect(/git clone --recursive #{github_url} "#{full_install_path}"/).to have_been_run
    end
  end

  context 'repos are full urls' do
    let(:git_repos) { [{ 'https://some-site.com/some-repo.git' => 'some/install/path' }] }

    it 'installs the repo at the given path' do
      run_installer

      url = 'https://some-site.com/some-repo.git'
      full_install_path = File.expand_path('some/install/path')
      expect(/git clone --recursive #{url} "#{full_install_path}"/).to have_been_run
    end
  end

  context 'repo already is installed' do
    let(:install_path) { Pathname.new('spec/sandbox/my-repo').expand_path }
    let(:git_repos) { [{ 'username/repo' => install_path.to_s }] }

    before(:each) { install_path.mkpath }
    after(:each) { FileUtils.rmdir(install_path) }

    it 'updates the repo' do
      run_installer

      update_command = /git pull && git submodule update --init --recursive/
      expect(update_command).to have_been_run.in_dir(install_path)
    end

    context 'there are unstaged changes' do
      it 'does not update the repo' do
        FakeShell.stub(/git status/, with: 'M some_file.rb')

        run_installer

        expect(/git pull/).not_to have_been_run
      end
    end
  end

  def run_installer
    quiet { MacSetup::GitRepoInstaller.run(config, instance_double(MacSetup::SystemStatus)) }
  end
end
