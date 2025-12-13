--Average order value (AOV)
--total revenue / Number of orders

select 
	round(
		sum(ii.quantity * ii.unit_price)/count (distinct i.invoice_no)
	, 2) as avg_order_value
from invoices as i
join invoice_items as ii 
using(invoice_no)
where ii.is_cancellation = False;

--Repeat purchase rate
--percentage of customers who places more than one order
with customer_orders as (
    select
        customer_id,
        count(distinct i.invoice_no) as order_count
    from invoices as i
    join invoice_items ii on i.invoice_no = ii.invoice_no
    where ii.is_cancellation = False
    group by customer_id
)
select
    round(
        count(*) filter (where order_count > 1)::decimal
        / count(*) * 100,
        2
    ) as repeat_purchase_rate
from customer_orders;

--Orders per customer(repeat frequency)
select
    round(
        count(distinct i.invoice_no)::decimal
        / count(distinct i.customer_id),
        2
    ) as avg_orders_per_customer
from invoices as i
join invoice_items as ii on i.invoice_no = ii.invoice_no
where ii.is_cancellation = FALSE;

--revenue per customer
select 
	round(
		sum(ii.quantity * ii.unit_price)/count(distinct i.customer_id)
	,2) as revenue_per_customer
from invoice_items as ii
join invoices as i
using(invoice_no)
where is_cancellation = False;

--average items per order
select
	round(
		sum(ii.quantity)/count(distinct ii.invoice_no)
	, 2) as avg_items_per_order
from invoice_items as ii
where is_cancellation = false;

--cancellation revenue 
select round(
		sum(case when is_cancellation = true then abs(ii.quantity*ii.unit_price)
		else 0 end)
	, 2) as cancelled_revenue,
	round(
		sum(abs(ii.quantity*ii.unit_price))
	, 2) as total_revenue,
	round(
		(sum(case when is_cancellation = true then abs(ii.quantity*ii.unit_price)
		else 0 end)/sum(abs(ii.quantity*ii.unit_price)))*100
	,2) as cancellation_revenue_pct
from invoice_items as ii;