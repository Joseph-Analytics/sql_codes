CREATE DATABASE hr_project;

USE hr_project;

SELECT * FROM hr;

ALTER TABLE hr 						-- modify/change table
CHANGE COLUMN ï»¿id emp_id 			-- change name from ... to ...
VARCHAR(20) NULL;					-- define field datatype and limit, 
-- by including NULL, i am saying it's acceptable for some employees 
-- not to have an ID value in that column.

DESCRIBE hr;
-- or
DESC hr;

SELECT birthdate FROM hr;

UPDATE hr
SET birthdate = CASE
WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL
END;

SET sql_safe_updates = 0; -- this is to allow our hr update to run successfully.
-- set back to 1 after update, for security reasons, which is protecting your db
-- this is to ensure that the data is not easily manipulated. got that ? cool!

SET sql_safe_updates = 1;
SELECT birthdate FROM hr;

-- change birthdate data type to date data type

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

DESCRIBE hr;

-- update the hiredate to a valid and consistent data pattern
UPDATE hr
SET hire_date = CASE
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL
END;

SELECT hire_date FROM hr;

SELECT termdate FROM hr;

UPDATE hr
SET termdate = DATE(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL 
AND termdate != '';

UPDATE hr
SET termdate = '0000-00-00'
WHERE termdate IS NULL OR termdate = '';


SELECT termdate FROM hr;

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

UPDATE hr
SET termdate = '1000-01-01'
WHERE termdate = '0000-00-00';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

DESC hr;

SELECT * FROM hr;

ALTER TABLE hr				-- modify/change smtn in the table hr
ADD COLUMN age INT;			-- add column age with int data type

UPDATE hr
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());

SELECT 
MIN(age) youngest, MAX(age) oldest
FROM hr;

SELECT COUNT(age)
FROM hr
WHERE age < 18;

-- QUESTIONS
-- 1. what is the gender breakdown of employees in the company?

-- STEPS
SELECT * FROM hr;
SELECT gender,
	COUNT(emp_id) AS count
FROM hr
WHERE age >= 18 AND termdate = '1000-01-01' 
GROUP BY gender
ORDER BY count DESC;
-- we use the condtion to show employable age from 18 with termdate invalid,
-- or in the future, to show these emps are still actively employed 

-- what is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '1000-01-01'
GROUP BY race
ORDER BY count DESC;
-- good practice to use count(*) rather than id, since some emp might have no/missing id

-- what is the age distribution of employee in the company?
-- steps
SELECT
	MIN(age) youngest, MAX(age) Oldest
FROM hr
WHERE AGE >= 18 AND termdate = '1000-01-01';

SELECT 
	CASE 
		WHEN age >= 18 AND age <=24 THEN '18-24'
        WHEN age >= 25 AND age <=34 THEN '25-34'
        WHEN age >= 35 AND age <=44 THEN '35-44'
        WHEN age >= 45 AND age <=54 THEN '45-54'
		WHEN age >= 55 AND age <=64 THEN '55-64'
        ELSE '65+'
        END AS age_group,
        COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '1000-01-01'
GROUP BY age_group
ORDER BY age_group;

-- how is the age distribution also among gender?
SELECT 
	CASE 
		WHEN age >= 18 AND age <=24 THEN '18-24'
        WHEN age >= 25 AND age <=34 THEN '25-34'
        WHEN age >= 35 AND age <=44 THEN '35-44'
        WHEN age >= 45 AND age <=54 THEN '45-54'
		WHEN age >= 55 AND age <=64 THEN '55-64'
        ELSE '65+'
        END AS age_group, gender,
        COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '1000-01-01'
GROUP BY age_group, gender 
ORDER BY age_group, gender;

-- 4. How many employrrs work at headquarters vs remote locations?
-- STEPS
SELECT * FROM hr;
SELECT location,
	COUNT(*) AS count
FROM hr
GROUP BY location
ORDER BY count DESC;

-- 5
-- what is the average lenght of employment for employees who have been terminated?
-- STEPS
SELECT * FROM hr;
SELECT ROUND(AVG(DATEDIFF(termdate, hire_date))/365, 0) AS avg_length_of_employment
FROM hr
WHERE termdate <= curdate() AND termdate <> '1000-01-01' AND age >=18;

-- nb: the result we get in the datediff is in days, say 3000 days for example,
-- hence the need to divide the result by 365days so the result is in year rather than days

-- 6
-- How does gender distribution vary across departments?
USE hr_project;
SELECT * FROM hr;

SELECT 
	Department, Gender, COUNT(*) AS Count
FROM hr
WHERE age >= 18 AND termdate = '1000-01-01'
GROUP BY department, gender
ORDER BY department, count DESC;

-- 7. What is the distribtion of the job titles across the company?
SELECT jobtitle, count(*) COUNT
FROM hr
WHERE age >= 18 AND termdate = '1000-01-01'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. what department has the highest turnover rate?
SELECT department, total_count, terminated_count,
 ROUND(terminated_count/total_count, 3) AS terminated_rate
FROM (
SELECT 
department,
COUNT(*) AS total_count,
SUM(CASE 
	WHEN termdate <> '1000-01-01' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
FROM hr
WHERE age >= 18 
GROUP BY department) AS turnover_rate
ORDER BY terminated_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT * FROM hr;
SELECT 
location_state,
COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '1000-01-01'
GROUP BY location_state
ORDER BY count DESC;

SELECT 
location_city,
COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '1000-01-01'
GROUP BY location_city
ORDER BY count DESC;

-- 10
-- How has the company's employee count changed over time based on hire and term dates?
SELECT
year, hires, terminations, 
hires-terminations AS net_change, 
ROUND((((hires-terminations)/hires)*100), 2) AS net_change_percent
FROM(
SELECT 
YEAR(hire_date) AS year,
COUNT(*) AS hires,
SUM(CASE 
		WHEN termdate <> '1000-01-01' AND termdate <= curdate() 
        THEN 1 ELSE 0 END) AS terminations
FROM hr
WHERE age >= 18
GROUP BY YEAR(hire_date)
) AS employee_count
ORDER BY year;

-- 11. What is the tenure distribution for each department ?
SELECT 
department,
ROUND(AVG(DATEDIFF(termdate, hire_date)/365), 0) AS avg_tenure
FROM hr
WHERE age >= 18 AND termdate <> '1000-01-01' AND termdate <= curdate()
GROUP BY department;