module SessionsHelper
require 'Digest'

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    set_last_visit_time
    set_user_signin_times(user)
    self.current_user = user
  end

  def signed_in?
    cookies[:last_visit] = Time.now if cookies[:last_visit].nil?
    current_times = ((Time.now - cookies[:last_visit].to_time) / 60).to_i
    if current_user
      current_user.update_attribute(:total_signin_times, current_user.total_signin_times + current_times)
    else
      cookies[:current_times] = cookies[:current_times].to_i + current_times
    end
    record_sessions
    set_last_visit_time
    !current_user.nil?
  end

  def online_num(opt)
    case opt
    when "all" # all users num
      num = $redis.keys.count
    when "anony" # anonymous users num
      num = 0
      $redis.keys.each do |k|
        num += 1 if k.size != 32
      end
    when "signed" # signed users num
      num = 0
      $redis.keys.each do |k|
        num += 1 if k.size == 32
      end
    end
    num
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
    cookies.delete(:last_visit)
    cookies.delete(:current_times)
  end

  private
  def record_sessions
    if current_user
      name = current_user.username
    else
      name = Digest::MD5.hexdigest "#{request.env['HTTP_USER_AGENT']} #{request.env['REMOTE_ADDR']}"
    end
    $redis.set(name, Time.now)
    $redis.expire(name, 5 * 60)
  end

  def set_last_visit_time
    cookies.permanent[:last_visit] = Time.now
  end

  def set_user_signin_times(user)
    user.update_attribute(:signin_times, user.signin_times + 1)
  end
end
