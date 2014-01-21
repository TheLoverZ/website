class AddTotalSigninTimesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :total_signin_times, :integer
  end
end
