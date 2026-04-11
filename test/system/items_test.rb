require "application_system_test_case"

class ItemsTest < ApplicationSystemTestCase
  test "visiting login page" do
    visit user_session_path
    assert_text "Log in"
  end
end
