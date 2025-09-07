-- Data cleaning

drop table if exists stg_clean;

-- Removing duplicate records
create table stg_clean as
select distinct *
from stg_table;

-- update null values in customer_id column to ANONYMOUS
alter table stg_clean
alter customer_id type varchar(20);

update stg_clean
set customer_id = 'ANONYMOUS'
where customer_id is null;

-- define an additional column acting as a flag for cancelled orders.
alter table stg_clean add column is_cancellation boolean;
update stg_clean
set is_cancellation = invoice_no like 'C%';

-- formatting description column
update stg_clean
set description = initcap(trim(description));

select description, count(*)
from stg_clean
group by description
having count(*) > 1;

update stg_clean
set description = 'UNKNOWN'
where description is null or description in ('', '?', '??', '???Missing', '?Missing');

-- type casting invoice_date to timestamp data_type
alter table stg_clean
alter column invoice_date type timestamp
using to_timestamp(invoice_date, 'MM/DD/YYYY HH24:MI');