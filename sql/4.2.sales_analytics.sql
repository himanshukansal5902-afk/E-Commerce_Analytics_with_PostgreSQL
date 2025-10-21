--analysing trend of revenue over different times of the year(seasons)

select 
	case
		when m in (12, 1, 2) then 'Winter'
        when m in (3, 4, 5) then 'Spring'
        when m in (6, 7, 8) then 'Summer'
        else 'Fall' end as season,
	round(sum(revenue), 2) as seasonal_revenue
from(
	select 
		to_char(i.invoice_date, 'FMMonth') as Month, 
		extract(month from i.invoice_date) as m, 
		sum(ii.quantity* ii.unit_price) as revenue 
	from invoices as i
	left join invoice_items as ii
	using(invoice_no)
	where is_cancellation = FALSE
	group by Month, m
) as sub
group by season
order by seasonal_revenue desc;

-- we found out that most profitable season was "Fall" whereas least profitable season was "Spring"

-- country-level sales breakdown
select
    i.country,
    sum(ii.quantity * ii.unit_price) as total_revenue,
    count(distinct i.invoice_no) as total_orders
from invoices i
join invoice_items ii on i.invoice_no = ii.invoice_no
WHERE ii.is_cancellation = FALSE
group by i.country
order by total_revenue desc, total_orders desc;

-- our results yields that United Kingdom generated the maximum revenue and placed the maximum orders

-- cancellation and refund analysis
with sales as(
    select
        count(distinct i.invoice_no) as total_orders
    from invoices as i
    JOIN invoice_items as ii 
	ON i.invoice_no = ii.invoice_no
    WHERE ii.is_cancellation = false
),
cancellations as(
    select
        count(distinct i.invoice_no) as cancelled_orders
    from invoices as i
    join invoice_items as ii on i.invoice_no = ii.invoice_no
    where ii.is_cancellation = true
)
select
    c.cancelled_orders,
    s.total_orders,
    round((c.cancelled_orders::decimal / s.total_orders) * 100, 2) AS cancellation_rate
FROM sales s, cancellations c;

-- cancellation rate is nearly 25% !!!!! This is unlikely in real world data, but if it is, it is a matter of grave concern

--daily performance

select
    to_char(i.invoice_date, 'Day') AS day_of_week,
    round(sum(ii.quantity * ii.unit_price), 2) AS total_revenue
from invoices as i
join invoice_items ii 
on i.invoice_no = ii.invoice_no
where ii.is_cancellation = FALSE
group by day_of_week
order by total_revenue desc;

--Thursdays generated the most revenue and sundays the least! Who could have guessed.
