class User < ApplicationRecord

  has_many :ratings, dependent: :destroy
  has_many :articles, through: :ratings
  has_many :comments, dependent: :nullify
  has_many :likes, dependent: :destroy
  has_many :liked_articles, through: :likes, source: :likeable, source_type: 'Article'
  has_many :commented_articles, -> { distinct }, through: :comments, source: :article
  has_many :like_comments, dependent: :destroy
  validates :favshare, :contactshare, :historyshare, inclusion: { in: [true, false] }
  before_validation :set_default_sharing_preferences, on: :create

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

  private

  def set_default_sharing_preferences
    self.favshare = true if favshare.nil?
    self.contactshare = true if contactshare.nil?
    self.historyshare = true if historyshare.nil?
  end

end
