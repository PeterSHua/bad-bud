CREATE TABLE IF NOT EXISTS players(
    PRIMARY KEY (id),
    id           serial,
    username     varchar(10) UNIQUE,
    password     varchar(100),
    name         varchar(20) NOT NULL,
    rating       integer CHECK(rating BETWEEN 1 AND 6) DEFAULT 1,
    about        varchar(300)
);

CREATE TABLE IF NOT EXISTS groups(
    PRIMARY KEY (id),
    id    serial,
    name  varchar(20) UNIQUE NOT NULL,
    about varchar(300),
    schedule_game_notes varchar(1000)
);

CREATE TABLE IF NOT EXISTS groups_players(
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
    is_organizer BOOLEAN NOT NULL DEFAULT false,
    UNIQUE (group_id, player_id)
);

CREATE TABLE IF NOT EXISTS games(
    PRIMARY KEY (id),
    id          serial,
    group_id    integer NOT NULL,
    start_time  timestamp NOT NULL,
    duration    integer CHECK(duration <= 24) NOT NULL,
    "location"  varchar(300),
    fee         integer CHECK(fee <= 1000) NOT NULL,
    total_slots integer CHECK(total_slots <= 1000) NOT NULL,
    notes       varchar(300),
    template    boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS games_players(
    PRIMARY KEY (id),
    id serial,
    game_id integer NOT NULL,
    FOREIGN KEY (game_id)
    REFERENCES games (id)
    ON DELETE CASCADE,
    player_id integer NOT NULL,
    FOREIGN KEY (player_id)
    REFERENCES players (id)
    ON DELETE CASCADE,
    fee_paid boolean NOT NULL DEFAULT false,
    UNIQUE (game_id, player_id)
);
