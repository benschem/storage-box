class CreateJoinTableBoxTags < ActiveRecord::Migration[7.1]
  def change
    create_join_table :boxes, :tags do |t|
      t.index [:box_id, :tag_id], unique: true
      t.index [:tag_id, :box_id], unique: true
    end
  end
end
