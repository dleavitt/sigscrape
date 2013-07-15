# sigscrape

A thing to pull down and store longitudinal Sigalert data, and eventually visualize it.


## Dependencies

- ruby 2.0 and bundler
- mongodb - `brew install mongodb` or equivalent

## Installation

1. Copy the env file and edit to taste (this sets the MongoDB DB & URL)

        cp example.env .env
        vim .env

2. Install ruby dependencies

        bundle install
        rbenv rehash # if you're running rbenv

3. Create DB indexes

        rake mongoid:create indexes

## Tasks

Run `rake -T` for the full list. Highlights:

Add your Sigalert account

    rake create_user[your_username,your_password]

Get current travel times for all users' routes

    rake update_journeys

## Deployment

Create the app

    heroku create appname

Add a mongodb provider

    heroku addons:add mongohq

Set the mongodb URL

    heroku config # copy the url from here
    heroku config:add MONGO_URL=mongodb://heroku:xx@x.mongohq.com:10015/app12

Create your user

    heroku run rake create_user[username,password]

Add the scheduler addon

    heroku addons:add scheduler
    heroku addons:open scheduler

And set it to run `rake update_journeys` every 10 minutes or so.

## Tests

First create a separate `.env` file for the tests and make sure it uses a different database.

    cp example.env .env.test
    vim .env.test

Run the specs with `rake` or `rake test` or `rspec spec`
