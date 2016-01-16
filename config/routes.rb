Rails.application.routes.draw do
  unless Rails.env.production?
    get '/translations' => 'translations#index', :as => 'translations'
    get '/translations/reset_stats' => 'translations#reset_stats', :as => 'translations_reset_stats'
    patch '/translation/:id' => 'translations#update', :as => 'translation_update'
  end
end
