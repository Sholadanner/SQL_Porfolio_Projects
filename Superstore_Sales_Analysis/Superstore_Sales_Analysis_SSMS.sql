--This query calculates the total reavenue for each year in the dataset

SELECT
	YEAR(Order_Date) Year,
	SUM(Sales * Quantity) Revenue
FROM
	Superstore_Sales_Project.dbo.sales sales
GROUP BY
	YEAR(Order_Date)
ORDER BY
	Year


--This query uncovers the 10 customers that generated the most revenue
SELECT TOP 10
	sales.Customer_ID,
	sales.Customer_Name,
	SUM(Sales * Quantity) AS Revenue
FROM
	Superstore_Sales_Project.dbo.sales AS sales
GROUP BY
	sales.Customer_ID,
	sales.Customer_Name
ORDER BY
	Revenue DESC,
	sales.Customer_Name


--This query is to determine the number of one time buyers
SELECT
	COUNT(subq.Customer_ID) AS num_one_time_buyers
FROM
	(SELECT
		sales.Customer_Name,
		sales.Customer_ID,
		COUNT(Customer_ID) AS num_purchases
	 FROM
		Superstore_Sales_Project.dbo.sales AS sales
	 GROUP BY
		sales.Customer_Name,
		sales.Customer_ID
	 HAVING
		COUNT(Customer_ID) < 2
	) AS subq


--This query is to determine the number of repeat customers
SELECT
  COUNT(subq.Customer_ID) AS num_repeat_customers
FROM
  (
	SELECT
		sales.Customer_Name,
		sale.Customer_ID,
		COUNT(Customer_ID) AS num_purchases
	FROM
		Superstore_Sales_Project.dbo.sales AS sales
	GROUP BY
		sales.Customer_Name,
		sales.Customer_ID
	HAVING
		COUNT(Customer_ID) > 1
  ) AS subq


--This query is to compare the top 10 repeat customers by their frequency of purchace and revenue genereted
--The "frequency" CTE ranks customers by their number of purchace
--The "monetary_value" CTE ranks customers by their revenue generated
--The final join identifies overlaps to evaluate whether the most frequent buyers also generate the most revenue
WITH frequency AS (
	SELECT TOP 10
		sales.Customer_Name AS cus_name,
		sales.Customer_ID AS cus_id,
		COUNT(Customer_ID) AS num_purchases,
		SUM(Sales * Quantity) AS Revenue
	FROM
		Superstore_Sales_Project.dbo.sales AS sales
	GROUP BY
		sales.Customer_Name,
		sales.Customer_ID
	HAVING
		COUNT(Customer_ID) > 1
	ORDER BY
		num_purchases DESC,
		Revenue DESC,
		sales.Customer_Name
),
monetary_value AS (
	SELECT TOP 10
		sales.Customer_Name AS cus_name,
		sales.Customer_ID AS cus_id,
		COUNT(Customer_ID) AS num_purchases,
		SUM(Sales * Quantity) AS Revenue
	FROM
		Superstore_Sales_Project.dbo.sales AS sales
	GROUP BY
		sales.Customer_Name,
		sales.Customer_ID
	HAVING
		COUNT(Customer_ID) > 1
	ORDER BY
		Revenue DESC,
		num_purchases DESC,
		sales.Customer_Name
)
SELECT
	*
FROM
	monetary_value AS mv
JOIN
	frequency AS fr
ON
	mv.cus_id = fr.cus_id


--This query is to further analyze any correlation between frequency of purchace and revenue generated
--Ranks are assigned to customers based on frequency and revenue
WITH customer_data AS (
	SELECT
		sales.Customer_Name AS cus_name,
		sales.Customer_ID AS cus_id,
		COUNT(Customer_ID) AS num_purchases,
		SUM(Sales * Quantity) AS Revenue
	FROM
		Superstore_Sales_Project.dbo.sales AS sales
	GROUP BY
		sales.Customer_Name,
		sales.Customer_ID
	HAVING
		COUNT(Customer_ID) > 1
	)
SELECT
	cus_name,
	cus_id,
	num_purchases,
	Revenue,
	RANK() OVER(ORDER BY num_purchases DESC) AS frequency_rank,
	RANK() OVER(ORDER BY Revenue DESC) AS revenue_rank
FROM
	customer_data
ORDER BY
	frequency_rank,
	revenue_rank


--This query is to determine the category of products that generated the most revenue
--It also shows the percentage of revenue each category has on the total revenue generated
WITH total_revenue AS (
	SELECT
		SUM(Sales * Quantity) AS Revenue
	FROM
		Superstore_Sales_Project.dbo.sales
		)
SELECT
	sales.Category,
	SUM((sales.Sales * sales.Quantity) / tot_rev.Revenue * 100) AS Percentage_of_Revenue
FROM
	Superstore_Sales_Project.dbo.sales AS sales
CROSS JOIN
	total_revenue AS tot_rev
GROUP BY
	sales.Category
ORDER BY
	Percentage_of_Revenue


