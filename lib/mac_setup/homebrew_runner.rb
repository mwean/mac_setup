module MacSetup
  class HomebrewRunner
    def self.run(config, _status)
      brewfile = build_brewfile(config)

      cmd = [
        "echo << EOF | brew bundle install --file=-",
        brewfile,
        "EOF"
      ]

      Shell.run(cmd.join("\n"))
    end

    def self.install_cask(cask)
      Shell.run("brew cask install #{cask}")
    end

    def self.build_brewfile(config)
      brews = config.brews.map do |name, opts|
        [%(brew "#{name}"), print_args(opts)].compact.join(", ")
      end

      casks = (config.fonts + config.casks + config.quicklook).map do |name|
        "cask #{name}"
      end

      (brews + casks).join("\n")
    end

    def self.print_args(opts)
      args = opts["args"]

      return unless args

      args_str = args.sort.map { |arg| %("#{arg}") }.join(", ")
      "args: [#{args_str}]"
    end
  end
end
