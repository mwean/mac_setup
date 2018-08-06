module MacSetup
  module Plugins
    class MacAppStore < MacSetup::Plugin
      attr_reader :config, :status

      def self.add_requirements(config)
        config.add(:brews, :mas)
      end

      def self.get_status(status)

      end

      def self.run(config, status)
        new(config, status).run
      end

      def initialize(config, status)
        @config = config
        @status = status
      end

      def run
        set_up_mas
        install_brewfile
      end

      private

      def set_up_mas
        return unless brewfile.read =~ /^mas /

        install_mas
        sign_in_to_mas
      end

      def install_mas
        MacSetup.log "Installing mas" do
          Shell.run("brew install mas")
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
        Shell.command_present?("mas")
      end

      def bundle_already_tapped?
        status.installed_taps.include?(BUNDLE_TAP)
      end

      def brewfile
        @brewfile ||= Pathname.new("~/.Brewfile").expand_path
      end
    end
  end
end
