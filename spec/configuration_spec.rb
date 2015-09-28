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

  describe '#taps' do
    context 'no taps are included' do
      it 'returns an empty array' do
        expect(config.taps).to eq([])
      end

      context 'casks are included' do
        let(:config_hash) { stringify(casks: ['CASK1']) }

        it 'includes the cask tap' do
          expect(config.taps).to eq(['caskroom/cask'])
        end
      end
    end

    context 'taps are included' do
      let(:taps) { %w(TAP1 TAP2) }
      let(:config_hash) { stringify(taps: taps) }

      it 'returns the included taps' do
        expect(config.taps).to eq(taps)
      end

      context 'casks are included' do
        let(:config_hash) { stringify(taps: taps, casks: ['CASK1']) }

        it 'includes the cask tap' do
          expect(config.taps).to include('caskroom/cask')
        end
      end

      context 'taps are listed more than once' do
        let(:taps) { %w(TAP1 TAP1) }

        it 'removes duplicates' do
          expect(config.taps).to eq([taps[0]])
        end
      end
    end
  end

  describe '#formulas' do
    context 'no formulas are included' do
      it 'returns an empty array' do
        expect(config.formulas).to eq([])
      end
    end

    context 'formulas are included' do
      let(:formulas) { %w(FORMULA1 FORMULA2) }
      let(:config_hash) { stringify(formulas: formulas) }

      it 'returns the included formulas' do
        expect(config.formulas).to eq(formulas)
      end

      context 'formulas are listed more than once' do
        let(:formulas) { %w(FORMULA1 FORMULA1) }

        it 'removes duplicates' do
          expect(config.formulas).to eq([formulas[0]])
        end
      end
    end
  end

  describe '#casks' do
    context 'no casks are included' do
      it 'returns an empty array' do
        expect(config.casks).to eq([])
      end
    end

    context 'casks are included' do
      let(:casks) { %w(CASK1 CASK2) }
      let(:config_hash) { stringify(casks: casks) }

      it 'returns the included casks' do
        expect(config.casks).to eq(casks)
      end

      context 'casks are listed more than once' do
        let(:casks) { %w(CASK1 CASK1) }

        it 'removes duplicates' do
          expect(config.casks).to eq([casks[0]])
        end
      end
    end
  end

  describe '#launch_agents' do
    context 'no launch agents are included' do
      it 'returns an empty array' do
        expect(config.launch_agents).to eq([])
      end
    end

    context 'launch agents are included' do
      let(:launch_agents) { %w(AGENT1 AGENT2) }
      let(:config_hash) { stringify(launch_agents: launch_agents) }

      it 'returns the included launch_agents' do
        expect(config.launch_agents).to eq(launch_agents)
      end

      context 'launch_agents are listed more than once' do
        let(:launch_agents) { %w(AGENT1 AGENT1) }

        it 'removes duplicates' do
          expect(config.launch_agents).to eq([launch_agents[0]])
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
end
