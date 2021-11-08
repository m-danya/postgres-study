-- set auto-commit OFF
begin;
DROP SCHEMA IF EXISTS stats CASCADE;
CREATE SCHEMA stats;

set search_path to stats;

CREATE TABLE users (
    worker_id integer
        -- REFERENCES resources.workers в теории
        PRIMARY KEY,
    salary numeric(10, 2)
        NOT NULL
        CONSTRAINT positive_salary CHECK (salary > 0),
	visits_count integer
        NOT NULL
        CONSTRAINT not_neg_count CHECK (visits_count >= 0),
    characteristics text
        NOT NULL
);

CREATE TABLE visits (
    id serial
        PRIMARY KEY,
    deposit_ids_seen integer[] 
        NOT NULL,
    time timestamp
        NOT NULL 
        DEFAULT current_timestamp,
    user_id integer
        REFERENCES users ON DELETE CASCADE -- если кто-то решил удалить пользователя, пусть удаляется и его статистика
        NOT NULL,
    required_models jsonb 
        NOT NULL
);

SET CONSTRAINTS ALL DEFERRED;

COPY users
    FROM 'users.csv' WITH (FORMAT TEXT, delimiter '|');

COPY visits(deposit_ids_seen, time, user_id, required_models)
    FROM 'visits.csv' WITH (FORMAT TEXT, delimiter '|');
	
commit;

-- set auto-commit ON
analyze;