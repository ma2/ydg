require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  test "should get callback" do
    get api_callback_url
    assert_response :success
  end

end
