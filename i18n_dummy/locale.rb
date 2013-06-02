module I18nDummy
  class Locale
    extend ::I18nDummy::Common

    class << self
      def prepare!(base, locale)
        start = Time.now

        result = locale.dup
        result.parsed = [locale.parsed.first] # grab head

        base.parsed.drop(1).each_with_index do |node, idx|
          node_local = locale.find_by_path(node.full_path)

          if node_local.nil?
            result.parsed[idx+1] = node.replicate(locale.country_code)
          else
            if node.updated? || (node.no_value? && !node_local.no_value?) # FIXME
              node_local.set_updated_values node.value
              node_local.multiline! if node.multiline?
            end
            result.parsed[idx+1] = node_local
          end
        end

        debug_speed "I18nDummy::Locale.prepare!", start

        result
      end
    end
  end
end