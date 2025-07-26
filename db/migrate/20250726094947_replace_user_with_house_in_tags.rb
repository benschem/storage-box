class ReplaceUserWithHouseInTags < ActiveRecord::Migration[7.1]
  def change
    remove_reference :tags, :user, foreign_key: true
    add_reference :tags, :house, null: false, foreign_key: true
  end
end
