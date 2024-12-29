--This query calculates the total reavenue for each year in the dataset

SELECT
  EXTRACT(YEAR FROM `Order Date`) Year,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data sale
GROUP BY
  EXTRACT(YEAR FROM `Order Date`)


--This query uncovers the 10 customers that generated the most revenue
SELECT
  sale.`Customer ID`,
  sale.`Customer Name`,
  SUM(Sales * Quantity) AS Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
GROUP BY
  sale.`Customer ID`,
  sale.`Customer Name`
ORDER BY
  Revenue DESC,
  sale.`Customer Name`
LIMIT 10

--This query is to determine the number of one time buyers
SELECT
  COUNT(subq.`Customer ID`) AS num_one_time_buyers
FROM
  (SELECT
    sale.`Customer Name`,
    sale.`Customer ID`,
    COUNT(`Customer ID`) AS num_purchases
  FROM
    sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
  GROUP BY
    sale.`Customer Name`,
    sale.`Customer ID`
  HAVING
    num_purchases < 2
  ORDER BY
    sale.`Customer Name`
  ) AS subq


--This query is to determine the number of repeat customers
SELECT
  COUNT(subq.`Customer ID`) AS num_repeat_customers
FROM
  (SELECT
    sale.`Customer Name`,
    sale.`Customer ID`,
    COUNT(`Customer ID`) AS num_purchases
  FROM
    sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
  GROUP BY
    sale.`Customer Name`,
    sale.`Customer ID`
  HAVING
    num_purchases > 1
  ORDER BY
    sale.`Customer Name`
  ) AS subq


