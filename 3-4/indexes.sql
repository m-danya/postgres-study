SET enable_seqscan TO on; -- всё честно, не выключаем возможность тупо всё сканировать

-- ARRAY

DROP INDEX IF EXISTS stats.gin_array;

explain analyze select * from stats.visits 
	WHERE (deposit_ids_seen = ARRAY[1, 5, 6, 7, 9]::integer[]);

"Gather  (cost=1000.00..3689494.98 rows=1 width=218) (actual time=274392.712..274397.689 rows=0 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on visits  (cost=0.00..3688494.88 rows=1 width=218) (actual time=273800.504..273800.504 rows=0 loops=3)"
"        Filter: (deposit_ids_seen = '{1,5,6,7,9}'::integer[])"
"        Rows Removed by Filter: 33333334"
"Planning Time: 0.320 ms"
"Execution Time: 274402.210 ms"

CREATE INDEX gin_array ON stats.visits USING GIN(deposit_ids_seen);
"
Query returned successfully in 5 min. 6 secs.
"

explain analyze select * from stats.visits 
	WHERE (deposit_ids_seen = ARRAY[1, 5, 6, 7, 9]::integer[]);

"Bitmap Heap Scan on visits  (cost=1772.00..1776.01 rows=1 width=218) (actual time=264099.428..264099.429 rows=0 loops=1)"
"  Recheck Cond: (deposit_ids_seen = '{1,5,6,7,9}'::integer[])"
"  Rows Removed by Index Recheck: 97845730"
"  Heap Blocks: exact=47727 lossy=3092555"
"  ->  Bitmap Index Scan on gin_array  (cost=0.00..1772.00 rows=1 width=0) (actual time=9446.225..9446.225 rows=14002051 loops=1)"
"        Index Cond: (deposit_ids_seen = '{1,5,6,7,9}'::integer[])"
"Planning Time: 135.226 ms"
"Execution Time: 264110.251 ms"


-- FULL TEXT

explain analyze select * from stats.visits join stats.users on (id = worker_id)
WHERE to_tsvector('russian', characteristics) @@ to_tsquery('Пират') limit 1000000;

"Limit  (cost=1000.57..5329451.57 rows=90877 width=673) (actual time=0.435..54556.370 rows=1000000 loops=1)"
"  ->  Gather  (cost=1000.57..5329451.57 rows=90877 width=673) (actual time=0.433..54460.148 rows=1000000 loops=1)"
"        Workers Planned: 2"
"        Workers Launched: 2"
"        ->  Nested Loop  (cost=0.57..5319363.87 rows=37865 width=673) (actual time=1.975..54270.166 rows=333335 loops=3)"
"              ->  Parallel Seq Scan on users  (cost=0.00..5010614.33 rows=37865 width=455) (actual time=1.952..49412.421 rows=333335 loops=3)"
"                    Filter: (to_tsvector('russian'::regconfig, characteristics) @@ to_tsquery('Пират'::text))"
"                    Rows Removed by Filter: 365786"
"              ->  Index Scan using visits_pkey on visits  (cost=0.57..8.15 rows=1 width=218) (actual time=0.014..0.014 rows=1 loops=1000004)"
"                    Index Cond: (id = users.worker_id)"
"Planning Time: 0.640 ms"
"Execution Time: 54614.426 ms"

DROP INDEX IF EXISTS stats.gin_text;

CREATE INDEX gin_text ON stats.users USING GIN(to_tsvector('russian', characteristics));

"
Query returned successfully in 21 min 4 secs.
"

explain analyze select * from stats.visits join stats.users on (id = worker_id)
WHERE to_tsvector('russian', characteristics) @@ to_tsquery('Пират') limit 1000000;

