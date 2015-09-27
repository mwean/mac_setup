require_relative 'shell'

module MacSetup
  class HomebrewInstaller
    BREW_INSTALL_URL = 'https://raw.githubusercontent.com/Homebrew/install/master/install'

    def self.run
      if homebrew_missing?
        puts 'Installing Homebrew...'
        Shell.run("curl -fsS '#{BREW_INSTALL_URL}' | ruby")
      else
        puts 'Homebrew already installed...'
      end

      puts 'Updating Homebrew formulas...'
      Shell.run('brew update')
    end

    def self.homebrew_missing?
      Shell.run('which brew').empty?
    end
  end
end
