$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "mac_setup"

require_relative "support/fake_shell"
require_relative "support/helpers"
require_relative "support/shell_command_matcher"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:each) do
    FakeShell.reset!
    stub_const("MacSetup::Shell", FakeShell)
  end
end
