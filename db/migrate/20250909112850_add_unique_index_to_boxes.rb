class AddUniqueIndexToBoxes < ActiveRecord::Migration[7.1]
  def change
    add_index :boxes, [:house_id, :number], unique: true
  end
end
