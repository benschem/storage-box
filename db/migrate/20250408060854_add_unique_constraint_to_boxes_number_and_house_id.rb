class AddUniqueConstraintToBoxesNumberAndHouseId < ActiveRecord::Migration[7.1]
  def change
    # This adds a composite index on the `number` and `room_id` columns of the `boxes` table.
    # The combination of `number` and `room_id` ensures that box numbers are unique
    # across all rooms within a house.

    # Explanation:
    # - `number`: This is the unique box number, and it needs to be unique within the context of the House.
    # - `room_id`: This is the foreign key linking a Box to a Room. Since a Room belongs to a House,
    #   the `room_id` indirectly associates the Box with a House.

    # By using a composite index on `number` and `room_id`, we ensure that the same box number cannot
    # be used in two different rooms within the same House, even though the `Box` table doesn't
    # directly reference `house_id`. Instead, we rely on the fact that `Room` belongs to `House`.
    add_index :boxes, [:number, :room_id], unique: true
  end
end
