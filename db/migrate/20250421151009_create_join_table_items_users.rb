class CreateJoinTableItemsUsers < ActiveRecord::Migration[7.1]
  create_join_table :items, :users do |t|
    t.index [:item_id, :user_id], unique: true
    t.index [:user_id, :item_id], unique: true
  end
end
