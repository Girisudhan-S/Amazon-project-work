-- Amazon Business Problems 1


-- 1. Find out the top 5 customers who made the highest profits.


SELECT *from ORDERS
select * from customers

	

SELECT
o.customer_id,
ROUND( SUM(o.SALE) )AS TOTAL_SALE,
ROUND(SUM(CASE WHEN R.order_id IS NOT NULL THEN O.sale ELSE 0 END) )	AS total_return_sale,
ROUND( SUM(o.SALE) )-ROUND(SUM(CASE WHEN R.order_id IS NOT NULL THEN O.sale ELSE 0 END) ) AS net_sale_revenue,
RANK () OVER(ORDER BY ROUND( SUM(o.SALE))- ROUND(SUM(CASE WHEN R.order_id IS NOT NULL THEN O.sale ELSE 0 END) ) DESC )AS RANK
FROM ORDERS AS O
left JOIN RETURNS AS R
ON o.order_id = r.order_id	
GROUP BY 1
ORDER BY 5 
LIMIT 5
	

	
-- 2. Find out the average quantity ordered per category.

SELECT *from ORDERS

SELECT
	COUNT (CASE WHEN category IS NULL THEN 1 ELSE NULL END) AS NULL_COUNT
FROM  ORDERS	
	

SELECT
	category,
	AVG (quantity) AS average_quantity
FROM orders
WHERE category IS NOT NULL
GROUP BY 1


-- 3. Identify the top 5 products that have generated the highest revenue.
SELECT * FROM PRODUCTS
SELECT * FROM ORDERS
SELECT*FROM RETURNS

SELECT
P.product_id,
p.product_name,
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_sale_revenue,
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_return_revenue,
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) -
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END))AS NET_REVENUE
FROM ORDERS AS o
LEFT JOIN returns as r
ON o.order_id = r.order_id
JOIN products AS P
ON p.product_id = o.product_id
GROUP BY 1,2
ORDER BY 5 DESC
LIMIT 5

 -- 4. Determine the top 5 products whose revenue has decreased compared to the previous year.


	-- extract month
	-- Sum of sale
	-- group by by month
	-- where extract year=2024
	
SELECT * FROM orders

SELECT
	ROUND(SUM(sale) ::"numeric",2) AS total_revenue,
	EXTRACT (MONTH FROM order_date) AS month
fROM orders
WHERE EXTRACT (YEAR FROM order_date)=2024-2
GROUP BY 2
ORDER BY 1 DESC	

	
	-- THE DATA FOR 2024 IS ONLY AVILABLE FOR JAN AND FEB
	
		-- So we are comparing the year 2023 and 2022
		-- Calculate the net_revenue (TOTAL SALE REVENUE-TOTAL RETURN REVENUE) for each product for the 2023 and 2022
		-- Find the difference in revenue between years.
		-- Order the products based on the decrease in revenue. 
		-- list top 5 products.

WITH current_year_net_revenue AS (
SELECT
P.product_id,
p.product_name,
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_sale_revenue,
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_return_revenue,
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) -
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END))AS current_year_net_revenue
FROM ORDERS AS o
LEFT JOIN returns as r
ON o.order_id = r.order_id
JOIN products AS P
ON p.product_id = o.product_id
WHERE EXTRACT (YEAR FROM o.order_date) = 2023
GROUP BY 1,2
ORDER BY 5 DESC),

previous_year_net_revenue AS (

SELECT
P.product_id,
p.product_name,
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_sale_revenue,
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_return_revenue,
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) -
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END))AS previous_year_net_revenue
FROM ORDERS AS o
LEFT JOIN returns as r
ON o.order_id = r.order_id
JOIN products AS P
ON p.product_id = o.product_id
WHERE EXTRACT (YEAR FROM o.ORDER_DATE) = 2023-1 
GROUP BY 1,2
ORDER BY 5 DESC),

revenue_decreased_compared AS(
SELECT 
	cy.product_id,
	cy.product_name,
	cy.current_year_net_revenue,
	py.previous_year_net_revenue,
	cy.current_year_net_revenue- py.previous_year_net_revenue AS revenue_decreased 
FROM current_year_net_revenue AS cy
JOIN previous_year_net_revenue as py
ON cy.product_id =py.product_id	
)

