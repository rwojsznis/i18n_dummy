module I18nDummy
  module Parser
    class NodeValue < Struct.new(:content, :comment)
      def initialize(value)
        value = value.strip.gsub(/^-\s?/,'')

        val, comment = value.split('#', 2)

        args = {
          content: val ? val.dequote.escape : nil,
          comment: comment ? comment.strip : nil
        }

        super *args.values
      end

      def to_s
        "#{content_output}#{comment_output}".strip
      end

      def content_output
        content.quote if content && !content.empty?
      end

      def comment_output
        " # #{comment}" if comment
      end

      def to_html
        %Q(<span>
            #{Rack::Utils.escape_html(content_output)}
            <em class='comment'>#{comment_output}</em>
          </span>)
      end

      def pending?
        comment && comment =~ /FIX\s?ME/i
      end

    end
  end
end
