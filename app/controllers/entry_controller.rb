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

    maybe_needs_authorization('url' => @entry_url, 'coll_url' => @coll_url) do
      @entry = new_atom_http.get_atom_entry @entry_url
    end
  end

  def update
    @entry_url = params[:url]
    @coll_url = params[:coll_url]

    @entry = make_entry(params[:entry])

    maybe_needs_authorization('url' => @entry_url, 'coll_url' => @coll_url, 'entry' => { 'original' => @entry.to_s }) do
      @res = new_atom_http.put_atom_entry(@entry, @entry_url)

      if @res.is_a? Net::HTTPSuccess
        flash[:notice] = 'Entry was successfully updated.'
        redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
      else
        raise "the server at #{@entry_url} responded to my PUT with unexpected status code #{@res.code}"
      end
    end
  end

  def destroy
    @delete_url = params[:url]
    @coll_url = params[:coll_url]

    @needs_auth = false
    begin
      @res = new_atom_http.delete(@delete_url)
    rescue Atom::Unauthorized
      @needs_auth = true
    rescue NeedAuthSub
      @needs_auth = :authsub
      next_url = authsub_url('url' => @delete_url, 'coll_url' => @coll_url)
    end

    respond_to do |wants|
      wants.html do
        if not @needs_auth
          if @res.is_a? Net::HTTPSuccess
            flash[:notice] = 'Entry was deleted.'
            redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
          else
            raise "the server at #{@delete_url} responded to my PUT with unexpected status code #{@res.code}"
          end
        elsif @needs_auth == :authsub
          redirect_to next_url
        else
          obtain_authorization(:delete, 'url' => @delete_url, 'coll_url' => @coll_url)
        end
      end
      wants.json do
        if not @unauthorized
          if @res.is_a? Net::HTTPSuccess
            render :json => {:status => "success"}.to_json
          else
            raise 'oops'
          end
        elsif @needs_auth == :authsub
          render :json => {:status => 'needtokenauth',
                           :redirect_to => next_url    }.to_json,
                 :status => 401
        else
          render :json => {:status => 'unauthorized',
                           :url => @delete_url,
                           :coll_url => @coll_url,
                           :abs_url => @abs_url,
                           :realm => @realm           }.to_json,
                 :status => 401
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
