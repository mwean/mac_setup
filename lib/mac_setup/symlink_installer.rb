module MacSetup
  class Symlink
    def initialize(options)
      @source_path = options[:source_path]
      @file_name = options[:name]
      @target_path = sanitize_target(options[:target_path])
    end

    def link
      return if Secrets.encrypted?(source_path)

      short_sorce_path = MacSetup.shorten_path(source_path)
      short_target_path = MacSetup.shorten_path(target_path)
      MacSetup.log "Linking #{short_sorce_path} to #{short_target_path}..."

      return unless source_exists

      target_exists? ? replace : FileUtils.ln_s(source_path, target_path)
    end

    private

    def source_exists
      File.exist?(source_path).tap do |exists|
        unless exists
          short_sorce_path = MacSetup.shorten_path(source_path)
          MacSetup.log "WARNING: Source doesn’t exist at #{short_sorce_path}. Skipping."
        end
      end
    end

    def target_exists?
      File.exist?(target_path)
    end

    def source_path
      @source_path ||= File.expand_path(file_name, DOTFILES_PATH)
    end

    def target_path
      @target_path ||= File.join(ENV["HOME"], ".#{sanitize_target(file_name)}")
    end

    def file_name
      @file_name ||= File.basename(source_path)
    end

    def replace
      if File.symlink?(target_path)
        replace_symlink
      elsif File.directory?(source_path)
        link_children
      else
        MacSetup.log "WARNING: File already exists at #{MacSetup.shorten_path(target_path)}. Skipping."
      end
    end

    def link_children
      MacSetup.log "Linking children..."

      children.each do |child|
        child_source = Symlink.new(
          source_path: File.join(source_path, child),
          target_path: File.join(target_path, child)
        )

        child_source.link
      end
    end

    def replace_symlink
      existing_link = File.readlink(target_path)

      if existing_link == source_path
        MacSetup.log "Already linked. Skipping."
      else
        print "Replacing existing symlink at #{MacSetup.shorten_path(target_path)}. "
        puts "Originally linked to #{MacSetup.shorten_path(existing_link)}..."
        FileUtils.ln_sf(source_path, target_path)
      end
    end

    def children
      Dir.entries(source_path).reject { |entry| entry.start_with?(".") }
    end

    def sanitize_target(file)
      Secrets.strip_extension(file)
    end
  end

  class SymlinkInstaller
    def self.run(config, _status)
      install_dotfiles
      install_symlinks(config)
    end

    def self.install_dotfiles
      dotfiles.each do |file_name|
        source = Symlink.new(name: file_name)
        source.link
      end
    end

    def self.install_symlinks(config)
      config.symlinks.each do |source_path|
        source = Symlink.new(source_path: File.expand_path(source_path))
        source.link
      end
    end

    def self.install_dotfile(name)
      dotfile = dotfiles.find { |file| file =~ /#{Regexp.escape(name)}/ }
      source = Symlink.new(name: dotfile)

      source.link
    end

    def self.dotfiles
      Dir.entries(DOTFILES_PATH).reject { |entry| entry.start_with?(".") }
    end
  end
end
