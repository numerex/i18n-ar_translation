Rails.application.routes.draw do
  unless Rails.env.production?
    match '/translations' => 'translations#index', :as => 'translations'
    match '/translation/:id' => 'translations#update', :as => 'translation_update'
  end
end
