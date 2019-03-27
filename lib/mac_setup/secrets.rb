module MacSetup
  class Secrets
    CRYPTO_LIB = "openssl".freeze
    CIPHER = "aes-256-cbc".freeze
    PLAINTEXT_EXT = "priv".freeze
    CIPHERTEXT_EXT = "crypt".freeze

    attr_reader :files, :password

    def self.encrypt(dir_or_files)
      new(filter_files(dir_or_files, PLAINTEXT_EXT)).encrypt
    end

    def self.decrypt(dir_or_files)
      new(filter_files(dir_or_files, CIPHERTEXT_EXT)).decrypt
    end

    def self.encrypted?(file)
      file.to_s.end_with?(CIPHERTEXT_EXT)
    end

    def self.strip_extension(file)
      return file unless file.to_s.end_with?(PLAINTEXT_EXT)

      file.sub(/\.#{PLAINTEXT_EXT}$/, "")
    end

    def self.filter_files(dir_or_files, extension)
      if dir_or_files.is_a?(Array)
        dir_or_files.select { |file| file.to_s.end_with?(extension) }
      else
        Dir.glob("#{File.expand_path(dir_or_files)}/**/*.#{extension}")
      end
    end

    def initialize(files)
      @files = files
    end

    def encrypt
      do_crypt("encrypt") { encrypt_files }
    end

    def decrypt
      if files.any?
        MacSetup.log "Decrypting files:"
      else
        MacSetup.log "No files to decrypt. Skipping"
      end

      list_files
      get_password
      decrypt_files
    end

    private

    def do_crypt(type)
      if files.any?
        MacSetup.log "#{titleized(type)}ing files:"
        list_files
        get_password
        yield
      else
        MacSetup.log "No files to #{type}. Skipping"
      end
    end

    def titleized(str)
      char, rest = str.split("", 2)
      char.upcase + rest
    end

    def list_files
      files.each { |file| puts "  #{MacSetup.shorten_path(file)}" }
    end

    def get_password
      @password = Shell.password
    end

    def encrypt_files
      files.each do |file|
        target_path = file.sub(/#{PLAINTEXT_EXT}$/, CIPHERTEXT_EXT)
        do_encrypt(file, target_path)
      end
    end

    def decrypt_files
      if password_correct?
        do_decrypt
      else
        puts "Wrong Password!"
        get_password
        decrypt_files
      end
    end

    def password_correct?
      Shell.success?(decrypt_command(files.first, files.first.sub(/#{CIPHERTEXT_EXT}$/, PLAINTEXT_EXT)))
    end

    def do_decrypt
      files.each { |file| decrypt_file(file) }
    end

    def decrypt_file(file, log: true)
      target_path = file.sub(/#{CIPHERTEXT_EXT}$/, PLAINTEXT_EXT)
      command = -> { Shell.run(decrypt_command(file, target_path)) }

      if log
        MacSetup.log "Decrypting #{raw_file_path(file)}", &command
      else
        command.call
      end
    end

    def do_encrypt(file, target_path)
      MacSetup.log "Encrypting #{raw_file_path(file)}" do
        Shell.run(encrypt_command(file, target_path))
      end
    end

    def encrypt_command(file, target_path)
      %W[openssl enc -aes-256-cbc -k testme -in #{file} -out #{target_path}]
    end

    def decrypt_command(file, target_path)
      %W[openssl enc -aes-256-cbc -k testme -d -in #{file} -out #{target_path}]
    end

    def base_command(password)
      %W[#{CRYPTO_LIB} enc -#{CIPHER} -k #{password}]
    end

    def raw_file_path(file)
      raw_file = file.sub(/\.#{CIPHERTEXT_EXT}|#{PLAINTEXT_EXT}$/, "")
      MacSetup.shorten_path(raw_file)
    end
  end
end
