module I18nDummy
  module Parser
    class NodeValue < OpenStruct
      def initialize(value)
        value = value.strip.gsub(/^-\s?/,'')

        val, comment = value.split('#', 2)

        args = {
          content: val.dequote.escape,
          comment: comment ? comment.strip : nil
        }

        super args
      end

      def to_s
        "#{content.quote}#{comment_output}"
      end

      def comment_output
        " # #{comment}" if comment
      end

      def to_html
        "<span>#{Rack::Utils.escape_html(content.quote)}<em class='comment'>#{comment_output}</em></span>"
      end

      def pending?
        comment && comment =~ /FIX\s?ME/i
      end

    end
  end
end