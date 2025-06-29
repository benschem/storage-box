# README

This is a Ruby on Rails 7.1 application

- _Asset pipeline:_ Vite
- _CSS:_ Tailwind CSS v4
- _Background jobs:_ SolidQueue (in main db)
- _User uploads:_ Local storage
- _Email:_ SendGrid

For the setup I followed the guidelines in this article [https://medium.com/@yatishmehta/ruby-on-rails-8-vite-and-tailwind-v4-1ad62c4f6943]

_Prerequisites:_

- Ruby
- Node.js
- Yarn (using Berry but either should work)
- PostgreSQL

_After cloning the repo:_
`bundle install`
`yarn install`
`bin/rails db:setup`
`bin/rails server` in one tab
`bin/vite dev` in another tab

_Other commands:_
`yarn up` to update JavaScript dependencies
