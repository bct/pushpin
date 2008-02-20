ActionController::Routing::Routes.draw do |map|
  # first created -> highest priority.

  # this user
  map.resource :user do |user|
    # this user's collections
    user.resource :collections
  end

  # a remote service document
  map.resource :service

  # a remote collection
  map.resource :collection

  # a remote entry
  map.resource :entry, :collection => { :delete_authorization => :get }

  map.resource :authsub

  # front page
  map.connect '', :controller => 'static', :action => 'index'

  # openid spiel
  map.connect 'signup', :controller => 'static', :action => 'signup'

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # uses non-REST routing
  map.connect 'login', :controller => 'openid', :action => 'login'
  map.connect 'complete', :controller => 'openid', :action => 'complete'
  map.connect 'logout', :controller => 'openid', :action => 'logout'

  map.connect 'openid/:action', :controller => 'openid'
end
