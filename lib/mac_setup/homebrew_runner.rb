require "tempfile"

module MacSetup
  class HomebrewRunner
    def self.run(config, _status)
      MacSetup.log("Installing Homebrew brews and casks") do
        Tempfile.create("Brewfile") do |brewfile|
          write_brewfile(config, brewfile)
          File.chmod(0644, brewfile)
          brewfile.rewind

          Shell.raw("brew bundle install --file=#{brewfile.path}")
        end
      end
    end

    def self.install_brew(formula)
      Shell.run("brew install #{formula}")
    end

    def self.install_cask(cask)
      Shell.run("brew cask install #{cask}")
    end

    def self.write_brewfile(config, brewfile)
      taps = config.taps.map { |parts| %(tap #{quote_args(parts)}) }

      brews = config.brews.map do |name, opts|
        [%(brew "#{name}"), print_args(opts)].compact.join(", ")
      end

      casks = (config.fonts + config.casks + config.quicklook).map do |name|
        %(cask "#{name}")
      end

      brewfile.write((taps + brews + casks).join("\n"))
    end

    def self.print_args(opts)
      args = opts["args"]

      return unless args

      "args: [#{quote_args(args.sort)}]"
    end

    def self.quote_args(args)
      args.map { |arg| %("#{arg}") }.join(", ")
    end
  end
end
