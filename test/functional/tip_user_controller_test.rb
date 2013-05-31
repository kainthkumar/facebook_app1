require 'test_helper'

class TipUserControllerTest < ActionController::TestCase
  test "should get send_notification" do
    get :send_notification
    assert_response :success
  end

  test "should get send_message" do
    get :send_message
    assert_response :success
  end

end
