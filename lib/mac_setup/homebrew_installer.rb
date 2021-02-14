require_relative "shell"

module MacSetup
  class HomebrewInstaller
    BREW_INSTALL_URL = "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh".freeze

    def self.run
      if Shell.command_present?("brew")
        MacSetup.log "Homebrew already installed. Skipping..."
      else
        MacSetup.log "Installing Homebrew" do
          Shell.raw(%{/bin/bash -c "$(curl -fsSL #{BREW_INSTALL_URL})"})
        end
      end
    end
  end
end
