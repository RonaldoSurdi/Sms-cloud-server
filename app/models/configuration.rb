class Configuration < ActiveRecord::Base
  belongs_to :customer
  validates :text_birthdays, presence: true, if: :send_birthdays?
end
