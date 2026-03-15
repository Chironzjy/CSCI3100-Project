require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user

    @item = items(:one)
  end

  test "should get index" do
    get items_url
    assert_response :success
    assert_not_nil assigns(:items)
  end

  test "should get new" do
    get new_item_url
    assert_response :success
  end

  test "should create item" do
    assert_difference("Item.count", 1) do
      post items_url, params: { item: { name: "New Item", description: "New Desc", status: "draft" } }
    end
    assert_redirected_to item_url(Item.last)
    follow_redirect!
    assert_match "Item was successfully created.", response.body
  end

  test "should not create item with invalid params" do
    assert_no_difference("Item.count") do
      post items_url, params: { item: { name: nil } }
    end
    assert_response :unprocessable_entity
  end

  test "should show item" do
    get item_url(@item)
    assert_response :success
    assert_equal @item, assigns(:item)
  end

  test "should get edit" do
    get edit_item_url(@item)
    assert_response :success
  end

  test "should update item" do
    patch item_url(@item), params: { item: { name: "Updated Name" } }
    assert_redirected_to item_url(@item)
    @item.reload
    assert_equal "Updated Name", @item.name
    follow_redirect!
    assert_match "Item was successfully updated.", response.body
  end

  test "should not update item with invalid params" do
    patch item_url(@item), params: { item: { name: nil } }
    assert_response :unprocessable_entity
    @item.reload
    assert_not_equal nil, @item.name
  end

  test "should destroy item" do
    assert_difference("Item.count", -1) do
      delete item_url(@item)
    end
    assert_redirected_to items_url
    follow_redirect!
    assert_match "Item was successfully destroyed.", response.body
  end

end