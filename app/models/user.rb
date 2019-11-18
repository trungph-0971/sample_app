class User < ApplicationRecord
  attr_accessor :remember_token
  before_save{email.downcase!}
  validates :name, presence: true, length: {maximum: Settings.max_name}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: {maximum: Settings.max_email},
                      format: {with: VALID_EMAIL_REGEX},
                      uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true,
            length: {minimum: Settings.min_password}, allow_nil: true

  # Returns the hash digest of the given string.
  class << self
    # Returns the hash digest of the given string.
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    return unless remember_digest

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update remember_digest: nil
  end
end
