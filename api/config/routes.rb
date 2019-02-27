Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'api/v1/freetime/test' => 'api/v1/freetime#test'
  post 'api/v1/freetime/get' => 'api/v1/freetime#get'
end
