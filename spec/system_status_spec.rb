describe MacSetup::SystemStatus do
  let(:status) { MacSetup::SystemStatus.new }

  describe '#installed_formulas' do
    context 'no formulas are installed' do
      it 'returns an empty array' do
        expect(status.installed_formulas).to eq([])
      end
    end

    context 'formulas are installed' do
      before(:each) do
        FakeShell.stub(/brew list/, with: "FORMULA1\nFORMULA2")
      end

      it 'gets the installed formulas' do
        expect(status.installed_formulas).to eq(%w(FORMULA1 FORMULA2))
      end
    end
  end

  describe '#outdated_formulas' do
    context 'no formulas are outdated' do
      it 'returns an empty array' do
        expect(status.outdated_formulas).to eq([])
      end
    end

    context 'formulas are outdated' do
      before(:each) do
        FakeShell.stub(/brew outdated/, with: "FORMULA1\nFORMULA2")
      end

      it 'gets the outdated formulas' do
        expect(status.outdated_formulas).to eq(%w(FORMULA1 FORMULA2))
      end
    end
  end

  describe '#installed_taps' do
    context 'no taps are installed' do
      it 'returns an empty array' do
        expect(status.installed_taps).to eq([])
      end
    end

    context 'taps are installed' do
      before(:each) do
        FakeShell.stub(/brew tap/, with: "TAP1\nTAP2")
      end

      it 'gets the installed taps' do
        expect(status.installed_taps).to eq(%w(TAP1 TAP2))
      end
    end
  end

  describe '#installed_casks' do
    context 'no casks are installed' do
      it 'returns an empty array' do
        expect(status.installed_casks).to eq([])
      end
    end

    context 'casks are installed' do
      before(:each) do
        FakeShell.stub(/brew cask list -1/, with: "CASK1\nCASK2")
      end

      it 'gets the installed casks' do
        expect(status.installed_casks).to eq(%w(CASK1 CASK2))
      end
    end
  end

  describe '#loaded_agents' do
    context 'no agents are loaded' do
      it 'returns an empty array' do
        expect(status.loaded_agents).to eq([])
      end
    end

    context 'agents are loaded' do
      before(:each) do
        response = "901 0 homebrew.mxcl.elasticsearch\n911 0 homebrew.mxcl.postgresql"
        FakeShell.stub(/launchctl list/, with: response)
      end

      it 'gets the loaded agents' do
        expect(status.loaded_agents).to eq(%w(homebrew.mxcl.elasticsearch homebrew.mxcl.postgresql))
      end
    end
  end
end
