class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name
      t.string :notes
      t.references :box, foreign_key: true, null: true
      t.references :room, foreign_key: true, null: true
      t.references :house, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
