module MacSetup
  class SymlinkPathBuilder
    HOME = (ENV.fetch("HOME") + "/").freeze

    class << self
      def paths_for(root_dir)
        root = Pathname.new(root_dir)

        each_child(root) do |child|
          yield [child.to_s, rewrite_path(child, root)]
        end
      end

      private

      def each_child(dir, &block)
        dir.children.each do |child|
          next if child.basename.to_s.start_with?(".")

          if child.directory?
            each_child(child, &block)
          else
            yield(child)
          end
        end
      end

      def rewrite_path(path, base)
        first_part, rest = path.to_s.split(%r{^#{Regexp.escape(base.to_s)}/([^/]+)}).drop(1)
        parts = Dir.exist?(HOME + first_part) ? [HOME, first_part, rest] : [HOME, ".", first_part, rest]
        parts.join
      end
    end
  end
end
