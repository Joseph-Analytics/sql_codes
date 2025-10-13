USE maven_advanced_sql;

-- Q1.
SELECT DISTINCT 
	p.product_id, p.product_name,
    o.product_id AS product_id_in_orders
FROM products p
	LEFT JOIN orders o
    ON p.product_id = o.product_id
WHERE o.product_id IS NULL;
    
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;

-- Q2.
SELECT 
	p1.product_name, p1.unit_price,
    p2.product_name, p2.unit_price,
    p1.unit_price - p2.unit_price AS price_diff
FROM products p1
	JOIN products p2
    ON p1.product_id <> p2.product_id
WHERE ABS(p1.unit_price - p2.unit_price) < 0.25
	AND p1.product_name < p2.product_name
ORDER BY price_diff DESC;

-- Q3.
SELECT *
FROM products;

SELECT 
AVG(unit_price) AS avg_price
FROM products;

SELECT 
	product_id, product_name, unit_price,
    (SELECT AVG(unit_price) FROM products) AS avg_unit_price,
    unit_price - (SELECT AVG(unit_price) FROM products) AS price_diff
FROM products
WHERE unit_price IS NOT NULL
ORDER BY unit_price DESC;

-- Q4.
SELECT factory, product_name
FROM products;

SELECT factory, COUNT(product_id) AS num_products
FROM products
GROUP BY factory;

SELECT p.factory, p.product_name, 
		np.num_products
FROM products p
	LEFT JOIN
		(SELECT factory, COUNT(product_id) AS num_products
		FROM products
		GROUP BY factory) AS np
	ON p.factory = np.factory
ORDER BY factory;
    -- nb: this is correlated subquery
 
-- Q5.
SELECT * 
FROM products
WHERE unit_price < ALL(SELECT unit_price FROM products WHERE factory = "Wicked Choccy's");

-- Q6.
SELECT 
	order_id,
	SUM(units * unit_price) AS total_amount_spent
FROM orders o
	LEFT JOIN products p
	ON o.product_id = p.product_id
GROUP BY order_id
HAVING total_amount_spent > 200
ORDER BY total_amount_spent DESC;

WITH tas AS (
	SELECT 
		order_id,
		SUM(units * unit_price) AS total_amount_spent
	FROM orders o
		LEFT JOIN products p
		ON o.product_id = p.product_id
	GROUP BY order_id
	HAVING total_amount_spent > 200
	ORDER BY total_amount_spent DESC
)
SELECT COUNT(*) AS order_count
FROM tas;

USE maven_advanced_sql;

-- Q7.
SELECT factory, COUNT(product_name) AS num_products
FROM products
GROUP BY factory;

WITH product_count AS (
	SELECT factory, COUNT(product_name) AS num_products
	FROM products
	GROUP BY factory
    )
SELECT p.factory, p.product_name,
		pc.num_products
FROM products p
	LEFT JOIN product_count pc
	ON p.factory = pc.factory
ORDER BY factory;

-- Q8.
SELECT 
customer_id, order_id, order_date, transaction_id, 
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS transaction_number
FROM orders;

-- Q9.
SELECT order_id, product_id, units, 
DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rank
FROM orders
WHERE order_id LIKE '%44262';

-- Q10.
SELECT 
order_id, product_id, units,
ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY units DESC) AS popularity
FROM orders;

WITH product_popularity AS (
	SELECT 
	order_id, product_id, units,
	ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY units DESC) AS popularity
	FROM orders
)
SELECT order_id, product_id, units
FROM product_popularity pp
WHERE popularity = 2;

-- or

WITH SPP AS (
	SELECT 
	order_id, product_id, units,
	NTH_VALUE(product_id, 2) OVER(PARTITION BY order_id ORDER BY units DESC) AS second_place_popularity
	FROM orders
)
SELECT order_id, product_id, units
FROM spp
WHERE second_place_popularity IS NOT NULL;

-- Q11
SELECT *
FROM orders;

SELECT customer_id, order_id, units
FROM orders;

SELECT customer_id, order_id, SUM(units) AS total_units
FROM orders
GROUP BY customer_id, order_id
ORDER BY customer_id;

SELECT customer_id, order_id, MIN(transaction_id) AS min_tid, SUM(units) AS total_units
FROM orders
GROUP BY customer_id, order_id
ORDER BY customer_id;

WITH tu AS (
	SELECT customer_id, order_id, MIN(transaction_id) AS min_tid, SUM(units) AS total_units
	FROM orders
	GROUP BY customer_id, order_id
	ORDER BY customer_id
)
SELECT customer_id, order_id, total_units,
	LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid) AS prior_units
