Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/users', to: 'users#create_user'
      post '/users/login', to: 'users#user_login'
      put '/users/forgot_password', to: 'users#forgot_password'
      put '/users/reset_password/:id', to: 'users#reset_password'

      #notes routes
      get '/notes', to: 'notes#get_all_notes'
      post '/notes', to: 'notes#create_note'
      get '/notes/:id', to: 'notes#get_note'
      put '/notes/:id', to: 'notes#update_note'
      delete '/notes/:id', to: 'notes#delete_note'

      put '/notes/:id/archive', to: 'notes#toggle_archive'
      put '/notes/:id/toggle_delete', to: 'notes#toggle_delete'

      put '/notes/:id/color', to: 'notes#change_color'
      post '/notes/:id/collaborators', to: 'notes#add_collaborator'

    end
  end
end
