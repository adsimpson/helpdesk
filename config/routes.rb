require 'api_constraints'

Helpdesk::Application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
       
      namespace :users do
        post "/sign_in", :to => 'access_tokens#create'
        delete "/sign_out", :to => 'access_tokens#destroy'
        resources :access_tokens, only: [:create, :destroy]
        resources :password_resets, only: [:show, :create, :update]
        resources :email_verifications, only: [:show, :create, :update]
      end
      resources :users, except: [:new, :edit] do
        get "/me" , :to => 'users#show_current_user', :on => :collection
        scope module: :users do
          get "/groups", :to => 'group_memberships#index_groups'
          resources :group_memberships, except: [:new, :edit, :update] do
            put "/make_default" , :to => 'group_memberships#set_default', :on => :member
          end
        end
      end
      resources :groups, except: [:new, :edit] do
        scope module: :groups do
          get "/users", :to => 'group_memberships#index_users'
          resources :group_memberships, path: '/memberships', only: [:index]
        end
      end
      resources :group_memberships, except: [:new, :edit, :update]
      resources :organizations, except: [:new, :edit] do
        get "/users", :to => 'organizations/users#index'
      end
      
    end
    
  end
  
end