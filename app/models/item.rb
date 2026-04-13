class Item < ApplicationRecord
  include PgSearch::Model

  geocoded_by :location

  has_many_attached :photos, dependent: :destroy

  belongs_to :user
  has_many :conversations, dependent: :destroy, inverse_of: :item

  STATUSES   = %w[available reserved inactive sold].freeze
  VISIBILITY_SCOPES = %w[campus college_only].freeze
  CATEGORIES = %w[Electronics Furniture Clothing Books Sports Others].freeze
  COLLEGES   = [
    'Any College', 'Shaw College', 'Morningside College', 'United College',
    'Chung Chi College', 'New Asia College', 'S.H. Ho College',
    'Wu Yee Sun College', 'Lee Woo Sing College', 'CW Chu College'
  ].freeze

  validates :title,       presence: true, length: { maximum: 100 }
  validates :description, presence: true
  validates :price,       presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status,      inclusion: { in: STATUSES }
  validates :category,    presence: true, inclusion: { in: CATEGORIES }
  validates :latitude,    numericality: true, allow_nil: true
  validates :longitude,   numericality: true, allow_nil: true
  validates :visibility_scope, inclusion: { in: VISIBILITY_SCOPES }
  validates :visibility_college, presence: true, if: :college_only_visibility?
  validate :meetup_location_selected

  before_validation :geocode_location_if_needed
  before_validation :apply_stock_driven_status
  before_save :capture_reserved_timestamp

  scope :available, -> { where(status: 'available') }
  scope :recent,    -> { order(created_at: :desc) }
  scope :reserved_for_auto_completion, -> { where(status: 'reserved').where("reserved_at <= ?", 48.hours.ago) }

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
    elsif coordinates_required? && (latitude.blank? || longitude.blank?)
      errors.add(:location, "could not be geocoded, please provide a more specific location")
    end
  end

  def status_color
    { 'available' => 'success', 'reserved' => 'warning',
      'inactive'  => 'secondary', 'sold' => 'danger' }.fetch(status, 'secondary')
  end

  def finalize_reservation!
    new_stock = [stock_quantity.to_i - 1, 0].max
    self.stock_quantity = new_stock
    self.status = new_stock.zero? ? 'sold' : 'available'
    self.reserved_at = nil
    save!
  end

  def self.auto_complete_reserved!
    reserved_for_auto_completion.find_each(&:finalize_reservation!)
  end

  private

  def geocode_location_if_needed
    return if location.blank?
    return if latitude.present? && longitude.present?

    geocode
  end

  def apply_stock_driven_status
    return if stock_quantity.nil?

    if stock_quantity.to_i <= 0
      self.status = 'sold'
      self.reserved_at = nil
    end
  end

  def capture_reserved_timestamp
    return unless will_save_change_to_status?

    self.reserved_at = status == 'reserved' ? Time.current : nil
  end

  def coordinates_required?
    !(Rails.env.development? && ENV['GOOGLE_MAPS_API_KEY'].blank?)
  end
end
