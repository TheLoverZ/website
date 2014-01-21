class AddSigninTimesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :signin_times, :integer
  end
end
