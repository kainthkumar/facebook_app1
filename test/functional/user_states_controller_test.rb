require 'test_helper'

class UserStatesControllerTest < ActionController::TestCase
  setup do
    @user_state = user_states(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_states)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_state" do
    assert_difference('UserState.count') do
      post :create, user_state: { model_id: @user_state.model_id }
    end

    assert_redirected_to user_state_path(assigns(:user_state))
  end

  test "should show user_state" do
    get :show, id: @user_state
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_state
    assert_response :success
  end

  test "should update user_state" do
    put :update, id: @user_state, user_state: { model_id: @user_state.model_id }
    assert_redirected_to user_state_path(assigns(:user_state))
  end

  test "should destroy user_state" do
    assert_difference('UserState.count', -1) do
      delete :destroy, id: @user_state
    end

    assert_redirected_to user_states_path
  end
end
