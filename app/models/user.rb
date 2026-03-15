class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :user_name, presence: true
  validates :location, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  geocoded_by :location
  after_validation :geocode, if: :location_changed?
end
