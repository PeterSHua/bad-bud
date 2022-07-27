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
VALUES (default, 1, '2022-07-25 20:00:00', 2, 1, 12, 18, 'E-transfer the fee to David at dcsparta@hotmail.com (your signup is not confirmed until payment is received and will be cancelled after a couple hours). Refundable until 24h before the game. Include the date(s) you''re paying for in the notes, thanks.'),
       (default, 1, '2022-07-27 18:00:00', 2, 2, 13, 6, 'E-transfer the fee to David at x@hotmail.com (your signup is not confirmed until payment is received and will be cancelled after a couple hours). Refundable until 24h before the game. Include the date(s) you''re paying for in the notes, thanks.'),
       (default, 2, '2022-07-30 18:00:00', 4, 4, 13, 6, 'Cancel by 1pm Thursday or $12 will be charged for late cancellation. Thanks! Cost = $14/person for 2 hours with feather birdies included. Etransfer Jeannie Yip at x@gmail.com for payment.'),
       (default, 3, '2022-07-29 17:00:00', 2, 3, 13, 12, 'No show or late withdrawal (within 48 hrs) without substitute player is committed to pay your share of game fee.');

INSERT INTO games_players
VALUES (default, 1, 1, true),
       (default, 1, 4, false),
       (default, 1, 5, true),
       (default, 2, 1, true),
       (default, 4, 1, true),
       (default, 4, 5, true),
       (default, 4, 7, true),
       (default, 3, 6, true);
