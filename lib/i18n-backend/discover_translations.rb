require 'i18n/backend/active_record'

module I18n
  module Backend

    class ActiveRecord
      module DiscoverTranslations

        def translate(locale, key, options = {})
          result = catch(:exception) do
            super
          end
          if result.is_a?(I18n::MissingTranslation)
            if not options[:resolve] and (interpolations = options.except(*I18n::RESERVED_KEYS)).empty? or interpolations.keys.detect{|interpolation_key| key =~ /%\{#{interpolation_key}\}/}
              store_translations(locale,{key => key},interpolations)
              result = interpolate(locale,key,interpolations)
            else
              throw(:exception, result)
            end
          end
          result
        end
      end
    end

    module DiscoverTranslations
      include I18n::Backend::Fallbacks
      include I18n::Backend::ActiveRecord::DiscoverTranslations
    end

  end
end
