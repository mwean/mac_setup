require 'ostruct'

module Helpers
  def quiet
    stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout = stdout
  end

  def empty_config
    OpenStruct.new.tap do |config|
      config.taps = []
      config.formulas = []
      config.casks = []
      config.launch_agents = []
    end
  end

  def stringify(hash)
    {}.tap do |result|
      hash.each_key do |key|
        result[key.to_s] = hash[key]
      end
    end
  end
end

RSpec.configure { |config| config.include(Helpers) }
