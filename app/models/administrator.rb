class Administrator < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles

  attr_accessor :current_password, :valid_current_password

  validates :name, presence: true
  validate :authenticate_password, if: :valid_current_password

  scope :filter, ->(filter) {
    where("name ILike :filter_like Or email ILike :filter_like", filter_like: "%#{filter}%") unless filter.blank?
  }

  private

  def authenticate_password
    errors.add(:current_password, "não confere") if self.password.present? && !Administrator.find(self.id).valid_password?(@current_password.to_s)
  end
end