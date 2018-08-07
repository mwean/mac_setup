module MacSetup
  module Plugins
    class MacAppStore < MacSetup::Plugin
      class << self
        def bootstrap(config)
          add_requirements(config)
          install
          log_in
        end

        def add_requirements(config)
          config.add(:brews, :mas)
        end

        def run(config, _status)
          log_in

          config.mas.each do |_name, id|
            Shell.run("mas install #{id}")
          end
        end

        private

        def install
          MacSetup.log "Installing mas" do
            HomebrewRunner.install_brew(:mas)
          end
        end

        def log_in
          if mas_signed_in?
            MacSetup.log "Already signed into Mac App Store. Skipping."
          else
            apple_id = Shell.ask("What is your Apple ID?")
            Shell.run("mas signin #{apple_id}")
          end
        end

        def mas_signed_in?
          Shell.success?("mas account")
        end
      end
    end
  end
end
