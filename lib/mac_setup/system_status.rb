require_relative "shell"

module MacSetup
  class SystemStatus
    def installed_taps
      @installed_taps ||= get_taps
    end

    private

    def get_taps
      Shell.run("brew tap").split("\n")
    end
  end
end
