require "fileutils"

require_relative "shell"

module MacSetup
  class ServicesInstaller
    LAUNCH_AGENTS_PATH = File.expand_path("~/Library/LaunchAgents")
    SERVICES_TAP = "homebrew/services"

    attr_reader :config, :status, :services, :running_services

    def self.run(config, status)
      new(config, status).run
    end

    def initialize(config, status)
      @config = config
      @status = status
      @services = config.services
    end

    def run
      return if services.none?

      puts "Installing services..."

      FileUtils.mkdir_p(LAUNCH_AGENTS_PATH)
      tap_services
      get_running_services

      services.each { |service| install_service(service) }
    end

    private

    def get_running_services
      services_list = Shell.run("brew services list").split("\n").drop(1)
      services_with_status = services_list.map { |line| line.split(/\s+/, 3).take(2) }

      @running_services = services_with_status.each_with_object([]) do |(service, status), services|
        services << service if status == "started"
      end
    end

    def install_service(service)
      if running_services.include?(service)
        puts "Restarting #{service} service..."

        Shell.run("brew services restart #{service}")
      else
        puts "Installing #{service} service..."

        Shell.run("brew services start #{service}")
      end
    end

    def tap_services
      return if services_already_tapped?

      Shell.run("brew tap #{SERVICES_TAP}")
    end

    def services_already_tapped?
      status.installed_taps.include?(SERVICES_TAP)
    end
  end
end
