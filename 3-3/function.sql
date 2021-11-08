DELETE FROM stats.computed_models_stats;

CREATE OR REPLACE PROCEDURE get_all_needed_models() AS
$$
DECLARE
    c1 CURSOR IS
        SELECT * FROM stats.visits
        WHERE extract(year from time) >= extract(year from current_timestamp) - 5;
    cur_row stats.visits%ROWTYPE;
    c integer;
    cur_model_id integer;
    cur_model_count integer;
    c2 CURSOR IS
        SELECT model_id FROM stats.computed_models_stats;
    cur_model integer;
BEGIN
    c = 100;
    FOR cur_row in c1 LOOP
        exit when c = 0; -- досрочный выход
        c = c - 1;
		raise notice 'cur_row: %', cur_row.required_models;
		FOR cur_model_id, cur_model_count in (select * from jsonb_each(cur_row.required_models)) LOOP
			raise notice 'models: %', cur_model_id;
            IF (select count(*) from stats.computed_models_stats where model_id = cur_model_id) = 0 
            THEN BEGIN
                raise notice 'gonna insert model % with count %', cur_model_id, cur_model_count; 
                INSERT INTO stats.computed_models_stats(model_id, requested_units, overall_visitors_count, unique_visitors_count)
                    VALUES(cur_model_id, cur_model_count, 1, 1);
			END;
            ELSE BEGIN
                raise notice 'gonna add % to model %', cur_model_count, cur_model_id; 
                UPDATE stats.computed_models_stats 
                    SET 
                        requested_units = requested_units + cur_model_count,
                        overall_visitors_count = overall_visitors_count + 1
                    where model_id = cur_model_id;
			END;
			END IF;

		END LOOP;
    END LOOP;
    
    -- now fill the unique_visitors_count
    IF 0 THEN 
		BEGIN
			FOR cur_model in c2 LOOP
				update stats.computed_models_stats
				set 
					unique_visitors_count = (select COUNT(*) from stats.visits where required_models?2::text group by user_id limit 10)
					where model_id = cur_model.model_id;
			END LOOP;
		END;
    END IF;

    EXCEPTION
        WHEN SQLSTATE '42501' THEN -- insufficient_privilege
            begin
            raise notice 'Not enough priveleges!';
            end;
END;

$$
LANGUAGE plpgsql;

CALL get_all_needed_models();
select * from stats.computed_models_stats
