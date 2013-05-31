require 'test_helper'

class EventsPropertiesControllerTest < ActionController::TestCase
  setup do
    @events_property = events_properties(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events_properties)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create events_property" do
    assert_difference('EventsProperty.count') do
      post :create, events_property: { event_id: @events_property.event_id, name: @events_property.name, value: @events_property.value }
    end

    assert_redirected_to events_property_path(assigns(:events_property))
  end

  test "should show events_property" do
    get :show, id: @events_property
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @events_property
    assert_response :success
  end

  test "should update events_property" do
    put :update, id: @events_property, events_property: { event_id: @events_property.event_id, name: @events_property.name, value: @events_property.value }
    assert_redirected_to events_property_path(assigns(:events_property))
  end

  test "should destroy events_property" do
    assert_difference('EventsProperty.count', -1) do
      delete :destroy, id: @events_property
    end

    assert_redirected_to events_properties_path
  end
end
