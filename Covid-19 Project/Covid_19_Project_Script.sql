--This query is to determine the countries with the most infections
SELECT TOP 10
	covid.country,
	MAX(covid.total_cases) AS  total_infections
FROM
	Covid_19_Project.dbo.covid_data AS covid
WHERE
	covid.total_cases > 0
GROUP BY
	covid.country,
	covid.population
ORDER BY
	total_infections DESC


-- This qurey finds the contries with the highest covid cases in Africa
--It calculates their percentage of the total cases in the continent
--The cast function is used to convert the values of the percentage of infection to a float
--The cast funtion is to ensure the division is done using floating-point arithmetics
SELECT
    covid.country,
    MAX(covid.total_cases) AS total_infections,
    CAST(SUM(covid.new_cases) AS FLOAT) / CAST((SELECT SUM(new_cases) FROM Covid_19_Project.dbo.covid_data) AS FLOAT) * 100 AS infection_percent
FROM
    Covid_19_Project.dbo.covid_data AS covid
WHERE
    covid.total_cases > 0
GROUP BY
    covid.country
ORDER BY
    total_infections DESC;



--This qurey finds the contries with the highest covid cases in Africa
--It calculates their percentage of the total cases in the continent as well as the their pecentage of the total population
--The cast function is used to convert the values of the percentage of infection to a float
--The cast funtion is to ensure the division is done using floating-point arithmetics
SELECT
    covid.country,
    MAX(covid.total_cases) AS total_infections,
    CAST(SUM(covid.new_cases) AS FLOAT) / CAST((SELECT SUM(new_cases) FROM Covid_19_Project.dbo.covid_data) AS FLOAT) * 100 AS infection_percent,
	CAST(MAX(covid.population) AS FLOAT) / CAST((SELECT SUM(max_pop)	FROM	(
											SELECT MAX(population) AS max_pop	FROM	Covid_19_Project.dbo.covid_data		GROUP BY	country
												) AS sub_query) AS FLOAT) * 100 AS population_percentage
FROM
    Covid_19_Project.dbo.covid_data AS covid
WHERE
    covid.total_cases > 0
GROUP BY
    covid.country
ORDER BY
    total_infections DESC;





--This query is to determine the countries with the highest infection rates
SELECT TOP 10
	covid.country,
	CAST(MAX(covid.total_cases) AS FLOAT) / CAST(covid.population AS FLOAT) infection_rate
FROM
	Covid_19_Project.dbo.covid_data AS covid
WHERE
	covid.total_cases > 0
GROUP BY
	covid.country,
	covid.population
ORDER BY
	infection_rate DESC



--This query is to see total infections allong with the infection rates suffered by each country
SELECT
	covid.country,
	MAX(covid.total_cases) AS  total_infections,
	CAST(MAX(covid.total_cases) AS FLOAT) / CAST(covid.population AS FLOAT) infection_rate
FROM
	Covid_19_Project.dbo.covid_data AS covid
WHERE
	covid.total_cases > 0
GROUP BY
	covid.country,
	covid.population
ORDER BY
	total_infections DESC


--This query is to determine the countries with the highest death count
--The query was filtered to retrieve data from only countries with at least one confirmed case
SELECT TOP 10
	covid.country,
	MAX(covid.total_deaths) AS  total_deaths
FROM
	Covid_19_Project.dbo.covid_data AS covid
WHERE
	covid.total_cases > 0
GROUP BY
	covid.country
ORDER BY
	total_deaths DESC


--This query is to retrieves the average gdp per capital of each country, along with their infection rate
--The query was filtered to retrieve data from only countries with at least one confirmed case
--The purpose of the query is to uncover the relationship, if any, between gdp per capital and infection rates
SELECT
	covid.country,
	AVG(covid.gdp_per_capital) average_gdp_per_capital,
	CAST(MAX(covid.total_cases) AS FLOAT) / CAST(covid.population AS FLOAT) infection_rate
FROM
	Covid_19_Project.dbo.covid_data AS covid
WHERE
	covid.total_cases > 0
GROUP BY
	covid.country,
	covid.population
ORDER BY
	covid.country


--This query is to retrieves the average gdp per capital of each country, along with their death rate
--The query was filtered to retrieve data from only countries with at least one confirmed case
--The purpose of the query is to uncover the relationship, if any, between gdp per capital and death rates
SELECT
	covid.country,
	AVG(covid.gdp_per_capital) average_gdp_per_capital,
	CAST(MAX(covid.total_deaths) AS FLOAT) / CAST(MAX(covid.total_cases) AS FLOAT) death_rate
FROM
	Covid_19_Project.dbo.covid_data AS covid
WHERE
	covid.total_cases > 0
GROUP BY
	covid.country
ORDER BY
	covid.country


--This query is to uncover the countries that carried out the most tests
SELECT TOP 10
	covid.country,
	MAX(covid.total_tests) total_test
FROM
	Covid_19_Project.dbo.covid_data AS covid
GROUP BY
	covid.country
ORDER BY
	total_test DESC


--This query is to uncover the countries that carried out the most tests as well as their percetage of the total test
--The cast function is used to convert the values of the percentage of infection to a float
--The cast funtion is to ensure the division is done using floating-point arithmetics
SELECT
	covid.country,
	MAX(covid.total_tests) total_test,
	CAST(MAX(covid.total_tests) AS FLOAT) / CAST((SELECT	SUM(max_test)	FROM (
											SELECT	MAX(total_tests) AS max_test	FROM	Covid_19_Project.dbo.covid_data		GROUP BY country
											) AS subq) AS FLOAT) * 100 AS test_percentage
FROM
	Covid_19_Project.dbo.covid_data AS covid
GROUP BY
	covid.country
ORDER BY
	total_test DESC


--This query retrieves the test rates in each country, along side the infection rates
--This is to uncover any relationship between test rates and infection rates
SELECT
	covid.country,
	CAST(MAX(covid.total_tests) AS FLOAT) / CAST(covid.population AS FLOAT) test_rate,
	CAST(MAX(covid.total_cases) AS FLOAT) / CAST(covid.population AS FLOAT) infection_rate
FROM
	Covid_19_Project.dbo.covid_data AS covid
GROUP BY
	covid.country,
	covid.population
ORDER BY
	test_rate DESC


--This query is to retrieve monthly cases and deaths by country over time
--The month and year were extracted from the date field
SELECT
	covid.country,
	YEAR(date_) AS year,
	MONTH(date_) AS month,
	SUM(covid.new_cases) AS monthly_cases,
	SUM(covid.new_deaths) AS monthly_deaths
FROM
	Covid_19_Project.dbo.covid_data AS covid
GROUP BY
	covid.country,
	YEAR(date_),
	MONTH(date_)
ORDER BY
	YEAR(date_),
	MONTH(date_)