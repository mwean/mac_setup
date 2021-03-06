module MacSetup
  class DefaultsInstaller
    def self.run(config, status)
      defaults_file = File.join(MacSetup.dotfiles_path, "mac_setup/defaults.yml")

      if File.exist?(defaults_file)
        MacSetup.log "Setting defaults..."
        new(defaults_file, config, status).run
      else
        MacSetup.log "No config file at #{MacSetup.shorten_path(defaults_file)}. Skipping..."
      end
    end

    def initialize(defaults_file, config, status)
      @defaults = YAML.load_file(defaults_file)
      @config = config
      @status = status
    end

    def run
      @defaults.each do |domain, values|
        MacSetup.log "Setting defaults for domain #{domain}..."
        set_defaults(domain, values)
      end
    end

    private

    def set_defaults(domain, values)
      values.each do |key, value|
        existing_value = @status.defaults_value(domain, key)

        if values_equal?(existing_value, value)
          MacSetup.log "Value for #{domain} #{key} is already set. Skipping..."
        else
          MacSetup.log "Changing #{existing_value} to #{value}"
          set_value(domain, key, value)
        end
      end
    end

    def values_equal?(existing, desired)
      return if existing.nil?

      case desired
      when Integer
        existing.to_i == desired
      when Float
        existing.to_f == desired
      when Array
        extract_array_values(existing) == desired
      when TrueClass
        existing == "1"
      when FalseClass
        existing == "0"
      when String
        existing == desired
      end
    end

    def set_value(domain, key, value)
      MacSetup.log "Setting #{domain} #{key} to #{value}"
      qualified_value = qualify_value(value)

      sudo = "sudo " if domain.start_with?("/")
      Shell.run(%(#{sudo}defaults write #{domain} "#{key}" #{qualified_value}))
    end

    def extract_array_values(string)
      string.split("\n")[1..-2].map { |line| line.lstrip.gsub(/(^")|(",?$)/, "") }
    end

    def qualify_value(value)
      case value
      when Integer
        "-int #{value}"
      when Float
        "-float #{value}"
      when TrueClass, FalseClass
        "-bool #{value}"
      when Array
        values = value.map { |val| "'#{val}'" }.join(" ")
        "-array #{values}"
      when String
        "-string '#{value}'"
      end
    end
  end
end
