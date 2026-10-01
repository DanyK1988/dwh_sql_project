/*
===============================================================
Advanced Data Analysis (ADA) Script
===============================================================
Script Purpose:
This script is designed to perform advanced data analysis on the data stored in the 'datawarehouse' database. 
It provides deep insights into business performance and trends.
The script includes: 
- Change over time analysis to track trends in sales, customers, and products.
- Cumulative analysis to understand the overall growth and performance.
- Performance analysis to compare current measures against targets and previous periods.
- Part-to-whole analysis to understand the contribution of different categories to the overall performance.

Also it includes general reports and segmentation analysis to categorize customers and products based on their behavior and characteristics.

This script does not modify any data; it is intended for analysis and reporting purposes only.

*/

-- Change overtime (track trends)

select
    extract(
        year
        from (order_date)
    ) as order_year,
    extract(
        month
        from (order_date)
    ) as order_month,
    sum(sales_amount) as total_Sales,
    count(distinct customer_key) as total_customers,
    sum(quantity) as total_quantity
from gold.fact_sales
where
    order_date is not null
group by
    extract(
        year
        from (order_date)
    ),
    extract(
        month
        from (order_date)
    )
order by order_year, order_month;

select
    date_trunc ('month', order_date) as order_month,
    sum(sales_amount) as total_Sales,
    count(distinct customer_key) as total_customers,
    sum(quantity) as total_quantity
from gold.fact_sales
where
    order_date is not null
group by
    date_trunc ('month', order_date)
order by order_month;

select
    to_char (order_date, 'YYYY-Mon') as order_year_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_key) as total_customers,
    sum(quantity) as total_quantity
from gold.fact_sales
where
    order_date is not null
group by
    date_trunc ('month', order_date),
    to_char (order_date, 'YYYY-Mon')
order by date_trunc ('month', order_date);

-- Cumulative analysis
select
    order_month,
    total_sales,
    sum(total_sales) over (
        order by order_month asc
    ) as running_total_sales,
    avg(avg_price) over (
        order by order_month
    ) as moving_avg_price
from (
        select
            date_trunc ('month', order_date) as order_month, sum(sales_amount) as total_sales, avg(price) as avg_price
        from gold.fact_sales
        where
            order_date is not null
        group by
            date_trunc ('month', order_date)
        order by order_month
    )

select
    order_year,
    total_sales,
    sum(total_sales) over (
        order by order_year asc
    ) as running_total_sales
from (
        select
            date_trunc ('year', order_date) as order_year, sum(sales_amount) as total_sales
        from gold.fact_sales
        where
            order_date is not null
        group by
            date_trunc ('year', order_date)
        order by order_year
    );

-- Performance Analysis: Current[Measure] - Target[Meassure]
/* Analyze the yearly performance of product by comparing their sales
* to both the average sales performance of the product and the previous year's sales */

with yearly_product_sales as (
select 
extract(year from (f.order_date)) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where f.order_date is not null
group by extract(year from (order_date)), p.product_name
order by order_year;

) 
select
order_year,
product_name,
current_sales,
avg(current_sales) over(partition by product_name) as avg_sales,
current_sales - avg(current_sales) over(partition by product_name) as diff_avg,
case when current_sales - avg(current_sales) over(partition by product_name) > 0 then 'Above Average'
	when current_sales - avg(current_sales) over(partition by product_name) = 0 then 'Average'
	else 'Below Average'
	end as avg_change,
lag(current_sales) over(partition by product_name  order by order_year) as prev_year_sales,
current_sales - lag(current_sales) over(partition by product_name  order by order_year) as diff_py,
case when current_sales - lag(current_sales) over(partition by product_name  order by order_year) > 0 then 'Growing Sales'
	when current_sales - lag(current_sales) over(partition by product_name  order by order_year) < 0 then 'Falling Sales'
	else 'No Change'
	end as yoy_sales
from yearly_product_sales
order by product_name, order_year;

-- Part-to-Whole Analysis

