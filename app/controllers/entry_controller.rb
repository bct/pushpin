class EntryController < ApplicationController
  # create a new entry
  def index; end

  def create
    @entry = make_entry(params[:entry])
  end

  # edit an existing entry
  def edit
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
      @res = new_atom_http.put_atom_entry(@entry, @entry_url)

      if @res.code == '200'
        flash[:notice] = 'Entry was successfully updated.'
        redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
      else
        raise "the server at #{@entry_url} responded to my PUT with unexpected status code #{@res.code}"
      end
    rescue Atom::Unauthorized
      render :action => 'get_put_auth'
    end
  end

  def destroy
    @delete_url = params[:url]
    @coll_url = params[:coll_url]

    @unauthorized = false
    begin
      @res = new_atom_http.delete(@delete_url)
    rescue Atom::Unauthorized
      @unauthorized = true
    end

    respond_to do |wants|
      wants.html do
        unless @unauthorized
          if @res.code == '200'
            flash[:notice] = 'Entry was deleted.'
            redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
          else
            raise "the server at #{@delete_url} responded to my PUT with unexpected status code #{@res.code}"
          end
        else
          render :action => 'get_delete_auth'
        end
      end
      wants.json do
        unless @unauthorized
          if @res.code == '200'
            render :json => {:status => "success"}.to_json
          else
            raise 'oops'
          end
        else
          render :json => {:status => "unauthorized"}.to_json, :status => 401
        end
      end
    end
  end
end
