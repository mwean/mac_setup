require_relative "shell"

module MacSetup
  class GitRepoInstaller
    def self.run(config, _status)
      repos = config.git_repos
      return if repos.none?

      puts "Installing Git Repos..."

      repos.each do |repo_and_path|
        repo, install_path = repo_and_path.to_a.flatten
        install_repo(repo, File.expand_path(install_path))
      end
    end

    def self.install_repo(repo, install_path)
      if Dir.exist?(install_path)
        print "#{repo} Already Installed. Updating..."
        update_repo(install_path)
      else
        print "Installing #{repo}..."
        url = expand_url(repo)
        Shell.run(%(git clone --recursive #{url} "#{install_path}"))
        puts "Ok"
      end
    end

    def self.update_repo(install_path)
      Dir.chdir(install_path) do
        if can_update?
          Shell.run("git pull && git submodule update --init --recursive")
          puts "Ok"
        else
          puts "\nCan't update. Unstaged changes in #{install_path}"
        end
      end
    end

    def self.can_update?
      Shell.run("git status --porcelain").empty?
    end

    def self.expand_url(repo)
      repo =~ %r{^[^/]+/[^/]+$} ? "https://github.com/#{repo}.git" : repo
    end
  end
end
