# README

"Where's that thing I need?"

Wouldn't it be cool if you could search your stuff? Now you can!

[searchyourstuff.fyi](https://searchyourstuff.fyi) is like a search engine for your belongings. Find out which room and what box that thing you need is in!

## Setup

After cloning the repo, run these commands to install dependencies and setup the database:

```
bundle install
yarn install
bin/rails db:setup
```

## Running it locally

Start puma in one tab

```
bin/rails server
```

Start vite in another tab

```
bin/vite dev
```

## Other commands

Update ruby dependencies:

```
bundle update
```

Update JavaScript dependencies:

```
yarn up
```

Run specs:

```
ENV=test bundle exec rspec --format documentation --order defined
```

## Backend

- Ruby
- Rails
- PostgreSQL

_Asset pipeline_

- Node
- Yarn
- Vite Ruby
- Vite Rails

_Background jobs_

- Solid Queue (single database mode)
- TODO: Mission Control dashboard

_User uploaded photos_

- Stored locally
- TODO: Set up an S3 bucket

_Email_

- TODO: SendGrid

## Front end

- ERB
- Hotwire (Turbo/Stimulus)
- Tailwind
