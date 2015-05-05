class User < ActiveRecord::Base
  before_save {self.email = email.downcase}

  validates :name, presence: true, length: {maximum: 50}
  validates :email,
      presence: true,
      length: {maximum: 255},
      format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i},
      uniqueness: {case_sensitive: false}
  # automatically adds the following:
  # password_digest (hashed version of password)
  # authenticate method
  has_secure_password
  validates :password, length: {minimum: 6}

  def User.digest(str)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine::cost
    return BCrypt::Password.create(str, cost: cost)
  end

end
