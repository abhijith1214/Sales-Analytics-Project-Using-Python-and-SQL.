Create database Project;

\c project


SELECT * FROM "Orders_data";


--Select distinct City from orders table.

SELECT distinct "City" from "Orders_data";



-- Write a query to find all orders from the 'Technology' category that were shipped using 'Second Class' ship mode, ordered by order date.

select "Order Id","Order Date" from "Orders_data" where "Category"='Technology' and "Ship Mode"='Second Class' order by "Order Date";



--Write query to find average order value
select cast(avg("Quantity"*"Unit Selling Price") as decimal(10,2)) as avg from "Orders_data";



--Find th city with highest Total Quantity of products ordered.

select "City",sum("Quantity") as highest_total_quantity from "Orders_data" group by "City" order by highest_total_quantity desc limit 1;



--Use a Window function to rank orders in each region by quantity in descending order.

select "Order Id","Region","Quantity",dense_rank() over (partition by "Region" order by "Quantity" desc)as rank from "Orders_data"



--Write sql query to list all orders place in first quanter of any year (januvary to March),including total cost for thes orders.

select "Order Id",sum("Quantity"*"Unit Selling Price") as Total_cost from "Orders_data" where Extract (month from "Order Date") in (1,2,3) group by "Order Id" order by Total_cost desc;



--Find top 10 higest profit generating products.

select "Product Id",sum("Total Profit") as Total_profit from "Orders_data" group by "Product Id" order by Total_Profit desc limit 10;



--Give alternative of above using window function.

select * from (select "Product Id",sum("Total Profit") as total_profit,Row_number() over(order by sum("Total Profit") desc) as row_no from "Orders_data" group by "Product Id") where row_no<=10;


--Find to 3 higest selling products in each region.

select * from(select "Product Id","Region",sum("Quantity"*"Unit Selling Price")as sales,Row_number() over(partition by "Region" order by sum("Quantity"*"Unit Selling Price") desc) as row_no from "Orders_data" group by "Product Id","Region")where row_no<=3;



--Find month over Month Comaprison for 2022 and 2023 sales eg:jan 2022 and jan 2023.

WITH cte AS (
    SELECT 
        EXTRACT(YEAR FROM "Order Date") AS order_year,
        EXTRACT(MONTH FROM "Order Date") AS order_month,
        SUM("Quantity" * "Unit Selling Price") AS sales
    FROM 
        "Orders_data"
    GROUP BY 
        EXTRACT(YEAR FROM "Order Date"),
        EXTRACT(MONTH FROM "Order Date")
)
SELECT 
    order_month,
    ROUND(SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END)::NUMERIC, 2) AS sales_2022,
    ROUND(SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END)::NUMERIC, 2) AS sales_2023
FROM 
    cte
GROUP BY 
    order_month
ORDER BY 
    order_month;



--For each Category which month has higest sales.

SELECT * 
FROM (
    SELECT 
        "Category", 
        TO_CHAR("Order Date", 'YYYY-MM') AS order_year_month,
        SUM("Quantity" * "Unit Selling Price") AS sales,
        ROW_NUMBER() OVER (
            PARTITION BY "Category" 
            ORDER BY SUM("Quantity" * "Unit Selling Price") DESC
        ) AS rn
    FROM 
        "Orders_data"
    GROUP BY 
        "Category", TO_CHAR("Order Date", 'YYYY-MM')
) AS sub
WHERE 
    rn = 1;



--Which sub Category had higest Growth by sales in 2023 comapre to 2022.


WITH cte AS (
    SELECT 
        "Sub Category" AS sub_category, 
        EXTRACT(YEAR FROM "Order Date") AS order_year,
        SUM("Quantity" * "Unit Selling Price") AS sales
    FROM 
        "Orders_data"
    GROUP BY 
        "Sub Category", EXTRACT(YEAR FROM "Order Date")
),
cte2 AS (
    SELECT 
        sub_category,
        ROUND(SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END)::NUMERIC, 2) AS sales_2022,
        ROUND(SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END)::NUMERIC, 2) AS sales_2023
    FROM 
        cte
    GROUP BY 
        sub_category
)
SELECT 
    sub_category AS "Sub Category",
    sales_2022 AS "Sales in 2022",
    sales_2023 AS "Sales in 2023",
    (sales_2023 - sales_2022) AS "Diff in Amount"
FROM 
    cte2
ORDER BY 
    (sales_2023 - sales_2022) DESC
LIMIT 1;

