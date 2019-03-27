require "pathname"
require_relative "shell"

module MacSetup
  class BrewfileInstaller
    BUNDLE_TAP = "homebrew/bundle".freeze

    attr_reader :config, :status

    def self.run(config, status)
      new(config, status).run
    end

    def initialize(config, status)
      @config = config
      @status = status
    end

    def run
      tap_bundle
      set_up_mas
      install_brewfile
    end

    private

    def tap_bundle
      return if bundle_already_tapped?

      Shell.run("brew tap #{BUNDLE_TAP}")
    end

    def set_up_mas
      brewfile = Pathname.new("~/.Brewfile").expand_path
      return unless brewfile.read =~ /^mas /

      install_mas
      sign_in_to_mas
    end

    def install_mas
      if mas_installed?
        MacSetup.log "mas already installed. Skipping."
      else
        MacSetup.log "Installing mas" do
          Shell.run("brew install mas")
        end
      end
    end

    def sign_in_to_mas
      if mas_signed_in?
        MacSetup.log "Already signed into Mac App Store. Skipping."
      else
        apple_id = Shell.ask("What is your Apple ID?")
        Shell.run("mas signin --dialog #{apple_id}")
      end
    end

    def mas_signed_in?
      Shell.success?("mas account")
    end

    def install_brewfile
      MacSetup.log "Installing Brewfile" do
        Shell.run("brew bundle --global")
      end
    end

    def mas_installed?
      Shell.success?("which mas")
    end

    def bundle_already_tapped?
      status.installed_taps.include?(BUNDLE_TAP)
    end
  end
end
