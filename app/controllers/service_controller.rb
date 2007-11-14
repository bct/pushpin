class ServiceController < ApplicationController
  def show
    @serv_url = params[:url]
    @service = Atom::Service.new @serv_url, new_atom_http

  rescue Atom::Unauthorized
    obtain_authorization(:get, 'url' => @serv_url)
  end
end
