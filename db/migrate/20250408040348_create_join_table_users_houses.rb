class CreateJoinTableUsersHouses < ActiveRecord::Migration[7.1]
  def change
    create_join_table :users, :houses do |t|
      t.index [:user_id, :house_id], unique: true
      t.index [:house_id, :user_id], unique: true
    end
  end
end
