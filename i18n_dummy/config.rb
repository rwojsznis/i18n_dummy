module I18nDummy
  class Config
    class << self

      def load
        raise I18nDummy::Error.new("Missing configuration (config.yml)") unless exists?

        yaml = Psych.load(File.read(config_file))

        file_check(yaml)

        yaml
      end

      private

      def file_check(yaml)
        yaml.each do |locale, files|
          raise I18nDummy::Error.new("Missing base locale for #{locale}") unless base_exists?(files)

          files.each do |name, file|
            raise I18nDummy::Error.new("Missing file: #{file}") unless File.exist?(file)
          end
        end
      end

      def base_exists?(hash)
        hash.keys.include?('base')
      end

      def exists?
        File.exist?(config_file)
      end

      def config_file
         File.join(File.dirname(__FILE__), '../config.yml')
      end

    end
  end
end