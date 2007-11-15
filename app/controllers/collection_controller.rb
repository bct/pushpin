class CollectionController < ApplicationController
  def show
    @collections = @user ? @user.collections : []

    @coll_url = params[:url]

    @coll = Atom::Collection.new @coll_url, new_atom_http

    maybe_needs_authorization('url' => @coll_url) do
      @coll.update!

      if @coll.title
        coll = find_coll(@coll_url)

        if coll
          coll.title = @coll.title.html
          coll.save
        end
      end

      @entry = Atom::Entry.new

      respond_to do |wants|
        wants.html # show.rhtml
        wants.xml  { render :xml => @collection.to_xml }
      end
    end
  end

  def edit
    @collection = find_coll(params[:url])
  end

  def create
    @coll_url = params[:url]

    @entry = make_entry(params[:entry])

    @coll = Atom::Collection.new params[:url], new_atom_http

    maybe_needs_authorization('url' => @coll_url, 'entry' => { 'original' => @entry.to_s}) do
      @res = @coll.post! @entry

      if @res.code == '201'
        flash[:notice] = %{Entry was successfully created. <a href="#{@res["Location"]}">link</a>.}
        redirect_to :controller => 'collection', :action => 'show', :url => params[:url]
      else
        raise "the server at #{@coll_url} responded to my POST with unexpected status code #{@res.code}"
      end
    end
  end

  def update
    @collection = find_coll(params[:collection][:url])

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
