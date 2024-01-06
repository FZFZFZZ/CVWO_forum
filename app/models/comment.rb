class Comment < ApplicationRecord
  belongs_to :article
  # include Visible
  belongs_to :user
  has_many :likes, as: :likeable
  
end
