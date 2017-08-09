FROM postgres:9.6

RUN mkdir -p /tmp
ADD pg_dump.bugs_ruby-lang_org-20170626.dat /tmp/pg_dump.dat

RUN mkdir -p /docker-entrypoint-initdb.d
ADD setup_database.sh /docker-entrypoint-initdb.d

ENV POSTGRES_PASSWORD=postgres
