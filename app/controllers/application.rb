# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_pushpin2_session_id'
  
  def new_atom_http
    http = Atom::HTTP.new

    http.when_auth do |abs_url, realm|
      @abs_url, @realm = abs_url, realm

      if @user
        auth = @user.auth_for(@abs_url, @realm)
      end
      
      if params[:user] and params[:pass]
        if @user and params[:store_auth] == 'yes'
          auth ||= HttpAuth.new

          auth.user_id = @user.id
          auth.abs_url = @abs_url
          auth.realm = @realm
          auth.username = params[:user]
          auth.password = params[:pass]
          auth.save
        end

        [ params[:user], params[:pass] ]
      elsif auth
        [ auth.username, auth.password ]
      else
        nil
      end
    end

    http
  end
end
