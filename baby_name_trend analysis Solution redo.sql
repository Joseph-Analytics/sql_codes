USE baby_names_db;

-- Objective 1
-- Track changes in name popularity
/* Your first objective is to see how the most popular names have changed over time, 
and also to identify the names that have jumped the most in terms of popularity. */

/* Find the overall most popular girl and boy names 
and show how they have changed in popularity rankings over the years */
-- Solution steps
-- Explore table
SELECT * FROM names;

SELECT COUNT(*) AS count_of_names	-- Insight: approx 2.3million names
FROM names;

SELECT 	MIN(year) AS min_yr, 		-- Insight: from 1980 - 2009, 30 yrs data
		MAX(year) AS max_yr,
		MAX(year) - MIN(year) AS total_yrs
FROM names;

SELECT * FROM regions;

SELECT COUNT(*) 		-- Insight: 50 states
FROM regions;

-- Now, we find the overall most popular names (boy and girl)
SELECT 	name, 
		SUM(births) AS name_count
FROM names
WHERE year BETWEEN 1980 AND 1989 AND gender LIKE "%M%"
GROUP BY name
ORDER BY name_count DESC
LIMIT 5;		-- Michael, Christopher, Matthew

SELECT 	name, 
		SUM(births) AS name_count
FROM names
WHERE year BETWEEN 1990 AND 1999 AND gender LIKE "%M%"
GROUP BY name
ORDER BY name_count DESC
LIMIT 5;		-- Michael, Chirstopher, Matthew

SELECT 	name,
		SUM(births) AS name_count
FROM names
WHERE year BETWEEN 2000 AND 2009 AND gender LIKE "%M%"
GROUP BY name
ORDER BY name_count DESC
LIMIT 5;		-- Jacob, Michael, Joshua
-- Insight: due to the volume of data, it's impossible to run the query at once
-- the data then divided between gender(M and F) and Years (in decades).
-- Most popular Male name since the last 3 dacades is Michael
-- In terms of change in popularity ranking, in the last decade, the name Jacob overtook Michael,
-- with Michael in the second place

-- let us see how the name "Michael" has changed over the years in terms of popularity
SELECT year, SUM(births) AS popularity,
DENSE_RANK() OVER(ORDER BY SUM(births) DESC) AS pop_rank
FROM names
WHERE name LIKE "Michael"
GROUP BY year
ORDER BY year;
-- Insight: In overall, the name "Michael" has seen decline in popularity over the decades
-- with the least popularity in 2009

-- Popularity among the female names
SELECT 	name,
		SUM(births) AS name_count
FROM names
WHERE year BETWEEN 1980 AND 1989 AND gender LIKE "%F%"
GROUP BY name
ORDER BY name_count DESC
LIMIT 5;		-- Jessica, Jennifer, Amanda

SELECT 	name, 
		SUM(births) AS name_count
FROM names
WHERE year BETWEEN 1990 AND 1999 AND gender LIKE "%F%"
GROUP BY name
ORDER BY name_count DESC
LIMIT 5;		-- Jessica, Ashley, Emily

SELECT 	name, 
		SUM(births) AS name_count
FROM names
WHERE year BETWEEN 2000 AND 2009 AND gender LIKE "%F%"
GROUP BY name
ORDER BY name_count DESC
LIMIT 5;		-- Emily, Madison, Emma
-- Insight: Most popular female name is Jessica
-- In terms of change/jump in popularity ranking, the names: Emily, Madison, Emma, overtook Jessica.

-- let us see how the name "Jessica" has changed over the years in terms of popularity
SELECT year, SUM(births) AS popularity,
DENSE_RANK() OVER(ORDER BY SUM(births) DESC) AS pop_rank
FROM names
WHERE name LIKE "Jessica"
GROUP BY year
ORDER BY year;
-- Insight: similarly, the name "Jessica" has seen a downward spiral in popularity over the decades
-- with the most popularity seen in 1987 and least in 2009

-- Objective 2
-- Compare popularity across decades
-- Your second objective is to find the top 3 girl names and top 3 boy names for each year, 
-- and also for each decade.
-- For each year, return the 3 most popular girl names and 3 most popular boy names

-- solution steps
SELECT 	year, name, 
		SUM(births) AS popularity
