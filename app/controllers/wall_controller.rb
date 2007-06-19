class WallController < ApplicationController
  # GET /wall
  def show
    @user = find_user

    @collections = @user ? @user.collections : []

    respond_to do |format|
      format.html # index.rhtml
    end
  end
  
  def new
    @collection = Collection.new
  end

  def create
    @user = find_user
    @collection = Collection.new(params[:collection].merge(:user_id => @user))

    respond_to do |format|
      if @collection.save
        flash[:notice] = 'Collection was successfully created.'
        format.html { redirect_to :controller => 'collection', :action => 'show', :url => @collection.url }
      else
        format.html { render :action => 'new' }
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
end
