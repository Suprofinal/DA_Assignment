USE MAVENMOVIES;
-- 1. Write a query to display the customer's first name, last name, email, and city they live in.
-- using subquery
SELECT 
    first_name,
    last_name,
    email,
    (SELECT 
            city
        FROM
            city
        WHERE
            city_id = (SELECT 
                    city_id
                FROM
                    address
                WHERE
                    address.address_id = customer.address_id)) AS city
FROM
    customer; 
-- using CTE
with customertable as ( select first_name,last_name,email,city from customer as c join address as a on a.address_id=c.address_id join city as ci on a.city_id=ci.city_id)
select first_name,last_name,email,city from  customertable;
-- using join
SELECT 
    first_name, last_name, email, city
FROM
    customer AS c
        JOIN
    address AS a ON a.address_id = c.address_id
        JOIN
    city AS ci ON ci.city_id = a.city_id;
    
-- 2. Retrieve the film title, description, and release year for the film that has the longest duration.
-- using subquery
select title,description,release_year from film as f where length=(select max(length) from film);
-- using join 
SELECT 
    f.title, f.description, f.release_year
FROM
    film AS f
        JOIN
    film AS f2 ON f.length = (SELECT 
            MAX(length)
        FROM
            film)
WHERE
    f.film_id = f2.film_id;
-- using CTE
with filterfilm as (select title,description,release_year from film where length=(select max(length) from film))
select title,description,release_year from filterfilm;

-- 3. List the customer name, rental date, and film title for each rental made. Include customers who have never
-- rented a film.
-- using join
SELECT 
    CONCAT(first_name, ' ', last_name) AS customer_name,
    rental_date,
    title
FROM
    customer AS c
        LEFT JOIN
    rental AS r ON c.customer_id = r.customer_id
        LEFT JOIN
    inventory AS i ON i.inventory_id = r.inventory_id
        LEFT JOIN
    film AS f ON f.film_id = i.film_id;
 -- using CTE
 with customer_rental as (select concat(first_name," ",last_name)as customer_name,i.inventory_id,rental_date from customer as c left join rental as r on c.customer_id=r.customer_id left join inventory as i on i.inventory_id=r.inventory_id),
 film_table as(select title,i.inventory_id from film as f left join inventory as i on f.film_id=i.film_id)
 select cr.customer_name,cr.rental_date,ft.title from customer_rental as cr left join  film_table as ft on cr.inventory_id=ft.inventory_id;
 
 -- 4. Find the number of actors for each film. Display the film title and the number of actors for each film.
 -- using subquery
select title ,(select count(*) from film_actor where film.film_id=film_actor.film_id) as no_of_actors from film;
-- using join
SELECT 
    title, COUNT(*) AS no_of_actor
FROM
    film_actor AS fa
        JOIN
    film AS f ON f.film_id = fa.film_id
GROUP BY f.title;

-- 5. Display the first name, last name, and email of customers along with the rental date, film title, and rental
-- return date.
SELECT 
    first_name,
    last_name,
    email,
    rental_date,
    title,
    return_date
FROM
    customer AS c
        JOIN
    rental AS r ON c.customer_id = r.customer_id
        JOIN
    inventory AS i ON i.inventory_id = r.inventory_id
        JOIN
    film AS f ON i.film_id = f.film_id;

-- 6. Retrieve the film titles that are rented by customers whose email domain ends with '.net'.
select title from film where film_id in (select inventory_id from inventory where inventory_id in (select inventory_id from rental where customer_id in(select customer_id from customer where email like '%net')));
-- using join
select title from film as f join inventory as i on f.film_id=i.film_id join rental as r on i.inventory_id=r.inventory_id join customer as c on c.customer_id=r.customer_id where c.email like '%net';

-- 7. Show the total number of rentals made by each customer, along with their first and last names.
-- using subquery
SELECT 
    SUM(rental_id) AS total_number_of_rentals,
    (SELECT 
            CONCAT(first_name, ' ', last_name) 
        FROM
            customer AS c
        WHERE
            r.customer_id = c.customer_id) as customer_name
