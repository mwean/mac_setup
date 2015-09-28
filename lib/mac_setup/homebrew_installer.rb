require_relative 'shell'

module MacSetup
  class HomebrewInstaller
    BREW_INSTALL_URL = 'https://raw.githubusercontent.com/Homebrew/install/master/install'

    def self.run(options = [])
      if homebrew_missing?
        puts 'Installing Homebrew...'
        Shell.run("curl -fsS '#{BREW_INSTALL_URL}' | ruby")
      else
        puts 'Homebrew already installed...'
      end

      update_homebrew(options)
    end

    def self.homebrew_missing?
      Shell.run('which brew').empty?
    end

    def self.update_homebrew(options)
      if options.include?('--skip-brew-update')
        puts 'Skipping Homebrew Update...'
      else
        puts 'Updating Homebrew...'
        Shell.run('brew update')
      end
    end
  end
end
