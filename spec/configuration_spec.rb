describe MacSetup::Configuration do
  let(:config_path) { File.expand_path("spec/support/test_config.yml") }
  let(:config_hash) { {} }
  let(:config) { described_class.new(config_path) }

  around do |example|
    File.open(config_path, "w") { |file| file.write(YAML.dump(config_hash)) }

    begin
      example.run
    ensure
      File.delete(config_path)
    end
  end

  describe "#git_repos" do
    context "no git_repos are included" do
      it "returns an empty hash" do
        expect(config.git_repos).to eq({})
      end
    end

    context "git_repos are included" do
      let(:config_hash) { stringify(git_repos: git_repos) }

      let(:git_repos) do
        {
          "REPO1" => "INSTALL_PATH1",
          "REPO2" => "INSTALL_PATH2"
        }
      end

      it "returns the included git_repos" do
        expect(config.git_repos).to eq(git_repos)
      end
    end
  end

  describe "#symlinks" do
    context "no symlinks are included" do
      it "returns an empty array" do
        expect(config.symlinks).to eq({})
      end
    end

    context "symlinks are included" do
      let(:config_hash) { stringify(symlinks: symlinks) }

      let(:symlinks) do
        {
          "symlink1" => "~/",
          "symlink2" => "~/"
        }
      end

      it "returns the included symlinks" do
        expect(config.symlinks).to eq(symlinks)
      end
    end
  end
end
