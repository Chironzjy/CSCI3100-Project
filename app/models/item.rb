class Item < ApplicationRecord
  include PgSearch::Model

  belongs_to :user

  STATUSES   = %w[available reserved inactive sold].freeze
  VISIBILITY_SCOPES = %w[campus college_only].freeze
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
  validates :latitude,    numericality: true, allow_nil: true
  validates :longitude,   numericality: true, allow_nil: true
  validates :visibility_scope, inclusion: { in: VISIBILITY_SCOPES }
  validates :visibility_college, presence: true, if: :college_only_visibility?
  validate :meetup_location_selected

  scope :available, -> { where(status: 'available') }
  scope :recent,    -> { order(created_at: :desc) }

  pg_search_scope :smart_search,
                  against: [:title, :description, :location],
                  using: {
                    tsearch: { prefix: true },
                    trigram: {}
                  },
                  ignoring: :accents

  scope :visible_to, lambda { |user|
    if user&.college.present?
      where(
        "visibility_scope = :campus OR (visibility_scope = :college_only AND visibility_college = :college)",
        campus: "campus", college_only: "college_only", college: user.college
      )
    else
      where(visibility_scope: "campus")
    end
  }

  def college_only_visibility?
    visibility_scope == "college_only"
  end

  def meetup_location_selected
    if location.blank?
      errors.add(:location, "can't be blank")
    elsif latitude.blank? || longitude.blank?
      errors.add(:location, "must be selected from Google Maps suggestions")
    end
  end

  def status_color
    { 'available' => 'success', 'reserved' => 'warning',
      'inactive'  => 'secondary', 'sold' => 'danger' }.fetch(status, 'secondary')
  end
end
