require 'fileutils'

require_relative 'shell'

module MacSetup
  class CommandLineToolsInstaller
    BIN_PATH = '/Library/Developer/CommandLineTools/usr/bin/clang'
    TMP_FILE = '/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress'

    def self.run
      if File.exist?(BIN_PATH)
        puts 'Command Line Tools already installed. Skipping...'
      else
        install_clts
      end
    end

    def self.install_clts
      puts 'Installing Command Line Tools...'
      FileUtils.touch(TMP_FILE)
      Shell.run(%(softwareupdate -i "#{package_name}" -v))
      FileUtils.rm_f(TMP_FILE)
    end

    def self.package_name
      response = Shell.run('softwareupdate -l')
      response.match(/(Command.*$)/)[1]
    end
  end
end
