require 'i18n/backend/active_record'

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
    raise 'Value cannot be blank' if (value = params[:translation][:value]).blank?
    translation = I18n::Backend::ActiveRecord::Translation.find(params[:id])
    translation.update_attributes!(value: value,predefined: false)
    flash[:success] = "Key '#{translation.key}' updated for #{translation.locale}"
  rescue
    flash[:error] = $!.to_s
  ensure
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
    @stats ||= [].tap do |stats|
      default_locale = I18n.default_locale
      stats << collect_counts(default_locale)
      I18n::Backend::ActiveRecord::Translation.where('locale != ?',default_locale)
      (I18n.available_locales - [default_locale]).each{|locale| stats << collect_counts(locale)}
      max_total = stats.collect{|stat| stat[:total]}.max
      stats.each{|stat| stat[:missing] = max_total - stat[:total]}
    end
  end

  def collect_counts(locale)
    scope = I18n::Backend::ActiveRecord::Translation.where(locale: locale)
    total = scope.count
    untranslated = scope.where(value: nil).count
    translated = total - untranslated
    unsourced = scope.where(predefined: 0).count
    sourced = total - unsourced
    {:locale => locale, :total => total, :translated => translated, :untranslated => untranslated, :unsourced => unsourced, :sourced => sourced}
  end

  def find_locale
    session[:locale] = params[:locale].to_sym if params[:locale]
    @locale = session[:locale] || :en
  end
end
