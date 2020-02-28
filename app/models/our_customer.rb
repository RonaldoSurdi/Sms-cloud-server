class OurCustomer < ActiveRecord::Base

  has_attached_file :logo, styles: { thumb: "300x300" }

  validates :descricao, :url, presence: true
  validates :logo, attachment_presence: true
  validates_attachment_content_type :logo, content_type: /^image\/(bmp|jpg|jpeg|png|gif)/

  scope :filter, -> (filter) {
    where("descricao ILike :filter OR url ILike :filter", filter: "%#{filter}%") unless filter.blank?
  }

  scope :randomic, -> (quantidade = 1) {
    order("random()").limit(quantidade)
  }
end
