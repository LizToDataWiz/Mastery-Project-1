-- Novelty Effect
-- Inspect the difference in the key metrics between the groups over time.


with cte_A as (
select
  g.uid as users_id,
  g.join_dt as join_date,
	case when g.group = 'A' then 'Control'
  	else 'Treatment' end as test_group,
  coalesce(sum(a.spent),0) as total_spent,
  case when a.spent is NOT NULL then 1
       when a.spent is NULL then 0
       end as spent
from groups g
left join activity a on g.uid = a.uid
group by 1,2,3,5
order by total_spent desc
),
control_metrics as (
select
  join_date,
  test_group,
  round(avg(total_spent),2) as avg_spent,
  round(avg(spent),4) as conversion_rate
from cte_A
where test_group = 'Control'
group by 1,2
),
treatment_metrics as (
select
  join_date,
  test_group,
  round(avg(total_spent),2) as avg_spent,
  round(avg(spent),4) as conversion_rate
from cte_A
where test_group = 'Treatment'
group by 1,2
)

select
  cm.join_date,
  tm.avg_spent - cm.avg_spent as diff_avg_spent,
  tm.conversion_rate - cm.conversion_rate as diff_conversion_rate
from control_metrics as cm
join treatment_metrics as tm on cm.join_date = tm.join_date








