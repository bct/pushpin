class EntryController < ApplicationController
  # create a new entry
  def index
  end

  # edit an existing entry
  def edit
    @entry_url = params[:url]
    @coll_url = params[:coll_url]

    # XXX check that 'url' was given
   
    # get_user
   
    @entry = new_atom_http.get_atom_entry @entry_url
  rescue Atom::Unauthorized
    render :action => 'get_auth'
  end

  def update
    @entry_url = params[:url]
    @coll_url = params[:coll_url]

    # get_user
   
  end
end
