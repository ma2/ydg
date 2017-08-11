require 'test_helper'

class OosamaControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get oosama_index_url
    assert_response :success
  end

end