"Limit  (cost=1845.45..3031012.72 rows=90920 width=673) (actual time=1980.181..50014.394 rows=1000000 loops=1)"
"  ->  Gather  (cost=1845.45..3031012.72 rows=90920 width=673) (actual time=1980.178..49932.080 rows=1000000 loops=1)"
"        Workers Planned: 2"
"        Workers Launched: 2"
"        ->  Nested Loop  (cost=845.45..3020920.72 rows=37883 width=673) (actual time=1911.878..49164.138 rows=333334 loops=3)"
"              ->  Parallel Bitmap Heap Scan on users  (cost=844.88..2712028.36 rows=37883 width=455) (actual time=1900.190..43113.103 rows=333334 loops=3)"
"                    Recheck Cond: (to_tsvector('russian'::regconfig, characteristics) @@ to_tsquery('Пират'::text))"
"                    Rows Removed by Index Recheck: 365911"
"                    Heap Blocks: lossy=43202"
"                    ->  Bitmap Index Scan on gin_text  (cost=0.00..822.15 rows=90920 width=0) (actual time=1970.094..1970.095 rows=8665465 loops=1)"
"                          Index Cond: (to_tsvector('russian'::regconfig, characteristics) @@ to_tsquery('Пират'::text))"
"              ->  Index Scan using visits_pkey on visits  (cost=0.57..8.15 rows=1 width=218) (actual time=0.017..0.017 rows=1 loops=1000002)"
"                    Index Cond: (id = users.worker_id)"
"Planning Time: 593.381 ms"
"Execution Time: 50067.277 ms"

-- JSON

explain analyze select * from stats.visits 
where (required_models?2::text) and ((required_models->>2::text)::integer > 5000)
	and (required_models?3::text) and ((required_models->>3::text)::integer > 5000)
limit 10000000;

"Limit  (cost=1000.00..4627465.43 rows=11 width=218) (actual time=277993.564..278005.590 rows=0 loops=1)"
"  ->  Gather  (cost=1000.00..4627465.43 rows=11 width=218) (actual time=277993.324..278005.350 rows=0 loops=1)"
"        Workers Planned: 2"
"        Workers Launched: 2"
"        ->  Parallel Seq Scan on visits  (cost=0.00..4626464.33 rows=5 width=218) (actual time=277845.468..277845.469 rows=0 loops=3)"
"              Filter: ((required_models ? '2'::text) AND (required_models ? '3'::text) AND (((required_models ->> '2'::text))::integer > 5000) AND (((required_models ->> '3'::text))::integer > 5000))"
"              Rows Removed by Filter: 33333334"
"Planning Time: 0.265 ms"
"Execution Time: 278012.635 ms"

DROP INDEX IF EXISTS stats.gin_json;


CREATE INDEX gin_json ON stats.visits USING GIN(required_models);

"
Query returned successfully in 22 min 51 secs.
"

explain analyze select * from stats.visits 
where (required_models?2::text)
	and (required_models?3::text)
	and (required_models?5::text)
	and (required_models?10::text)
limit 10000000;

"Limit  (cost=40.00..44.02 rows=1 width=218) (actual time=21690.678..145207.441 rows=10000000 loops=1)"
"  ->  Bitmap Heap Scan on visits  (cost=40.00..44.02 rows=1 width=218) (actual time=21669.739..144285.669 rows=10000000 loops=1)"
"        Recheck Cond: ((required_models ? '2'::text) AND (required_models ? '3'::text) AND (required_models ? '5'::text) AND (required_models ? '10'::text))"
"        Rows Removed by Index Recheck: 39990637"
"        Heap Blocks: lossy=1583672"
"        ->  Bitmap Index Scan on gin_json  (cost=0.00..40.00 rows=1 width=0) (actual time=21609.647..21609.648 rows=19998615 loops=1)"
"              Index Cond: ((required_models ? '2'::text) AND (required_models ? '3'::text) AND (required_models ? '5'::text) AND (required_models ? '10'::text))"
"Planning Time: 185.382 ms"
"Execution Time: 145692.082 ms"


-- PARTITIONING

-- p.s. тут я делаю секционирование на таблице размером в 1 млн, а не в 100, чтобы не плодить еще 40 гб данных

