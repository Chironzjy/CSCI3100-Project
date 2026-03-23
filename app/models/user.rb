class User < ApplicationRecord
  COLLEGES = [
    "Shaw College", "Morningside College", "United College",
    "Chung Chi College", "New Asia College", "S.H. Ho College",
    "Wu Yee Sun College", "Lee Woo Sing College"
  ].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :items, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :buyer_conversations,
           class_name: "Conversation",
           foreign_key: :buyer_id,
           dependent: :destroy,
           inverse_of: :buyer
  has_many :seller_conversations,
           class_name: "Conversation",
           foreign_key: :seller_id,
           dependent: :destroy,
           inverse_of: :seller

  validates :user_name, presence: true, uniqueness: { case_sensitive: false }
  validates :location,  presence: true
  validates :latitude,  presence: true
  validates :longitude, presence: true
  validates :college,   inclusion: { in: COLLEGES }, allow_blank: true

  geocoded_by :location
  after_validation :geocode, if: :location_changed?

  def conversations
    Conversation.involving(self)
  end
end
