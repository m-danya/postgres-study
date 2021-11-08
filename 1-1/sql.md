## 1
Среднее количество билетов в каждой брони
```sql
select avg(t.c) FROM (select book_ref, count(ticket_no) as c from bookings.tickets GROUP BY book_ref) as t;
```
## 2
Считает, сколько раз самолёты прибывали и улетали в/из этого аэропорта. 
```sql
SELECT airport_code, airport_name, city, departure_times, arrive_times
    FROM airports 
    INNER JOIN 
        (
            SELECT departure_airport AS airport_code, COUNT(departure_airport) AS departure_times 
            FROM 
                flights AS f
                INNER JOIN airports_data ON departure_airport = airport_code
            GROUP BY departure_airport
            ORDER BY departure_airport
        )
    AS d_count_table 
    USING(airport_code)
    INNER JOIN 
        (
            SELECT arrival_airport AS airport_code, COUNT(arrival_airport) AS arrive_times 
            FROM 
                flights AS f
                    INNER JOIN airports_data ON departure_airport = airport_code
            GROUP BY arrival_airport
            ORDER BY arrival_airport
        )
    AS a_count_table USING(airport_code);
```
## 3
Показать сколько каких классов обслуживания было
```sql
SELECT seats.fare_conditions, COUNT(*) FROM seats GROUP BY seats.fare_conditions;
```
## 4
Показать, какой пассажир в каком классе летал
```sql
SELECT book_ref, 
    to_char(book_date, 'YYYY') as y, 
    to_char(book_date, 'MM') as m, 
    to_char(book_date, 'DD') as d
FROM bookings.bookings
WHERE total_amount > 30000.00
ORDER BY y, m, d;
```

## Задания на паре

1. вывести всех пассажиров, у которых уровень обсл. наимеенее популярный среди всех
```sql
SELECT passenger_name, fare_conditions
FROM
	ticket_flights AS tf
	INNER JOIN 
		(SELECT 
			ticket_flights.fare_conditions,
			COUNT(*) as c
		FROM Ticket_flights
		GROUP BY ticket_flights.fare_conditions
		ORDER BY c ASC
		LIMIT 1) as least_popular
	USING (fare_conditions)
	INNER JOIN tickets USING (ticket_no);
```
ALT
```sql
WITH
least_popular as 
	(SELECT 
	ticket_flights.fare_conditions,
	COUNT(*) as c
	FROM Ticket_flights
	GROUP BY ticket_flights.fare_conditions
	ORDER BY c ASC
	LIMIT 1)
SELECT passenger_name, fare_conditions
FROM tickets INNER JOIN ticket_flights USING (ticket_no)
WHERE fare_conditions IN (SELECT fare_conditions from least_popular)

limit 1000;
```
2. посчитать топ аэропортов по суммарным стоимостям бронирования (dep + arr, каждая бронь уч. 2 раза (если не один и тот же город)))
```sql
SELECT airport_name, sum_1 + sum_2 as sum
FROM 
    (SELECT departure_airport as airport_code, sum(total_amount) as sum_1
        FROM
                bookings
            LEFT OUTER JOIN
                tickets USING (book_ref)
            INNER JOIN
                ticket_flights USING (ticket_no)
            INNER JOIN
                flights USING (flight_id)
            GROUP BY departure_airport
        LIMIT 50
    ) as d_table 
    INNER JOIN 
    (SELECT arrival_airport as airport_code, sum(total_amount) as sum_2
        FROM
                bookings
            LEFT OUTER JOIN
                tickets USING (book_ref)
            INNER JOIN
                ticket_flights USING (ticket_no)
            INNER JOIN
                flights USING (flight_id)
            GROUP BY arrival_airport

        LIMIT 50
    ) as a_table
    USING (airport_code)
	INNER JOIN airports USING (airport_code)
	ORDER BY sum
	;
```


правда ли, что самолет имеет бОльшую дальность, чем другие из той же модели:
```sql
select model, range, range > (
	select avg(range) from aircrafts where model like 
	concat(SUBSTR(model,1, POSITION(' ' IN model)), $$%$$)
)
from aircrafts
```

.
.
.
.
.
.
.
.
.
.
.
.
.
.
.
.
.
## Намётки

```sql
SELECT city FROM weather
    WHERE temp = (SELECT max(temp) FROM weather)
```

```sql
select * from bookings.seats as s, bookings.aircrafts_data as a 
	where a.aircraft_code = s.aircraft_code;
```
можно заюзать USING тут
```sql
T1 INNER T2 USING (id)
```


```sql
SELECT string_agg(a, ',' ORDER BY b DESC) FROM table
```

```sql
SELECT depname, empno, salary, avg(salary) OVER (PARTITION BY depname)
  FROM empsalary;
```

Пример: показать номер по зарплате отдела:

```sql
SELECT depname, empno, salary,
       rank() OVER (PARTITION BY depname ORDER BY salary DESC)
FROM empsalary;
```
Данный запрос покажет только те строки внутреннего запроса, у которых `rank` (порядковый номер) меньше 3:
```sql
SELECT depname, empno, salary, enroll_date
FROM
  (SELECT depname, empno, salary, enroll_date,
    rank() OVER (PARTITION BY depname ORDER BY salary DESC, empno) AS pos
   FROM empsalary
  ) AS ss
WHERE pos < 3;
```

Вывести самый населённый город в каждом штате:
```sql
SELECT name, 
        (SELECT max(population) FROM cities WHERE cities.state = states.name)
    FROM states;
```

```sql
SELECT product_id, p.name, (sum(s.units) * (p.price - p.cost)) AS profit
    FROM products p LEFT JOIN sales s USING (product_id)
    WHERE s.date > CURRENT_DATE - INTERVAL '4 weeks'
    GROUP BY product_id, p.name, p.price, p.cost
    HAVING sum(p.price * s.units) > 5000;
```