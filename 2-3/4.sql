SET search_path TO resources;

-- единица транспорта и количество работников, имеющих доступ к ней

select equipment_units.id, equipment_models.name, equipment_units.decommissioning_year, count(*) as workers from
	equipment_units left join equipment_availability on (id = deposit_id)
					--left join equipment_units on (equipment_unit_id = equipment_units.id)
					left join equipment_models on (equipment_model_id = equipment_models.id)
					left join deposits on (deposits.id = deposit_id)
					left join workers on (workers.deposit_id = deposits.id)
	group by equipment_units.id, equipment_models.name
	order by equipment_models.name; 
