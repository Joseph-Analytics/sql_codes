-- ADVANCED SQL PROJECT
-- Questions and Answers 

-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
SELECT * FROM schools;
SELECT * FROM school_details;

-- 2. In each decade, how many schools were there that produced players?
-- solution preview
SELECT * FROM schools;		-- data preview
SELECT COUNT(DISTINCT yearID) FROM schools; -- how many decades are there?
SELECT MIN(yearID), MAX(yearID) FROM schools; -- what's the min and max year in the time series?

SELECT 	FLOOR(yearID/10)*10  AS decade, 		-- using floor to break the years into bins for decade
		COUNT(schoolID) AS count_of_school
FROM schools
GROUP BY FLOOR(yearID/10)*10
ORDER BY decade;

-- 3. What are the names of the top 5 schools that produced the most players?
SELECT *
FROM schools s
LEFT JOIN school_details sd
ON s.schoolID = sd.schoolID;			-- join

SELECT name_full,
		COUNT(playerID) AS count_of_players
FROM schools s
LEFT JOIN school_details sd
ON s.schoolID = sd.schoolID
GROUP BY name_full
ORDER BY count_of_players DESC;			-- list of schools along its count of players

-- limiting data to the top 5 schools
SELECT name_full,
		COUNT(playerID) AS count_of_players
FROM schools s
LEFT JOIN school_details sd
ON s.schoolID = sd.schoolID
GROUP BY name_full
ORDER BY count_of_players DESC
LIMIT 5; 				-- Top 5 schools

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
-- solution steps
-- creating the decade bin and count of players fields
SELECT 	FLOOR(yearID/10)*10 AS decade, 
		name_full,
		COUNT(playerID) AS count_of_players
FROM schools s
LEFT JOIN school_details sd
ON s.schoolID = sd.schoolID
GROUP BY FLOOR(yearID/10)*10, name_full
ORDER BY FLOOR(yearID/10)*10, count_of_players DESC; -- lsit of schools by decade with count of players


WITH cop AS( -- count of players
		SELECT 	FLOOR(yearID/10)*10 AS decade, 
				name_full,
				COUNT(playerID) AS count_of_players
		FROM schools s
		LEFT JOIN school_details sd
		ON s.schoolID = sd.schoolID
		GROUP BY FLOOR(yearID/10)*10, name_full
		ORDER BY FLOOR(yearID/10)*10, count_of_players DESC
),
	rn AS (
		SELECT decade, name_full, count_of_players, 
		ROW_NUMBER() OVER(PARTITION BY decade ORDER BY count_of_players DESC) AS rn_cop
		FROM cop
        )
SELECT * 
FROM rn
WHERE rn_cop < 4;

-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
SELECT * FROM salaries; 		-- table preview

-- 2. Return the top 20% of teams in terms of average annual spending
-- solution steps
-- select relevant fields
SELECT yearID, teamID, AVG(salary) As average_annual_spending
FROM salaries
GROUP BY yearID, teamID;  -- teams in terms of avg annual spending by year 

-- suing ctes, dense_rank and ntile() function to organize the data
WITH aas AS (
	SELECT yearID, teamID, AVG(salary) As average_annual_spending
	FROM salaries
	GROUP BY yearID, teamID)
SELECT yearID, teamID, average_annual_spending,
DENSE_RANK() OVER(PARTITION BY yearID ORDER BY average_annual_spending DESC) AS dr, -- creating dense_rank
NTILE(5) OVER(PARTITION BY yearID ORDER BY average_annual_spending DESC) as aas_pct -- creating the aas_pct
FROM aas;

-- limiting dense_rank to the top 20%. i.e 1 of 5 with aas in DESC
WITH aas AS (
	SELECT yearID, teamID, AVG(salary) As average_annual_spending
	FROM salaries
	GROUP BY yearID, teamID),
    ap AS( -- AS aas_pct
	SELECT yearID, teamID, average_annual_spending,
	DENSE_RANK() OVER(PARTITION BY yearID ORDER BY average_annual_spending DESC) AS dr, -- creating dense_rank
	NTILE(5) OVER(PARTITION BY yearID ORDER BY average_annual_spending DESC) as aas_pct -- creating the aas_pct
	FROM aas)
SELECT yearID, teamID, ROUND(average_annual_spending, 2) AS avg_ann_spending, dr, aas_pct
FROM ap
WHERE aas_pct = 1; -- you can choose to filter out column dr and aas_pct if you find it extraneous

-- 3. For each team, show the cumulative sum of spending over the years
SELECT * FROM salaries; --  sneak_peeking the table

-- solution steps
-- keyword here is cumulative sum
-- starting with relevant fields
SELECT 	yearID, teamID, SUM(salary) AS annual_spending
FROM salaries
GROUP BY yearID, teamID
ORDER BY teamID, yearID; 		-- annual_spending by team

-- the cumulative sum
WITH ann_spend AS(
	SELECT 	yearID, teamID, SUM(salary) AS annual_spending
	FROM salaries
	GROUP BY yearID, teamID
	ORDER BY teamID, yearID)
