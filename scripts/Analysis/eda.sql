/*
===============================================================
Exploratory Data Analysis (EDA) Script
===============================================================
Script Purpose:
This script is designed to perform exploratory data analysis (EDA) on the data stored in the 'datawarehouse' database. It provides insights into the structure, distribution, and relationships within the data across the bronze, silver, and gold layers.
It includes queries to explore tables, columns, dimensions, measures, and rankings of various metrics.
This script does not modify any data; it is intended for analysis and reporting purposes only.

*/

-- Explore All Objects in the Database

select *
from information_schema.tables
where
    table_schema in ('bronze', 'silver', 'gold');

-- Explore All Columns in the Database

select * from information_schema."columns" c 
where table_name in (
select table_name from information_schema.tables
where table_schema in ('bronze', 'silver', 'gold')
)
order by table_schema, table_name;

-- Dimension Exploration
select distinct country from gold.dim_customers dc;

select distinct
    category,
    subcategory,
    product_name
from gold.dim_products dc
order by category, subcategory;

-- Date Exploration
-- How many years of sales are available

select
    min(order_date) as first_date,
    max(order_date) as last_date,
    extract(
        year
        from max(order_date)
    ) - extract(
        year
        from min(order_date)
    ) as order_range_years
from gold.fact_sales;

-- The yongest and the oldest customer

select
    min(birthday) as oldest_birthdate,
    extract(
        year
        from now()
    ) - extract(
        year
        from min(birthday)
    ) as oldest_age,
    max(birthday) as youngest_birthdate,
    extract(
        year
        from now()
    ) - extract(
        year
        from max(birthday)
    ) as youngest_age
from gold.dim_customers;

-- Mesures Explorations
-- Find the Total Sales
select sum(sales_amount) as total_sales
from gold.fact_sales
    -- 29,356,250

-- How many items are sold
select sum(quantity) as total_quantity from gold.fact_sales;
-- 60,423

-- Find the average selling price
select avg(price) as total_quantity from gold.fact_sales;
-- 486.04

-- Find the Total number of Orders
select count(order_number) as total_orders from gold.fact_sales;
-- 60,398
select count(distinct order_number) as total_orders
from gold.fact_sales;
-- 27,659

-- Find the total number of products
select count(product_key) as total_products
from gold.dim_products dc;

select count(distinct product_key) as total_products
from gold.dim_products dc;
-- 295

-- Find the total number of customers
select count(customer_key) from gold.dim_customers dc;
-- 18,485

-- Find the total number of customers that has placed an order
select count(distinct customer_key) as total_customer
from gold.fact_sales;
-- 18,484

-- General report for all of the metrics
select 'Total Sales' as measure_name, SUM(sales_amount) as measure_value
from gold.fact_sales
union all
select 'Total Quantity', SUM(quantity) as measure_value
from gold.fact_sales
union all
select 'Average Price', avg(price)
from gold.fact_sales
union all
select 'Total Nr. Orders', count(distinct order_number)
from gold.fact_sales
union all
select 'Total Nr. Products', count(product_name)
from gold.dim_products
union all
select 'Total Nr. Customers', count(customer_key)
from gold.dim_customers;

-- Magnitude

-- Find total of customers by countries
select country, count(customer_key) as total_customers
from gold.dim_customers
group by
    country
order by total_customers desc;

-- Find total customers by gender
select gender, count(customer_key) as total_customers
from gold.dim_customers
group by
    gender
order by total_customers desc;

-- Find total products by category
select category, count(product_key) as total_products
from gold.dim_products
group by
    category
order by total_products desc;

-- What is the average costs in each category
select category, avg(cost) as avg_costs
from gold.dim_products
group by
    category
order by avg_costs desc;

-- What is the total revenue by category
select p.category, sum(f.sales_amount) as total_revenue
from gold.fact_sales f
    left join gold.dim_products p on p.product_key = f.product_key
group by
    p.category
order by total_revenue desc;

-- What is the total revenue by customer
select c.customer_key, c.first_name, c.last_name, sum(f.sales_amount) as total_revenue
from gold.fact_sales f
    left join gold.dim_customers c on c.customer_key = f.customer_key
group by
    c.customer_key,
    c.first_name,
    c.last_name
order by total_revenue desc;

-- What is the distribution of items across countries
select c.country, sum(f.quantity) as total_items
from gold.fact_sales f
    left join gold.dim_customers c on c.customer_key = f.customer_key
group by
    c.country
order by total_items desc;

-- Ranking Analysis

-- Which 5 products generate the highest revenue

select p.product_name, sum(f.sales_amount) as total_revenue
from gold.fact_sales f
    left join gold.dim_products p on p.product_key = f.product_key
group by
    p.product_name
order by total_revenue desc
limit 5;

select *
from (
        select
            p.product_name, sum(f.sales_amount) as total_revenue, row_number() over (
                order by sum(f.sales_amount) desc
            ) as rank_product
        from gold.fact_sales f
            left join gold.dim_products p on p.product_key = f.product_key
        group by
            p.product_name
        order by total_revenue desc
    )
where
    rank_product < 6;

-- 5 worst products

select p.product_name, sum(f.sales_amount) as total_revenue
from gold.fact_sales f
    left join gold.dim_products p on p.product_key = f.product_key
group by
    p.product_name
order by total_revenue asc
limit 5;