FROM names
WHERE gender LIKE "%M%"
GROUP BY year, name
HAVING year BETWEEN 1980 AND 1985
ORDER BY year, popularity DESC;

SELECT year, name, SUM(births) AS popularity,
DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(births) DESC) AS pop_rank
FROM names
WHERE gender LIKE "%M%"
GROUP BY year, name
HAVING year BETWEEN 1980 AND 1989;

WITH pr AS (
			SELECT 	year, name, 
					SUM(births) AS popularity,
					DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(births) DESC) AS pop_rank
			FROM names
			WHERE gender LIKE "%M%"
			GROUP BY year, name
			HAVING year BETWEEN 1980 AND 1989
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: in each year, across the first decade, the popularity rank revolved mostly around
-- Michael, Christopher, and Matthew, in that order


WITH pr AS (
		SELECT 	year, name, 
				SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(births) DESC) AS pop_rank
		FROM names
		WHERE gender LIKE "%M%"
		GROUP BY year, name
		HAVING year BETWEEN 1990 AND 1999
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: in the second decade, on a yearly basis, the popularity revolved around
-- Michael, Christopher, Matthew, however, Jacob overtook all by 1999

WITH pr AS (
		SELECT 	year, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(births) DESC) AS pop_rank
		FROM names
		WHERE gender LIKE "%M%"
		GROUP BY year, name
		HAVING year BETWEEN 2000 AND 2009
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: the query for last decade keeps losing connection due to the size of the data
-- however, same logic applies

-- To find the 3 most popular names by decade
-- first, we define the decade
SELECT 	FLOOR(year/10)*10 AS decade,
		name, SUM(births) AS popularity,
		DENSE_RANK() OVER(PARTITION BY FLOOR(year/10)*10 ORDER BY SUM(births) DESC) AS pop_rank
FROM names
WHERE gender LIKE "%M%"
GROUP BY decade, name
ORDER BY decade, popularity DESC;

-- then, using CTE, we define the pop_rank to <4
WITH pr AS(
		SELECT 	FLOOR(year/10)*10 AS decade,
				name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY FLOOR(year/10)*10 ORDER BY SUM(births) DESC) AS pop_rank
		FROM names
		WHERE gender LIKE "%M%"
		GROUP BY decade, name
		ORDER BY decade, popularity DESC
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: As previously mentioned in obj_1, the popularity ranks among
-- Michael, Christopher, Matthew, with Jacob overtaking the trio in the 3rd decade

-- finding top 3 girl-child most popular names
WITH pr AS (
		SELECT 	year, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(births) DESC) AS pop_rank
		FROM names
		WHERE gender LIKE "%F%"
		GROUP BY year, name
		HAVING year BETWEEN 1980 AND 1989
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: in this first decade, popularity falls btw Jennifer and Jessica,
-- overall, Jennifer tops the popularity

WITH pr AS (
		SELECT 	year, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(births) DESC) AS pop_rank
		FROM names
		WHERE gender LIKE "%F%"
		GROUP BY year, name
		HAVING year BETWEEN 1990 AND 1999
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: connection timeout, but this should work if split into managable shunks

USE baby_names_db;

WITH pr AS (
		SELECT 	year, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(births) DESC) AS pop_rank
		FROM names
		WHERE gender LIKE "%F%"
		GROUP BY year, name
		HAVING year BETWEEN 2000 AND 2009
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: cconnection lost. But query can be broken into manageble chunks

-- most popular female names by the decade
SELECT 	FLOOR(year/10)*10 AS decade,
		name, SUM(births) AS popularity,
		DENSE_RANK() OVER(PARTITION BY FLOOR(year/10)*10 ORDER BY SUM(births) DESC) AS pop_rank
FROM names
WHERE year BETWEEN 1980 AND 1989 AND gender LIKE "%F%"
GROUP BY FLOOR(year/10)*10, name
ORDER BY decade, popularity DESC;

