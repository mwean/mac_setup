require "ostruct"

module Helpers
  def quiet
    stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout = stdout
  end

  def empty_config
    OpenStruct.new.tap do |config|
      config.plugins = []
      config.casks = []
      config.git_repos = {}
      config.symlinks = {}
      config.brews = []
      config.extra_dotfiles = []
      config.fonts = []
      config.quicklook = []
      config.taps = []
      config.mas = {}
    end
  end

  def stringify(hash)
    {}.tap do |result|
      hash.each_key do |key|
        result[key.to_s] = hash[key]
      end
    end
  end

  def command_matching(str)
    Regexp.new(Regexp.escape(str))
  end
end

RSpec.configure { |config| config.include(Helpers) }
