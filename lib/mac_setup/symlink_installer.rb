module MacSetup
  class Symlink
    def initialize(options)
      @source_path = options[:source_path]
      @file_name = options[:name]
      @target_path = options[:target_path]
    end

    def link
      puts "Linking #{shorten_path(source_path)} to #{shorten_path(target_path)}..."

      return unless source_exists

      target_exists? ? replace : FileUtils.ln_s(source_path, target_path)
    end

    private

    def source_exists
      File.exist?(source_path).tap do |exists|
        unless exists
          puts "WARNING: Source doesn’t exist at #{shorten_path(source_path)}. Skipping..."
        end
      end
    end

    def target_exists?
      File.exist?(target_path)
    end

    def target
      @target ||= SymlinkTarget.new(target_path)
    end

    def source_path
      @source_path ||= File.expand_path(file_name, DOTFILES_PATH)
    end

    def target_path
      @target_path ||= File.join(ENV['HOME'], ".#{file_name}")
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
        puts "WARNING: File already exists at #{shorten_path(target_path)}. Skipping..."
      end
    end

    def link_children
      puts "Linking children..."

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
        puts "Already linked. Skipping..."
      else
        print "Replacing existing symlink at #{shorten_path(target_path)}. "
        puts "Originally linked to #{shorten_path(existing_link)}..."
        FileUtils.ln_sf(source_path, target_path)
      end
    end

    def shorten_path(path)
      path.sub(/#{ENV['HOME']}/, '~')
    end

    def children
      Dir.entries(source_path).reject { |entry| entry.start_with?('.') }
    end
  end

  class SymlinkInstaller
    def self.run(config)
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
        file_name = File.basename(source_path)

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
      Dir.entries(DOTFILES_PATH).reject { |entry| entry.start_with?('.') }
    end
  end
end