WITH pr AS(
SELECT 	FLOOR(year/10)*10 AS decade,
		name, SUM(births) AS popularity,
		DENSE_RANK() OVER(PARTITION BY FLOOR(year/10)*10 ORDER BY SUM(births) DESC) AS pop_rank
FROM names
WHERE gender LIKE "%F%"
GROUP BY FLOOR(year/10)*10, name
ORDER BY decade, popularity DESC
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: the name Jessica dominated the 90s, but overtaken Emily, Madison, Emma, the following decade

/*
Objective 3
Compare popularity across regions
Your third objective is to find the number of babies born in each region, 
and also return the top 3 girl names and top 3 boy names within each region.
*/

-- Return the number of babies born in each of the six regions
-- (NOTE: The state of MI should be in the Midwest region)

-- Solution steps
-- sneak peek relevant table
SELECT * FROM regions; 

SELECT 	COUNT(state) AS state_count,
		COUNT(DISTINCT region) AS region_count
FROM regions;		
-- Insight: 50 states, 7 regions

SELECT DISTINCT region
FROM regions;
-- Insight: there is meant to be 6 regions, New England is same as New_England
-- We need to UPDATE the region field

UPDATE regions
SET region = "New_England"
WHERE region = "New England";

SET SQL_SAFE_UPDATES = 0; -- Remove update restriction: Data Security Language
SET SQL_SAFE_UPDATES = 1; -- restore update security to prevent data loss

SELECT DISTINCT region
FROM regions;  -- region is up-to-date: now 6 regions

-- join tables
SELECT *
FROM regions r
LEFT JOIN names n
ON r.state = n.state;

SELECT * FROM regions
WHERE state LIKE "%M%"; 
-- Insight: we see that the state of Michigan(MI) in Midwest region is mis-spelt for MO
-- We need to UPDATE our State.

UPDATE regions
SET state = "MI"
WHERE state LIKE "%MO%"; 
-- State updated


-- Births by region
SELECT 	region, SUM(births) AS num_of_birth,
		DENSE_RANK() OVER(ORDER BY SUM(births) DESC) AS region_rank
FROM regions r
LEFT JOIN names n
ON r.state = n.state
WHERE year BETWEEN 1980 AND 1989
GROUP BY region
ORDER BY num_of_birth DESC;
-- due to the volume of data, the query is split into decades
-- Insight: In the 80s, South region has the highest birth population

SELECT 	region, SUM(births) AS num_of_birth,
		DENSE_RANK() OVER(ORDER BY SUM(births) DESC) AS region_rank
FROM regions r
LEFT JOIN names n
ON r.state = n.state
WHERE year BETWEEN 1990 AND 1999
GROUP BY region
ORDER BY num_of_birth DESC;
-- Insight: In the 90s, south region remains top on the birth pop_rank

SELECT 	region, SUM(births) AS num_of_birth,
		DENSE_RANK() OVER(ORDER BY SUM(births) DESC) AS region_rank
FROM regions r
LEFT JOIN names n
ON r.state = n.state
WHERE year BETWEEN 2000 AND 2009
GROUP BY region
ORDER BY num_of_birth DESC;
-- Insight: South region remains on the top list in the 3rd decade
-- Overall, South region has the highest birth population

-- top 3 boy names by region
SELECT 	region, name, SUM(births) AS popularity,
		DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(births) DESC) AS pop_rank
FROM regions r
LEFT JOIN names n
ON r.state = n.state
WHERE year BETWEEN 1980 AND 1989 AND gender LIKE "%M%"
GROUP BY region, name
ORDER BY region, popularity DESC;

-- limiting to top 3 names using CTEs
WITH pr AS (
		SELECT 	region, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(births) DESC) AS pop_rank
		FROM regions r
		LEFT JOIN names n
		ON r.state = n.state
		WHERE year BETWEEN 1980 AND 1989 AND gender LIKE "%M%"
		GROUP BY region, name
		ORDER BY region, popularity DESC
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Inisght: the dominating name across regions in the 80s are as below;
-- Michael, Christopher, Matthew, David, Joshua

WITH pr AS (
		SELECT 	region, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(births) DESC) AS pop_rank
		FROM regions r
		LEFT JOIN names n
		ON r.state = n.state
		WHERE year BETWEEN 1990 AND 1999 AND gender LIKE "%M%"
		GROUP BY region, name
		ORDER BY region, popularity DESC
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: the most popular names across regions in the 90s are:
-- Michael, Matthew, Christopher, Jacob, Nicholas, Daniel, Joshua

