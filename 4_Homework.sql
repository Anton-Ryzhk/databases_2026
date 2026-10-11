select * from demo.bookings.airports
where city = 'Moscow'


select departure_airport, status, scheduled_departure as sc_dp from demo.bookings.flights
where status = 'Arrived' and departure_airport in ('SVO','VKO','DME') and scheduled_departure < '2017-09-01' and scheduled_departure >= '2017-07-31'
order by actual_departure

select flight_no, scheduled_arrival, actual_arrival  from demo.bookings.flights
where ROUND(extract(EPOCH from(actual_arrival - scheduled_arrival)) / 60) >= 2
order by ROUND(extract(EPOCH from(actual_arrival - scheduled_arrival)) / 60)

select flight_no, COUNT(actual_arrival) as ac_amount from demo.bookings.flights
where flight_no like 'PG04%'
group by flight_no

select  departure_airport, COUNT(actual_arrival),ROUND(AVG(extract(EPOCH from(actual_arrival - scheduled_arrival)) / 60)) from demo.bookings.flights
where actual_arrival notnull
group by departure_airport
having COUNT(actual_arrival) > 500
order by ROUND(AVG(extract(EPOCH from(actual_arrival - scheduled_arrival)) / 60))


---------------------- HOMEWORK -----------------------------
--- 3.1
select 
	t.passenger_name,
	tf.amount,
	f.flight_no,
	d.city as departure_city,
	a.city as arrival_city
from ticket_flights tf
	join tickets t on t.ticket_no = tf.ticket_no
	join flights f on f.flight_id = tf.flight_id
	join airports  d on d.airport_code = f.departure_airport
	join airports  a on a.airport_code = f.arrival_airport
order by tf.amount desc
limit 10;


--- 3.2
select
    a.airport_code,
    a.airport_name,
    a.city,
    COUNT(f.flight_id) as departures_cnt
from airports a
    left join flights f on f.departure_airport = a.airport_code
group by a.airport_code, a.airport_name, a.city
order by departures_cnt desc;


--- 3.3
select
    t.passenger_id,
    t.passenger_name,
    COUNT(tf.flight_id) as flights_cnt,
    SUM(tf.amount)      as total_spent
from tickets t
    join ticket_flights tf on tf.ticket_no = t.ticket_no
group by t.passenger_id, t.passenger_name
order by total_spent desc
LIMIT 5;


--- 1 ---
select
    EXTRACT(month from f.scheduled_departure) as month,
    SUM(tf.amount) as monthly_revenue
from ticket_flights tf
    join flights f on f.flight_id = tf.flight_id
where f.scheduled_departure >= '2017-01-01'
  and f.scheduled_departure < '2018-01-01'
group by rollup (EXTRACT(month from f.scheduled_departure))
having SUM(tf.amount) > 10000000000
   or EXTRACT(month from f.scheduled_departure) is null
order by month;

--- 2 ---
--- с условием в on
select 
    a.airport_code,
    a.airport_name,
    COUNT(f.flight_id) as arrived_flights
from airports a
    left join flights f on f.arrival_airport = a.airport_code
                       and f.status = 'Arrived'
group by a.airport_code, a.airport_name
order by arrived_flights desc;

--- с условием в where
select
    a.airport_code,
    a.airport_name,
    COUNT(f.flight_id) as arrived_flights
from airports a
    left join flights f on f.arrival_airport = a.airport_code
where f.status = 'Arrived'
group by a.airport_code, a.airport_name
order by arrived_flights desc;

--- 3 ---
CREATE INDEX idx_flights_actual_arrival ON flights(actual_arrival);

--- неоптимизированный
select *
from flights f
where
  f.status = 'Arrived'
  and TO_CHAR(f.actual_arrival , 'YYYY-MM') = '2017-08'
  and EXTRACT(day from f.actual_arrival) in (5,6,12,13,19,20,26,27);

--- оптимизированный
select *
from flights f
where
f.status = 'Arrived'
and(
  f.actual_arrival >= '2017-08-05' and f.actual_arrival < '2017-08-07'
  or f.actual_arrival >= '2017-08-12' and f.actual_arrival < '2017-08-14'
  or f.actual_arrival >= '2017-08-19' and f.actual_arrival < '2017-08-21'
  or f.actual_arrival >= '2017-08-26' and f.actual_arrival < '2017-08-28');

--- 4
--- Запрос с NOT IN
select
    f.flight_id,
    f.flight_no,
    f.scheduled_departure,
    f.departure_airport,
    f.arrival_airport
from flights f
where f.flight_id not in (
    select tf.flight_id
    from ticket_flights tf
    where tf.fare_conditions = 'Business'
);

--- Запрос с NOT EXISTS
select 
    f.flight_id,
    f.flight_no,
    f.scheduled_departure,
    f.departure_airport,
    f.arrival_airport
from flights f
where not exists (
    select 1
    from ticket_flights tf
    where tf.flight_id = f.flight_id
      and tf.fare_conditions = 'Business'
);

--- 5
select status, COUNT(*)
from flights
group by status;

---
CREATE INDEX idx_flights_status ON flights(status);
VACUUM flights;

--- 
EXPLAIN (ANALYZE, BUFFERS) select status, COUNT(*)
from flights
group by status;