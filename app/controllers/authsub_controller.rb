class AuthsubController < ApplicationController
  def show
    token = params[:token]

    if @user
      # exchange for session token
      h = Atom::HTTP.new
      h.token = token
      h.always_auth = :authsub
      r = h.get "https://www.google.com/accounts/AuthSubSessionToken"
      token = r.body.split(/=/).last.chomp

      AuthsubToken.create(:user_id => @user.id, :token => token)
    end

    dr = DelayedRequest.find(params[:id])
    dr.destroy

    c = dr[:controller]
    a = dr[:action]

    ps = YAML.load dr[:params]
    ps[:token] = token

    if dr[:method] == 'get'
      redirect_to({:controller => c, :action => a}.merge(ps))
    else
      render_component :controller => c, :action => a, :params => ps
    end
  end
end
