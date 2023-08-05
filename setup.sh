#! usr/bin/bash

dropdb bad_bud
dropdb bad_bud_test
createdb bad_bud
createdb bad_bud_test
psql -d bad_bud < schema.sql
psql -d bad_bud_test < schema.sql
psql -d bad_bud < data.sql
