class ChangeLastVisitToDatetime < ActiveRecord::Migration
  def change
    change_column :users, :last_visit, :datetime
  end
end
