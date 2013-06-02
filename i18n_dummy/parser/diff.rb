module I18nDummy
  module Parser
    class Diff
      include ::I18nDummy::Common

      attr_accessor :base, :locale

      def initialize(base, locale)
        @base = base
        @locale = locale
      end

      def any?
        ! new_nodes.empty?
      end

      def new_nodes
        @new_nodes ||= begin
          start = Time.now
          nodes = []

          (base.full_paths.values - locale.full_paths.values).each do |p|
            nodes.push(base.parsed[base.full_paths.key(p)])
          end

          nodes << base.updated_nodes
          nodes.flatten!

          debug_speed "I18nDummy::Parser::Diff.new_nodes", start
          nodes
        end
      end
    end
  end
end