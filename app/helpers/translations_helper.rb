module TranslationsHelper
  def name_for_locale(locale)
    I18n.t(locale,scope: 'i18n.locale_names',default: locale)
  end

  def locale_options_for_select(locales,selected)
    options_for_select(locales.inject({}){|options,locale| options[name_for_locale(locale)] = locale; options},selected)
  end
end