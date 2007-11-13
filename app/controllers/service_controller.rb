class ServiceController < ApplicationController
  def show
    @serv_url = params[:url]

    @service = Atom::Service.new @serv_url
  rescue Atom::Unauthorized
    obtain_authorization(:get, 'url' => @serv_url)
  end
end
