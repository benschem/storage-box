class AddNameAndHouseholdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :name, :string
    add_reference :users, :household, null: true, foreign_key: true
  end
end
