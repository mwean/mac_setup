describe MacSetup::SystemStatus do
  let(:status) { described_class.new }

  describe '#installed_taps' do
    context "no taps are installed" do
      it "returns an empty array" do
        expect(status.installed_taps).to eq([])
      end
    end

    context "taps are installed" do
      before(:each) do
        FakeShell.stub(/brew tap/, with: "TAP1\nTAP2")
      end

      it "gets the installed taps" do
        expect(status.installed_taps).to eq(%w(TAP1 TAP2))
      end
    end
  end
end
