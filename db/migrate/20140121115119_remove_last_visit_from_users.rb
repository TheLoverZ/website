class RemoveLastVisitFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :last_visit
  end

  def down
    add_column :users, :last_visit, :datetime
  end
end
