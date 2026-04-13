class Conversation < ApplicationRecord
  belongs_to :item, inverse_of: :conversations
  belongs_to :buyer, class_name: "User", inverse_of: :buyer_conversations
  belongs_to :seller, class_name: "User", inverse_of: :seller_conversations

  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy

  validates :item_id, uniqueness: { scope: [:buyer_id, :seller_id] }
  validate :participants_must_be_different

  scope :involving, ->(user) { where("buyer_id = :id OR seller_id = :id", id: user.id) }

  def participant?(user)
    buyer_id == user.id || seller_id == user.id
  end

  def counterpart_for(user)
    buyer_id == user.id ? seller : buyer
  end

  private

  def participants_must_be_different
    errors.add(:buyer_id, "must be different from seller") if buyer_id == seller_id
  end
end
