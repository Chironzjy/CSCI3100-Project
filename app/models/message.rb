class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :body, presence: true, length: { maximum: 1000 }
  validate :sender_must_be_conversation_participant

  after_create_commit :broadcast_to_conversation

  private

  def sender_must_be_conversation_participant
    # Allow scheduler-generated system messages to pass the participant check.
    return if user&.email == "system@local"
    return if conversation&.participant?(user)

    errors.add(:user_id, "is not part of this conversation")
  end

  def broadcast_to_conversation
    ConversationChannel.broadcast_to(
      conversation,
      {
        id: id,
        body: body,
        sender_id: user_id,
        sender_name: user.user_name,
        created_at: created_at.strftime("%H:%M")
      }
    )
  end
end
