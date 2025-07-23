class AddHouseToBox < ActiveRecord::Migration[7.1]
  def change
    add_reference :boxes, :house, null: false, foreign_key: true
  end
end