FROM
    rental AS r
GROUP BY r.customer_id;
-- using join
SELECT 
    first_name, last_name, SUM(rental_id)
FROM
    customer AS c
        JOIN
    rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

-- 8. List the customers who have made more rentals than the average number of rentals made by all
-- customers.
SELECT 
    CONCAT(first_name, ' ', last_name) AS customers
FROM
    customer
WHERE
    customer_id IN (SELECT 
            customer_id
        FROM
            rental
        GROUP BY customer_id
        HAVING COUNT(*) > (SELECT 
                AVG(rentals)
            FROM
                (SELECT 
                    COUNT(rental_id) AS rentals
                FROM
                    rental
                GROUP BY customer_id) AS rental_counts));
	-- 9. Display the customer first name, last name, and email along with the names of other customers living in
-- the same city.
select c1.first_name,c1.last_name,c1.email,c2.first_name,c2.last_name 
from customer as c1 join address as a1 on c1.address_id=a1.address_id 
join city as ci on a1.city_id=ci.city_id 
join address as a2 on a2.city_id=ci.city_id 
join customer as c2 on c2.address_id=a2.address_id 
where c1.customer_id<>c2.customer_id;

-- 10. Retrieve the film titles with a rental rate higher than the average rental rate of films in the same category.
SELECT 
    title
FROM
    film AS f1
WHERE
    rental_rate > (SELECT 
            AVG(rental_rate)
        FROM
            film AS f2
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film_category AS fc
                WHERE
                    category_id IN (SELECT 
                            category_id
                        FROM
                            film_category
                        WHERE
                            film_id = f1.film_id)));
-- 11 Retrieve the film titles along with their descriptions and lengths that have a rental rate greater than the
-- average rental rate of films released in the same year.
select title,description,length from film as f1 where rental_rate>(select avg(rental_rate) from film as f2 where f1.release_year=f2.release_year);

-- 12 List the first name, last name, and email of customers who have rented at least one film in the
-- 'Documentary' category.
SELECT 
    first_name, last_name, email
FROM
    customer
WHERE
    customer_id IN (SELECT 
            customer_id
        FROM
            rental
        WHERE
            inventory_id IN (SELECT 
                    inventory_id
                FROM
                    inventory
                WHERE
                    film_id IN (SELECT 
                            film_id
                        FROM
                            film
                        WHERE
                            film_id IN (SELECT 
                                    film_id
                                FROM
                                    film_category
                                WHERE
                                    category_id IN (SELECT 
                                            category_id
                                        FROM
                                            category
                                        WHERE
                                            name = 'Documentary')))));

-- 13 Show the title, rental rate, and difference from the average rental rate for each film.
select title,rental_rate,rental_rate-avg_rental_rate as difference from film,(select avg(rental_rate) as avg_rental_rate from film)as average;

-- 14 Retrieve the titles of films that have never been rented.
-- using subquey
select title from film where film_id in (select film_id from inventory where inventory_id not in (select inventory_id from rental));
-- using join
select distinct title from film as f join inventory as i on f.film_id=i.film_id left join rental as r on i.inventory_id=r.inventory_id where r.inventory_id is NULL;

-- 15 List the titles of films whose rental rate is higher than the average rental rate of films released in the same
-- year and belong to the 'Sci-Fi' category.
SELECT 
    title
FROM
    film AS f1
WHERE
    rental_rate > (SELECT 
            AVG(rental_rate)
        FROM
            film AS f2
        WHERE
            f1.release_year = f2.release_year
                AND film_id IN (SELECT 
                    film_id
                FROM
                    film_category
                WHERE
                    category_id IN (SELECT 
                            category_id
                        FROM
                            category
                        WHERE
                            name = 'Sci-Fi')));
-- 16. Find the number of films rented by each customer, excluding customers who have rented fewer than five
-- films.
select customer_id,count(rental_id) as no_of_films_rented from rental where (select count(customer_id)<5) and customer_id in (select customer_id from customer) group by customer_id;

 