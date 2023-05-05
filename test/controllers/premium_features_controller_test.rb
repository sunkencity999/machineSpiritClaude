require "test_helper"

class PremiumFeaturesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get premium_features_index_url
    assert_response :success
  end
end
