# a remote Atom Publishing Protocol Collection
class CollectionController < ApplicationController
  def show
    @collections = @user ? @user.collections : []

    @coll_url = n_url params[:url]
    @coll = find_coll(@coll_url)

    maybe_needs_authorization('url' => @coll_url) do
      @coll.update!

      @entry = Atom::Entry.new

      respond_to do |wants|
        wants.html # show.rhtml
        wants.xml  { render :xml => @collection.to_xml }
      end
    end
  rescue Atom::WrongMimetype => e
    flash[:error] = "#{CGI.escapeHTML @coll_url} doesn't seem to be an Atom Collection (wrong Content-Type)."

    if @user
      redirect_to user_path
    else
      redirect_to ''
    end
  end

  # form for POSTing a new Entry
  def new
    @coll_url = n_url params[:url]
    @redirect = params[:redirect]

    @entry = make_entry(params[:entry])

    @coll = find_coll(@coll_url)
  end

  # POSTing a new entry
  def create
    @coll_url = n_url params[:url]
    @redirect = params[:redirect]

    @coll = find_coll(@coll_url)

    if params.member? :new_file_url or params.member? :new_file_upload
      post_media_entry
    else
      @entry = make_entry(params[:entry])

      post_regular_entry
    end
  end

  def post_regular_entry
    maybe_needs_authorization('url' => @coll_url, 'entry' => { 'original' => @entry.to_s}) do
      @res = @coll.post! @entry

      if @redirect
        redirect_to @redirect
      else
        flsh = 'Entry was successfully created.'

        if @res['Content-Type'].match /atom\+xml/
          entry = Atom::Entry.parse @res.body, @res['Location']

          alt = entry.links.find { |l| l['rel'] == 'alternate' }

          if alt
            flsh += %{ <a href="#{CGI.escapeHTML alt['href']}">link</a>.}
          end
        end

        flash[:notice] = flsh

        redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
      end
    end
  rescue RemoteFailure => e
    @res = e.res

    @status = 500

    render :template => 'static/remote_failure'
  end

  def post_media_entry
    # XXX maximum file size limits or at least tracking

    if params[:new_file_upload].respond_to? :read
      media = params[:new_file_upload].read
      mimetype = params[:new_file_upload].content_type
    elsif params[:new_file_url] and not params[:new_file_url].empty?
      res = @coll.http.get params[:new_file_url]

      media = res.body
      mimetype = res['Content-Type']
    end

    maybe_needs_authorization('url' => @coll_url, 'entry' => { 'original' => @entry.to_s}) do
      @res = @coll.post_media!(media, mimetype) do |orig|
        ps = params[:entry]

        if orig
          ps[:original] = @res.body
        end

        @entry = make_entry(ps)
      end

      if @redirect
        redirect_to @redirect
      else
        flash[:notice] = 'Media entry successfully created.'

        redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
      end
    end
  rescue RemoteFailure => e
    @res = e.res

    @status = 500

    render :template => 'static/remote_failure'
  end

  # form for editing an existing entry
  def edit
    @collection = Collection.find_by_url_and_user_id(n_url(params[:url]), @user)
  end

  # updates this collection's details
  def update
    @coll_url = n_url params[:collection][:url]
    @collection = Collection.find_by_url_and_user_id(@coll_url, @user)

    respond_to do |format|
      if @collection.update_attributes(params[:collection])
        flash[:notice] = 'collection was successfully updated.'
        format.html { redirect_to collection_path(:url => @coll_url) }
      else
        raise "couldn't save the updated collection's details"
      end
    end
  end
end
