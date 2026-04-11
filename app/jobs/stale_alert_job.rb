class StaleAlertJob < ApplicationJob
  queue_as :default

  def perform
    unless system_user
      Rails.logger.warn("StaleAlertJob skipped: system user is missing.")
      return
    end

    reminder_items.find_each { |item| send_renewal_reminder(item) }
    deletion_items.find_each { |item| delete_inactive_item(item) }
  end

  private

  def reminder_items
    Item.where(status: "inactive")
        .where("updated_at <= ?", 15.days.ago)
        .where("updated_at > ?", 30.days.ago)
  end

  def deletion_items
    Item.where(status: "inactive")
        .where("updated_at <= ?", 30.days.ago)
  end

  def send_renewal_reminder(item)
    conversation = Conversation.find_or_create_by(
      item: item,
      buyer: system_user,
      seller: item.user
    )

    body = "⚠️ Your item '#{item.title}' has been inactive for over 15 days. Please consider updating or relisting it."
    # We only send one stale reminder per item until the seller updates it.
    return if conversation.messages.exists?(user: system_user, body: body)

    conversation.messages.create!(
      user: system_user,
      body: body
    )
  end

  def delete_inactive_item(item)
    # Remove dependent conversations first so item deletion does not violate foreign keys.
    Conversation.where(item_id: item.id).destroy_all
    item.destroy!
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed => error
    Rails.logger.warn("StaleAlertJob could not delete item #{item.id}: #{error.message}")
  end

  def system_user
    User.find_by(email: "system@local")
  end
end