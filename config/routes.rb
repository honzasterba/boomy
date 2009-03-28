ActionController::Routing::Routes.draw do |map|
  map.boomy       '', :controller => "boom", :action => "index"
  map.novinky     'novinky', :controller => "boom", :action => "novinky"
  map.nejlepsi    'nejlepsi', :controller => "boom", :action => "best_of"
  
  map.user        'uzivatel/:id/:slug', :controller => "boom", :action => "user"
  map.tag         'tag/:id/:slug', :controller => "boom", :action => "tag"
  map.detail      'detail/:id/:slug', :controller => "boom", :action => "detail"

  map.pridat      'pridat', :controller => "boom", :action => "add"
  map.help        'napoveda', :controller => "boom", :action => "help"
  map.o_projektu  'o_projektu', :controller => "boom", :action => "o_projektu"
  map.login       'login', :controller => "boom", :action => "login"
  map.logout      'logout', :controller => "boom", :action => "logout"
  map.forgot_pass 'pass_reset', :controller => "boom", :action => "forgot_pass"
  map.change_pass 'zmenit_heslo', :controller => "boom", :action => "change_pass"


  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id'
  
  map.error '*path', :controller => "boom", :action => "not_found"
end
