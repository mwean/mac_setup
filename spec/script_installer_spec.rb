describe MacSetup::ScriptInstaller do
  let(:config) { empty_config }

  before(:each) { config.scripts = scripts }

  context 'repos are from github' do
    let(:scripts) { %w(do_stuff1 do_stuff2) }

    it 'runs the given scripts' do
      run_installer

      expect(%r{#{MacSetup::DOTFILES_PATH}/mac_setup/scripts/do_stuff1}).to have_been_run
      expect(%r{#{MacSetup::DOTFILES_PATH}/mac_setup/scripts/do_stuff2}).to have_been_run
    end
  end

  def run_installer
    MacSetup::ScriptInstaller.run(config)
  end
end
