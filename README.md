# E‑Commerce Analytics with PostgreSQL

## 📌 Project Overview

This project is an **end‑to‑end PostgreSQL analytics pipeline** built on the Kaggle *Online Retail* dataset. The goal is to move beyond simple SQL querying and demonstrate **real‑world data engineering, advanced analytics, and performance optimization** using PostgreSQL.

The project covers the full lifecycle of a data analytics system:

* Raw data ingestion and cleaning
* Relational database modeling
* Advanced SQL analytics
* Operational KPI design
* Query performance optimization using indexes and `EXPLAIN ANALYZE`.

This mirrors how analytics systems are designed and optimized in production environments.

---

## 🎯 Business Objective

To analyze e‑commerce transaction data and extract actionable insights related to:

* Customer behavior and retention
* Sales performance over time and geography
* Product performance and returns
* Operational efficiency metrics

The insights can support decisions in marketing, inventory planning, and operational strategy.

---

## 🗂 Dataset

* **Source:** Kaggle – Online Retail Dataset
* **Size:** ~500K transactions
* **Description:** UK‑based online retail transactions including invoices, customers, products, quantities, prices, and cancellations.

> Note: The raw dataset is included in the repository. A link to the dataset is also provided herewith.
Dataset: https://www.kaggle.com/datasets/carrie1/ecommerce-data?resource=download

---

## 🏗 Database Design & Data Engineering (Phase 1)

### Staging

* Raw CSV data is first loaded into a staging table using pgadmin's import.
* Basic validation and cleanup are performed before transformation.
  * Supposed date column was not postgresql supported `date` datatype: changed it to `varchar`
  * There was a character which was not properly encoded according to utf-8 encoding: had to remove that as it was part of the description column.
  * There was an entry in the `stockcode` column which was slightly bigger in size: had to expand size for the column.
  * `invoiceno` had, for some values, ‘c’ preceding the id, which meant the order was cancelled: changed data type from `int` to `varchar`


### Data Cleaning

* Removed (4879) duplicate rows
* Handled (135080) missing `CustomerID` values (tagged as `ANONYMOUS`)
* Identified cancellations via invoice numbers and negative quantities
* Normalized returns using an `is_cancellation` flag
* Some descriptions map to multiple `StockCodes`; analysis is done using `StockCode` as the primary product identifier.
* Some customers had multiple country entries. For normalization, we kept one country per customer for primary key purposes.
* Stored the cleaned csv file as `stg_clean` to preserve the original *unclean* file as well.

### Normalized Schema

The staging data is transformed into a relational schema:

* **customers** (`customer_id`, `country`)
* **products** (`stock_code`, `description`, `unit_price`)
* **invoices** (`invoice_no`, `invoice_date`, `customer_id`, `country`)
* **invoice_items** (`invoice_no`, `stock_code`, `quantity`, `unit_price`, `is_cancellation`)

This design reduces redundancy and supports scalable analytics.

---

## 📊 Analytics (Phase 2)

### 1️⃣ Customer Analytics

* Customer Lifetime Value (CLV)
* Churn identification (no purchases in the last 6 months)
* RFM (Recency, Frequency, Monetary) segmentation using window functions

**Outcome:** Identified high‑value customers, at‑risk customers, and churned segments.

---

### 2️⃣ Sales Analytics

* Revenue trends by season and time
* Country‑level revenue and order volume
* Cancellation and refund analysis
* Day‑of‑week performance patterns

**Outcome:** Seasonal sales patterns and geographic revenue concentration were identified.

---

### 3️⃣ Product Analytics

* Best‑ and worst‑selling products
* Product‑level cancellation rates
* Frequently bought together analysis (market basket analysis)

**Outcome:** Highlighted top revenue‑driving products, high‑return items, and cross‑selling opportunities.

---

### 4️⃣ Operational KPIs

* Average Order Value (AOV)
* Orders per customer
* Repeat purchase rate
* Revenue per customer
* Average items per order
* Revenue lost due to cancellations

These KPIs provide a dashboard‑style view of business health.

---

## ⚡ Performance Optimization (Phase 3)

To simulate production‑grade analytics, performance optimization was applied.

### Indexing Strategy

