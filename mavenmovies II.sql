-- Maven Movies II
/*
-- The Letter 
Dear Maven Movies Management,

I am excited about the potential acquisition and learning more about your rental
business. Please bear with me as I am bew to the industry. I have a number of questions
for you. Assuming you can answer them all, and that there are no major surprises, we
should be able to move forward with the purchase.

Best,
Martin Moneybags
*/
-- Questions
/* 1.
My partner and I want to come by each of the store in person and meet the managers.
Please send over the managers' names at each store, with the full address of each 
property (street address, district, city, and country) please.
*/
-- SOLUTION steps
-- select the relevant table(s)
SELECT *
FROM staff;

SELECT * 
FROM city;

SELECT *
FROM country;

SELECT * 
FROM address;

-- Join tables
-- country-->country_id, country; city-->city_id, country_id;
-- address-->city_id

SELECT	s.first_name, s.last_name,
		a.address, a.district,
		c.city, co.country
FROM staff s
	LEFT JOIN address a
    ON s.address_id = a.address_id
		LEFT JOIN city c
        ON a.city_id = c.city_id
			LEFT JOIN country co
            ON c.country_id = co.country_id;


/* 2.
I would like to get a better understanding od all of the inventory that would come 
with the business. Please pull together a list of each inventory item you have stocked,
including the store_id number, the inventory_id, the name of the film, the film's rating,
its rental rate and replacement cost
*/
-- SOLUTION steps
-- find relevant table(s)
SELECT * FROM inventory;
SELECT * FROM film;

-- Join the tables and select relevant fields
SELECT i.store_id, i.inventory_id, f.title,
		f.rating, f.rental_rate, f.replacement_cost
FROM inventory i
	LEFT JOIN film f
    ON i.film_id = f.film_id;
    
/*3.
From the same list of films you just pulled, please roll that data up 
and provide a summary level overview of your inventory. We would like to know how
many inventory items you have with each rating at each store.

*/    
-- SOLUTION steps
-- Relevant tables already identified
-- paste previoous query
SELECT i.store_id, i.inventory_id, f.title,
		f.rating, f.rental_rate, f.replacement_cost
FROM inventory i
	LEFT JOIN film f
    ON i.film_id = f.film_id;
    
    -- Using SUBQERY/CTEs to extract relevant data as well as provide the summary overview
    
SELECT store_id, rating, COUNT(inventory_id) AS count_of_inventory
FROM 

(SELECT i.store_id, i.inventory_id, f.title,
		f.rating, f.rental_rate, f.replacement_cost
FROM inventory i
	LEFT JOIN film f
    ON i.film_id = f.film_id) AS summary

GROUP BY store_id, rating;

/* 4.
Similarly, we want to understand how diversified the inventory is in terms of 
replacement cost. We want to see how big of a hit it would be if a certain category 
of film became unpopular at a certain store. We would like to see the number of 
films, as well as the average replacement cost, and total replacement cost,
sliced by store and film category
*/

-- SOLUTION steps
-- Select the relevant tables
SELECT * FROM inventory; -- in common: film_id in film
SELECT * FROM film; 
SELECT * FROM film_category; -- in common: film_id
SELECT * FROM category;
-- 
SELECT i.store_id, fc.category_id,
 COUNT(f.film_id) AS count_of_film, AVG(f.replacement_cost) AS avg_repalcement_cost,
 SUM(f.replacement_cost) AS total_replacement_cost
 FROM film f
 LEFT JOIN inventory i
 ON f.film_id = i.film_id
	LEFT JOIN film_category fc
    ON i.film_id = fc.film_id
GROUP BY i.store_id, fc.category_id
ORDER BY total_replacement_cost DESC;

/*5.
We want to make sure you folks have a good handle on who your customers are. Please
provide a list of all customer names, which store they go to, whether or not they are 
currently active, and their full addresses - street address, city, and country.
*/
-- SOLUTION steps
-- Select releant table(s)
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

-- Select relevant fields and join
SELECT c.first_name, c.last_name,c.store_id,
	CASE WHEN active = 1 THEN 'active' ELSE 'inactive' END AS active_status,
    a.address, ci.city, co.country
FROM customer c
LEFT JOIN address a
ON c.address_id = a.address_id
	LEFT JOIN city ci 
    ON a.city_id = ci.city_id
		LEFT JOIN country co
        ON ci.country_id = co.country_id;


/*6. 
We would like to understand how much your customers are spending with you, and
also to know who your most valuable customers are. Please pull together a list of 
customer names, their total lifetime rentals, and the sum of all payments you have
collected from them. It would be great to see this ordered on total lifetime value,
with the most valueable customers at the top of the list.
*/
-- SOLUTION steps
-- Select relevant table(s)
SELECT * FROM customers;
SELECT * FROM rental;
SELECT * FROM payment;

-- Join the tables and select the relevant fields
SELECT 	c.first_name, c.last_name, 
		COUNT(r.rental_id) AS lifetime_rental,
		SUM(p.amount) AS total_rental
FROM customer c
	LEFT JOIN rental r
    ON c.customer_id = r.customer_id
		LEFT JOIN payment p
        ON r.rental_id = p.rental_id
GROUP BY c.first_name, c.last_name
ORDER BY total_rental DESC;

/* 7.
My partner and I would like to get to know your board of advisors and current investors.
could you please provdie a list of advisor and investor names in one table? could you 
please note whether they are investor or advisor, and for the investors, it would be 
good to include which company they work with.
*/
-- SOLUTION steps
-- select relevant table(s)
SELECT * FROM investor;
SELECT * FROM advisor;

-- create a field for type--where we can specify investors or advisor
SELECT *, 'investor' AS type
FROM investor;

SELECT*, 'advisor' AS type
FROM advisor;

-- Now, join both table using the UNION ALL 
SELECT first_name, last_name, company_name, 'investor' AS type
FROM investor

UNION ALL

SELECT first_name, last_name, NULL AS company_name, 'advisor' AS type
FROM advisor;

/* 8.
We are interested in how well you have covered the most-awarded actors. Of all actors
with three types of awards, for what percent of them do we carry a film? and how about
for actors with two types of awards? Same question. Finally. how about actors with 
jsut one award?
*/
-- SOLUTION steps
-- select relevant table(s)
SELECT * FROM actor_award;

-- query
SELECT 
	CASE 
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
        ELSE '1 award'
	END AS number_of_awards,
    AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS percentage_with_one_film,
	COUNT(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS count_of_awarded_per_group,
	COUNT(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE NULL END) AS awarded_but_not_in_collection    
FROM actor_award
GROUP BY number_of_awards;

-- THE END







