-- Normalization

-- Choosing the first country for instances with same customer_id but different country for normalization
drop table if exists customers;
create table customers as
select customer_id,
       min(country) as country
from stg_clean
where customer_id != 'ANONYMOUS'
group by customer_id;

drop table if exists products;
create table products as
select stock_code,
      min(description) as description,
       min(unit_price) as unit_price
from stg_clean
group by stock_code;

drop table if exists invoices;
create table invoices as
select invoice_no,
       min(invoice_date) as invoice_date,
       min(customer_id) as customer_id,
       min(country) as country
from stg_clean
group by invoice_no;

drop table if exists invoice_items;
create table invoice_items as
select invoice_no,
       stock_code,
       sum(quantity) as quantity,
       min(unit_price) as unit_price,
       (sum(quantity) < 0) as is_cancellation
from stg_clean
group by invoice_no, stock_code;;

-- adding primary key constraints to the tables
alter table customers
add primary key (customer_id);

alter table products
add primary key (stock_code);

alter table invoices
add primary key (invoice_no);

alter table invoice_items
add primary key (invoice_no, stock_code);

-- adding foreign keys from invoices to customers

-- to handle for the anonymous values in the customer table while defining foreign key
insert into customers (customer_id, country)
values ('ANONYMOUS', 'UNKNOWN');

alter table invoices
drop constraint if exists fk_inv_cust;

alter table invoices
add constraint fk_inv_cust
foreign key (customer_id)
references customers(customer_id);

-- adding foreign key from invoice_items to invoices and products
alter table invoice_items
drop constraint if exists fk_ii_inv_1;

alter table invoice_items
add constraint fk_ii_inv_1
foreign key (invoice_no)
references invoices(invoice_no);

alter table invoice_items
drop constraint if exists fk_ii_inv_2;

alter table invoice_items
add constraint fk_ii_inv_2
foreign key (stock_code)
references products(stock_code);

