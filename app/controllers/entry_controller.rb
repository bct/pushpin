class EntryController < ApplicationController
  # create a new entry
  def index
  end

  # edit an existing entry
  def editor
    @entry_url = params[:url]
    @coll_url = params[:coll_url]

    # XXX check that 'url' was given
   
    @entry = new_atom_http.get_atom_entry @entry_url
  rescue Atom::Unauthorized
    render :action => 'get_auth'
  end

  def update
    @entry_url = params[:url]
    @coll_url = params[:coll_url]

    @entry = make_entry(params[:entry])

    begin
      @res = new_atom_http.put_atom_entry(@entry, params[:url])

      if @res.code == '200'
        flash[:notice] = 'Entry was successfully updated.'
        redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
      else
        raise 'oops'
      end
    rescue Atom::Unauthorized
      render :action => 'get_put_auth'
    end
  end

  def destroy
    http = new_atom_http

    begin
      @res = http.delete(params[:url])

      if @res.code == '200'
        flash[:notice] = 'Entry was deleted.'
        redirect_to :controller => 'collection', :action => 'show', :url => params[:coll_url]
      else
        raise 'oops'
      end
    rescue Atom::Unauthorized
      @delete_url = params[:url]
      @coll_url = params[:coll_url]

      render :action => 'get_delete_auth'
    end
  end
end
