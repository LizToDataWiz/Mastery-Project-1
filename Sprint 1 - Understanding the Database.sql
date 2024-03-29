-- SPRINT 1 tasks. Understanding the database.
-- 1. Can a user show up more than once in the activity table? 
select 
	uid,
 	count(spent) as purchased
from activity
group by uid
having count(spent) > 1

-------------------------------------------------------------------

-- 2. What type of join should we use to join the users table to the activity table?
select distinct users.id, 
users.country, 
users.gender, 
activity.device, 
sum(activity.spent)
from users
left join activity on users.id = activity.uid
group by 1,2,3,4

-------------------------------------------------------------------

-- 3. What SQL function can we use to fill in NULL values?
select
	distinct u.id,
  u.country,
  coalesce(u.gender,'O') as gender,
	SUM(COALESCE(a.spent, 0)) as total_spent
from users as u 
left join activity as a on u.id = a.uid
group by 1,2,3
-------------------------------------------------------------------

-- 4. What are the start and end dates of the experiment?
select
	min(join_dt) as start_date,
  max(join_dt) as end_date
from groups
-------------------------------------------------------------------

-- 5. How many total users were in the experiment?
select
	count(distinct id) as total_users
from users
-------------------------------------------------------------------

-- 6. How many users were in the control and treatment groups?
select
	case when groups.group = 'A' then 'Control'
  	else 'Treatment' end as group,
  count(groups.uid) as total_users
from groups
group by 1
-------------------------------------------------------------------

-- 7. What was the conversion rate of all users?
with cte as (
select
	case when a.spent is NOT NULL then 1
  		when a.spent is NULL then 0
      end as spent,
  u.id
from users u
left join activity a on u.id = a.uid
group by 1,2
)
select
	round(avg(spent) * 100,2) as conversion_rate
from cte
-------------------------------------------------------------------

-- 8. What is the user conversion rate for the control and treatment groups?

with cte as (
  select
	case when g.group = 'A' then 'Control'
  	else 'Treatment' end as test_group,
  case when a.spent is NOT NULL then 1
  		when a.spent is NULL then 0
      end as spent,
  g.uid as users
from groups g
left join activity a on g.uid = a.uid
group by 1,2,3
  )
select
	test_group,
	round(avg(spent) * 100,2) as conversion_rate
from cte
group by 1
-------------------------------------------------------------------

-- 9. What is the average amount spent per user for the control and treatment groups, 
--    including users who did not convert?

with cte as (
select
	case when g.group = 'A' then 'Control'
  	else 'Treatment' end as test_group,
  g.uid as total_users,
  coalesce(sum(a.spent),0) as total_spent
from groups g
left join users u on g.uid = u.id
left join activity a on g.uid = a.uid
group by 1,2
order by total_spent desc
)
select
	test_group,
  round(avg(total_spent),2) as avg_spent
from cte
group by 1
