class FakeShell
  def self.stub(pattern, options = {}, &block)
    if block_given?
      return_val = block
    else
      return_val = options[:with] || ''
    end

    @stubs.unshift(pattern: pattern, return_val: return_val)
  end

  def self.run(command)
    matching_stub = @stubs.find { |stub| command =~ stub[:pattern] }
    @calls << { command: command, pwd: Dir.pwd }

    return_value(matching_stub, command)
  end

  def self.called?(pattern)
    @calls.any? { |call| call[:command] =~ pattern }
  end

  def self.reset!
    @stubs = []
    @calls = []
  end

  def self.return_value(matching_stub, command)
    return '' unless matching_stub

    return_val = matching_stub[:return_val]
    return_val.respond_to?(:call) ? return_val.call(command) : return_val.to_s
  end

  def self.pwd(pattern)
    @calls.find { |call| call[:command] =~ pattern }[:pwd]
  end
end
