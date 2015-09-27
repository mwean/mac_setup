require 'English'

require_relative 'shell'

module MacSetup
  class TapInstaller
    def self.run(config, status)
      return if config.taps.none?

      puts 'Installing taps...'

      uninstalled_taps = config.taps - status.installed_taps

      if uninstalled_taps.none?
        puts 'No uninstalled taps'
      else
        uninstalled_taps.each { |tap| install_tap(tap) }
      end
    end

    def self.install_tap(tap)
      print "Installing #{tap}..."
      output = Shell.run("brew tap #{tap}")

      $CHILD_STATUS.success? ? puts('Ok') : puts("\n#{output}")
    end
  end
end
