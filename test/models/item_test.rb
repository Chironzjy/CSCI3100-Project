require "test_helper"

class ItemTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "should be valid with all attributes" do
    item = Item.new(valid_item_attributes)
    assert item.valid?
  end

  test "should be invalid without a title" do
    item = Item.new(valid_item_attributes.merge(title: nil))
    assert_not item.valid?
    assert_includes item.errors[:title], "can't be blank"
  end

  test "should belong to a user" do
    item = Item.new(valid_item_attributes.except(:user))
    assert_not item.valid?
    assert_includes item.errors[:user], "must exist"
  end

  private

  def valid_item_attributes
    {
      title: "Test Item",
      description: "This is a test description.",
      price: 100,
      category: "Electronics",
      status: "available",
      location: "MTR University",
      latitude: 22.4138,
      longitude: 114.2102,
      visibility_scope: "campus",
      user: @user
    }
  end

end