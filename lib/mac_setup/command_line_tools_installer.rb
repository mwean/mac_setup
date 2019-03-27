require_relative "shell"

module MacSetup
  class CommandLineToolsInstaller
    BIN_PATH = "/Library/Developer/CommandLineTools/usr/bin/clang".freeze

    def self.run
      if File.exist?(BIN_PATH)
        puts "Command Line Tools already installed. Skipping..."
      else
        Shell.run("xcode-select --install")
      end
    end
  end
end
