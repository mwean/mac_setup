describe MacSetup::Configuration do
  let(:config_path) { File.expand_path('spec/support/test_config.yml') }
  let(:config_hash) { {} }
  let(:config) { MacSetup::Configuration.new(config_path) }

  around(:each) do |example|
    File.open(config_path, 'w') { |file| file.write(YAML.dump(config_hash)) }

    begin
      example.run
    ensure
      File.delete(config_path)
    end
  end

  describe '#services' do
    context 'no services are included' do
      it 'returns an empty array' do
        expect(config.services).to eq([])
      end
    end

    context 'services are included' do
      let(:services) { %w(SERVICE1 SERVICE2) }
      let(:config_hash) { stringify(services: services) }

      it 'returns the included services' do
        expect(config.services).to eq(services)
      end

      context 'services are listed more than once' do
        let(:services) { %w(SERVICE1 SERVICE1) }

        it 'removes duplicates' do
          expect(config.services).to eq([services[0]])
        end
      end
    end
  end

  describe '#git_repos' do
    context 'no git_repos are included' do
      it 'returns an empty array' do
        expect(config.git_repos).to eq([])
      end
    end

    context 'git_repos are included' do
      let(:config_hash) { stringify(git_repos: git_repos) }

      let(:git_repos) do
        [
          { 'REPO1' => 'INSTALL_PATH1' },
          { 'REPO2' => 'INSTALL_PATH2' }
        ]
      end

      it 'returns the included git_repos' do
        expect(config.git_repos).to eq(git_repos)
      end

      context 'git_repos are listed more than once' do
        let(:git_repos) do
          [
            { 'REPO1' => 'INSTALL_PATH1' },
            { 'REPO1' => 'INSTALL_PATH1' }
          ]
        end

        it 'removes duplicates' do
          expect(config.git_repos).to eq([git_repos[0]])
        end
      end
    end
  end

  describe '#symlinks' do
    context 'no symlinks are included' do
      it 'returns an empty array' do
        expect(config.symlinks).to eq([])
      end
    end

    context 'symlinks are included' do
      let(:config_hash) { stringify(symlinks: symlinks) }
      let(:symlinks) { %w(symlink1 symlink2) }

      it 'returns the included symlinks' do
        expect(config.symlinks).to eq(symlinks)
      end

      context 'symlinks are listed more than once' do
        let(:symlinks) { %w(symlink1 symlink1) }

        it 'removes duplicates' do
          expect(config.symlinks).to eq([symlinks[0]])
        end
      end
    end
  end
end
