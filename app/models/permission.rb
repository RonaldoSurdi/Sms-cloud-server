class Permission < ActiveRecord::Base
  belongs_to :role
  serialize :actions
  validates :subject, presence: true

  default_scope {order(:subject)}
end
