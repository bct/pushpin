class CollectionController < ApplicationController
  before_filter :login_required, :only => [:new, :create]

  def show
    @coll_url = params[:url]

    @coll = Atom::Collection.new @coll_url, new_atom_http
    @coll.update!

    @user = find_user

    if @coll.title
      coll = find_coll(@coll_url)

      if coll
        coll.title = @coll.title.html
        coll.save
      end
    end

    @entry = Atom::Entry.new

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @collection.to_xml }
    end
  end

  def new
    @collection = Collection.new
  end

  def edit
    @user = find_user

    @collection = find_collection(params[:url])
  end

  def create
    @user = find_user
    @entry = make_entry(params[:entry])

    @coll = Atom::Collection.new params[:url], new_atom_http

    @res = @coll.post! @entry

    respond_to do |format|
      if @res.code == '201'
        flash[:notice] = 'Entry was successfully created.'
        format.html { redirect_to :action => 'show', :url => params[:url] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collection.errors.to_xml }
      end
    end
  end

  def update
    @user = find_user
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

  def destroy
    @user = find_user
    @collection = find_coll(params[:url])
    
    @collection.destroy

    respond_to do |format|
      format.html { redirect_to wall_url }
    end
  end
 
  def find_coll(url)
    Collection.find(:first, :conditions => ['url = ? and user_id = ?', params[:url], @user])
  end
end
