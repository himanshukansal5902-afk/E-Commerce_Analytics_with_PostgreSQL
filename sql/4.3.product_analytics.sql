-- Product Anlytics

-- Which is the best and worst selling product?

-- Best Selling (Top 10)(In terms of revenue and quantity)
select 
	ii.stock_code, 
	p.description, 
	sum(ii.quantity) as total_quantitiy_sold,
	sum(ii.quantity * ii.unit_price) as total_revenue
from invoice_items as ii
left join products as p 
using(stock_code)
left join invoices as i
on ii.invoice_no = i.invoice_no
where ii.is_cancellation = False
group by ii.stock_code, p.description
order by total_revenue desc 
limit 10

-- Worst selling (10)
select 
	ii.stock_code, 
	p.description, 
	sum(ii.quantity) as total_quantitiy_sold,
	sum(ii.quantity * ii.unit_price) as total_revenue
from invoice_items as ii
left join products as p 
using(stock_code)
left join invoices as i
on ii.invoice_no = i.invoice_no
where ii.is_cancellation = False
group by ii.stock_code, p.description
order by total_revenue asc
limit 10;

-- Cancellation Rate
with cte as (
	select 
		ii.stock_code, 
		sum(case when not ii.is_cancellation then ii.quantity else 0 end) as sold_quantity,
		sum(case when ii.is_cancellation then abs(ii.quantity) else 0 end) as returned_quantity
	from invoice_items as ii
	group by ii.stock_code
)

select 
	c.stock_code, 
	p.description, 
	c.sold_quantity, 
	c.returned_quantity, 
	coalesce(round((c.returned_quantity::numeric/nullif(c.sold_quantity, 0)::numeric) * 100, 2), 0) as cancellation_rate
from cte as c
left join products as p
using(stock_code)
order by cancellation_rate desc
limit 10;

-- Some products are being cancelled more often than they are being sold, may be the dealer couldn't deliver them on time!

-- Items frequently bought together(Market Basket Analysis)
select a.stock_code, p1.description, b.stock_code, p2.description, count(*) as times_bought_together
from invoice_items as a
join invoice_items as b
on a.invoice_no = b.invoice_no and a.stock_code < b.stock_code -- here using inequality(<>) yielded similar pairs a, b and b, a in the results, so setting lexicological comparison eliminates the problem
left join products as p1
on a.stock_code = p1.stock_code
left join products as p2
on b.stock_code = p2.stock_code
where a.is_cancellation = False and b.is_cancellation = False
group by a.stock_code, p1.description, b.stock_code, p2.description
having count(*) > 10
order by times_bought_together desc
limit 10;

