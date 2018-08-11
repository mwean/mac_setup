require "fileutils"

module MacSetup
  class Symlink
    def initialize(options)
      @source_path = options[:source_path]
      @file_name = options[:name]
      @target_path = sanitize_target(options[:target_path])
    end

    def link
      return if Secrets.encrypted?(source_path)

      short_source_path = MacSetup.shorten_path(source_path)
      short_target_path = MacSetup.shorten_path(target_path)
      MacSetup.log "Linking #{short_source_path} to #{short_target_path}..."

      return unless source_exists

      target_exists? ? replace : FileUtils.ln_s(source_path, target_path)
    end

    private

    def source_exists
      File.exist?(source_path).tap do |exists|
        unless exists
          short_source_path = MacSetup.shorten_path(source_path)
          MacSetup.log "WARNING: Source doesn’t exist at #{short_source_path}. Skipping."
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
      install_symlinks(config)
    end

    def self.install_symlinks(config)
      config.symlinks.each do |source_path, target_path|
        # source = Symlink.new(source_path: File.expand_path(source_path))
        # source.link
        source = Pathname.new(source_path).expand_path
        short_source_path = MacSetup.shorten_path(source.to_s)

        unless source.exist?
          MacSetup.log "#{short_source_path} doesn't exist. Skipping."
          next
        end

        target = Pathname.new(target_path).expand_path
        short_target_path = MacSetup.shorten_path(target.to_s)

        MacSetup.log "Linking #{short_source_path} to #{short_target_path}..."

        home = Pathname.new(ENV.fetch("HOME"))

        if target.directory?
          filename = target == home ? ".#{source.basename}" : source.basename
          full_target = target.join(filename)
          link(source, full_target)
        elsif target.to_s.end_with?("/")
          target.mkpath
          full_target = target.join(source.basename)
          link(source, full_target)
        else
          target.dirname.mkpath
          link(source, target)
        end
      end
    end

    def self.link(source, target)
      if File.exist?(target)
        if File.symlink?(target)
          existing_link = File.readlink(target)

          if existing_link == source.to_s
            MacSetup.log "Already linked. Skipping."
          else
            print "Replacing existing symlink at #{MacSetup.shorten_path(target)}. "
            puts "Originally linked to #{MacSetup.shorten_path(existing_link)}..."
            FileUtils.ln_sf(source, target)
          end
        else
          MacSetup.log "WARNING: File already exists at #{MacSetup.shorten_path(target)}. Skipping."
        end
      else
        FileUtils.ln_s(source, target)
      end
    end
  end
end
