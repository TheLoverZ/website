class AddLastVisitToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_visit, :time
  end
end
