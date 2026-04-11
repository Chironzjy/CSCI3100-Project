class AutoCompleteReservedItemsJob < ApplicationJob
  queue_as :default

  def perform
    system_user = User.find_by(email: "system@local")
    unless system_user
      Rails.logger.warn("AutoCompleteReservedItemsJob skipped: system user is missing.")
      return
    end

    Item.reserved_for_auto_completion.find_each do |item|
      item.finalize_reservation!

      conversation = Conversation.find_or_create_by(
        item: item,
        buyer: system_user,
        seller: item.user
      )

      body = "⚠️ '#{item.title}' was automatically marked as sold after 48 hours of reservation."
      # This keeps the job safe to retry without creating duplicate alerts.
      next if conversation.messages.exists?(user: system_user, body: body)

      conversation.messages.create!(
        user: system_user,
        body: body
      )
    end
  end
end