CREATE TABLE IF NOT EXISTS users_parted (
    worker_id integer,
	salary numeric(10, 2)
        NOT NULL
        CONSTRAINT positive_salary CHECK (salary > 0),
	visits_count integer
        NOT NULL
        CONSTRAINT not_neg_count CHECK (visits_count >= 0),
    characteristics text
        NOT NULL,
	PRIMARY KEY(visits_count, worker_id)
) PARTITION BY RANGE (visits_count);

-- salary range: (15000, 250000)


CREATE TABLE IF NOT EXISTS users_parted_by_salary_0_to_25000
	PARTITION OF users_parted FOR VALUES FROM (0) TO (25000);

CREATE TABLE IF NOT EXISTS users_parted_by_salary_25000_to_50000
	PARTITION OF users_parted FOR VALUES FROM (25000) TO (50000);

CREATE TABLE IF NOT EXISTS users_parted_by_salary_50000_to_75000
	PARTITION OF users_parted FOR VALUES FROM (50000) TO (75000);

CREATE TABLE IF NOT EXISTS users_parted_by_salary_75000_to_100000
	PARTITION OF users_parted FOR VALUES FROM (75000) TO (100000);

CREATE TABLE IF NOT EXISTS users_parted_by_salary_100000_to_300000
	PARTITION OF users_parted FOR VALUES FROM (100000) TO (300000);

INSERT INTO users_parted (worker_id, salary, visits_count, characteristics)
	SELECT * FROM stats.users;

"
Query returned successfully in 29 min 22 secs.
"

explain analyze select * from stats.users where salary > 76500 and salary < 86444;

"Gather  (cost=1000.00..1321024.83 rows=769711 width=455) (actual time=38.203..351261.112 rows=770216 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on users  (cost=0.00..1243053.73 rows=320713 width=455) (actual time=317.756..349617.221 rows=256739 loops=3)"
"        Filter: ((salary > '76500'::numeric) AND (salary < '86444'::numeric))"
"        Rows Removed by Filter: 5804580"
"Planning Time: 37.556 ms"
"Execution Time: 351392.924 ms"

explain analyze select * from users_parted where salary > 76500 and salary < 86444;

"Gather  (cost=1000.00..1292989.18 rows=747562 width=456) (actual time=21.539..272454.693 rows=770216 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Append  (cost=0.00..1217232.98 rows=311484 width=456) (actual time=7.070..271959.458 rows=256739 loops=3)"
"        ->  Parallel Seq Scan on users_parted_by_salary_0_to_25000  (cost=0.00..1215601.32 rows=311476 width=456) (actual time=7.068..271908.228 rows=256739 loops=3)"
"              Filter: ((salary > '76500'::numeric) AND (salary < '86444'::numeric))"
"              Rows Removed by Filter: 5804580"
"        ->  Parallel Seq Scan on users_parted_by_salary_25000_to_50000  (cost=0.00..18.56 rows=3 width=56) (actual time=0.000..0.001 rows=0 loops=1)"
"              Filter: ((salary > '76500'::numeric) AND (salary < '86444'::numeric))"
"        ->  Parallel Seq Scan on users_parted_by_salary_50000_to_75000  (cost=0.00..18.56 rows=3 width=56) (actual time=0.000..0.000 rows=0 loops=1)"
"              Filter: ((salary > '76500'::numeric) AND (salary < '86444'::numeric))"
"        ->  Parallel Seq Scan on users_parted_by_salary_75000_to_100000  (cost=0.00..18.56 rows=3 width=56) (actual time=0.000..0.000 rows=0 loops=1)"
"              Filter: ((salary > '76500'::numeric) AND (salary < '86444'::numeric))"
"        ->  Parallel Seq Scan on users_parted_by_salary_100000_to_300000  (cost=0.00..18.56 rows=3 width=56) (actual time=0.001..0.001 rows=0 loops=1)"
"              Filter: ((salary > '76500'::numeric) AND (salary < '86444'::numeric))"
"Planning Time: 184.658 ms"
"Execution Time: 272524.085 ms"

-- посмотреть все индексы
SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'stats'
ORDER BY
    tablename,
    indexname;	