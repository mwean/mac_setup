require_relative "shell"

module MacSetup
  class HomebrewInstaller
    BREW_INSTALL_URL = "https://raw.githubusercontent.com/Homebrew/install/master/install"

    def self.run
      if homebrew_missing?
        MacSetup.log "Installing Homebrew" do
          Shell.run(%{/usr/bin/ruby -e "$(curl -fsSL #{BREW_INSTALL_URL})"})
        end
      else
        MacSetup.log "Homebrew already installed. Updating" do
          Shell.run("brew update")
        end
      end
    end

    def self.homebrew_missing?
      Shell.run("which brew").empty?
    end
  end
end
