require_relative 'shell'

module MacSetup
  class CaskInstaller
    def self.run(config, status)
      casks = config.casks
      return if casks.none?

      puts 'Installing casks...'

      uninstalled_casks = casks - status.installed_casks

      uninstalled_casks.each do |cask|
        print "Installing #{cask}..."
        Shell.run("brew cask install #{cask}")
        puts('Ok')
      end
    end
  end
end
