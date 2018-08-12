require_relative "shell"

module MacSetup
  class GitRepoInstaller
    attr_reader :repo, :install_path, :tracking_key, :status

    def self.run(config, _status)
      repos = config.git_repos
      return if repos.none?

      MacSetup.log "Installing Git Repos..."

      repos.each do |repo_and_path|
        repo, install_path = repo_and_path.to_a.flatten
        new(repo, File.expand_path(install_path)).install_or_update
      end
    end

    def self.install_repo(repo, install_path, track: nil, status: nil)
      new(repo, install_path, tracking_key: track, status: status).install_or_update
    end

    def initialize(repo, install_path, tracking_key: nil, status: nil)
      @repo         = repo
      @install_path = install_path
      @tracking_key = tracking_key
      @status       = status
    end

    def install_or_update
      if Dir.exist?(install_path)
        MacSetup.log("#{repo} Already Installed. Updating") { update }
      else
        MacSetup.log("Installing #{repo}") { install }
      end
    end

    private

    def install
      clone_repo
      track_install
    end

    def update
      in_install_path do
        unless can_update?
          MacSetup.log "Can't update. Unstaged changes in #{install_path}"
          MacSetup.log Shell.result("git status --porcelain")
          return
        end

        Shell.run("git fetch")
        track_update
        Shell.run("git merge origin && git submodule update --init --recursive")
      end
    end

    def clone_repo
      Shell.run(%(git clone --recursive #{repo_url} "#{install_path}"))
    end

    def can_update?
      Shell.result("git status --porcelain").empty?
    end

    def track_install
      return unless tracking_key

      in_install_path do
        status.git_changes(tracking_key, Shell.result("git ls-files").split("\n"))
      end
    end

    def track_update
      return unless tracking_key

      status.git_changes(tracking_key, Shell.result("git diff --name-only origin").split("\n"))
    end

    def in_install_path
      Dir.chdir(install_path) { yield }
    end

    def repo_url
      repo =~ %r{^[^/]+/[^/]+$} ? "https://github.com/#{repo}.git" : repo
    end
  end
end
