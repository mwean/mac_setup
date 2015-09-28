RSpec::Matchers.define :have_been_run do
  match do |expected|
    FakeShell.called?(expected) && correct_path?(FakeShell.pwd(expected))
  end

  failure_message do |expected|
    %(expected "#{expected.source}" to have been run)
  end

  chain :in_dir do |path|
    @expected_pwd = path.to_s
  end

  def correct_path?(actual_pwd)
    @expected_pwd.nil? || @expected_pwd == actual_pwd
  end
end
