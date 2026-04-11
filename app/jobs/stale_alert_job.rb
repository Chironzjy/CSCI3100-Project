class StaleAlertJob < ApplicationJob
  queue_as :default

  def perform
    stale_items.find_each do |item|
      send_system_message(item)
    end
  end

  private

  def stale_items
    Item.where("updated_at <= ?", 30.days.ago).where(status: "available")
  end

  def send_system_message(item)
    conversation = Conversation.find_or_create_by(
      item: item,
      buyer: system_user,
      seller: item.user
    )

    conversation.messages.create!(
      user: system_user,
      body: "⚠️ Your item '#{item.title}' has been inactive for over 30 days. Please consider updating or relisting it."
    )
  end

  def system_user
    User.find_by(email: "system@local")
  end
end