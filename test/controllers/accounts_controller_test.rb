require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get accounts_update_url
    assert_response :success
  end
end
