class ContactGroup < ActiveRecord::Base
  has_and_belongs_to_many :contacts, dependent: :nullify
  belongs_to :customer

  validates :descricao, presence: true
end
