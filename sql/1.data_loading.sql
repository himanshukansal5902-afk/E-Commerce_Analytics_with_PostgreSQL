create table stg_table(
	InvoiceNo varchar(10),
	StockCode varchar(10),
	Description varchar,
	Quantity int,
	InvoiceDate date,
	UnitPrice numeric,
	CustomerID	int,
	Country varchar(30)
);	

alter table stg_table
alter column invoiceno type varchar(10);

alter table stg_table
alter column stockcode type varchar(15);

alter table stg_table
alter column invoicedate type varchar(20);

select * from stg_table
limit 10;
