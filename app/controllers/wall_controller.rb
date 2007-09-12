class WallController < ApplicationController
  # GET /wall
  def show
    @collections = @user ? @user.collections : []

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
    res = http.get(_url, "Accept" => "application/atom+xml;type=feed, application/atomsvc+xml, application/xhtml+xml;q=0.6, text/html;q=0.5")

    if res.code == '200'
      case res["Content-Type"]
      when /application\/atom\+xml/
        @collection = Collection.new(:url => _url, :user_id => @user)

        if @collection.save
          flash[:notice] = 'Collection was successfully created.'
          redirect_to :controller => 'collection', :action => 'show', :url => @collection.url
        else
          raise "oops"
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

        flash[:notice] = "I added the collections I found there."
        redirect_to :action => 'show'
      when /text\/html/, /application\/xhtml\+xml/
        raise "autodiscovery not yet implemented" 
      else
        raise "oops"
      end
    else
      raise "oops"
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
