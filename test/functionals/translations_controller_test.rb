require 'test_helper'

class TranslationsControllerTest < ActionController::TestCase

  def setup
    I18n::Backend::ActiveRecord::Translation.delete_all
    TranslationsController.send(:include,Rails.application.routes.url_helpers)
    @controller = TranslationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @routes     = Rails.application.routes
  end

  test 'should get index' do
    setup_one_of_each

    assert_equal nil,session[:translation_option]

    get :index
    assert_response :success
    assert_equal :en,assigns(:locale)
    assert_equal 'untranslated',session[:translation_option]
    assert_equal 0,assigns(:translations).length

    get :index,translation_option: 'translated'
    assert_response :success
    assert_equal :en,assigns(:locale)
    assert_equal 'translated',session[:translation_option]
    assert_equal 3,assigns(:translations).length

    get :index,locale: 'es'
    assert_response :success
    assert_equal :es,assigns(:locale)
    assert_equal 'translated',session[:translation_option]
    assert_equal 1,assigns(:translations).length

    get :index,translation_option: 'untranslated'
    assert_response :success
    assert_equal :es,assigns(:locale)
    assert_equal 'untranslated',session[:translation_option]
    assert_equal 1,assigns(:translations).length

    get :index,locale: 'en'
    assert_response :success
    assert_equal :en,assigns(:locale)
    assert_equal 'untranslated',session[:translation_option]
    assert_equal 0,assigns(:translations).length

    get :index,translation_option: 'unsourced'
    assert_response :success
    assert_equal :en,assigns(:locale)
    assert_equal 'unsourced',session[:translation_option]
    assert_equal 1,assigns(:translations).length

    get :index,locale: 'es'
    assert_response :success
    assert_equal :es,assigns(:locale)
    assert_equal 'unsourced',session[:translation_option]
    assert_equal 1,assigns(:translations).length
  end

  test 'should reset stats' do
    session[:translation_stats] = []

    get :reset_stats
    assert_redirected_to translations_path
    assert_equal nil,session[:translation_stats]
  end

  test 'do not replace translations for the default locale' do
    translation = I18n::Backend::ActiveRecord::Translation.create!(locale: 'en',key: 'One translated',value: 'One translated')

    patch :update, id: translation.id
    assert_redirected_to translations_path
    assert_equal '',flash[:success].to_s
    assert_equal 'Do not use this page to update the default locale',flash[:error].to_s
  end

  test 'value cannot be blank' do
    translation = I18n::Backend::ActiveRecord::Translation.create!(locale: 'es',key: 'One translated')

    patch :update, id: translation.id, locale: 'es', translation: {}
    assert_redirected_to translations_path
    assert_equal '',flash[:success].to_s
    assert_equal 'Value cannot be blank',flash[:error].to_s
  end

  test 'value must include matching parameters' do
    key = 'One translated with option %{test1} and %{test2}'
    I18n::Backend::ActiveRecord::Translation.create!(locale: 'en',key: key,value: key)
    translation = I18n::Backend::ActiveRecord::Translation.create!(locale: 'es',key: key)

    patch :update, id: translation.id, locale: 'es', translation: { value: 'Un traducido con opcion %{test1}' }
    assert_redirected_to translations_path
    assert_equal '',flash[:success].to_s
    assert_equal 'Value is missing required interpolation parameters: test2',flash[:error].to_s
  end

  test 'value saved' do
    key = 'One translated with option %{test}'
    I18n::Backend::ActiveRecord::Translation.create!(locale: 'en',key: key,value: key)
    translation = I18n::Backend::ActiveRecord::Translation.create!(locale: 'es',key: key)

    patch :update, id: translation.id, locale: 'es', translation: { value: 'Un traducido con opcion %{test}' }
    assert_redirected_to translations_path
    assert_equal "Key '#{key}' updated for es",flash[:success].to_s
    assert_equal '',flash[:error].to_s
  end

end
