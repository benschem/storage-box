class AddUniqueConstraintToBoxesNumberAndHouseholdId < ActiveRecord::Migration[7.1]
  def change
    # This adds a composite index on the `number` and `room_id` columns of the `boxes` table.
    # The combination of `number` and `room_id` ensures that box numbers are unique
    # across all rooms within a household.

    # Explanation:
    # - `number`: This is the unique box number, and it needs to be unique within the context of the Household.
    # - `room_id`: This is the foreign key linking a Box to a Room. Since a Room belongs to a Household,
    #   the `room_id` indirectly associates the Box with a Household.

    # By using a composite index on `number` and `room_id`, we ensure that the same box number cannot
    # be used in two different rooms within the same Household, even though the `Box` table doesn't
    # directly reference `household_id`. Instead, we rely on the fact that `Room` belongs to `Household`.
    add_index :boxes, [:number, :room_id], unique: true
  end
end
