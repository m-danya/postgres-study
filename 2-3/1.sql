SET search_path TO resources;

-- узнаём, сколько денег на текущий момент принесла добыча конкретного ресурса

select name, count(*) as count_of_deposits, sum(100 - percents_left) * price as overall_sum
from 
	resources left join deposits on (resources.id = resource_id)
	group by resource_id, name, price
	order by overall_sum desc NULLS LAST;

-- подумать про left join


-- удалить все ресурсы

delete from resources; -- так не получится

--1. удалить все месторождения, тогда можно будет удалить все ресурсы
delete from deposits;
delete from resources; 
--2. удалить ресурсы, которые не найдены ни в одном месторождении
SET search_path TO resources;

delete from
resources
where id in
	(
		select resources.id 
		from resources 
			 left outer join deposits on (resources.id = resource_id)
		where deposits.id is null
	)
returning resources.name;

-- full!