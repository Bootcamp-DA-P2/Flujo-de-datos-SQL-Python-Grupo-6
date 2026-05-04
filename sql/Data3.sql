Use sakila;
SELECT 
    f.film_id,
    f.title AS titulo_pelicula,
    a.actor_id,
    CONCAT(LOWER(a.first_name), ' ', LOWER(a.last_name)) AS actor_full_name,
    -- Conteo de actores en esta película específica
    (SELECT COUNT(*) 
     FROM film_actor fa2 
     WHERE fa2.film_id = f.film_id) AS total_actores_en_pelicula,
    -- Conteo de películas en las que participa este actor
    (SELECT COUNT(*) 
     FROM film_actor fa3 
     WHERE fa3.actor_id = a.actor_id) AS total_peliculas_del_actor
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
INNER JOIN actor a ON fa.actor_id = a.actor_id
ORDER BY f.title ASC;