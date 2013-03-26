require 'i18n-ar_translation/version'
require 'i18n-backend/discover_translations'
require 'i18n-backend/filter_locales'
require 'i18n-config/filter_locales'
require 'active_record'

I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Flatten)
I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)
I18n::Backend::Simple.send(:include, I18n::Backend::Flatten)
I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

I18n::Config.send(:include, I18n::Config::FilterLocales)

I18n::Backend::Simple.send(:include, I18n::Backend::FilterLocales)

I18n::Backend::Chain.send(:include, I18n::Backend::DiscoverTranslations)

module I18n
  module ArTranslation

    class Engine < ::Rails::Engine
      initializer 'common.init' do |app|
        ## Publish #{root}/public path so it can be included at the app level
        #if app.config.serve_static_assets
        #  app.config.middleware.use ::ActionDispatch::Static, "#{root}/public"
        #end
      end
    end

    module Configuration

      mattr_accessor :translation_locales
      @@translation_locales = [:en]

      def self.setup
        yield self

        I18n.config.set_filter_locales(*@@translation_locales)
        I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new,I18n::Backend::Simple.new) if ::ActiveRecord::Base.connection.tables.include?('translations')

      end

    end

  end
end
