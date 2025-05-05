class AddItemsCountAndRoomsCountToHouses < ActiveRecord::Migration[7.1]
  def change
    add_column :houses, :items_count, :integer, default: 0, null: false
    add_column :houses, :rooms_count, :integer, default: 0, null: false
  end
end
