class User < ActiveRecord::Base
  attr_accessible :password, :username, :sign_times, :last_visit, :total_signin_times, :anonymous
  before_save {
    self.username = username.downcase
    self.anonymous = false
  }
  before_create :create_remember_token

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
