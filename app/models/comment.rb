class Comment < ApplicationRecord
  belongs_to :article
  # include Visible
  belongs_to :user
  has_many :like_comments, dependent: :destroy
end