WITH pr AS (
		SELECT 	region, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(births) DESC) AS pop_rank
		FROM regions r
		LEFT JOIN names n
		ON r.state = n.state
		WHERE year BETWEEN 2000 AND 2009 AND gender LIKE "%M%"
		GROUP BY region, name
		ORDER BY region, popularity DESC
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Inisght: Jacob, Ethan, Michael, Matthew, Ryan, Daniel, Anthony, Joshua, William
-- these are the most popular names across the region

-- Popularity by region(Girl-name)
WITH pr AS (
		SELECT 	region, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(births) DESC) AS pop_rank
		FROM regions r
		LEFT JOIN names n
		ON r.state = n.state
		WHERE year BETWEEN 1980 AND 1989 AND gender LIKE "%F%"
		GROUP BY region, name
		ORDER BY region, popularity DESC
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: Top names across region in the 80s: Jennifer, Jessica, Amanda, Ashley

WITH pr AS (
		SELECT 	region, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(births) DESC) AS pop_rank
		FROM regions r
		LEFT JOIN names n
		ON r.state = n.state
		WHERE year BETWEEN 1989 AND 1999 AND gender LIKE "%F%"
		GROUP BY region, name
		ORDER BY region, popularity DESC
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: In the 90s: Ashley, Jessica, Samantha, Emily,Sarah, Brittany

WITH pr AS (
		SELECT 	region, name, SUM(births) AS popularity,
				DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(births) DESC) AS pop_rank
		FROM regions r
		LEFT JOIN names n
		ON r.state = n.state
		WHERE year BETWEEN 2000 AND 2009 AND gender LIKE "%F%"
		GROUP BY region, name
		ORDER BY region, popularity DESC
)
SELECT *
FROM pr
WHERE pop_rank < 4;
-- Insight: Emily, Olivia, Madison, Emma, Ashley, Isabella, Hannah

/*
Objective 4
Explore unique names in the dataset
Your final objective is to find the most popular androgynous names, 
the shortest and longest names, 
and the state with the highest percent of babies named "Chris".
*/
-- Find the 10 most popular androgynous names (names given to both females and males)

-- solution steps
-- what state has the highest percent of babies named "Chris"
SELECT 	r.state, SUM(births) AS popularity,
		DENSE_RANK() OVER(ORDER BY SUM(births) DESC) AS pop_rank
FROM regions r 
LEFT JOIN names n
ON r.state = n.state
WHERE Name LIKE "Chris"
GROUP BY state
ORDER BY popularity DESC;
-- Insight: CA(California)

-- 10 most popular androgenous name
SELECT 	name, SUM(births) AS total_birth,
		DENSE_RANK() OVER(ORDER BY SUM(births) DESC) AS pop_rank
FROM names
GROUP BY name
HAVING COUNT(DISTINCT gender) = 2 -- where name has a distinct count of gender M & F
ORDER BY total_birth DESC
lIMIT 10;
-- insight: result looks funny, which parents name their boy Jessica? 
-- well, a mum who wants a girl! 
-- let's investigate

SELECT *
FROM names
WHERE name LIKE "Jessica" 
AND gender LIKE "M";
-- What the hell!!

-- shortest and longest name
-- shortest name
SELECT name, LENGTH(name) AS name_len
FROM names
WHERE LENGTH(name) = 2;

-- longest name
SELECT name, LENGTH(name) AS name_len
FROM names
WHERE LENGTH(name) = 15;

-- state with highest percent of babies named 'Chris'
-- total birth by STATE
SELECT state, SUM(births) AS total_births
FROM names 
GROUP BY state
ORDER BY total_births DESC;  -- total birth by states

WITH tb_by_state AS (
	SELECT state, SUM(births) AS total_births
	FROM names 
	GROUP BY state
	ORDER BY total_births DESC		-- total births by state
),
	chris_b AS(
		SELECT state, SUM(births) AS chris_births
		FROM names
		WHERE name LIKE "Chris"
		GROUP BY state
		ORDER BY chris_births DESC		-- total births by state where child name is Chirs
        )
SELECT tbbs.state, tbbs.total_births, cb.chris_births,
ROUND((cb.chris_births/tbbs.total_births)*100,3) AS chris_percent
FROM tb_by_state tbbs
INNER JOIN chris_b cb
ON tbbs.state = cb.state
ORDER BY chris_percent DESC;
-- Insight: LA(Los Angeles) has the highest babies named Chris