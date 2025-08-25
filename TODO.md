<!-- don't forget to grep todos in the actual code -->

# TODO:

# UX

[ ] A house with no rooms is unintuitive what to do
[ ] A brand new user probably needs hints for workflow
[ ] Items new page should be a modal or something else
[ ] Items form should have a better way to add tags and boxes in the form
[ ] Adding an item - choosing which house is done by choosing room - don't like it

# Bugs

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

## New features

[ ] Assignable owner for items so you can filter by your items or household

<!-- item already belongs to user and house
could be you have the option to set owner to one of the users in the house, or it can be a "household" item, belonging to all users
maybe need an owner column on db? -->

[ ] Slugs based on name for urls for house and rooms
[ ] Option to delete User account - use give away items method
[ ] Option to export data to csv
[X] Uncomment code in User model to enforce password strength
[ ] Magic login via email sign in link
[ ] Check if user passwords are pwned both on signup and login [https://github.com/michaelbanfield/devise-pwned_password]

## Refactoring

[ ] Extract filter and sorting concerns to `app/queries/items/filters.rb` Items::Filters
[ ] Invite - use token to generate acceptance link
[ ] Multiple solidqueue queues - high low default
[ ] `decline_invite!` could just use the enum `declined!`
