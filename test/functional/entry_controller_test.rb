require File.dirname(__FILE__) + '/../test_helper'
require 'entry_controller'

# Re-raise errors caught by the controller.
class EntryController; def rescue_action(e) raise e end; end

class EntryControllerTest < Test::Unit::TestCase
  def setup
    @controller = EntryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    with_options :controller => 'entry' do |test|
      test.assert_routing 'entry',   :action => 'index'
      test.assert_routing 'entry/edit', :action => 'edit'
    end
  end
end
