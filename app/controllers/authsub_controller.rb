class AuthsubController < ApplicationController
  def show
    token = params[:token]

    # exchange for session token
    h = Atom::HTTP.new
    h.token = token
    h.always_auth = :authsub
    r = h.get "http://www.google.com/accounts/AuthSubSessionToken"
    token = r.body.split(/=/).last.chomp

    AuthsubToken.create(:user_id => @user.id, :token => token)

    dr = DelayedRequest.find(params[:id])

    if dr[:method] == 'get'
      redirect_to dr.url
    end
  end
end
