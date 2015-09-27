RSpec::Matchers.define :have_been_run do
  match do |expected|
    FakeShell.called?(expected)
  end

  failure_message do |expected|
    %(expected "#{expected.source}" to have been run)
  end
end
