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

  def new
    @coll_url = n_url params[:url]
    @coll = find_coll(@coll_url)

    @entry = Atom::Entry.new
  end

  def edit
    @collection = Collection.find_by_url_and_user_id(n_url(params[:url]), @user)
  end

  def create
    @coll_url = n_url params[:url]

    @entry = make_entry(params[:entry])

    @coll = find_coll(@coll_url)

    maybe_needs_authorization('url' => @coll_url, 'entry' => { 'original' => @entry.to_s}) do
      @res = @coll.post! @entry

      if @res.code == '201'
        flash[:notice] = %{Entry was successfully created. <a href="#{@res["Location"]}">link</a>.}
        redirect_to :controller => 'collection', :action => 'show', :url => @coll_url
      else
        raise "the server at #{@coll_url} responded to my POST with unexpected status code #{@res.code}"
      end
    end
  end

  def update
    @collection = Collection.find_by_url_and_user_id(n_url(params[:collection][:url]), @user)

    respond_to do |format|
      if @collection.update_attributes(params[:collection])
        flash[:notice] = 'Collection was successfully updated.'
        format.html { redirect_to :action => 'show', :url => @collection.url }
      else
        format.html { render :action => "edit" }
      end
    end
  end
end
