module MacSetup
  module Plugins
    class Asdf < MacSetup::Plugin
      TOOL_VERSIONS_FILE = Pathname.new("~/.tool-versions").expand_path

      class << self
        def add_requirements(config)
          config.require_value(:asdf)
          config.add(:brews, :asdf)
        end

        def run(config, _status)
          install_missing_plugins(config)
          install_missing_versions
        end

        private

        def install_missing_plugins(config)
          (config.asdf - installed_plugins).each do |plugin|
            Shell.run("asdf", "plugin-add", plugin)
          end
        end

        def install_missing_versions
          tool_versions = TOOL_VERSIONS_FILE.read.split("\n")

          tool_versions.each do |line|
            plugin, version = line.split(" ")

            Shell.run("asdf", "install", plugin, version)
          end
        end

        def installed_plugins
          @installed_plugins ||= Shell.result("asdf", "plugin-list").split("\n")
        end
      end
    end
  end
end
