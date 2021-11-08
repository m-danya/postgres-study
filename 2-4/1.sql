-- Грязное чтение и повторное чтение в READ (UN)COMMITTED

set search_path to resources;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
begin;
                                                        set search_path to resources;
                                                        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
                                                        begin;

update resources set price = 500 where name='алмаз';

                                                        select * from resources where (name = 'алмаз')
                                        -- не работает, т.к. в postgres read uncommited работает как read commited
rollback;
                                                        select * from resources where (name = 'алмаз')
                                        -- аномалия повторного чтения


-- аномалия потерянных изменений

set search_path to resources;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
begin;
update resources set price = price + 10 where name='алмаз';
                                                        set search_path to resources;
                                                        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
                                                        begin;
                                                        update resources set price = price + 1 where name='алмаз';
                                                        commit;
                                        -- ожидание завершения первой транзакции
                                        -- в итоге цена будет 
                                        

commit;