require 'test_helper'

class InboxControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get replay" do
    get :replay
    assert_response :success
  end

end
