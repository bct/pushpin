class CollectionsController < ApplicationController
  # GET /collections
  # GET /collections.xml
  def index
    @collections = Collection.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @collections.to_xml }
    end
  end

  # GET /collections/1
  # GET /collections/1.xml
  def show
    @collection = Collection.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @collection.to_xml }
    end
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1;edit
  def edit
    @collection = Collection.find(params[:id])
  end

  # POST /collections
  # POST /collections.xml
  def create
    @collection = Collection.new(params[:collection])

    respond_to do |format|
      if @collection.save
        flash[:notice] = 'Collection was successfully created.'
        format.html { redirect_to collection_url(@collection) }
        format.xml  { head :created, :location => collection_url(@collection) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collection.errors.to_xml }
      end
    end
  end

  # PUT /collections/1
  # PUT /collections/1.xml
  def update
    @collection = Collection.find(params[:id])

    respond_to do |format|
      if @collection.update_attributes(params[:collection])
        flash[:notice] = 'Collection was successfully updated.'
        format.html { redirect_to collection_url(@collection) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collection.errors.to_xml }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.xml
  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy

    respond_to do |format|
      format.html { redirect_to collections_url }
      format.xml  { head :ok }
    end
  end
end
