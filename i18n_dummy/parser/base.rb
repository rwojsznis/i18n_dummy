module I18nDummy
  module Parser
    class Base
      include ::I18nDummy::Common
      attr_accessor :parsed, :current_line, :file, :key_stack

      def initialize(file)
        start         = Time.now
        @parsed       = []
        @current_line = 0
        @file         = path_name(file)
        @key_stack    = Set.new
        content       = File.read(file)

        psych_check(content)
        parse(content)

        debug_speed "I18nDummy::Parser::Base.initialize", start
      end

      def find_by_path(path)
        index = full_paths.key(path)
        parsed[index] if index
      end

      def head
        parsed.first
      end

      def without_head
        parsed.drop(1)
      end

      def country_code
        head.key
      end

      def output
        @output ||= parsed.map do |node|
          node.to_s
        end.join("\n") + "\n"
      end

      def html_output(base = nil)
        start = Time.now

        @html_output ||= parsed.map do |node|
          node.to_html(file, base)
        end.join

        debug_speed "I18nDummy::Parser::Base.html_output", start

        @html_output
      end

      def validate!
        psych_check(output)
      end

      def save!(backup = false)
        FileUtils.cp file,("#{file}.bak") if backup
        File.open(file, 'w') { |f| f.write(output) }
      end

      def inspect
        parsed.each { |p| puts p.inspect }
      end

      # it's not pretty but it's faster than original approach
      def full_paths
        @full_paths ||= Hash[without_head.map.each_with_index do |p, i|
          [i+1, p.full_path]
        end]
      end

      def updated_nodes
        parsed.select { |p| p.updated? }
      end

      private

      def psych_check(content)
        Psych.load(content)
        rescue Psych::SyntaxError => e
          raise I18nDummy::Error.new("[#{file}] Invalid syntax according to Psych: #{e.message}")
      end

      def parse(content)
        key_path      = []
        value_stack   = []
        previous_node = nil

        content.split("\n").each do |line|
          @current_line += 1

          if is_key_value?(line, previous_node)
            previous_node.multiline!
            value_stack << line
          else
            if previous_node && previous_node.multiline? # multiline node just ended
              previous_node.set_value(value_stack)
              value_stack = []
            end
              node = push!(line, key_path)

              if previous_node
                if node.depth > previous_node.depth     # current node is nested in previous one
                  key_path.push(previous_node.key)      # add key from previous node to stack
                  node.add_to_path!(previous_node.key)  # push key from 'above' to current node
                elsif node.depth < previous_node.depth  # level of nesting decreased
                  (previous_node.depth - node.depth).times do
                    node.pop_path
                    key_path.pop
                  end
                end
              end

              path_check(node.full_path)
              previous_node = node
          end
        end

        if previous_node && previous_node.multiline? # additional cleanup
          previous_node.set_value(value_stack)
        end

        compact!
      end

      def compact!
        i = 0
        while i < parsed.size
          # leaf without value
          if parsed[i].value.empty? && parsed[i+1] && parsed[i+1].depth <= parsed[i].depth
            parsed.delete_at(i)
            i -= 1 # step back
          else
            i+=1
          end
        end
      end

      def push!(line, key_path)
        node = Node.new(line, key_path.dup, current_line)
        @parsed.push(node)
        node
      end

      def path_check(path)
        if key_stack.include?(path)
          raise I18nDummy::Error.new("[#{file}] Duplicate key: #{path} on line #{current_line}")
        end

        key_stack << path
      end

      def path_name(file_name)
        Pathname.new(file_name).realpath.to_s
      end

      def is_key_value?(line, previous_node)
        return true if line.strip[0] == '-' # array values
      end
    end
  end
end