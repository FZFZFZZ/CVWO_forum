class Article < ApplicationRecord
	include Visible
	has_many :likes, as: :likeable
	has_many :comments, dependent: :destroy
	has_many :taggables, dependent: :destroy
	has_many :tags, through: :taggables
	has_many :ratings, dependent: :destroy
  	has_many :users, through: :ratings
	validates :title, presence: true
	validates :body, presence: true, length: {minimum: 5}
	validates :year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1900}

	attr_accessor :poster_url
	
	scope :title_contains_words, -> (words) {
    	where(
    	  words.split.map { |word| 
    	    sanitize_sql_for_conditions(["title LIKE ?", "%#{word}%"]) 
    	  }.join(' AND ')
    	)
    }

	ransacker :average_rating do
    	query = '(SELECT AVG(ratings.score) FROM ratings WHERE ratings.article_id = articles.id)'
    	Arel.sql(query)
  	end
  	
	def self.ransackable_attributes(auth_object = nil)
    # Allow only the 'title' attribute to be searchable
    	["title", "year"]
  	end
  	def self.ransackable_associations(auth_object = nil)
    # Allow only these associations to be searchable
    	["tags"]
  	end
  	def average_rating
    	ratings.average(:score)
  	end
end
