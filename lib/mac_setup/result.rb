module MacSetup
  class Result
    def initialize(stdout, stderr, status)
      @stdout = stdout
      @stderr = stderr
      @status = status
    end

    def success?
      @status.success?
    end

    def output
      [@stderr, @stdout].join("\n").strip
    end
  end
end