FROM tu;

WITH tu AS (
	SELECT customer_id, order_id, MIN(transaction_id) AS min_tid, SUM(units) AS total_units
	FROM orders
	GROUP BY customer_id, order_id
	ORDER BY customer_id
),
	pu AS(
		SELECT customer_id, order_id, total_units,
			LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid) AS prior_units
		FROM tu)
SELECT customer_id, order_id, total_units, prior_units,
total_units - prior_units AS unit_diff
FROM pu;

-- Q12.
SELECT *
FROM products;

SELECT * 
FROM orders;

SELECT o.customer_id, o.units,
		p.unit_price
FROM orders o
INNER JOIN products p
ON o.product_id = p.product_id;

SELECT o.customer_id, 
		SUM(o.units * p.unit_price) AS total_spent
FROM orders o
	INNER JOIN products p
	ON o.product_id = p.product_id
GROUP BY o.customer_id
ORDER BY total_spent DESC;

WITH ts AS (
	SELECT o.customer_id, 
			SUM(o.units * p.unit_price) AS total_spent
	FROM orders o
		INNER JOIN products p
		ON o.product_id = p.product_id
	GROUP BY o.customer_id
	ORDER BY total_spent DESC
)
SELECT customer_id, total_spent,
	NTILE(100) OVER(ORDER BY total_spent DESC) AS spend_pct
FROM ts
ORDER BY total_spent DESC;

WITH ts AS (
	SELECT o.customer_id, 
			SUM(o.units * p.unit_price) AS total_spent
	FROM orders o
		INNER JOIN products p
		ON o.product_id = p.product_id
	GROUP BY o.customer_id
	ORDER BY total_spent DESC
),
	pct AS(
			SELECT customer_id, total_spent,
				NTILE(100) OVER(ORDER BY total_spent DESC) AS spend_pct
			FROM ts)
SELECT * 
FROM pct
WHERE spend_pct = 1
ORDER BY total_spent DESC;

-- Q13
SELECT *
FROM products;

SELECT factory, product_id, 
	CONCAT(factory, product_id) AS factory_product_id
FROM products;

WITH fp AS (
		SELECT factory, product_id, 
			REPLACE(REPLACE(factory, "'", ""), " ","-") AS factory_clean 
		FROM products)
SELECT 
factory, product_id, 
CONCAT(factory_clean, "-", product_id) AS factory_product_id
FROM fp
ORDER BY factory;

-- Q13.
SELECT *,
ROW_NUMBER() OVER(PARTITION BY student_name ORDER BY id DESC) AS std_num
FROM students;

WITH student_num AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY student_name ORDER BY id DESC) AS std_num
FROM students)

SELECT id, student_name, email, std_num
FROM student_num
WHERE std_num = 1
ORDER BY id;

-- Q14. 
SELECT *
FROM students;
SELECT * 
FROM student_grades;

SELECT id,student_name, final_grade, class_name
FROM students s
LEFT JOIN student_grades sg
ON s.id = sg.student_id;

SELECT id,student_name, final_grade, class_name,
MAX(final_grade) OVER(PARTITION BY student_name ORDER BY id) AS top_grade
FROM students s
LEFT JOIN student_grades sg
ON s.id = sg.student_id;

WITH tg AS(
	SELECT id,student_name, final_grade, class_name,
	MAX(final_grade) OVER(PARTITION BY student_name ORDER BY id) AS top_grade
	FROM students s
	LEFT JOIN student_grades sg
	ON s.id = sg.student_id)
SELECT id, student_name, top_grade, class_name
FROM tg
WHERE final_grade = top_grade
ORDER BY id;

-- Q15
SELECT * FROM orders;
SELECT * FROM products;

SELECT 
order_date, units, unit_price
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id;

SELECT 
order_date, units*unit_price AS total_sales
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id;

SELECT 
YEAR(order_date) AS year, MONTH(order_date) AS month, units*unit_price AS total_sales
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id;

SELECT 
YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(units*unit_price) AS total_sales
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

SELECT 
YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(units*unit_price) AS total_sales
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

WITH ts AS(
SELECT 
YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(units*unit_price) AS total_sales
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)
)

SELECT year, month, total_sales,
		ROW_NUMBER() OVER(ORDER BY year, month) AS rn,
        SUM(total_sales) OVER(ORDER BY year, month) AS cumulative_sales,
        ROUND(AVG(total_sales) OVER(ORDER BY year, month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW), 2) AS 6mnth_ma
        
FROM ts;