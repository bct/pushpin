require "pathname"
require "cgi"

# load the openid library
begin
  require "rubygems"
  gem "openid", ">= 1.0.2"
rescue LoadError
  require "openid"
end

class OpenidController < ApplicationController
  # process the login request, disover the openid server, and
  # then redirect.
  def login
    openid_url = params[:openid_url]

    if request.post?
      request = consumer.begin(openid_url)

      case request.status
      when OpenID::SUCCESS
        return_to = url_for(:action=> 'complete')
        trust_root = url_for(:controller => 'static', :action => 'index')

        url = request.redirect_url(trust_root, return_to)
        redirect_to(url)
        return
      when OpenID::FAILURE
        escaped_url = CGI.escapeHTML(openid_url)
        flash[:notice] = "Could not find OpenID server for #{escaped_url}"
      else
        flash[:notice] = "An unknown error occured."
      end

      redirect_to :controller => "static", :action => "index"
    end    
  end

  # handle the openid server response
  def complete
    response = consumer.complete(params)
    
    case response.status
    when OpenID::SUCCESS
      @user = User.find_or_initialize_by_openid_url(response.identity_url)

      if @user.new_record?
        # redirect them to their settings page on first login
        @user.save
        session[:user_id] = @user.id

        redirect_to :controller => "user", :action => "show"
      else
        session[:user_id] = @user.id

        redirect_back_or_default wall_path
      end

      return
    when OpenID::FAILURE
      if response.identity_url
        escaped_url = CGI.escapeHTML(response.identity_url)
        flash[:notice] = "Verification of #{escaped_url} failed."
      else
        flash[:notice] = 'Verification failed.'
      end
    when OpenID::CANCEL
      flash[:notice] = 'Verification cancelled.'
    else
      flash[:notice] = 'Unknown response from OpenID server.'
    end
  
    redirect_to :controller => "static", :action => "index"
  end
  
  def logout
    session[:user_id] = nil

    redirect_to :controller => 'static', :action => 'index'
  end
    
  private

  # Get the OpenID::Consumer object.
  def consumer
    # Create the OpenID store for storing associations and nonces,
    # putting it in your app's db directory.
    # Note: see the plugin located at examples/active_record_openid_store 
    # if you need to store this information in your database. 
    store_dir = Pathname.new(RAILS_ROOT).join('db').join('openid-store')
    store = OpenID::FilesystemStore.new(store_dir)

    return OpenID::Consumer.new(session, store)
  end
end
