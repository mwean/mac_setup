module MacSetup
  class Shell
    def self.run(command)
      `#{command}`
    end
  end
end
