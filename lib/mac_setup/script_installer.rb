require_relative 'shell'

module MacSetup
  class ScriptInstaller
    def self.run(config)
      config.scripts.each do |script|
        full_path = File.join(DOTFILES_PATH, 'mac_setup/scripts', script)
        Shell.run(full_path)
      end
    end
  end
end
