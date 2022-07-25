INSERT INTO players
VALUES (default, 'Peter H', 3, 30, 'Tiger got to hunt, bird got to fly;
Man got to sit and wonder ''why, why, why?''
Tiger got to sleep, bird got to land;
Man got to tell himself he understand.'),
       (default, 'David M', 3, 50, 'Founder of Novice BM Vancouver'),
       (default, 'John C', 3, 12, 'Shuttlecock lover'),
       (default, 'Rustam', 3, 78, 'aka Wuffle'),
       (default, 'Nikhil Chadurveti', 3, 87, 'Too cheap for uber'),
       (default, 'Jeannie', 2.5, 100, 'Founder of DJ Baddy'),
       (default, 'Carol', 2.5, 100, 'Founder of Active Badminton');

INSERT INTO groups
VALUES (default, 'Novice BM Vancouver', 'Beginner/intermediate games every week'),
       (default, 'DJ Baddy', 'Every wed/sat at Stage 18'),
       (default, 'Active Badminton', 'HK players');

INSERT INTO groups_players(group_id, player_id)
VALUES (1, 1),
       (2, 1),
       (3, 1),
       (1, 2),
       (1, 3),
       (2, 3),
       (3, 3),
       (2, 4),
       (3, 5);

INSERT INTO locations(name, address, phone_number, cost_per_court)
VALUES ('Badminton Vancouver',
        '13100 Mitchell Rd SUITE 110, Richmond, BC V6V 1M8',
        '(604) 325-5128',
        40),
       ('Drive Badminton',
        '4551 No. 3 Rd #138, Richmond, BC V6X 2C3',
        '(604) 285-2638',
        50),
       ('ClearOne No.5',
        '2368 No 5 Rd Unit 160, Richmond, BC V6X 2T1',
        '(604) 370-9078',
        50),
       ('Stage 18',
        '2351 No 6 Rd #170, Richmond, BC V6V 1P3',
        '(604) 278-3233',
        20);

INSERT INTO games
VALUES (default, 1, '2022-07-25 20:00:00', 2, 1, 12, 18),
       (default, 1, '2022-07-27 18:00:00', 2, 2, 13, 6),
       (default, 2, '2022-07-30 18:00:00', 4, 4, 13, 6),
       (default, 3, '2022-07-29 17:00:00', 2, 3, 13, 12);

