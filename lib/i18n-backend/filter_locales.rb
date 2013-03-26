require 'i18n'
require 'i18n/backend'
require 'i18n/config'

module I18n
  module Backend
    module FilterLocales
      def load_file(filename)
        super if filename =~ I18n.config.filter_pattern
      end
    end
  end
end