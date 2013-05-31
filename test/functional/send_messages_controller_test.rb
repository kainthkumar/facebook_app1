require 'test_helper'

class SendMessagesControllerTest < ActionController::TestCase
  setup do
    @send_message = send_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:send_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create send_message" do
    assert_difference('SendMessage.count') do
      post :create, send_message: {  }
    end

    assert_redirected_to send_message_path(assigns(:send_message))
  end

  test "should show send_message" do
    get :show, id: @send_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @send_message
    assert_response :success
  end

  test "should update send_message" do
    put :update, id: @send_message, send_message: {  }
    assert_redirected_to send_message_path(assigns(:send_message))
  end

  test "should destroy send_message" do
    assert_difference('SendMessage.count', -1) do
      delete :destroy, id: @send_message
    end

    assert_redirected_to send_messages_path
  end
end
