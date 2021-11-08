set search_path to stats;

-- добавляю 2 таблицы, которые у меня пунктирные на рисунке

DROP TABLE IF EXISTS computed_deposits_stats;
DROP TABLE IF EXISTS computed_models_stats;

CREATE TABLE computed_deposits_stats (
    deposit_id integer
        PRIMARY KEY
        REFERENCES resources.deposits,
    overall_visits_count integer NOT NULL
        CONSTRAINT pos_count_1 CHECK (overall_visits_count > 0),
    unique_visitors_count integer NOT NULL
        CONSTRAINT pos_count_2 CHECK (unique_visitors_count > 0),
    average_salary numeric(10, 2) NOT NULL 
        CONSTRAINT positive_avg_salary CHECK (average_salary > 0)
);

CREATE TABLE computed_models_stats (
    model_id integer
        PRIMARY KEY
        REFERENCES resources.equipment_models,
    requested_units integer NOT NULL
        CONSTRAINT pos_count_3 CHECK (requested_units > 0),
    overall_visitors_count integer NOT NULL
        CONSTRAINT pos_count_4 CHECK (overall_visitors_count > 0),
    unique_visitors_count integer NOT NULL
        CONSTRAINT pos_count_5 CHECK (unique_visitors_count > 0)
);