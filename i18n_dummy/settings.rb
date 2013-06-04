module I18nDummy
  class Settings

    CONFIG_NAME = "settings.yml"

    class << self
      def marker_regex
         @@regex ||= Regexp.new(suffix? ? /#{marker}$/ : /^#{marker}/)
      end

      private

      def suffix?
        config.fetch('marker', {}).fetch('type','suffix') == 'suffix'
      end

      def marker
        Regexp.escape config.fetch('marker',{}).fetch('symbol', nil) || 'U'
      end

      def config_file
        File.join(File.dirname(__FILE__), "../#{CONFIG_NAME}")
      end

      def config
        @@config ||= File.exists?(config_file) ? Psych.load(File.read(config_file)) : {}
      end
    end
  end
end
