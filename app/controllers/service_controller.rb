class ServiceController < ApplicationController
  def show
    serv_url = n_url params[:url]

    @title = 'browsing service document.'

    maybe_needs_authorization('url' => serv_url) do
      @service = Atom::Service.discover serv_url, new_atom_http
    end
  rescue Atom::AutodiscoveryFailure
    @title = "couldn't find any collections."

    render :template => 'static/autodiscovery_failure'
  end
end
