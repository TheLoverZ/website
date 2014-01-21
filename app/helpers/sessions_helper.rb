module SessionsHelper

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
    if !current_user.nil?
      current_user.update_attribute(:total_signin_times, 0) if current_user.total_signin_times.nil?
    end
    unless current_user.nil?
      current_session_times =  (Time.now - cookies[:last_visit].to_time) / 60
      current_user.total_signin_times += current_session_times
      current_user.save
    end
    cookies.permanent[:last_visit] = Time.now
    current_user.update_attribute(:last_visit, Time.now) unless current_user.nil?
    !current_user.nil?
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

  def current_user_numbers
    total = 0
    User.all.each do |u|
      total += 1 if Time.now - u.last_visit < 60 * 5 # 5 分钟内访问过的
    end
    total
  end

end
