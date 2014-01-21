class ApiController < ApplicationController

  def signed_online_numbers
    format.json { render json: {"signed_users", current_user_numbers }}
  end

  def anonymous_online_numbers
  end

end