--This query is to compare the top 10 repeat customers by their frequency of purchace and revenue genereted
--The "frequency" CTE ranks customers by their number of purchace
--The "monetary_value" CTE ranks customers by their revenue generated
--The final join identifies overlaps to evaluate whether the most frequent buyers also generate the most revenue
WITH frequency AS (
  SELECT
    sale.`Customer Name` AS cus_name,
    sale.`Customer ID` AS cus_id,
    COUNT(`Customer ID`) AS num_purchases,
    SUM(Sales * Quantity) AS Revenue
  FROM
    sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
  GROUP BY
    sale.`Customer Name`,
    sale.`Customer ID`
  HAVING
    num_purchases > 1
  ORDER BY
    num_purchases DESC,
    Revenue DESC,
    sale.`Customer Name`
  LIMIT 10
),
monetary_value AS (
  SELECT
    sale.`Customer Name` AS cus_name,
    sale.`Customer ID` AS cus_id,
    COUNT(`Customer ID`) AS num_purchases,
    SUM(Sales * Quantity) AS Revenue
  FROM
    sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
  GROUP BY
    sale.`Customer Name`,
    sale.`Customer ID`
  HAVING
    num_purchases > 1
  ORDER BY
    Revenue DESC,
    num_purchases DESC,
    sale.`Customer Name`
  LIMIT 10
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
  sale.`Customer Name` AS cus_name,
  sale.`Customer ID` AS cus_id,
  COUNT(`Customer ID`) AS num_purchases,
  SUM(Sales * Quantity) AS Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
GROUP BY
  sale.`Customer Name`,
  sale.`Customer ID`
HAVING
  num_purchases > 1
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
SELECT
  sale.Category,
  SUM(Sales * Quantity) Revenue,
  (SUM(Sales * Quantity)/ (SELECT
                            SUM(Sales * Quantity)
                          FROM sql-portfolio-projects-2024.Superstore_sales.sales_data) * 100) Percentage_of_revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
GROUP BY
  1
ORDER BY
  2 DESC


--This query is to determine the sub-category of products that generated the most revenue
--It also shows the percentage of revenue each sub-category has on the total revenue generated
SELECT
  sale.`Sub-Category`,
  SUM(Sales * Quantity) Revenue,
  (SUM(Sales * Quantity)/ (SELECT
                            SUM(Sales * Quantity)
                          FROM sql-portfolio-projects-2024.Superstore_sales.sales_data) * 100) Percentage_of_revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
GROUP BY
  1
ORDER BY
  2 DESC


--This query is to aggregate the revenue by category, year and month
--This is to analyze the sales trends by month and year
SELECT
  sale.Category,
  EXTRACT(YEAR FROM `Order Date`) AS year,
  EXTRACT(MONTH FROM `Order Date`) AS month,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
GROUP BY
  1,2,3
ORDER BY
  2,3


--This query is to aggregate the revenue by sub-category, year and month
--This is to analyze the sales trends by month and year
SELECT
  sale.`Sub-Category`,
  EXTRACT(YEAR FROM `Order Date`) AS year,
  EXTRACT(MONTH FROM `Order Date`) AS month,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
GROUP BY
  1,2,3
ORDER BY
  2,3


--This query is to calculate the year on year growth of revenue for each category
--A self join is used to compare revenue across years of the same month
WITH aggregated_sales AS (
SELECT
  sale.Category,
  EXTRACT(YEAR FROM `Order Date`) AS year,
  EXTRACT(MONTH FROM `Order Date`) AS month,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
GROUP BY
  1,2,3
ORDER BY
  2,3
)
SELECT
  present.Category,
  present.month,
  present.year,
  present.Revenue,
  previous.year,
  previous.Revenue,
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


--This query is to calculate the year on year growth of revenue for each sub-category
--A self join is used to compare revenue across years of the same month
WITH aggregated_sales AS (
SELECT
  sale.`Sub-Category`,
  EXTRACT(YEAR FROM `Order Date`) AS year,
  EXTRACT(MONTH FROM `Order Date`) AS month,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data AS sale
GROUP BY
  1,2,3
ORDER BY
  2,3
)
SELECT
  present.`Sub-Category`,
  present.month,
  present.year,
  present.Revenue,
  previous.year,
  previous.Revenue,
  ((present.Revenue - previous.Revenue)/previous.Revenue) * 100 AS yearly_growth
FROM
  aggregated_sales AS present
LEFT JOIN
  aggregated_sales AS previous
ON
  present.`Sub-Category` = previous.`Sub-Category`
AND present.month = previous.month
AND present.year = previous.year + 1
ORDER BY
  1,2,3


--This query is to determine the revenue generated per region
SELECT
  sale.Region,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data sale
GROUP BY
  sale.Region
ORDER BY
  Revenue DESC


--This query is to determine the revenue generated per sub-category, per region
--This shows what sub-categories are most popular in each state
SELECT
  sale.Region,
  sale.`Sub-Category`,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data sale
GROUP BY
  sale.Region,
  sale.`Sub-Category`
ORDER BY
  sale.Region,
  Revenue DESC


--This query is to determine the revenue generated per sub-category, per region
--This shows what sub-categories are most popular in each state
SELECT
  sale.Region,
  sale.`Sub-Category`,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data sale
GROUP BY
  sale.Region,
  sale.`Sub-Category`
ORDER BY
  sale.Region,
  Revenue DESC


--This query is to calculate the total revenue generated each month for the year 2014
SELECT
  EXTRACT(MONTH FROM `Order Date`) AS month,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data sale
WHERE
  EXTRACT(YEAR FROM `Order Date`) = 2014
GROUP BY
  month
ORDER BY
  Revenue DESC


--This query is to calculate the total revenue generated each month for the year 2015
SELECT
  EXTRACT(MONTH FROM `Order Date`) AS month,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data sale
WHERE
  EXTRACT(YEAR FROM `Order Date`) = 2015
GROUP BY
  month
ORDER BY
  Revenue DESC


--This query is to calculate the total revenue generated each month for the year 2016
SELECT
  EXTRACT(MONTH FROM `Order Date`) AS month,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data sale
WHERE
  EXTRACT(YEAR FROM `Order Date`) = 2016
GROUP BY
  month
ORDER BY
  Revenue DESC


--This query is to calculate the total revenue generated each month for the year 2017
SELECT
  EXTRACT(MONTH FROM `Order Date`) AS month,
  SUM(Sales * Quantity) Revenue
FROM
  sql-portfolio-projects-2024.Superstore_sales.sales_data sale
WHERE
  EXTRACT(YEAR FROM `Order Date`) = 2017
GROUP BY
  month
ORDER BY
  Revenue DESC