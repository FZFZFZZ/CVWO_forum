class User < ApplicationRecord

  has_many :ratings
  has_many :articles, through: :ratings
  has_many :comments, dependent: :destroy
  has_many :likes
  has_many :liked_articles, through: :likes, source: :likeable, source_type: 'Article'
  has_many :commented_articles, -> { distinct }, through: :comments, source: :article
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attr_accessor :login

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end
end
