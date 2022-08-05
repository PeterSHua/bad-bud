#! usr/bin/bash

dropdb bad_buds
dropdb bad_buds_test
createdb bad_buds
createdb bad_buds_test
psql -d bad_buds < schema.sql
psql -d bad_buds_test < schema.sql
psql -d bad_buds < data.sql
psql -d bad_buds_test < data.sql
