class AddBoxesCountToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :boxes_count, :integer, default: 0, null: false
  end
end