SELECT yearID, teamID, annual_spending,
		SUM(annual_spending) OVER(PARTITION BY teamID ORDER BY teamID, yearID) AS cum_spend
FROM ann_spend; -- cum_spending by team over the year.
-- NB: no need to partition by teamID anymore actually since the column was already partition through the previous query


-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
-- solution steps contd from --3.
WITH ann_spend AS(
	SELECT 	yearID, teamID, SUM(salary) AS annual_spending
	FROM salaries
	GROUP BY yearID, teamID
	ORDER BY teamID, yearID),
cs AS( -- cum_spend
	SELECT yearID, teamID, annual_spending,
			SUM(annual_spending) OVER(PARTITION BY teamID ORDER BY teamID, yearID) AS cum_spend
	FROM ann_spend),
    rcs AS ( -- AS rn_cum_spend
		SELECT 	yearID, teamID, annual_spending, cum_spend,
				ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY cum_spend) AS rn_cum_spend
		FROM cs
		WHERE cum_spend > 1000000000)
SELECT * 
FROM rcs
WHERE rn_cum_spend = 1; -- you can choose to not call the extraneous columns, as all we need is the yearID,teamID

-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
SELECT * FROM players; 		-- table preview
DESC players; 				-- describe table
SELECT COUNT(playerID) AS count_of_players
FROM players;				-- count_of_players

-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). 
-- Sort from longest career to shortest career.
-- solution steps
-- seleted the relevant fields from the table, concated and casted the birthdate field to date datatype
SELECT 	playerID, birthYear, birthMonth, BirthDay,
		CONCAT(birthYear,"-", birthMonth,"-",birthDay) AS birthdate,
		debut, finalGame
FROM players;

-- from concat() to date data type
SELECT 	playerID, birthYear, birthMonth, BirthDay,
		STR_TO_DATE(CONCAT(birthYear,"-", birthMonth,"-",birthDay), "%Y-%m-%d") AS birthdate,
		debut, finalGame
FROM players;		-- calc the birthdate

-- age at debut, finalgame, and career_length using the FROM subquery
SELECT 	playerID, birthdate, debut, finalGame,
		TIMESTAMPDIFF(YEAR, birthdate, debut) AS age_at_debut,
        TIMESTAMPDIFF(YEAR, birthdate, finalGame) AS age_at_finalGame,
		TIMESTAMPDIFF(YEAR, birthdate, finalGame) - TIMESTAMPDIFF(YEAR, birthdate, debut) AS career_length
FROM
		(SELECT 	playerID, birthYear, birthMonth, BirthDay,
				STR_TO_DATE(CONCAT(birthYear,"-", birthMonth,"-",birthDay), "%Y-%m-%d") AS birthdate,
				debut, finalGame
		FROM players) AS bd;	-- age at debut, finalGame, and career_length using subquery

-- 3. What team did each player play on for their starting and ending years?
-- solution steps
SELECT *
FROM Players p
LEFT JOIN salaries s
ON p.playerID = s.playerID;		-- join tables

-- create starting and ending year,
-- create starting and ending team
SELECT 	p.nameGiven,
		s.yearID AS starting_year, s.teamID AS starting_team,
        e.yearID AS ending_year, e.teamID AS ending_team
FROM	players p INNER JOIN salaries s
							ON p.playerID = s.playerID
							AND YEAR(p.debut) = s.yearID
				  INNER JOIN salaries e
							ON p.playerID = e.playerID
							AND YEAR(p.finalGame) = e.yearID;

-- 4. How many players started and ended on the same team and also played for over a decade?
-- solution steps contd from --3.
-- tweak the WHERE condition to starting_team = ending_team
SELECT 	p.nameGiven, 
		s.yearID AS starting_year, s.teamID AS starting_team,
		e.yearID AS ending_year, e.teamID AS ending_team
FROM Players p
	INNER JOIN salaries s
	ON p.playerID = s.playerID
	AND YEAR(p.debut) = s.yearID
		INNER JOIN salaries e
		ON p.playerID = e.playerID
		AND YEAR(p.finalGame) = e.yearID
WHERE s.teamID = e.teamID AND e.yearID - s.yearID > 10
ORDER BY nameGiven;

-- or

WITH first_last AS (
  -- 1) we get earliest and latest salary years per player
  SELECT playerID,
         MIN(yearID) AS starting_year,
         MAX(yearID) AS ending_year
  FROM salaries
  GROUP BY playerID
),
teams AS (
  -- 2) we get the team at the starting year and the team at the ending year
  SELECT f.playerID,
         f.starting_year,
         s.teamID AS starting_team,
         f.ending_year,
         e.teamID AS ending_team
  FROM first_last f
  JOIN salaries s
    ON s.playerID = f.playerID
   AND s.yearID = f.starting_year
  JOIN salaries e
    ON e.playerID = f.playerID
   AND e.yearID = f.ending_year
)
-- 3) join to Players for the name and apply the filters
SELECT p.nameGiven,
       t.starting_year,
       t.starting_team,
       t.ending_year,
       t.ending_team
FROM teams t
JOIN Players p
  ON p.playerID = t.playerID
