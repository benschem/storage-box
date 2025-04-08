class CreateHouseholds < ActiveRecord::Migration[7.1]
  def change
    create_table :households do |t|
      t.string :address
      t.string :name

      t.timestamps
    end
  end
end
