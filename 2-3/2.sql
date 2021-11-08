SET search_path TO resources;

-- сколько единиц техники нужно будет вывести из эксплуатации каждому пункту добычи в течении трёх лет

select points.id, points.name, count(*) as going_to_be_decommissioned from 
equipment_units
	left join equipment_availability on (equipment_unit_id = equipment_units.id)
	left join deposits on (deposit_id = deposits.id)
	left join points on (point_id = points.id)
where decommissioning_year <= date_part('year', current_timestamp) + 3
group by points.id, points.name
order by going_to_be_decommissioned DESC
;

-- выводить критические первыми


SET search_path TO resources;

-- прибавить еще 5 лет ко всем истекающим срокам службы оборудования на указанном пункте, который нас попоросил об этом

update equipment_units as units
set decommissioning_year = decommissioning_year + 5
from equipment_availability 
	left join deposits on (deposit_id = deposits.id)
	left join points on (point_id = points.id)
where equipment_unit_id = units.id and points.id = 7 and units.decommissioning_year <= date_part('year', current_timestamp) + 3
returning equipment_unit_id, decommissioning_year as new_decommissioning_year;