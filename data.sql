INSERT INTO players (username, password, name, rating, about)
VALUES ('peter', '$2a$12$W5ACHXiMPoYIHUEjTWtnUOnO18zfz65mQiqsIn/IVabLsJQ5ZelqS', 'Peter H', 3, 'Here we are, trapped in the amber of the moment. There is no why.'),
       ('david', '$2a$12$W5ACHXiMPoYIHUEjTWtnUOnO18zfz65mQiqsIn/IVabLsJQ5ZelqS', 'David C', 3,'Founder of Novice BM Vancouver'),
       ('john', '$2a$12$W5ACHXiMPoYIHUEjTWtnUOnO18zfz65mQiqsIn/IVabLsJQ5ZelqS', 'John C', 3, 'Shuttlecock lover'),
       ('rustam', '$2a$12$W5ACHXiMPoYIHUEjTWtnUOnO18zfz65mQiqsIn/IVabLsJQ5ZelqS', 'Rustam', 3, 'aka Wuffle'),
       ('nikhil', '$2a$12$W5ACHXiMPoYIHUEjTWtnUOnO18zfz65mQiqsIn/IVabLsJQ5ZelqS', 'Nikhil C', 3, 'otaku'),
       ('jeannie', '$2a$12$W5ACHXiMPoYIHUEjTWtnUOnO18zfz65mQiqsIn/IVabLsJQ5ZelqS', 'Jeannie', 2.5,'Founder of DJ Baddy'),
       ('carol', '$2a$12$W5ACHXiMPoYIHUEjTWtnUOnO18zfz65mQiqsIn/IVabLsJQ5ZelqS', 'Carol', 2.5, 'Founder of Active Badminton');

INSERT INTO groups (name, about, schedule_game_notes)
VALUES ('Novice BM Vancouver', 'Beginner/intermediate games every week', 'E-transfer the fee to David at x@hotmail.com (your signup is not confirmed until payment is received and will be cancelled after a couple hours). Refundable until 24h before the game. Include the date(s) you''re paying for in the notes, thanks.'),
       ('DJ Baddy', 'Every wed/sat at Stage 18', 'Cancel by 1pm Thursday or $12 will be charged for late cancellation. Thanks! Cost = $14/person for 2 hours with feather birdies included. Etransfer Jeannie Yip at x@gmail.com for payment.'),
       ('Active Badminton', 'HK players', 'No show or late withdrawal (within 48 hrs) without substitute player is committed to pay your share of game fee.');

INSERT INTO groups_players(group_id, player_id, is_organizer)
VALUES (1, 1, false),
       (2, 1, false),
       (3, 1, false),
       (1, 2, true),
       (1, 3, false),
       (1, 4, false),
       (2, 4, false),
       (3, 4, false),
       (1, 5, false),
       (2, 5, false),
       (3, 5, false),
       (2, 6, true),
       (3, 7, true);

INSERT INTO games
VALUES (default, 1, '2022-07-25 20:00:00', 2, 'Badminton Vancouver', 'Intermediate+', 12, 18, 'E-transfer the fee to David at x@hotmail.com (your signup is not confirmed until payment is received and will be cancelled after a couple hours). Refundable until 24h before the game. Include the date(s) you''re paying for in the notes, thanks.', false),
       (default, 1, '2022-07-27 18:00:00', 2, 'Badminton Vancouver', 'Intermediate+', 13, 6, 'E-transfer the fee to David at x@hotmail.com (your signup is not confirmed until payment is received and will be cancelled after a couple hours). Refundable until 24h before the game. Include the date(s) you''re paying for in the notes, thanks.', false),
       (default, 2, '2022-07-30 18:00:00', 4, 'Clear One 3', 'All level', 13, 6, 'Cancel by 1pm Thursday or $12 will be charged for late cancellation. Thanks! Cost = $14/person for 2 hours with feather birdies included. Etransfer Jeannie Yip at x@gmail.com for payment.', false),
       (default, 3, '2022-07-29 17:00:00', 2, 'Stage 18', 'Open to all', 13, 12, 'No show or late withdrawal (within 48 hrs) without substitute player is committed to pay your share of game fee.', false),
       (default, 1, '2022-07-03 14:00:00', 2, 'Badminton Vancouver', 'All level', 12, 18, '', true),
       (default, 1, '2022-07-03 16:00:00', 2, 'Badminton Vancouver', 'All level', 12, 18, '', true),
       (default, 1, '2022-07-07 18:00:00', 2, 'Badminton Vancouver', 'Intermediate+', 12, 12, '', true),
       (default, 1, '2022-07-09 10:00:00', 2, 'Badminton Vancouver', 'Intermediate+', 12, 18, '', true);

INSERT INTO games_players(game_id, player_id, fee_paid)
VALUES (1, 1, true),
       (1, 4, false),
       (1, 5, true),
       (2, 1, true),
       (4, 1, true),
       (4, 5, true),
       (4, 7, true),
       (3, 6, true),
       (5, 1, true),
       (5, 2, false),
       (5, 3, true),
       (5, 4, true),
       (5, 5, true);

