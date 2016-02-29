require 'i18n/backend/active_record'
require 'i18n-ar_translation/stats'

class TranslationsController < ActionController::Base

  layout 'translations'
  before_filter :find_locale

  helper_method :translation_stats,:check_for_missing_params

  def index
    @translations = I18n::Backend::ActiveRecord::Translation.where(locale: @locale || I18n.default_locale)
    session[:translation_option] = params[:translation_option] if params[:translation_option]
    session[:show_keys] = params[:show_keys] if params[:show_keys]
    case session[:translation_option]
      when 'translated' then @translations = @translations.where('value is not null')
      when 'unsourced'  then @translations = @translations.where(predefined: false)
      else
        session[:translation_option] = 'untranslated'
        @translations = @translations.where('value is null')
    end
    send_data @translations.collect{|translation| translation.attributes.slice('key','value')}.to_yaml,type: 'text/plain',disposition: 'attachment',filename: "#{@locale}_#{session[:translation_option] || 'all'}_#{Time.now.strftime('%Y%m%d%H%M%S')}.yml" if params[:export] == 'yaml'
  end

  def update
    raise 'Do not use this page to update the default locale' if @locale == I18n.default_locale
    raise 'Value cannot be blank' if (value = params[:translation] && params[:translation][:value]).blank?
    translation = I18n::Backend::ActiveRecord::Translation.find(params[:id])
    if (default_translation = I18n::Backend::ActiveRecord::Translation.locale(I18n.default_locale).lookup(translation.key).first) and (missing_params = check_for_missing_params(default_translation.value,value))
      raise "Value is missing required interpolation parameters: #{missing_params.join(', ')}"
    end
    translation.value = value
    translation.predefined = false
    translation.save!
    flash[:success] = "Key '#{translation.key}' updated for #{translation.locale}"
  rescue
    flash[:error] = $!.to_s
  ensure
    redirect_to action: 'index',translation_option: session[:translation_option]
  end

  def reset_stats
    session[:translation_stats] = nil
    redirect_to action: 'index',translation_option: session[:translation_option]
  end

private

  def check_for_missing_params(default_value,target_value)
    return if (default_params = default_value.to_s.scan(/\%\{(.*?)\}/).flatten).empty?
    return default_params if target_value.nil? or (target_params = target_value.scan(/\%\{(.*?)\}/).flatten).empty?
    return if (missing_params = default_params - target_params).empty?
    missing_params
  end

  def translation_stats
    session[:translation_stats] ||= I18n::ArTranslation::Stats.collect_stats
  end

  def find_locale
    session[:locale] = params[:locale].to_sym if params[:locale]
    @locale = session[:locale] || :en
  end
end
