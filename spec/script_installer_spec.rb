describe MacSetup::ScriptInstaller do
  let(:scripts) { %w(do_stuff1 do_stuff2) }
  let(:sandbox_path) { Pathname.new("spec/sandbox").expand_path }
  let(:scripts_path) { sandbox_path.join(described_class::SCRIPTS_PATH) }

  before(:each) do
    stub_const("MacSetup::DOTFILES_PATH", sandbox_path)

    scripts_path.mkpath
    scripts.each { |script| FileUtils.touch(scripts_path.join(script)) }
  end

  after(:each) { scripts_path.rmtree }

  it "runs the scripts in the scripts folder" do
    run_installer

    scripts.each do |script|
      expect(scripts_path.join(script).to_s).to have_been_run
    end
  end

  def run_installer
    MacSetup::ScriptInstaller.run(empty_config, instance_double(MacSetup::SystemStatus))
  end
end
