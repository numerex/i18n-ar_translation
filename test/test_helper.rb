ENV['RAILS_ENV'] = 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'rubygems'
require 'bundler/setup'
require 'shoulda'
require 'simplecov'

SimpleCov.start'rails' do
  add_filter '/test/'
end

require 'test/unit'
begin; require 'turn'; rescue LoadError; end

#$:.unshift File.expand_path('../../lib', __FILE__)

require 'rails'

load File.dirname(__FILE__) + '/support/migration.rb'
load File.dirname(__FILE__) + '/support/locale.rb'

require 'i18n-ar_translation'

require "minitest/reporters"
if ENV["IS_BAMBOO"]
  Minitest::Reporters.use! Minitest::Reporters::JUnitReporter.new
else
  Minitest::Reporters.use! [
    Minitest::Reporters::DefaultReporter.new(
      :color => true,
      slow_count: 10,
      :slow_suite_count => 5,
      :fast_fail => true
    )
  ]
end

class ActiveSupport::TestCase

  use_transactional_fixtures = true

  def setup_one_of_each
    I18n::Backend::ActiveRecord::Translation.delete_all

    assert_difference 'I18n::Backend::ActiveRecord::Translation.count',5 do
      I18n::Backend::ActiveRecord::Translation.create!(locale: 'en',key: 'One translated',value: 'One translated')
      I18n::Backend::ActiveRecord::Translation.create!(locale: 'en',key: 'One untranslated with option %{test}',value: 'One untranslated with option %{test}')
      I18n::Backend::ActiveRecord::Translation.create!(locale: 'es',key: 'One translated',value: 'Un traducido')
      I18n::Backend::ActiveRecord::Translation.create!(locale: 'es',key: 'One untranslated')

      I18n::Backend::ActiveRecord::Translation.where('value is not null').update_all(predefined: true)

      I18n::Backend::ActiveRecord::Translation.create!(locale: 'en',key: 'One discovered',value: 'One discovered')
    end
  end

end