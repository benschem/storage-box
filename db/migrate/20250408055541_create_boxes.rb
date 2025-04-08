class CreateBoxes < ActiveRecord::Migration[7.1]
  def change
    create_table :boxes do |t|
      t.integer :number
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
