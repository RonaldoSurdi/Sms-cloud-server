class Role < ActiveRecord::Base

  has_and_belongs_to_many :administrators

  has_many :permissions, dependent: :destroy

  accepts_nested_attributes_for :permissions

  validates :description, presence: true, uniqueness: true

  scope :filter, ->(filter) {
    where("description ILike :filter_like", filter_like: "%#{filter}%") unless filter.blank?
  }

  def destroy
    super unless self.full_control
  end
end
