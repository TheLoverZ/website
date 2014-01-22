class User < ActiveRecord::Base
  attr_accessible :password, :username, :sign_times, :total_signin_times
  before_save {
    self.username = username.downcase
    self.total_signin_times = 0 unless self.total_signin_times
  }
  before_create :create_remember_token

  validates :username, uniqueness: true

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private
  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end

  has_secure_password
end
