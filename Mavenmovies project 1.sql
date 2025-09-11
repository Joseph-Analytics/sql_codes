-- SQL PROJECT 
-- THE LETTER 
/*
Dear Maven Movies Management,

In our review of your policy renewal application, we have realized that your business
information has not been updated in a number of years. In order to accurately assess the 
risk and approve your policy renewal, we will need you to provide all of the following
information. 

Sincerely,
Joe Scardycat, Lead Underwriter

*/

/*
-- Q.1. We will need a list of all staff members, including their first and last names,
		email addresses, and the store identification number where they work.

*/
-- Solution in steps
-- Find relevant table(s)
USE mavenmovies;
SELECT *
FROM staff;

-- select relevant fields from the table
SELECT first_name, last_name, email, store_id
FROM staff;

/*
2.	 We will need separate counts of inventory items held at each of your
	two stores.
*/
-- solution Steps
-- find relevant table(s)
SELECT * 
FROM inventory;

-- how many inventory items are there in each store?
SELECT store_id, COUNT(inventory_id) AS 'count of inventory items'
FROM inventory
GROUP BY store_id;

-- OR alias this way
SELECT store_id, COUNT(inventory_id) AS count_of_inventory_items
FROM inventory
GROUP BY store_id;

/*
3. 	We will need a count of active customers for each of your stores. 
	Separately, please
*/
-- SOLUTION steps
-- Find relevant table(s)
SELECT *
FROM customer;

-- insight: taking a sneak peek into the active field, it seem to be a dummy variable
-- 0 for inactive and 1 for active
-- lets find the count of active for each store

SELECT store_id, COUNT(active) AS active_customers
FROM customer
WHERE active = 1
GROUP BY store_id;

/*
4. In order to assess the liability of a data breach, we will need you to provide 
a count of all customer email addresses stored in the database
*/
-- select the relevant table(s)
SELECT *
FROM customer;

-- find the count of customer email
-- PS. I am not using the customer_id as a reference for count, since its a unique identifier
-- Besides, customer_id wouldn't have a missing value, hence, a possible error of assumption
-- using the email field since some customers might have a missing email record
-- let's find out by doing a count for both custome_id and email to see if 
-- there are missing customer emails.

SELECT COUNT(email) AS count_of_customer_email
FROM customer;

SELECT COUNT(customer_id) AS count_of_cID
FROM customer;
-- insight: no customer with missing email record in our db

/*
5.	We are interested in how diverse your film offering is as a means of understanding 
	how likely you are to keep customers engaged in the future. Please provide a count of 
	unique film titles you have in inventory at each store and then provide a count of the 
	unique categories of films you provide.

*/
-- SOLUTION steps
-- find the relevant table(s)
SELECT *
FROM film;

SELECT * 
FROM inventory;

SELECT *
FROM film_category;

-- select relevant fields
-- it happens that we have the fields we need scattered across different tables
-- the need for join statement
-- title, film_id--pkey in film; store_id, film_id, inventory_id--pkey in inventory;
-- film_id --pkey, category_id in film_category

-- we need to join these tables
SELECT
	f.film_id, f.title, i.store_id, i.inventory_id, fm.category_id
FROM film f
	LEFT JOIN inventory i 
    ON f.film_id = i.film_id
		LEFT JOIN film_category fm
        ON i.film_id = fm.film_id;
        
-- provide a count of unique film titles in inventory at each store
SELECT
	i.store_id, COUNT(f.film_id)  AS count_of_film_title -- i.inventory_id, fm.category_id
FROM film f
	LEFT JOIN inventory i 
    ON f.film_id = i.film_id
		LEFT JOIN film_category fm
        ON i.film_id = fm.film_id
GROUP BY i.store_id;

-- the count above isn't DISCTINCT. It is the count of all the film titles in
-- the inventory PS. Some films have a lot of copies prolly because they are in 
-- high demand than others. However, we are only interest in the DISTINCT film title.
-- i hope the question and query makes more sense now.
--  Look below to see the DISTINCT count for each film title in each store in our inventory
-- this could also be used to mean distinct count of films in each store

SELECT
	i.store_id, COUNT(DISTINCT f.film_id)  AS count_of_film_title -- i.inventory_id, fm.category_id
FROM film f
	LEFT JOIN inventory i 
    ON f.film_id = i.film_id
		LEFT JOIN film_category fm
        ON i.film_id = fm.film_id
GROUP BY i.store_id;

-- btw, we see that there are 42 uniwue movie titles with no ascribed store ID
-- in our inventory.

/*
6. 	We would like to understand the replacement cost of your films. Please provide the 
	replacement cost for the film that is least expensive to replace, the most expensive 
	to replace, and the average of all films you carry.
*/

-- SOLUTION steps
-- Select the relevant table(s)
SELECT *
FROM film;

-- select relevant fields and find the min, max, avg of replacement cost
SELECT -- film_id, title, 
		MIN(replacement_cost) AS least_rc,
		MAX(replacement_cost) AS most_exp_rc,
        AVG(replacement_cost) AS avg_rc
FROM film;

/*
7. We are interested in having you put payment monitoring systems and maximum payment
	processing  restrictions in place in order to minimize the future risk of fraud by 
	your staff. Please provide the average payment you process, as well as the maximum
	payment you have processed
*/
-- SOLUTION steps
-- find the relevant table(s)
SELECT *
FROM payment;

-- Select relevant fields
SELECT staff_id, AVG(amount) AS avg_payment_processed,
		MAX(amount) AS max_payment_processed
FROM payment
GROUP BY staff_id;

/*
8. 	We would like to better understand what your customer base looks like. please provide 
	a list of all customer identification value, with a count of rentals they have made all-time,
	with your highest volumne customers at the top of the list

*/
-- SOLUTION steps
-- select relevant table(s)
SELECT * 
FROM customer;

SELECT *
FROM rental;

-- select relevant fields -- join tables
SELECT c.customer_id, r.rental_id
FROM customer c
	LEFT JOIN rental r
    ON c.customer_id = r.customer_id;
    
   -- find the count of rentals by each customers
SELECT c.customer_id, COUNT(r.rental_id) AS all_time_rentals
FROM customer c
	LEFT JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY COUNT(r.rental_id) DESC;




