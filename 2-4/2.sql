-- Неповторяющееся чтение и фантомы в REPEATABLE READ

set search_path to resources;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
begin;
select price from resources where name like 'алмаз%';
                                                        set search_path to resources;
                                                        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
                                                        begin;
                                                        update resources set price = price * 10 where name='алмаз';
                                                        commit;
select price from resources where name like 'алмаз%';
-- то же самое, т.к. есть защита от update и delete
                                                        set search_path to resources;
                                                        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
                                                        begin;
                                                        insert into resources (name, price, type, unit)
                                                            values
                                                            ('алмазная пыль', 533, 'пыль', 'грамм');
                                                        commit;
select price from resources where name like 'алмаз%';

-- опять ничего не поменялось, несмотря на то, что по стандарту могло.
-- потому что в postgresql есть защита и от insert (фантомных чтений)
-- поэтому то же самое будет с serializable


-- пример serializable: class/value таблица. a: sum(class=1) -> insert(value=sum,class=2), b: наоборот
-- выдаст ошибку:  не удалось сериализовать доступ из-за зависимостей чтения/записи между транзакциями
