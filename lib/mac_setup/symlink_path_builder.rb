module MacSetup
  class SymlinkPathBuilder
    HOME = ENV.fetch("HOME").freeze

    class << self
      def paths_for(root_dir)
        root = Pathname.new(root_dir)

        each_child(root) do |child|
          yield [relative_path(child, HOME), relative_path(child, root, "~/.")]
        end
      end

      private

      def each_child(dir, &block)
        dir.children.each do |child|
          next if child.basename.to_s.start_with?(".")

          if child.directory?
            each_child(child, &block)
          else
            block.call(child)
          end
        end
      end

      def relative_path(path, base, replacement = "~/")
        path.to_s.sub(%r{^#{base}\/}, replacement)
      end
    end
  end
end
