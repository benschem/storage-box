# README

Where's that thing I need? Wouldn't it be cool if I could search my stuff? Now I can!

(Searchyourstuff.fyi)[Searchyourstuff.fyi] is like a search engine for your belongings. Find out which room and what box that thing you need is in!

# Running it locally

_After cloning the repo:_
`bundle install`
`yarn install`
`bin/rails db:setup`
`bin/rails server` in one tab
`bin/vite dev` in another tab

_Other commands:_
`yarn up` to update JavaScript dependencies

# Tech Stack

## Backend

- Ruby 3.3.5
- Rails 8.1.2

## Database

- PostgreSQL 15

### Background jobs

- Solid Queue (single database mode)
- TODO: Mission Control dashboard

### User uploads

- Local storage

### Email

- SendGrid

## Front end

### Javascript

- Hotwire (Turbo/Stimulus)

### CSS

- Tailwind v4

### Asset pipeline

- Node v21.7.2
- Yarn 4.9.1
- bin/vite
- vite_ruby 3.9.2
- vite_rails 3.0.20
