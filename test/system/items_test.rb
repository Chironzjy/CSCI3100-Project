require "application_system_test_case"

class ItemsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    visit login_url
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    @item = items(:one)
  end

  test "visiting the index" do
    visit items_url
    assert_selector "h1", text: "Items"
    assert_text @item.name
  end

  test "creating a new item" do
    visit items_url
    click_on "New Item"

    fill_in "Name", with: "System Test Item"
    fill_in "Description", with: "Created by system test"
    select "active", from: "Status"
    click_on "Create Item"

    assert_text "Item was successfully created"
    assert_text "System Test Item"
  end

  test "updating an item" do
    visit items_url
    within "tr#item_#{@item.id}" do
      click_on "Edit"
    end

    fill_in "Name", with: "Updated System Test Name"
    click_on "Update Item"

    assert_text "Item was successfully updated"
    assert_text "Updated System Test Name"
  end

  test "destroying an item" do
    visit items_url
    page.accept_confirm do
      within "tr#item_#{@item.id}" do
        click_on "Delete"
      end
    end

    assert_text "Item was successfully destroyed"
    assert_no_text @item.name
  end
end