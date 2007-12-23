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

    @entry = make_entry(params[:entry])

    @coll = find_coll(@coll_url)

    maybe_needs_authorization('url' => @coll_url, 'entry' => { 'original' => @entry.to_s}) do
      @res = @coll.post! @entry

      if @res.code == '201'
        flash[:notice] = %{Entry was successfully created. <a href="#{@res["Location"]}">link</a>.}

        if @redirect
          redirect_to @redirect
        else
          redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
        end
      else
        @status = 500

        render :template => 'static/remote_failure'
      end
    end
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
