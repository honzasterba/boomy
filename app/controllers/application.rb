class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable

  session :session_key => '_blbosti_session_id'

  before_filter :init_db
  
  protected

    def init_db
       ActiveRecord::Base.connection.execute "SET NAMES UTF8"
    end

    def act_user
      if session[:user] and User.find(:first, session[:user])
        @act_user ||= User.find(session[:user])
      elsif cookies[:user_token]
        @act_user ||= User.find_by_password(cookies[:user_token])
        session[:user] = @act_user.id
      else
        nil
      end
    end
    helper_method :act_user
    
end
