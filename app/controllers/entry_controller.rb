class EntryController < ApplicationController
  # create a new entry
  def index
  end

  # edit an existing entry
  def editor
    @entry_url = params[:url]
    @coll_url = params[:coll_url]

    # XXX check that 'url' was given
   
    @user = find_user
   
    @entry = new_atom_http.get_atom_entry @entry_url
  rescue Atom::Unauthorized
    render :action => 'get_auth'
  end

  def update
    @entry_url = params[:url]
    @coll_url = params[:coll_url]

    @user = find_user
 
    @entry = make_entry(params[:entry])

    @res = new_atom_http.put_atom_entry(@entry, params[:url])

    if @res.code == '200'
      flash[:notice] = 'Entry was successfully updated.'
      redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
    else
      render :action => 'edit'
    end
  end
end