--This query is to determine the sub-category of products that generated the most revenue
--It also shows the percentage of revenue each sub-category has on the total revenue generated
WITH total_revenue AS (
	SELECT
		SUM(Sales * Quantity) AS Revenue
	FROM
		Superstore_Sales_Project.dbo.sales
	)
SELECT
	sales.Sub_Category,
	SUM((sales.Sales * sales.Quantity) / tot_rev.Revenue * 100) Percentage_of_Revenue
FROM
	Superstore_Sales_Project.dbo.sales sales
CROSS JOIN
	total_revenue AS tot_rev
GROUP BY
	sales.Sub_Category
ORDER BY
	Percentage_of_Revenue DESC



--This query is to calculate the year on year growth of revenue for each category
--A self join is used to compare revenue across years of the same month
WITH aggregated_sales AS (
SELECT
	sales.Category,
	YEAR(Order_Date) AS year,
	MONTH(Order_Date) AS month,
	SUM(Sales * Quantity) Revenue
FROM
	Superstore_Sales_Project.dbo.sales AS sales
GROUP BY
	sales.Category,
	YEAR(Order_Date),
	MONTH(Order_Date)
)
SELECT
	present.Category,
	present.month,
	present.year AS Present_year,
	present.Revenue AS Current_Revenue,
	previous.year AS Previous_year,
	previous.Revenue AS Previous_Revenue,
	((present.Revenue - previous.Revenue)/previous.Revenue) * 100 AS yearly_growth
FROM
	aggregated_sales AS present
LEFT JOIN
	aggregated_sales AS previous
ON
	present.Category = previous.Category
AND present.month = previous.month
AND present.year = previous.year + 1
ORDER BY
  1,2,3


--This query is to calculate the year on year growth of revenue for each category
--A self join is used to compare revenue across years of the same month
WITH aggregated_sales AS (
SELECT
	sales.Sub_Category,
	YEAR(Order_Date) AS year,
	MONTH(Order_Date) AS month,
	SUM(Sales * Quantity) Revenue
FROM
	Superstore_Sales_Project.dbo.sales AS sales
GROUP BY
	sales.Sub_Category,
	YEAR(Order_Date),
	MONTH(Order_Date)
)
SELECT
	present.Sub_Category,
	present.month,
	present.year AS Present_year,
	present.Revenue AS Current_Revenue,
	previous.year AS Previous_year,
	previous.Revenue AS Previous_Revenue,
	((present.Revenue - previous.Revenue)/previous.Revenue) * 100 AS yearly_growth
FROM
	aggregated_sales AS present
LEFT JOIN
	aggregated_sales AS previous
ON
	present.Sub_Category = previous.Sub_Category
AND present.month = previous.month
AND present.year = previous.year + 1
ORDER BY
	1,2,3


--This query is to determine the revenue generated per region
SELECT
	sales.Region,
	SUM(Sales * Quantity) Revenue
FROM
	Superstore_Sales_Project.dbo.sales sales
GROUP BY
	sales.Region
ORDER BY
	Revenue DESC


--This query is to calculate the total revenue generated each month for the year 2014
SELECT
	DATENAME(MONTH, Order_Date) AS month,
	SUM(Sales * Quantity) Revenue
FROM
	Superstore_Sales_Project.dbo.sales sales
WHERE
	YEAR(Order_Date) = 2014
GROUP BY
	DATENAME(MONTH, Order_Date)
ORDER BY
	Revenue DESC


--This query is to calculate the total revenue generated each month for the year 2015
SELECT
	DATENAME(MONTH, Order_Date) AS month,
	SUM(Sales * Quantity) Revenue
FROM
	Superstore_Sales_Project.dbo.sales sales
WHERE
	YEAR(Order_Date) = 2015
GROUP BY
	DATENAME(MONTH, Order_Date)
ORDER BY
  Revenue DESC


--This query is to calculate the total revenue generated each month for the year 2016
SELECT
	DATENAME(MONTH, Order_Date) AS month,
	SUM(Sales * Quantity) Revenue
FROM
	Superstore_Sales_Project.dbo.sales sales
WHERE
	YEAR(Order_Date) = 2016
GROUP BY
	DATENAME(MONTH, Order_Date)
ORDER BY
	Revenue DESC


--This query is to calculate the total revenue generated each month for the year 2017
SELECT
	DATENAME(MONTH, Order_Date) AS month,
	SUM(Sales * Quantity) Revenue
FROM
	Superstore_Sales_Project.dbo.sales sales
WHERE
	YEAR(Order_Date) = 2017
GROUP BY
	DATENAME(MONTH, Order_Date)
ORDER BY
	Revenue DESC


--This query aims to determine the total revenue generated in each month across all years in the dataset
SELECT
	DATENAME(MONTH, Order_Date) AS Month,
	SUM(Sales * Quantity) Revenue
FROM
	Superstore_Sales_Project.dbo.sales sales
GROUP BY
	DATENAME(MONTH, Order_Date)
ORDER BY
	Revenue DESC