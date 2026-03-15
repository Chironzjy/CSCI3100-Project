require "test_helper"

class ItemTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "should be valid with all attributes" do
    item = Item.new(
      name: "Test Item",
      description: "This is a test description.",
      status: "active",
      user: @user
    )
    assert item.valid?
  end

  test "should be invalid without a name" do
    item = Item.new(name: nil, user: @user)
    assert_not item.valid?
    assert_includes item.errors[:name], "can't be blank"
  end

  test "should belong to a user" do
    item = Item.new(name: "Orphan Item")
    assert_not item.valid?
    assert_includes item.errors[:user], "must exist"
  end

end