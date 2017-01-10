require_relative "shell"

module MacSetup
  class ScriptInstaller
    SCRIPTS_PATH = "mac_setup/scripts"

    def self.run(_config, _status)
      Pathname.new(File.join(DOTFILES_PATH, SCRIPTS_PATH)).each_child do |script|
        MacSetup.log "Running script #{script}..."
        Shell.run(script.to_s)
      end
    end
  end
end
