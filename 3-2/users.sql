REASSIGN OWNED BY test TO postgres;

REVOKE ALL ON ALL TABLES IN SCHEMA stats FROM test;
REVOKE ALL ON SCHEMA stats FROM test;
REVOKE ALL ON DATABASE resources FROM test;
REVOKE ALL ON TABLE prev_year_visits FROM test;
DROP ROLE IF EXISTS test;

CREATE USER test; -- == CREATE ROLE name LOGIN
GRANT USAGE ON SCHEMA stats TO test;
GRANT ALL ON DATABASE resources to test;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA stats TO test;

GRANT SELECT, UPDATE, INSERT ON stats.visits to test;
GRANT SELECT (worker_id, salary, visits_count, characteristics), UPDATE(characteristics) ON stats.users to test;
GRANT SELECT ON stats.computed_deposits_stats to test;
GRANT SELECT ON stats.computed_models_stats to test;

CREATE OR REPLACE VIEW public.prev_year_visits AS 
	SELECT * FROM stats.visits 
     WHERE extract(year from time) = extract(year from current_timestamp) - 1;
	 
CREATE OR REPLACE VIEW public.prev_5_years_visits AS 
	SELECT * FROM stats.visits 
     WHERE extract(year from time) >= extract(year from current_timestamp) - 5;
	 
CREATE OR REPLACE VIEW public.prev_10_years_visits AS 
	SELECT * FROM stats.visits 
     WHERE extract(year from time) >= extract(year from current_timestamp) - 10;


GRANT SELECT ON prev_year_visits to test;

CREATE ROLE visits_from_2020;
GRANT UPDATE(deposit_ids_seen, required_models) ON prev_year_visits to visits_from_2020;

CREATE USER view_test;
GRANT visits_from_2020 TO view_test;



-- ========================================================================================================

SET ROLE test;
-- тут пытаемся что-то делать от его имени





-- удаляем роли visits_from_2020 и view_test для повторного запуска скрипта
DROP ROLE IF EXISTS visits_from_2020

-- удаляем все права, данные пользователю, чтобы стереть пользователя.
-- как это сделать проще, я не нашёл
REASSIGN OWNED BY visits_from_2020 TO postgres;
REVOKE ALL ON ALL TABLES IN SCHEMA stats FROM visits_from_2020;
REVOKE ALL ON DATABASE resources FROM visits_from_2020;
REVOKE ALL ON TABLE prev_year_visits FROM visits_from_2020;
DROP ROLE IF EXISTS visits_from_2020;

REASSIGN OWNED BY view_test TO postgres;
REVOKE ALL ON ALL TABLES IN SCHEMA stats FROM view_test;
REVOKE ALL ON DATABASE resources FROM view_test;
REVOKE ALL ON TABLE prev_year_visits FROM view_test;
DROP ROLE IF EXISTS view_test;