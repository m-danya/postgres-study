set search_path to resources;

-- p.s. этот триггер простоват — его можно заменить через check

CREATE OR REPLACE FUNCTION models_checker() RETURNS trigger AS $models_checker$
    BEGIN
        -- сумма юнитов меньше 
        IF 
                NEW.category <> 'оборудование для добычи' 
            and 
                NEW.category <> 'транспорт'
            THEN
                RAISE EXCEPTION 'wrong category!';
        END IF;
        RETURN NEW;
    END;
$models_checker$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS models_checker on equipment_models;

CREATE CONSTRAINT TRIGGER models_checker 
    AFTER INSERT OR UPDATE ON equipment_models
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE FUNCTION models_checker();


-- проверка триггера:

set search_path to resources;

select * from equipment_models;
insert into equipment_models(name, category) values('имя', 'транспорт');

-- auto-commit OFF

set search_path to resources;
begin;
select * from equipment_models;
insert into equipment_models(name, category) values('имя', 'нетранспорт');
-- ничего нельзя будет сделать до rollback