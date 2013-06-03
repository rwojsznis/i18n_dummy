module I18nDummy
  module Parser
    class Node < OpenStruct
      attr_accessor :line, :deleted

      def initialize(line, path, line_number)
        depth    = (line.size - line.lstrip.size)/2
        key, val = line.strip.split(/:/,2)

        value = !val.empty? ? [NodeValue.new(val)] : []

        args = {
          :value     => value,
          :key       => key.strip.without_marker,
          :depth     => depth,
          :multiline => false,
          :path      => path,
          :updated   => key.strip.key_updated?
        }
        @line = line_number
        @deleted = false

        super(args)
      end

      def replicate(country_code)
        node = dup
        node.path[0] = country_code
        node.value = value.map { |v| v.dup }
        node.fixmes!
        node
      end

      def updated?
        updated
      end

      def deleted?
        deleted
      end

      def pending?
        value.any? { |v| v.pending? }
      end

      def delete!
        @deleted = true
      end

      def multiline?
        multiline
      end

      def multiline!
        self.multiline = true
      end

      def set_updated_values(new_value)
        self.value = new_value.map { |v| v.dup }
        fixmes!
      end

      def set_value(values) # set array values
        return unless values
        values.each do |line|
          self.value.push NodeValue.new(line)
        end
      end

      def add_to_path!(key)
        self.path.push key
      end

      def pop_path
        self.path.pop
      end

      def no_value?
        value.empty?
      end

      def simple_values
        if value.size == 1
          value.first.content
        else
          value.map { |v| v.content }
        end
      end

      def full_path # full path without locale code
        (path.drop(1) + [key.without_marker]).join('.')
      end

      def to_s
        "#{indentation}#{key}:#{output_value}"
      end

      def to_html(file = nil, base = nil)
        %Q(<tr#{css_class(base)}>
          <td>
            #{line}
          </td>
          <td style='padding-left: #{depth}em'>
            <a href='#{link(file)}'>#{key}:</a>#{output_html_value}
          </td>
         </tr>)
      end

      def to_html_diff
        %Q(<tr>
            <td>#{line}</td>
            <td>#{full_path}:#{output_html_value}</td>
           </tr>)
      end

      def fixmes!
        value.each { |v| v.comment = "FIX ME" }
      end

      private

      def link(file)
        "subl://open?url=file://#{file}&line=#{line}"
      end

      def css_class(base)
        css = []
        css.push("info")    if updated?
        css.push("warning") if pending?
        css.push("error")   if base && depth > 0 && base.find_by_path(full_path).nil?
        " class='#{css.join(' ')}'" unless css.empty?
      end

      def indentation
        "  " * depth
      end

      def value_indentation
        "  " * (depth + 1)
      end

      def output_html_value
        return if value.empty?

        result = value.map { |v| v.to_html }.join

        multiline? ? "<div class='multiline'>#{result}</div>" : result
      end

      def output_value
        return if value.empty?

        if multiline?
          "\n" + value.map { |v| "#{value_indentation}- #{v.to_s}" }.join("\n")
        else
          " " + value.map { |v| v.to_s }.join
        end
      end
    end
  end
end