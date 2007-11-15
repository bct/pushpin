class ServiceController < ApplicationController
  def show
    @serv_url = params[:url]

    maybe_needs_authorization('url' => @serv_url) do
      @service = Atom::Service.new @serv_url, new_atom_http
    end
  end
end
