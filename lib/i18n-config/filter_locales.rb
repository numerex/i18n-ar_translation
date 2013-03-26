require 'i18n'
require 'i18n/config'

module I18n
  class Config
    module FilterLocales
      def filter_locales
        @@filter_locales ||= [default_locale]
      end

      def set_filter_locales(*locales)
        @@filter_pattern = nil
        @@filter_locales = ([default_locale] + locales.collect(&:to_sym)).uniq
      end

      def filter_pattern
        @@filter_pattern ||= Regexp.new(%((#{filter_locales.join('|')})\\.\\w+$))
      end
    end
  end
end
