class Tag < ApplicationRecord
	has_many :taggables, dependent: :destroy
	has_many :articles, through: :taggables
  def self.ransackable_attributes(auth_object = nil)
    # Allow only these attributes to be searchable
    %w[created_at id name updated_at]
  end
end
