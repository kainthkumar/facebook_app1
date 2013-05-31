require 'test_helper'

class TrackControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
