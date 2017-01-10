require_relative "shell"

module MacSetup
  class GitRepoInstaller
    def self.run(config, _status)
      repos = config.git_repos
      return if repos.none?

      MacSetup.log "Installing Git Repos..."

      repos.each do |repo_and_path|
        repo, install_path = repo_and_path.to_a.flatten
        install_repo(repo, File.expand_path(install_path))
      end
    end

    def self.install_repo(repo, install_path)
      if Dir.exist?(install_path)
        MacSetup.log "#{repo} Already Installed. Updating" do
          update_repo(install_path)
        end
      else
        MacSetup.log "Installing #{repo}" do
          url = expand_url(repo)
          Shell.run(%(git clone --recursive #{url} "#{install_path}"))
        end
      end
    end

    def self.update_repo(install_path)
      Dir.chdir(install_path) do
        if can_update?
          Shell.run("git pull && git submodule update --init --recursive")
        else
          puts "\nCan't update. Unstaged changes in #{install_path}"
          exit 1
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
