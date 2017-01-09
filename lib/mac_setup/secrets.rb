module MacSetup
  class Secrets
    CIPHER = "aes-256-cbc"
    PLAINTEXT_EXT = "priv"
    CIPHERTEXT_EXT = "crypt"

    attr_reader :dir

    def self.encrypt(dir)
      new(dir).encrypt
    end

    def self.decrypt(dir)
      new(dir).decrypt
    end

    def self.encrypted?(file)
      file.to_s.end_with?(CIPHERTEXT_EXT)
    end

    def self.strip_extension(file)
      return file unless file.to_s.end_with?(PLAINTEXT_EXT)

      file.sub(/#{PLAINTEXT_EXT}$/, "")
    end

    def initialize(dir)
      @dir = File.expand_path(dir)
    end

    def encrypt
      puts "Encrypting files:"
      files = Dir.glob("#{dir}/**/*.#{PLAINTEXT_EXT}")
      do_crypt(files, from: PLAINTEXT_EXT, to: CIPHERTEXT_EXT, overwrite: true)
    end

    def decrypt
      puts "Decrypting files:"
      files = Dir.glob("#{dir}/**/*.#{CIPHERTEXT_EXT}")

      do_crypt(files, from: CIPHERTEXT_EXT, to: PLAINTEXT_EXT, args: "-d") do |command|
        unless Shell.success?(command + %W(-in #{files.first}))
          puts "Wrong password!"
          exit 1
        end
      end
    end

    private

    def do_crypt(files, options)
      old_ext = options.fetch(:from)
      new_ext = options.fetch(:to)
      overwrite = options.fetch(:overwrite, false)
      args = Array(options.fetch(:args, []))

      files.each { |file| puts " - #{file}" }
      command = base_command(Shell.password) + args

      yield command if block_given?

      files.each do |file|
        target_path = file.sub(/#{old_ext}$/, new_ext)
        next if !overwrite && File.exist?(target_path)
        Shell.run(command + %W(-in #{file} -out #{target_path}))
      end
    end

    def base_command(password)
      %W(openssl enc -#{CIPHER} -k #{password})
    end
  end
end
