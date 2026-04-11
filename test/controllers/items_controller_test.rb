require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user

    @item = items(:one)
  end

  test "should get index" do
    get items_url
    assert_response :success
    assert_match @item.title, response.body
  end

  test "should get new" do
    get new_item_url
    assert_response :success
  end

  test "should create item" do
    assert_difference("Item.count", 1) do
      post items_url, params: {
        item: {
          title: "New Item",
          description: "New Desc",
          price: 50,
          category: "Books",
          location: "MTR University",
          latitude: 22.4138,
          longitude: 114.2102,
          visibility_scope: "campus"
        }
      }
    end
    assert_redirected_to item_url(Item.last)
    follow_redirect!
    assert_match "Item listed successfully!", response.body
  end

  test "should not create item with invalid params" do
    assert_no_difference("Item.count") do
      post items_url, params: { item: { title: nil } }
    end
    assert_response :unprocessable_entity
  end

  test "should show item" do
    get item_url(@item)
    assert_response :success
    assert_match @item.title, response.body
  end

  test "should get nearby sellers map" do
    get map_items_url, params: { radius: 8 }
    assert_response :success
    assert_match "Nearby Sellers", response.body
  end

  test "map should show fallback when user has no coordinates" do
    @user.update!(latitude: nil, longitude: nil)
    get map_items_url

    assert_response :success
    assert_match(/results are sorted by latest listings instead of distance|No geocoded listings found in this range yet/, response.body)
  end

  test "should get edit" do
    get edit_item_url(@item)
    assert_response :success
  end

  test "should update item" do
    patch item_url(@item), params: { item: { title: "Updated Name" } }
    assert_redirected_to item_url(@item)
    @item.reload
    assert_equal "Updated Name", @item.title
    follow_redirect!
    assert_match "Item updated successfully!", response.body
  end

  test "should not update item with invalid params" do
    patch item_url(@item), params: { item: { title: nil } }
    assert_response :unprocessable_entity
    @item.reload
    assert_not_nil @item.title
  end

  test "should destroy item" do
    assert_difference("Item.count", -1) do
      delete item_url(@item)
    end
    assert_redirected_to items_url
    follow_redirect!
    assert_match "Listing removed.", response.body
  end

end