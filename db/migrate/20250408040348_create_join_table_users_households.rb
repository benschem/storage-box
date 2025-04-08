class CreateJoinTableUsersHouseholds < ActiveRecord::Migration[7.1]
  def change
    create_join_table :users, :households do |t|
      t.index [:user_id, :household_id], unique: true
      t.index [:household_id, :user_id], unique: true
    end
  end
end
