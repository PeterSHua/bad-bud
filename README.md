# Badminton Buddies
Organize badminton matches and find friends to play together with in the **Badminton Buddies** web app.

## Features
Organizers, say goodbye to the headache of managing your games and signups.
- Create groups
- Post games
- Create weekly game schedules
- Keep track of player signups and payment
- Add and remove players from your games

Badminton lovers, enjoy a simple and easy to use interface. No more fiddling with long group chat signup messages!
- Find and sign up for games
- Create an account to manage your signups

## Installation
This app was tested on:

Ruby 3.1.2
PostgreSQL 13.8
Firefox 103.0.2 (64-bit)

### Local Installation
Install gems
`bundle install`

Start PostgreSQL
`sudo service postgresql start`

Setup the local database
`bash setup.sh`

Run app on your machine
`rake`

Enter the URL in your browser to access the app
`localhost:4567/`

Run test suite
`rake test`

### Heroku Installation
Create app
`heroku apps:create your-app-name`

Enable PostgreSQL
`heroku addons:create heroku-postgresql:hobby-dev -a your-app-name`

Setup the database
`heroku pg:psql -a your-app-name < schema.sql`

Deploy to Heroku
`rake deploy`

## License
The source code in this project is released under the GNU GPLv3 License.
