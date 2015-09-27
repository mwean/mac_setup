require 'English'

require_relative 'shell'

module MacSetup
  class FormulaInstaller
    attr_reader :config, :status

    def self.run(config, status)
      new(config, status).run
    end

    def initialize(config, status)
      @config = config
      @status = status
    end

    def run
      formulas = config.formulas
      return if formulas.none?

      puts 'Installing formulas...'

      formulas.each { |formula| install_formula(formula) }
    end

    def install_formula(formula)
      if status.installed_formulas.include?(formula)
        upgrade_formula(formula)
      else
        print "Installing #{formula}..."
        output = Shell.run("brew install #{formula}")

        $CHILD_STATUS.success? ? puts('Ok') : puts("\n#{output}")
      end
    end

    def upgrade_formula(formula)
      if can_upgrade?(formula)
        print "Upgrading #{formula}..."
        output = Shell.run("brew upgrade #{formula}")

        $CHILD_STATUS.success? ? puts('Ok') : puts("\n#{output}")
      else
        puts "Already using latest version of #{formula}..."
      end
    end

    def can_upgrade?(formula)
      status.outdated_formulas.include?(full_name(formula))
    end

    def full_name(formula)
      Shell.run("brew info #{formula}").split("\n")[0].split(':')[0]
    end
  end
end
