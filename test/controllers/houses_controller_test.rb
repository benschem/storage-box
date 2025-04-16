require "test_helper"

class HousesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get houses_show_url
    assert_response :success
  end

  test "should get create" do
    get houses_create_url
    assert_response :success
  end

  test "should get update" do
    get houses_update_url
    assert_response :success
  end

  test "should get destroy" do
    get houses_destroy_url
    assert_response :success
  end
end
