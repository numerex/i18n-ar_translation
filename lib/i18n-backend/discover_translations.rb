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
              unless I18n::Backend::ActiveRecord::Translation.locale(locale).lookup(key).first
                I18n.backend.backends.first.reload! # ensure that the an already-memoized translation is not remembered without its value
                translation = I18n::Backend::ActiveRecord::Translation.new(locale: locale,key: key,value: key)
                translation.interpolations = interpolations.keys
                translation.save!
              end
              result = interpolate(locale,key,interpolations)
            else
              #:nocov: remove when it's clear how to test for other exceptions
              throw(:exception, result)
              #:nocov:
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
