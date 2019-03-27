require "yaml"
require "set"

module MacSetup
  class Configuration
    InvalidConfigError = Class.new(StandardError)
    DEFAULT_KEYS = [
      :repo, :plugins, :git_repos, :symlinks, :taps, :brews, :fonts, :casks, :quicklook, :mas, :extra_dotfiles
    ].freeze

    def initialize(config_path)
      @config_path = config_path
      load_config
    end

    def require_value(key)
      value = @config.fetch(key.to_s) do
        raise InvalidConfigError, "Missing config value for #{key}!"
      end

      define_singleton_method(key) { value }
      allowed_keys << key.to_sym
    end

    def add(type, value)
      add_method = "add_#{type}"

      if respond_to?(add_method, include_private: true)
        send(add_method, value)
      else
        collection = public_send(type)

        case collection
        when Set
          collection << value.to_s
        when Hash
          collection.merge!(value) do |key, oldval, newval|
            raise InvalidConfigError, "#{key} is defined twice!: #{oldval}, #{newval}"
          end
        end
      end
    end

    def plugins
      @plugins ||= Set.new(@config["plugins"])
    end

    def validate!
      extra_keys = @config.keys.map(&:to_sym) - allowed_keys.to_a

      return if extra_keys.none?

      raise InvalidConfigError, "Extra keys in config: #{extra_keys.join(', ')}"
    end

    def dotfiles_repo
      @config.fetch("repo")
    end

    def extra_dotfiles
      @config.fetch("extra_dotfiles", [])
    end

    def git_repos
      @git_repos ||= @config["git_repos"] || {}
    end

    def symlinks
      @symlinks ||= @config["symlinks"] || {}
    end

    def taps
      @taps ||= (@config["taps"] || []).map { |item| item.split(/\s+/) }.to_set
    end

    def brews
      @brews ||= (@config["brews"] || []).each_with_object({}) do |item, merged|
        add_brews(item, merged)
      end
    end

    def fonts
      @fonts ||= Set.new(@config["fonts"])
    end

    def casks
      @casks ||= Set.new(@config["casks"])
    end

    def quicklook
      @quicklook ||= Set.new(@config["quicklook"])
    end

    def mas
      @mas ||= @config["mas"] || {}
    end

    private

    def add_brews(item, existing_brews = brews)
      existing_brews.merge!(brew_value(item)) do |key, oldval, newval|
        raise InvalidConfigError, "#{key} is defined twice!: #{oldval}, #{newval}" unless oldval == newval

        oldval
      end
    end

    def brew_value(item)
      item.is_a?(Hash) ? item : { item.to_s => {} }
    end

    def allowed_keys
      @allowed_keys ||= Set.new(DEFAULT_KEYS)
    end

    def load_config
      @config = YAML.load_file(@config_path)
    end
  end
end
