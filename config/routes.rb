ActionController::Routing::Routes.draw do |map|
  # first created -> highest priority.
 
  map.resource :entry, :collection, :wall, :user

  map.connect 'login', :controller => 'openid', :action => 'login'
  map.connect 'complete', :controller => 'openid', :action => 'complete'
  map.connect 'logout', :controller => 'openid', :action => 'logout'

  map.connect '', :controller => 'static', :action => 'index'
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # uses non-REST routing
  map.connect 'openid/:action', :controller => 'openid'
  map.connect 'openid/:action', :controller => 'openid'
end
