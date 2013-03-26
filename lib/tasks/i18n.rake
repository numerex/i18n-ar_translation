namespace :i18n do

  task :reset_translations => :environment do
    require 'i18n-ar_translation/tools'

    I18n::ArTranslation::Tools.reset_translations(ENV['VERBOSE'])
  end

end
