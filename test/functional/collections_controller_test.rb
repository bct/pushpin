require File.dirname(__FILE__) + '/../test_helper'
require 'collections_controller'

# Re-raise errors caught by the controller.
class CollectionsController; def rescue_action(e) raise e end; end

class CollectionsControllerTest < Test::Unit::TestCase
  fixtures :collections

  def setup
    @controller = CollectionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:collections)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_collection
    old_count = Collection.count
    post :create, :collection => { }
    assert_equal old_count+1, Collection.count
    
    assert_redirected_to collection_path(assigns(:collection))
  end

  def test_should_show_collection
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_collection
    put :update, :id => 1, :collection => { }
    assert_redirected_to collection_path(assigns(:collection))
  end
  
  def test_should_destroy_collection
    old_count = Collection.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Collection.count
    
    assert_redirected_to collections_path
  end
end
