class CreateInvites < ActiveRecord::Migration[7.1]
  def change
    create_table :invites do |t|
      t.references :house, null: false, foreign_key: true
      t.references :inviter, null: false, foreign_key: { to_table: :users }
      t.references :invitee, null: true, foreign_key: { to_table: :users }
      t.string :invitee_email
      t.datetime :expires_on
      t.string :status, default: 'pending'
      t.string :token

      t.timestamps
    end

    add_index :invites, :token, unique: true
  end
end
