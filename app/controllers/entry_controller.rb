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

    @entry = new_atom_http.get_atom_entry @entry_url
  rescue Atom::Unauthorized
    obtain_authorization(:get, 'url' => @entry_url, 'coll_url' => @coll_url)
  end

  def update
    @entry_url = params[:url]
    @coll_url = params[:coll_url]

    @entry = make_entry(params[:entry])

    begin
      @res = new_atom_http.put_atom_entry(@entry, @entry_url)

      if @res.is_a? Net::HTTPSuccess
        flash[:notice] = 'Entry was successfully updated.'
        redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
      else
        raise "the server at #{@entry_url} responded to my PUT with unexpected status code #{@res.code}"
      end
    rescue Atom::Unauthorized
      obtain_authorization(:put, 'url' => @entry_url, 'coll_url' => @coll_url, 'entry[original]' => @entry.to_s)
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
          if @res.is_a? Net::HTTPSuccess
            flash[:notice] = 'Entry was deleted.'
            redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
          else
            raise "the server at #{@delete_url} responded to my PUT with unexpected status code #{@res.code}"
          end
        else
          obtain_authorization(:delete, 'url' => @delete_url, 'coll_url' => @coll_url)
        end
      end
      wants.json do
        unless @unauthorized
          if @res.is_a? Net::HTTPSuccess
            render :json => {:status => "success"}.to_json
          else
            raise 'oops'
          end
        else
          render :json => {:status => "unauthorized",
                           :url => @delete_url,
                           :coll_url => @coll_url,
                           :abs_url => @abs_url,
                           :realm => @realm           }.to_json, :status => 401
        end
      end
    end
  end

  def delete_authorization
    @abs_url = params[:abs_url]
    @realm = params[:realm]

    @continue_path = entry_path
    obtain_authorization(:delete, 'url' => params[:url], 'coll_url' => params[:coll_url])
  end
end
