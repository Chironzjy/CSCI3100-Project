class AutoCompleteReservedItemsJob < ApplicationJob
  queue_as :default

  def perform
    system_user = User.find_by(email: "system@local")

    Item.reserved_for_auto_completion.find_each do |item|
      item.finalize_reservation!

      conversation = Conversation.find_or_create_by(
        item: item,
        buyer: system_user,
        seller: item.user
      )

      conversation.messages.create!(
        user: system_user,
        body: "⚠️ '#{item.title}' was automatically marked as Sold after 48 hours of reservation."
      )
    end
  end
end