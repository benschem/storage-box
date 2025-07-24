class MakeRoomIdNotNullOnItems < ActiveRecord::Migration[7.1]
  def change
    change_column_null :items, :room_id, false
  end
end
