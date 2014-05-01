require 'test_helper'

class BmetLaborHoursControllerTest < ActionController::TestCase
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = createTestUser()
    sign_in user
    @bmet_labor_hour = bmet_labor_hours(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bmet_labor_hours)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bmet_labor_hour" do
    assert_difference('BmetLaborHour.count') do
      post :create, bmet_labor_hour: { bmet_work_order_id: @bmet_labor_hour.bmet_work_order_id, date_started: @bmet_labor_hour.date_started, duration: @bmet_labor_hour.duration, technician_id: @bmet_labor_hour.technician_id }
    end

    assert_redirected_to @bmet_labor_hour.bmet_work_order
  end

  test "should show bmet_labor_hour" do
    get :show, id: @bmet_labor_hour
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bmet_labor_hour
    assert_response :success
  end

  test "should update bmet_labor_hour" do
    patch :update, id: @bmet_labor_hour, bmet_labor_hour: { bmet_work_order_id: @bmet_labor_hour.bmet_work_order_id, date_started: @bmet_labor_hour.date_started, duration: @bmet_labor_hour.duration, technician_id: @bmet_labor_hour.technician_id }
    assert_redirected_to @bmet_labor_hour.bmet_work_order
  end

  test "should destroy bmet_labor_hour" do
    assert_difference('BmetLaborHour.count', -1) do
      delete :destroy, id: @bmet_labor_hour
    end

    assert_redirected_to @bmet_labor_hour.bmet_work_order
  end
end