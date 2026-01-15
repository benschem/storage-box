<!-- don't forget to grep todos in the actual code -->

# TODO:

## UX

[ ] A house with no rooms is unintuitive what to do
[ ] A brand new user probably needs hints for workflow
[ ] Items new page should be a modal or something else
[ ] Items form should have a better way to add tags and boxes in the form
[ ] Adding an item - choosing which house is done by choosing room - don't like it

## Bugs

[ ] Item filter doesn't chain scopes
[ ] Item scopes return nothing when passed nothing - not empty AR relation
[ ] Stimulus controller to clear new house form after one gets submitted
[ ] Fix eager loading issues as per Bullet
[ ] Filter - when a house is selected should not show rooms from other houses in the room select
[ ] Filter - when a room is selected should not show boxes from other rooms in the box select
[ ] If you edit an item then change sort to be by most recently modified it needs a refresh to work

## Config

[ ] Add mission control dashboard for jobs
[ ] Prod should email me when jobs fail
[ ] Install libvips on server [https://stackoverflow.com/questions/70849182/could-not-open-library-vips-42-could-not-open-library-libvips-42-dylib]
[ ] Use caching [https://chatgpt.com/c/6809ddd4-bac4-8004-8505-c876cfeb165d]
[ ] Log user ids [https://chatgpt.com/c/6809ddd4-bac4-8004-8505-c876cfeb165d]

## Policies

[X] Box
[X] House
[X] Invite
[X] Item
[X] Room
[X] Tag
[ ] Taggings
[ ] User?

## Policy Specs

[ ] Box
[ ] House
[ ] Invite
[X] Item
[ ] Room
[X] Tag
[ ] Taggings
[ ] User?

## System Specs

[ ] A user viewing their items
[ ] A user searching for an item
[ ] A user adding an item

## New features

[ ] Assignable owner for items so you can filter by your items or household

<!-- item already belongs to user and house
could be you have the option to set owner to one of the users in the house, or it can be a "household" item, belonging to all users
maybe need an owner column on db? -->

[ ] Memberships join table for user houses
[ ] Membership roles - see link in user or house to get started
[ ] Slugs based on name for urls for house and rooms
[ ] Option to delete User account - use give away items method
[ ] Option to export data to csv
[X] Uncomment code in User model to enforce password strength
[ ] Magic login via email sign in link
[ ] Check if user passwords are pwned both on signup and login [https://github.com/michaelbanfield/devise-pwned_password]

## Refactoring

[X] Extract filter concern to `app/queries/filter.rb` use with Filter.call
[X] Move `TagFilterable` tests to `spec/concerns` and add `spec/support/shared_examples/tag_filterable_examples.rb`
[ ] Invite - use token to generate acceptance link
[ ] Multiple solidqueue queues - high low default
[ ] `decline_invite!` could just use the enum `declined!`
[ ] Box model - Uniqueness validation should have a unique index on the database column.
[ ] Create some more factories -> there are too many example helpers in scope tests

# 2026 TODO noted:
[X] Update everything
[ ] Lint everything
[ ] In item, include PGSearch thing should go inside the Searchable concern
[ ]
