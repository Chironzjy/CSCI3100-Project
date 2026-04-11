require "test_helper"

class StaleAlertJobTest < ActiveJob::TestCase
  setup do
    @system_user = User.find_or_create_by!(email: "system@local") do |user|
      user.password = "password123"
      user.user_name = "System"
      user.location = "CUHK"
      user.latitude = 22.4133
      user.longitude = 114.2104
    end

    @item = items(:one)
    @item.update!(status: "inactive", updated_at: 20.days.ago)
  end

  test "sends renewal reminder for inactive item older than 15 days" do
    assert_difference("Message.count", 1) do
      StaleAlertJob.perform_now
    end

    message = Message.last
    assert_equal @system_user.id, message.user_id
    assert_includes message.body, "inactive for over 15 days"
  end

  test "does not duplicate stale alert when rerun without item updates" do
    StaleAlertJob.perform_now

    assert_no_difference("Message.count") do
      StaleAlertJob.perform_now
    end
  end

  test "deletes inactive item older than 30 days" do
    @item.update!(updated_at: 40.days.ago)

    assert_difference("Item.count", -1) do
      StaleAlertJob.perform_now
    end
  end

  test "does not delete available item even if old" do
    @item.update!(status: "available", updated_at: 60.days.ago)

    assert_no_difference("Item.count") do
      StaleAlertJob.perform_now
    end
  end
end
