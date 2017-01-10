require_relative "shell"

module MacSetup
  class SystemStatus
    def installed_taps
      @installed_taps ||= get_taps
    end

    def installed_formulas
      @installed_formulas ||= get_formulas
    end

    private

    def get_taps
      Shell.run("brew tap").split("\n")
    end

    def get_formulas
      Shell.run("brew list -1").split("\n")
    end
  end
end
