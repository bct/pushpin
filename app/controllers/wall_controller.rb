class WallController < ApplicationController
  # GET /wall
  def show
    return redirect_to :controller => 'static', :action => 'index' unless @user

    @collections = @user.collections

    respond_to do |format|
      format.html # index.rhtml
    end
  end
  
  def new
    @collection = Collection.new
  end

  def create
    _url = params[:collection][:url]

    http = new_atom_http
    res = http.get(@coll_url, "Accept" => "application/atom+xml;type=feed, application/atomsvc+xml, application/xhtml+xml;q=0.6, text/html;q=0.5")

    if res.code == '200'
      case res["Content-Type"]
      when /application\/atom\+xml/
        @collection = Collection.new(:url => @coll_url, :user_id => @user)

        if @collection.save
          flash[:notice] = 'Collection was successfully created.'
          redirect_to :controller => 'collection', :action => 'show', :url => @collection.url
        else
          raise "couldn't save collection"
        end
      when /application\/atomsvc\+xml/
        @service = Atom::Service.parse(res.body)

        @collections = []

        @service.collections.each do |acoll|
          coll = Collection.new(:url => acoll.uri.to_s, :user_id => @user)
          unless coll.save
            raise coll.errors.inspect
          end
          @collections << coll
        end

        flash[:notice] = "i added the collections i found there."
        redirect_to :action => 'show'
      when /text\/html/, /application\/xhtml\+xml/
        raise "collection autodiscovery from HTML not yet implemented"
      else
        raise "i don't know how to get a collection from a document of type #{res['Content-Type']}"
      end
    else
      raise "#{@coll_url} responded with unexpected status: #{res.code}"
    end
  end

  def destroy
    @collection = find_coll(params[:url])
    
    @collection.destroy

    respond_to do |format|
      format.html { redirect_to wall_url }
    end
  end
end