with category_sales as (
select 
category,
sum(sales_amount) as total_sales
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by category
)
select
category,
total_sales,
sum(total_sales) over() as overall_sales,
round(total_sales::numeric / sum(total_sales) OVER () * 100, 2) || ' %' AS percentage_of_total
from category_sales
order by total_sales desc;

-- Data Segmentation [Measure] By [Measure]

with
    products_segments as (
        select
            product_key,
            product_name,
            cost,
            case
                when cost < 100 then 'Below 100'
                when cost between 100 and 500  then '100-500'
                when cost between 500 and 1000  then '500-1000'
                else 'Above 1000'
            end as cost_range
        from gold.dim_products
        where
            cost != 0
    )
select cost_range, count(product_key) as total_products
from products_segments
group by
    cost_range
order by total_products desc;

with
    customer_spending as (
        select
            c.customer_key,
            sum(f.sales_amount) as total_sales,
            min(f.order_date) as first_order,
            max(f.order_date) as last_order,
            (
                extract(
                    year
                    from age (
                            max(f.order_date), min(f.order_date)
                        )
                ) * 12
            ) + extract(
                month
                from age (
                        max(f.order_date), min(f.order_date)
                    )
            ) as lifespan
        from gold.fact_sales f
            left join gold.dim_customers c on f.customer_key = c.customer_key
        group by
            c.customer_key
    ),
    customer_categories as (
        select
            customer_key,
            total_sales,
            lifespan,
            case
                when lifespan >= 12
                and total_sales > 5000 then 'VIP'
                when lifespan >= 12
                and total_sales <= 5000 then 'Regular'
                else 'New'
            end as customer_segment
        from customer_spending
    )
select
    customer_segment,
    count(customer_key) as total_customers
from customer_categories
group by
    customer_segment
order by total_customers desc;

-- Customer Report

create or replace view gold.report_customers as
with
    base_query as (
        /*------------------------------------------------------------------------------------
        * 1) Base Query: Retrieves core columns from tables
        * ----------------------------------------------------------------------------------*/
        select
            f.order_number,
            f.product_key,
            f.order_date,
            f.sales_amount,
            f.quantity,
            c.customer_key,
            c.customer_number,
            c.first_name || ' ' || c.last_name as full_name,
            extract(
                year
                from age (now(), c.birthdate)
            ) as age
        from gold.fact_sales f
            left join gold.dim_customers c on f.customer_key = c.customer_key
        where
            order_date is not null
    ),
    customer_aggregation as (
        /*------------------------------------------------------------------------------------
        * 2) Customer Aggregation: Summarazes key metrics at the customer level
        * ----------------------------------------------------------------------------------*/
        select
            customer_key,
            customer_number,
            full_name,
            age,
            count(distinct order_number) as total_orders,
            sum(sales_amount) as total_sales,
            sum(quantity) as total_quantity,
            count(distinct product_key) as total_products,
            max(order_date) as last_order_date,
            (
                extract(
                    year
                    from age (
                            max(order_date), min(order_date)
                        )
                ) * 12
            ) + extract(
                month
                from age (
                        max(order_date), min(order_date)
                    )
            ) as lifespan
        from base_query
        group by
            customer_key,
            customer_number,
            full_name,
            age
    )
select
    customer_key,
    customer_number,
    full_name,
    age,
    case
        when age < 20 then 'Under 20'
        when age between 20 and 29  then '20-29'
        when age between 30 and 39  then '30-39'
        when age between 40 and 49  then '40-49'
        else '50 and above'
    end as age_group,
    case
        when lifespan >= 12
        and total_sales > 5000 then 'VIP'
        when lifespan >= 12
        and total_sales <= 5000 then 'Regular'
        else 'New'
    end as customer_segment,
    last_order_date,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- Compute average order value (AVO)
    case
        when total_orders = 0 then 0
        else total_sales / total_orders
    end as avg_order_value,
    -- Compute average monthly spend
    case
        when lifespan = 0 then total_sales
        else total_sales / lifespan
    end as avg_monthly_spend
from customer_aggregation;