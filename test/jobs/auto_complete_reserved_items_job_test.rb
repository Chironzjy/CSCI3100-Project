require "test_helper"

class AutoCompleteReservedItemsJobTest < ActiveJob::TestCase
  setup do
    @system_user = User.find_or_create_by!(email: "system@local") do |user|
      user.password = "password123"
      user.user_name = "System"
      user.location = "CUHK"
      user.latitude = 22.4133
      user.longitude = 114.2104
    end

    @item = items(:one)
    @item.update_columns(status: "reserved", reserved_at: 49.hours.ago, stock_quantity: 1)
  end

  test "creates one system message when auto-completing a reservation" do
    assert_difference("Message.count", 1) do
      AutoCompleteReservedItemsJob.perform_now
    end

    @item.reload
    assert_equal "sold", @item.status

    message = Message.last
    assert_equal @system_user.id, message.user_id
    assert_includes message.body, "automatically marked as sold"
  end

  test "does not duplicate the same system message on retry" do
    AutoCompleteReservedItemsJob.perform_now

    assert_no_difference("Message.count") do
      AutoCompleteReservedItemsJob.perform_now
    end
  end
end
