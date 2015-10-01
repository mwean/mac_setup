module MacSetup
  class SymlinkInstaller
    def self.run(config)
      install_dotfiles
      install_symlinks(config)
    end

    def self.install_dotfiles
      dotfiles.each do |file_name|
        source = File.expand_path(file_name, DOTFILES_PATH)
        create_link(source, file_name)
      end
    end

    def self.install_symlinks(config)
      config.symlinks.each do |file|
        file_name = File.basename(file)
        source = File.expand_path(file)

        create_link(source, file_name)
      end
    end

    def self.install_dotfile(name)
      dotfile = dotfiles.find { |file| file =~ /#{Regexp.escape(name)}/ }
      source = File.expand_path(dotfile, DOTFILES_PATH)

      create_link(source, dotfile)
    end

    def self.dotfiles
      Dir.entries(DOTFILES_PATH).reject { |entry| entry.start_with?('.') }
    end

    def self.create_link(source, file_name)
      target = File.join(ENV['HOME'], ".#{file_name}")

      if File.exist?(target)
        replace(source, target, name)
      else
        FileUtils.ln_s(source, target)
      end
    end

    def self.replace(source, target, dotfile)
      if File.symlink?(target)
        replace_symlink(source, target, dotfile)
      else
        puts "File already exists at #{target}. Skipping..."
      end
    end

    def self.replace_symlink(source, target, dotfile)
      if File.readlink(target) == source
        puts "#{dotfile} already linked. Skipping..."
      else
        FileUtils.ln_sf(source, target)
      end
    end
  end
end
