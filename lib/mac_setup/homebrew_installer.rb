require_relative 'shell'

module MacSetup
  class HomebrewInstaller
    BREW_INSTALL_URL = 'https://raw.githubusercontent.com/Homebrew/install/master/install'

    def self.run
      if homebrew_missing?
        puts 'Installing Homebrew...'
        Shell.run(%{/usr/bin/ruby -e "$(curl -fsSL #{BREW_INSTALL_URL})"})
      else
        puts 'Homebrew already installed. Updating...'

        Shell.run('brew update')
      end
    end

    def self.homebrew_missing?
      Shell.run('which brew').empty?
    end
  end
end
