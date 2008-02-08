require "pathname"
require "cgi"

# load the openid library
require "rubygems"

gem "ruby-openid", ">= 2.0.0"

require 'openid/store/filesystem'
require 'openid/consumer'

class OpenidController < ApplicationController
  # process the login request, disover the openid server, and
  # then redirect.
  def login
    openid_url = params[:openid_url]

    if request.post?
      begin
        request = consumer.begin(openid_url)
      rescue Timeout::Error
        flash[:notice] = "could not connect with OpenID server"

        redirect_to :controller => "static", :action => "index"

        return
      rescue OpenID::OpenIDError
        escaped_url = CGI.escapeHTML(openid_url)
        flash[:notice] = "Could not find OpenID server for #{escaped_url}"

        redirect_to :controller => "static", :action => "index"

        return
      end

      return_to = url_for :action => 'complete'
      trust_root = url_for :controller => 'static', :action => 'index'

      url = request.redirect_url(trust_root, return_to)

      redirect_to url
    end
  end

  # handle the openid server response
  def complete
    current_url = url_for :action => 'complete', :only_path => false
    parameters = params.reject{|k,v|request.path_parameters[k]}
    response = consumer.complete(parameters, current_url)

    case response.status
    when OpenID::Consumer::SUCCESS
      @user = User.find_or_initialize_by_openid_url(response.identity_url)

      if @user.new_record?
        @user[:uri] = response.identity_url
        @user.save!
      end

      session[:user_id] = @user.id

      redirect_to :controller => "user", :action => "show"

      return
    when OpenID::Consumer::FAILURE
      if response.identity_url
        escaped_url = CGI.escapeHTML(response.identity_url)
        flash[:notice] = "OpenID verification for #{escaped_url} failed."
      else
        flash[:notice] = 'OpenID verification failed.'
      end
    when OpenID::Consumer::CANCEL
      flash[:notice] = 'OpenID verification cancelled.'
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
    store = OpenID::Store::Filesystem.new(store_dir)

    return OpenID::Consumer.new(session, store)
  end
end
