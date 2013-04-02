Rails.application.routes.draw do
  unless Rails.env.production?
    match '/translations' => 'translations#index', :as => 'translations'
    match '/translations/reset_stats' => 'translations#reset_stats', :as => 'translations_reset_stats'
    match '/translation/:id' => 'translations#update', :as => 'translation_update'
  end
end
