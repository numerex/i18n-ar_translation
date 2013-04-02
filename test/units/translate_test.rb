require 'test_helper'

class TranslateTest < ActiveSupport::TestCase

  def setup
    I18n.locale = I18n.default_locale
  end

  test 'normal i18n handling works' do
    assert_no_difference 'I18n::Backend::ActiveRecord::Translation.count' do
      test = TestModel.new
      assert !test.valid?
      assert_equal ["Name can't be blank"],test.errors.to_a
    end
  end

  test "english language is captured" do

    ['This is a test','This has a TEST','This test has a trailing blank.'].each do |key|

      assert_difference 'I18n::Backend::ActiveRecord::Translation.count' do
        assert_equal key,I18n.t(key)
      end

      assert_no_difference 'I18n::Backend::ActiveRecord::Translation.count' do
        assert_equal key,I18n.t(key)
      end

      assert_no_difference 'I18n::Backend::ActiveRecord::Translation.count' do
        I18n.locale = :es
        assert_equal key,I18n.t(key)
      end

    end

  end

end
