require 'i18n/active_record'
require 'i18n-ar_translation'

I18n::ArTranslation::Configuration.setup do |config|
  config.translation_locales = [:en,:es]
end
