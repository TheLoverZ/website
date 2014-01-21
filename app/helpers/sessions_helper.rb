module SessionsHelper
require 'Digest'

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    cookies.permanent[:last_visit] = Time.now
    user.update_attribute(:last_visit, Time.now)
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    if user.signin_times.nil?
      user_signin_times = 0
    else
      user_signin_times = user.signin_times
    end
    user.update_attribute(:signin_times, user_signin_times + 1)
    self.current_user = user
  end

  def signed_in?
    unless current_user.nil?
      current_session_times = (Time.now - cookies[:last_visit].to_time) / 60
      current_user.total_signin_times += current_session_times
      current_user.save
    end
    record_sessions
    cookies.permanent[:last_visit] = Time.now
    current_user.update_attribute(:last_visit, Time.now) unless current_user.nil?
    !current_user.nil?
  end

  def record_sessions
    if current_user
      name = current_user.username
    else
      name = Digest::MD5.hexdigest "#{request.env['HTTP_USER_AGENT']} #{request.env['REMOTE_ADDR']}"
    end
    $redis.set(name, Time.now)
    $redis.expire(name, 5 * 60)
  end

  def online_num
    $redis.keys.count
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by_remember_token(remember_token)
  end

  def sign_out
    current_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token))
    self.current_user = nil
    cookies.delete(:remember_token)
  end

end
