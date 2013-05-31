MissionfigGame::Application.routes.draw do

  resources :send_messages

  get "tip_user/send_notification"

  get "tip_user/send_message", :defaults => { :format => 'json'}
  get "tip_user/custom_send_message",:format=>'json'
  resources :tip_user do
    collection do
      get :callback_method,:custom_send_message
    end
  end
  
  resources :user_applications do
    collection do
      get :application_status
    end
  end
  
  

  get "metrics", :to => "events#index"
  #get "events/quest_tracker", :to => "events#show_quest", :defaults => { :format => 'json' } 
  
  get "events/new", :to => "events#new"

  get "events/portolio_invested", :to => "events#portolio_invested", :defaults => { :format => 'json' } 
  get "events/user_level", :to => "events#user_level", :defaults => { :format => 'json' }
  get "events/stock_report", :to => "events#stock_report", :defaults => { :format => 'json' }
  get "events/friends_joined", :to => "events#friends_joined", :defaults => { :format => 'json' }
  get "events/csv", :to => "events#to_csv"
  match "events/:event_name", :to => "events#show", :defaults => { :format => 'json' } 

  post "events", :to => "events#create", :defaults => { :format => 'json' } 

  get "track", :to => "track#index", :defaults => { :format => 'json' } 

  get "admin_mail/get", :to => "admin_mail#get", :defaults => { :format => 'json' } 
  get "admin_mail", :to => "admin_mail#index"
  get "admin_mail/index"
  get "admin_mail/new"
  post "admin_mail/create"

  #user Controller
  get "users/:user_id", :to => "users#show", :defaults => { :format => 'json' } 
  match "users/:user_id/friends" => "users#friends", :defaults => { :format => 'json' }
  match "users/:user_id/reset" => "users#reset", :defaults => { :format => 'json' } 
  post 'users/:user_id/doc', :to => 'users#update_doc', :defaults => { :format => 'json' } 
  match 'users/:user_id/notify', :to => 'users#notify', :defaults => { :format => 'json' } 

  #fb_oauth Controller
  get "fb-oauth/show", :to => "fb-oauth#show"
   get "fb-oauth/set_session", :to => "fb-oauth#set_session"
  post "fb-oauth", :to => 'fb_oauth#index'
  get "fb-oauth", :to => 'fb_oauth#index'
  get "fb-oauth/authorize", :to => "fb_oauth#authorize"

  #dialy_report
  get "daily_report/:user_id", :to => "daily_report#index", :defaults => { :format => 'json' } 
  
  #inbox controller
  match 'inbox/:user_id/reply'=> 'inbox#reply_message', :defaults => { :format => 'json' } 
  #match 'inbox/:user_id/request'=> 'inbox#request_action', :defaults => { :format => 'json' }
  match 'inbox/:user_id/send'=> 'inbox#send_message', :defaults => { :format => 'json' } 
  match 'inbox/:user_id/read'=> 'inbox#read', :defaults => { :format => 'json' }
  match 'inbox/:user_id/delete'=> 'inbox#delete', :defaults => { :format => 'json' }

  #stock search controler 
  get "stock-search",:to => "stock-search#index", :defaults => { :format => 'json' } 
  
  #stock index controler 
  get "stock-index" => "stock-index#index", :defaults => { :format => 'json' } 
  
  #stock historical
  get "stock-history", :to => 'stock_history#index', :defaults => { :format => 'json' } 

  #stock realtime controller
  get "stock-realtime", :to => 'stock_realtime#index', :defaults => { :format => 'json' } 
  get "stock-realtime/category", :to => 'stock_realtime#category', :defaults => { :format => 'json' } 
  get "stock-realtime/fund", :to => 'stock_realtime#fund', :defaults => { :format => 'json' }
  get "stock-realtime/foreign", :to => 'stock_realtime#foreign', :defaults => { :format => 'json' }
  get "stock-realtime/all", :to => 'stock_realtime#all', :defaults => { :format => 'json' }
  #get "stock-realtime/popular", :to => 'stock_realtime#get_filter_details', :defaults => { :format => 'json' } 

  #game settings controller
  get "game-settings", :to => 'game-settings#index', :defaults => { :format => 'json' } 
  
   
  resources :quests

  resources :users, :defaults => { :format => 'json' } 

  resources :maps
  
  
  #delete 'user_states/:id' => 'user_states#destroy', :defaults => { :format => 'json' } 
  get 'user_states' => 'user_states#index' , :defaults => { :format => 'json' } 
  get 'user_states/:model_id' => 'user_states#show' , :defaults => { :format => 'json' } 
  put 'user_states' => 'user_states#update' , :defaults => { :format => 'json' } 
  post 'maps/create' , :defaults => { :format => 'json' } 
  post 'stocks/create' , :defaults => { :format => 'json' } 
  resources :user_states  do
        resources :maps
        resources :stocks
  end
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
