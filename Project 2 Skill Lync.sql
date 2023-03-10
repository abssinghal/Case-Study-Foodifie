use test;
-- 
SELECT s1.customer_id,
s1.plan_id,
s2.plan_id,
s1.start_date,
s2.start_date
FROM
subscriptions s1,
subscriptions s2
WHERE
s1.customer_id = s2.customer_id
AND s1.plan_id < s2.plan_id
ORDER BY s1.plan_id , s2.plan_id;

-- 1
SELECT
COUNT(DISTINCT (customer_id)) AS customers_count
FROM
subscriptions;

-- 2
select distinct(month(start_date)) as month,
count(month(start_date)) over (partition by month(start_date) ) as count
from subscriptions
where plan_id=0;

-- 3
select distinct(s.plan_id),p.plan_name,
count(s.start_Date) over (partition by year(s.start_date)) as count_events

from subscriptions as s,plans as p
 where year(s.start_date)>2020 and p.plan_id=s.plan_id

order by s.plan_id;

-- 4
select (select count(distinct(customer_id)) from subscriptions where plan_id=4) as count_churned,
round((select count(distinct (customer_id)) from subscriptions where plan_id=4)*100/count(distinct (customer_id)),1) as percentage
from subscriptions;

-- 5
select (count(distinct (a.customer_id))) as count_churned from
(select s1.customer_id from subscriptions s1,subscriptions s2 where
s1.customer_id = s2.customer_id and s1.plan_id=0 and s2.plan_id=4) as a;

-- 6 
select count(a.customer_id) as counts,
count(a.customer_id)*100/(select count(b.customer_id) from (SELECT s1.customer_id
FROM
subscriptions s1,
subscriptions s2
WHERE
s1.customer_id = s2.customer_id
AND s1.plan_id < s2.plan_id 
ORDER BY s1.plan_id , s2.plan_id) as b) as percentage
from 
(SELECT s1.customer_id
FROM
subscriptions s1,
subscriptions s2
WHERE
s1.customer_id = s2.customer_id
AND s1.plan_id < s2.plan_id 
AND s1.plan_id =0
ORDER BY s1.plan_id , s2.plan_id) as a;

-- 7
select distinct(a.plan_id),
p.plan_name,
count(a.customer_id) over (partition by a.plan_id) as counts,
count(a.customer_id) over (partition by a.plan_id) *100.0/8 as percentage from 
(select distinct(s.customer_id),
max(s.plan_id) over (partition by s.customer_id) as plan_id, 
max(s.start_date) over (partition by s.customer_id) as Start_Date 
from subscriptions as s 
where s.start_date<='2020-12-31' 
order by s.customer_id) as a, plans as p
where a.plan_id=p.plan_id;

-- 8
SELECT distinct s1.customer_id,
max(s1.plan_id) over (partition by s1.customer_id) as Initial_plan,
s2.plan_id as New_plan,
p.plan_name,
max(s2.start_date) over (partition by s1.customer_id) as Start_Date
FROM
subscriptions as s1,
subscriptions as s2,
plans as p
WHERE
s1.customer_id = s2.customer_id
AND s2.plan_id=p.plan_id
AND s1.plan_id < s2.plan_id
AND year(s1.start_date)=2020
AND s2.plan_id=3
ORDER BY s1.plan_id , s2.plan_id
;

-- 9
select avg(v.days) as average_days from 
(SELECT distinct s1.customer_id,
min(s1.plan_id) over (partition by s1.customer_id) as Initial_plan,
s2.plan_id as New_plan,
p.plan_name,
min(s1.start_date) over (partition by s1.customer_id) as Initial_date,
max(s2.start_date) over (partition by s1.customer_id) as Renwal_date,
datediff(max(s2.start_date) over (partition by s1.customer_id),min(s1.start_date) over (partition by s1.customer_id)) as days
FROM
subscriptions as s1,
subscriptions as s2,
plans as p
WHERE
s1.customer_id = s2.customer_id
AND s2.plan_id=p.plan_id
AND s1.plan_id < s2.plan_id
AND year(s1.start_date)=2020
AND s2.plan_id=3
ORDER BY s1.plan_id , s2.plan_id) as v
;

-- 10
select case 
		when avg(v.days) between 0 and 30 then '0-30'
        when avg(v.days) between 30 and 60 then '30-60'
        when avg(v.days) between 60 and 90 then '60-90'
        when avg(v.days) between 90 and 120 then '90-120'
        else 'Above 120 days'
        end 
        as average_days_status from 
(SELECT distinct s1.customer_id,
min(s1.plan_id) over (partition by s1.customer_id) as Initial_plan,
s2.plan_id as New_plan,p.plan_name,
min(s1.start_date) over (partition by s1.customer_id) as Initial_date,
max(s2.start_date) over (partition by s1.customer_id) as Renwal_date,
datediff(max(s2.start_date) over (partition by s1.customer_id),min(s1.start_date) over (partition by s1.customer_id)) as days
FROM
subscriptions as s1,subscriptions as s2,plans as p
WHERE
s1.customer_id = s2.customer_id
AND s2.plan_id=p.plan_id
AND s1.plan_id < s2.plan_id
AND year(s1.start_date)=2020
AND s2.plan_id=3
ORDER BY s1.plan_id , s2.plan_id) as v;

-- 11
SELECT distinct s1.customer_id,
max(s1.plan_id) over (partition by s1.customer_id) as Initial_plan,
s2.plan_id as New_plan,
p.plan_name,
max(s2.start_date) over (partition by s1.customer_id) as Start_Date
FROM
subscriptions as s1,
subscriptions as s2,
plans as p
WHERE
s1.customer_id = s2.customer_id
AND s2.plan_id=p.plan_id
AND s1.plan_id > s2.plan_id
AND year(s1.start_date)=2020
AND s2.plan_id=2
AND s1.plan_id=1
ORDER BY s1.plan_id , s2.plan_id
;
update plans set plan_name='pro monthly' where plan_id=2;
select * from plans;

select 1 union all select 1 union all select 1;

--
select *, 
row_number() over (partition by customer_id order by start_date desc)  as orders
from subscriptions 
order by customer_id,start_date ;
--

select a.* from 
(select *, 
row_number() over (partition by customer_id order by start_date desc)  as orders
from subscriptions 
order by customer_id,start_date ) as a 
where a.plan_id>0
;

--
select a.*, if(plan_id=1 AND year(start_Date)=2020 AND month(Start_Date)<12,date_add(start_Date,interval 1 month),0) as new_month from 
(select *, 
row_number() over (partition by customer_id order by start_date desc)  as orders
from subscriptions 
order by customer_id,start_date ) as a 
where a.plan_id>0
;

