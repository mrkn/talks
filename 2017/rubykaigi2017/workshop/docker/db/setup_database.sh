#!/bin/bash -x

createdb -E UTF-8 -U "$POSTGRES_USER" redmine
pg_restore -O -d redmine -U "$POSTGRES_USER" /tmp/pg_dump.dat