SELECT 
	product_id,
	product_name,
	current_year_net_revenue,
	previous_year_net_revenue,
    revenue_decreased,
    CASE WHEN previous_year_net_revenue = 0 THEN NULL
		ELSE  ROUND((revenue_decreased::numeric / previous_year_net_revenue::numeric)*100 , 2)
		END AS percentage_reduction  
FROM revenue_decreased_compared
WHERE revenue_decreased < 0
ORDER BY 5 
LIMIT 5


		


-- 5. Identify the highest profitable sub-category.
	
-- select the required colums
-- join the tables accordling
-- Calculate the net_revenue for each sub category using proper Group by
-- Order the net_revenue 
-- limit 1


SELECT *FROM orders
SELECT *FROM products
	
SELECT
P.product_id,
o.sub_category,	
p.product_name,
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_sale_revenue,
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_return_revenue,
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) -
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END))AS net_revenue
FROM ORDERS AS o
LEFT JOIN returns as r
ON o.order_id = r.order_id
JOIN products AS P
ON p.product_id = o.product_id
GROUP BY 1,2,3
ORDER BY 6 DESC
LIMIT 1

-- 6. Find out the states with the highest total orders.

SELECT*FROM orders	

SELECT
	state,
	count(order_id) AS total_orders
FROM orders
WHERE state IS NOT NULL	
GROUP BY 1 	
ORDER BY 2 DESC

-- 7. Determine the month with the highest number of orders.
SELECT*FROM orders	
	
SELECT
	EXTRACT (YEAR FROM order_date) AS year,
	EXTRACT (MONTH FROM order_date) AS month,
	count(order_id) AS total_orders
FROM orders
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1

-- 8. Calculate the profit margin percentage for each sale (Profit divided by Sales).
SELECT*FROM orders	

WITH PROFIT AS(	SELECT
	o.order_id,
	o.customer_id,
	o.sale,
	(p.cogs* o.quantity) as total_cogs,  
	o.sale-( p.cogs* o.quantity) as profit
(((o.sale-( p.cogs* o.quantity))/o.sale)*100) AS profit_percentage 
	FROM orders AS o
JOIN products AS P
ON p.product_id = o.product_id	)
	
SELECT
	PR.order_id,
	PR.customer_id,
	PR.sale,
	PR.total_cogs,
	ROUND( PR.profit)  AS PROFIT,
    ROUND(((PR.profit/PR.sale)* 100) :: "numeric",2) AS profit_percentage 
	FROM PROFIT AS PR

-- 9. Calculate the percentage contribution of each sub-category. 
	
WITH contribution  AS (
SELECT
o.product_id,	
o.sub_category,	
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_sale_revenue,
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_return_revenue,
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) -
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END))AS net_revenue
FROM orders AS o	
LEFT JOIN returns as r
ON o.order_id = r.order_id
WHERE o.category IS NOT NULL	
GROUP BY 1,2
ORDER BY 5	)

SELECT
	ct.product_id,	
	ct.sub_category,
	ct.total_sale_revenue,
	ct.total_return_revenue,
	ct.net_revenue,
   ROUND ((ct.net_revenue::"numeric"/total_net_revenue::"numeric")*100,2) AS percentage_contribution
FROM 	contribution AS ct,
	 (SELECT SUM(net_revenue) AS total_net_revenue FROM contribution) AS total
ORDER BY 6 DESC



	
-- 10. Identify the top 2 categories that have received maximum returns and their return percentage.

-- select the required colums
-- join the tables accordling
-- Calculate the net_revenue for each category using  Group by
-- calculate the return %
-- limit 2


SELECT *FROM sellers
SELECT *FROM products
	
SELECT
o.category,	
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_sale_revenue,
ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END)) AS total_return_revenue,
(ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sale ELSE 0 END))/
ROUND(SUM(CASE WHEN o.order_id IS NOT NULL THEN o.sale ELSE 0 END)) *100)AS return_percentage
FROM ORDERS AS o
LEFT JOIN returns as r
ON o.order_id = r.order_id
WHERE category IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC
LIMIT 2	
