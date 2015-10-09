describe MacSetup::FormulaInstaller do
  let(:config) { empty_config }
  let(:status) { instance_double(MacSetup::SystemStatus, installed_formulas: []) }

  before(:each) { config.formulas = formulas }

  context 'no formulas are specified' do
    let(:formulas) { [] }

    it "doesn't try to install anything" do
      run_installer

      expect(/brew install/).not_to have_been_run
    end
  end

  context 'formulas are specified' do
    let(:formulas) { %w(FORMULA1 FORMULA2) }
    let(:status) { instance_double(MacSetup::SystemStatus, installed_formulas: []) }

    it 'installs the given formulas' do
      run_installer

      formulas.each do |formula|
        expect(/brew install #{formula}/).to have_been_run
      end
    end

    context 'formulas are already installed' do
      let(:installed) { formulas }

      let(:status) do
        instance_double(
          MacSetup::SystemStatus,
          installed_formulas: installed,
          outdated_formulas: outdated
        )
      end

      before(:each) do
        FakeShell.stub(/brew info/) do |command|
          formula_name = command.split(' ')[-1]
          "#{formula_name}: version 1.2.3"
        end
      end

      context 'installed formula can be upgraded' do
        let(:long_formula_name) { 'tap/tap/FORMULA2' }
        let(:outdated) { [formulas[0], long_formula_name] }

        it 'upgrades the formula' do
          run_installer

          expect(/brew upgrade #{formulas[0]}/).to have_been_run
        end

        it 'expands the formula names given' do
          response = "#{long_formula_name}: version 1.2.3"
          FakeShell.stub(/brew info #{formulas[1]}/, with: response)

          run_installer

          expect(/brew upgrade #{formulas[1]}/).to have_been_run
        end
      end

      context 'installed formula cannot be upgraded' do
        let(:outdated) { [] }

        it 'does not try to upgrade those formulas' do
          run_installer

          formulas.each do |formula|
            expect(/brew upgrade #{formula}/).not_to have_been_run
          end
        end
      end

      context 'with long formula names' do
        let(:formulas) { ['caskroom/cask/brew-cask'] }
        let(:installed) { ['brew-cask'] }
        let(:outdated) { [] }

        it 'correctly matches against installed formulas' do
          run_installer

          expect(/brew install #{formulas[0]}/).not_to have_been_run
        end
      end
    end
  end

  def run_installer
    quiet { MacSetup::FormulaInstaller.run(config, status) }
  end
end
