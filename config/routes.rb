require 'api_constraints'

Helpdesk::Application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
       
      post "/sign_in", :to => "access_tokens#create"
      delete "/sign_out", :to => "access_tokens#destroy"
      get "/me" , :to => "users#show_current_user"
      resources :access_tokens, only: [:create, :destroy]
      resources :password_reset_tokens, only: [:show, :create, :update]
      resources :email_verification_tokens, only: [:show, :create, :update]
      
      resources :users, except: [:new, :edit] do
        scope module: :users do
          get "/groups", :to => "group_memberships#index_groups"
          resources :group_memberships, only: [:index, :show, :create, :destroy] do
            put "/make_default" , :to => "group_memberships#make_default", :on => :member
          end
          resources :email_addresses, except: [:new, :edit]
        end
      end
      
      resources :groups, except: [:new, :edit] do
        scope module: :groups do
          get "/users", :to => "memberships#index_users"
          resources :memberships, only: [:index]
        end
      end
      
      resources :group_memberships,  only: [:index, :show, :create, :destroy]
      
      resources :organizations, except: [:new, :edit] do
        scope module: :organizations do
          resources :users, only: [:index]
        end
      end
      
    end
    
  end
  
end