A dedicated indexing strategy was implemented to optimize:

* Join operations
* Filtering on cancellation flags
* Time‑based analytics
* Self‑joins used in market basket analysis

Indexes include:

* Single‑column indexes
* Composite indexes
* Partial indexes (e.g., non‑cancelled transactions only)

All indexes are defined in a separate `indexes.sql` file.

---

### Query Benchmarking with `EXPLAIN ANALYZE`

High‑cost analytical queries were benchmarked using `EXPLAIN ANALYZE` before and after optimization.

Key improvements:

* Sequential scans replaced with index scans
* Significant reductions in execution time for aggregation and self‑join queries

This provided measurable evidence of optimization effectiveness.

---

## 🛠 Technology Stack & Versions

The project was developed using the following tools and technologies:

Database: PostgreSQL (tested on PostgreSQL 17)

Client / IDE: pgAdmin 4 (tested on version 9.6)

SQL Features Used: CTEs, window functions, views, indexing, `EXPLAIN ANALYZE`

Version Control: Git & GitHub

Exact PostgreSQL version may vary; all queries rely on standard PostgreSQL features available in modern releases.

---
## 📁 Project Structure

```
ecommerce-analytics-postgresql/
├── query_outputs/                  # Query outputs / CSV exports
│   ├── 1.data_staging_area.csv
│   ├── 2.data_cleaned.csv
│   ├── 3.1.customers.csv
│   ├── 3.2.invoices.csv
│   ├── 3.3.products.csv
│   ├── 3.4.invoice_items.csv
│   ├── 4.1.1(customer_analytics)customer_lifetime_value.csv
│   ├── 4.1.2(customer_analytics)churned_customers.csv
│   ├── 4.1.3(customer_analytics)rfm_score.csv
│   ├── 4.2.1(sales_analytics)seasonal_revenue.csv
│   ├── 4.2.2(sales_analytics)revenue_and_orders_by_country.csv
│   ├── 4.2.3(sales_analytics)cancellation_and_refund_analysis.csv
│   ├── 4.2.4(sales_analytics)day_of_week_sales_analysis.csv
│   ├── 4.3.1(product_analytics)best_selling_products.csv
│   ├── 4.3.2(product_analytics)worst_selling_products.csv
│   ├── 4.3.3(product_analytics)cancellation_rate.csv
│   ├── 4.3.4(product_analytics)assossiation_among_products.csv
│   ├── 4.4.1(operational_KPIs)average_order_value.csv
│   ├── 4.4.2(operational_KPIs)repeat_purchase_rate.csv
│   ├── 4.4.3(operational_KPIs)avg_order_per_custoemr.csv
│   ├── 4.4.4(operational_KPIs)avg_revenue_per_customer.csv
│   ├── 4.4.5(operational_KPIs)avg_items_per_customer.csv
│   └── 4.4.6(operation_KPIs)cancellation_impact.csv
├── sql/
│   ├── 1.data_loading.sql
│   ├── 2.data_cleaning.sql
│   ├── 3.normalization.sql
│   ├── 4.1.customer_analytics.sql
│   ├── 4.2.sales_analytics.sql
│   ├── 4.3.product_analytics.sql
│   ├── 4.4.operational_KPIs.sql
│   └── 5.1.indexes.sql
├── er_diagram.png/                 # ER diagrams
├── raw_data.csv/                     # Dataset link
└── README.md
```

---

## 🧠 Key Skills Demonstrated

* Relational database design
* Advanced SQL (CTEs, window functions, self‑joins)
* Data cleaning and transformation
* Query optimization and indexing
* Performance analysis using `EXPLAIN ANALYZE`
* Business‑oriented KPI design

---

## 🚀 Future Enhancements

* Power BI / Tableau dashboards on top of PostgreSQL
* Python‑based churn prediction and customer segmentation
* Dockerized PostgreSQL environment
* Automated query testing with CI/CD

---

## 🧾 How to Run

1. Load the dataset into PostgreSQL
2. Execute SQL files in order:

   * `data_cleaning.sql`
   * `normalization.sql`
   * Analytics scripts
   * `indexes.sql`
3. Review results in the `query_outputs/` directory

---