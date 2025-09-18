-- calculating customer lifetime value (CLI)
-- we disregard 'ANONYMOUS' customers and identify customers with highest lifetime values

select 
	c.customer_id, 
	sum(
		case when ii.is_cancellation then -quantity*unit_price
		else quantity*unit_price end	
	) as CUSTOMER_LIFETIME_VALUE
from customers as c
left join invoices as i
on c.customer_id = i.customer_id
left join invoice_items as ii
on i.invoice_no = ii.invoice_no
where c.customer_id <> 'ANONYMOUS'
group by c.customer_id
order by customer_lifetime_value desc;


-- identifying churned customers (customers who haven't bought anything is the last 6 months)
-- we consider the date of latest order as the current date for our calculations

select 
	sub.customer_id, 
	sub.latest_order_date::date
from(
	select customer_id, max(invoice_date) as latest_order_date
	from customers as c
	left join invoices as i
	using(customer_id)
	group by c.customer_id
) as sub
where 
	(
		(
			select max(invoice_date)::timestamp
			from invoices
		) - latest_order_date::timestamp
	) > interval '6 months';


-- Segment customers by RFM (Recency, Frequency, Monetary) using window functions.

with cte as(select 
	c.customer_id, 
	(select max(invoice_date)::date from invoices) - max(i.invoice_date)::date as recency, 
	count(distinct i.invoice_no) as frequency,
	sum(
		case when is_cancellation then -ii.quantity * ii.unit_price
		else ii.quantity * ii.unit_price end
	) as monetary
from customers as c
left join invoices as i
using(customer_id)
left join invoice_items as ii
on i.invoice_no = ii.invoice_no
where c.customer_id <> 'ANONYMOUS'
group by c.customer_id)
,

-- mapping the recency, frequency, monetary values from cte into scores(1-5, 5 is highest) 
cte2 as (
select 
	customer_id,
	6 - ntile(5) over(order by recency) as recency_score, -- the highest recency count means the least recent purchase
	ntile(5) over(order by frequency) as frequency_score,
	ntile(5) over(order by monetary) as monetary_score
from cte
)

select 
	customer_id, 
	recency_score,
	frequency_score,
	monetary_score, 
	(recency_score::char || frequency_score::char || monetary_score::char) as rfm_segment,
	recency_score + frequency_score + monetary_score as rfm_score -- max: 15, min: 3
from cte2;