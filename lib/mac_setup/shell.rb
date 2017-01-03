module MacSetup
  class Shell
    def self.run(command)
      `#{command}`
    end

    def self.ask(question)
      puts question
      gets.strip
    end
  end
end
