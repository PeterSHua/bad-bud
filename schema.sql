CREATE TABLE players(
    PRIMARY KEY (id),
    id           serial,
    name         varchar(20) UNIQUE NOT NULL,
    rating       integer CHECK(rating BETWEEN 1 AND 6),
    games_played integer,
    about        varchar(300)
);

CREATE TABLE groups(
    PRIMARY KEY (id),
    id    serial,
    name  varchar(20) UNIQUE NOT NULL,
    about varchar(300)
);

CREATE TABLE groups_players(
    PRIMARY KEY (id),
    id       serial,
    group_id integer NOT NULL,
    FOREIGN KEY (group_id)
    REFERENCES groups (id)
    ON DELETE CASCADE,
    player_id integer NOT NULL,
    FOREIGN KEY (player_id)
    REFERENCES players (id)
    ON DELETE CASCADE,
    UNIQUE (group_id, player_id)
);

CREATE TABLE locations(
    PRIMARY KEY (id),
    id             serial,
    name           varchar(20) UNIQUE NOT NULL,
    address        varchar(300),
    phone_number   varchar(20),
    cost_per_court numeric
);

CREATE TABLE games(
    PRIMARY KEY (id),
    id          serial,
    group_id    integer NOT NULL,
    start_time  timestamp NOT NULL,
    duration    integer CHECK(duration <= 24) NOT NULL,
    location_id integer NOT NULL,
    FOREIGN KEY (location_id)
    REFERENCES locations (id)
    ON DELETE CASCADE,
    fee         integer CHECK(fee <= 1000) NOT NULL,
    total_slots integer CHECK(total_slots <= 1000) NOT NULL,
    notes       varchar(300)
);

CREATE TABLE games_players(
    PRIMARY KEY (id),
    id serial,
    game_id integer NOT NULL,
    FOREIGN KEY (game_id)
    REFERENCES games (id),
    player_id integer NOT NULL,
    FOREIGN KEY (player_id)
    REFERENCES players (id),
    fee_paid boolean NOT NULL,
    UNIQUE (game_id, player_id)
);
