require "test_helper"

class UserGuideControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_guide_index_url
    assert_response :success
  end
end
