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

  test "finalize_reservation! marks item back to available when stock remains" do
    item = items(:one)
    item.update!(status: "reserved", reserved_at: 49.hours.ago, stock_quantity: 2)

    item.finalize_reservation!
    item.reload

    assert_equal "available", item.status
    assert_equal 1, item.stock_quantity
    assert_nil item.reserved_at
  end

  test "finalize_reservation! marks item sold when stock reaches zero" do
    item = items(:one)
    item.update!(status: "reserved", reserved_at: 49.hours.ago, stock_quantity: 1)

    item.finalize_reservation!
    item.reload

    assert_equal "sold", item.status
    assert_equal 0, item.stock_quantity
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