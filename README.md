## Badminton Buddy
> Find friends, organize matches, play badminton together!

- [Features](#features)
- [Installation](#installation)

## Features
Made for players and organizers.

## For badminton lovers
No more fiddling with long group chat signups!
### Find games
![game](https://github.com/PeterSHua/bad-bud/blob/019a719a45a6a7d848069392efb9175c93512c1e/public/images/games.png)

### Sign up for games
![signup](https://github.com/PeterSHua/bad-bud/blob/97fb9ee0fedece00671ac8162e3f2702bab259cc/public/images/game_details.png)

## For organizers
Say goodbye to the headache of managing your games and signups.
### Create groups
![groups](https://github.com/PeterSHua/bad-bud/blob/97fb9ee0fedece00671ac8162e3f2702bab259cc/public/images/group_list.png)

### Create weekly game schedules
![schedule](https://github.com/PeterSHua/bad-bud/blob/97fb9ee0fedece00671ac8162e3f2702bab259cc/public/images/schedules.png)

## Installation
This app was tested on:

- Ruby 3.1.2
- PostgreSQL 13.8
- Firefox 103.0.2 (64-bit)

### Local Installation
Install gems
```unix
bundle install
```

Start PostgreSQL
```unix
sudo service postgresql start
```

Setup the local database
```unix
bash setup.sh
```

Run app on your machine
```unix
rake
```

Enter the URL in your browser to access the app
```unix
localhost:4567/
```

Run test suite
```unix
rake test
```

### Heroku Installation
Create app
```unix
heroku apps:create your-app-name
```

Enable PostgreSQL
```unix
heroku addons:create heroku-postgresql:hobby-dev -a your-app-name
```

Setup the database
```unix
heroku pg:psql -a your-app-name < schema.sql
```

Deploy to Heroku
```unix
rake deploy
```
