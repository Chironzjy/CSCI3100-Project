class Item < ApplicationRecord
  belongs_to :user

  STATUSES   = %w[available reserved inactive sold].freeze
  CATEGORIES = %w[Electronics Furniture Clothing Books Sports Others].freeze
  COLLEGES   = [
    'Any College', 'Shaw College', 'Morningside College', 'United College',
    'Chung Chi College', 'New Asia College', 'S.H. Ho College',
    'Wu Yee Sun College', 'Lee Woo Sing College'
  ].freeze

  validates :title,       presence: true, length: { maximum: 100 }
  validates :description, presence: true
  validates :price,       presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status,      inclusion: { in: STATUSES }
  validates :category,    presence: true, inclusion: { in: CATEGORIES }

  scope :available, -> { where(status: 'available') }
  scope :recent,    -> { order(created_at: :desc) }

  def status_color
    { 'available' => 'success', 'reserved' => 'warning',
      'inactive'  => 'secondary', 'sold' => 'danger' }.fetch(status, 'secondary')
  end
end
