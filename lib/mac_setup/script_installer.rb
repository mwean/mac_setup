require_relative 'shell'

module MacSetup
  class ScriptInstaller
    SCRIPTS_PATH = "mac_setup/scripts"

    def self.run(config, _status)
      Pathname.new(File.join(DOTFILES_PATH, SCRIPTS_PATH)).each_child do |script|
        Shell.run(script.to_s)
      end
    end
  end
end
