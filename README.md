# I18n::ArTranslation

This gem provides a complete translation framework.
It establishes as the I18n::Backend for an application a "chain" of I18n::Backend::ActiveRecord and I18n::Backend::Simple.
The AR-based backend exists to capture "direct English" (or whatever the default locale is) in application code,
and a translations controller for non-development translation specialists to use to provide matching translations in
whichever additional locales the application is configured to accept.

Some of the algorithms in this gem were borrowed from the "i18n_backend_database" project,
but as much as possible, it relies on the current "i18n" and "i18n-active_record" gems manage the majority
of translation management functionality.

## Installation

Add this line to your application's Gemfile:

    gem 'i18n-ar_translation'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install i18n-ar_translation

In additional, you will need to create a migration for a "translation" stable in your following the instructions in "i18n-active_record".
However, you must additionally add a "boolean" field called "predefined."

Finally, put the following in your /config/initializers/locale.rb file using your own choices for "translation_locales":

    require 'i18n-ar_translation'

    I18n::ArTranslation::Configuration.setup do |config|
      config.translation_locales = [:en,:es]
    end

## Usage

To initialize your I18n::Backend:ActiveRecord::Translation database table, use the following rake task to capture
"direct English" translation keys in your application code:

    rake i18n:reset_translations

As a safety measure, this task will create a "/config/translations/<locale>.missing" file containing the current translations
in the database that were not previously captured by the process.

Along with "direct English" in the application code, this task will also look for "/config/translations/<locale>.yml"
files for each of the non-default locales of the application to load in the database.

When "Rails.env.production?" is false, an unauthenticated web route "/translations" will be available.

Once translations are complete, use the "Export to YAML" button on this page for a selected locale to download a new
"/config/translations/<locale>.yml" file to store in your application code for future use.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