WHERE t.starting_team = t.ending_team
  AND (t.ending_year - t.starting_year) > 10
  ORDER BY nameGiven;



-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
SELECT * FROM players;

-- 2. Which players have the same birthday?
-- solution steps
-- concat() to generate the birthdate field
-- cast() concat() to date or use str_to_date() function
SELECT 	STR_TO_DATE(CONCAT(birthYear,"-",birthMonth,"-",birthDay), "%Y-%m-%d") AS birthdate,
	-- 	CAST(CONCAT(birthYear,"-",birthMonth,"-",birthDay) AS DATE) AS birthdate |(either CAST() or STR_TO_DATE() works)
		nameGiven
FROM players;

WITH bn AS ( -- bn = birthdate namegiven
		SELECT 	STR_TO_DATE(CONCAT(birthYear,"-",birthMonth,"-",birthDay), "%Y-%m-%d") AS birthdate,
			-- 	CAST(CONCAT(birthYear,"-",birthMonth,"-",birthDay) AS DATE) AS birthdate, (either CAST() or STR_TO_DATE() works)
				nameGiven
		FROM players)
SELECT 	birthdate,
		GROUP_CONCAT(nameGiven separator', ') AS players
FROM bn
WHERE birthdate IS NOT NULL
AND YEAR(birthdate) BETWEEN 1980 AND 1990
GROUP BY birthdate
ORDER BY birthdate;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
-- solution steps
SELECT * FROM players; 	-- table preview

SELECT DISTINCT bats 		-- distinct values in the bats' field
FROM players;

-- bat count, summary using CASE statement for PIVOTING
SELECT teamID, 
CASE WHEN bats = 'R' THEN 1 ELSE 0 END AS bats_right,
CASE WHEN bats = 'L' THEN 1 ELSE 0 END AS bats_left,
CASE WHEN bats = 'B' THEN 1 ELSE 0 END AS bats_both
FROM players p
INNER JOIN salaries s
ON p.playerID = s.playerID;

-- aggregate the count using SUM()
-- PS: using COUNT() rather than SUM() counts the zeros too. not what we want
WITH bat_count AS (
SELECT teamID, 
SUM(CASE WHEN bats = 'R' THEN 1 ELSE 0 END) AS bats_right,
SUM(CASE WHEN bats = 'L' THEN 1 ELSE 0 END) AS bats_left,
SUM(CASE WHEN bats = 'B' THEN 1 ELSE 0 END) AS bats_both
FROM players p
INNER JOIN salaries s
ON p.playerID = s.playerID
GROUP BY teamID)
SELECT teamID, bats_right, bats_left, bats_both,
bats_right + bats_left + bats_both AS total_bat
FROM bat_count;

-- Bats and percentages
-- we find the fractions: br, bl, bb
-- we divide by the whole: bats_total
WITH bat_count AS (
SELECT 	teamID, 
		SUM(CASE WHEN bats = 'R' THEN 1 ELSE 0 END) AS bats_right,
		SUM(CASE WHEN bats = 'L' THEN 1 ELSE 0 END) AS bats_left,
		SUM(CASE WHEN bats = 'B' THEN 1 ELSE 0 END) AS bats_both
FROM players p
INNER JOIN salaries s
ON p.playerID = s.playerID
GROUP BY teamID
),
	bt AS(
		SELECT 	teamID, bats_right, bats_left, bats_both,
				bats_right + bats_left + bats_both AS bats_total
		FROM bat_count
)
SELECT 	teamID, 
		bats_right, ROUND(bats_right/bats_total, 2) AS br_pct,
		bats_left, ROUND(bats_left/bats_total, 2) AS bl_pct,
		bats_both, ROUND(bats_both/bats_total,2) AS bb_pct,
		bats_total
FROM bt
ORDER BY bats_total DESC;

-- 4. How have average height and weight at debut game changed over the years, 
-- and what's the decade-over-decade difference?
SELECT * FROM players; -- data preview

-- solution steps
-- select relevant fields in the table
-- chose the year() in the debut as a standard measure for decade
-- apply the agg function (avg())
SELECT 	FLOOR(YEAR(debut)/10)*10 AS decade,
		ROUND(AVG(height), 2) AS avg_height,
		ROUND(avg(weight), 2) AS avg_weight
FROM players
WHERE YEAR(debut) IS NOT NULL
		AND height IS NOT NULL
		AND weight IS NOT NULL
GROUP BY decade
ORDER BY decade;

-- decade-over-decade via CTEs
WITH avg_hw AS(
SELECT 	FLOOR(YEAR(debut)/10)*10 AS decade,
		ROUND(AVG(height), 2) AS avg_height,
		ROUND(avg(weight), 2) AS avg_weight
FROM players
WHERE YEAR(debut) IS NOT NULL
AND height IS NOT NULL
AND weight IS NOT NULL
GROUP BY decade
ORDER BY decade
)
SELECT 	avg_height,
		avg_height - LAG(avg_height) OVER(ORDER BY decade) AS height_diff,
		avg_weight,
		avg_weight - LAG(avg_weight) OVER(ORDER BY decade) AS weight_diff
FROM avg_hw;