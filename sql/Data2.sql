USE sakila;
SELECT 
        f.film_id,
        LOWER(TRIM(f.title)) AS title,
        LOWER(TRIM(f.description)) AS description,
        f.release_year,
        LOWER(l.name) AS language,
        LOWER(cat.name) AS category,
        f.length,
        f.rating,
        -- Columna derivada: Película larga
        CASE WHEN f.length >= 120 THEN 1 ELSE 0 END AS is_long_film,
        -- Conteo de copias en inventario (Agrupación útil)
        (SELECT COUNT(*) FROM inventory i WHERE i.film_id = f.film_id) AS inventory_count
    FROM film f
    INNER JOIN language l ON f.language_id = l.language_id
    LEFT JOIN film_category fc ON f.film_id = fc.film_id
    LEFT JOIN category cat ON fc.category_id = cat.category_id
    WHERE 
        f.length > 0              -- Eliminar duraciones <= 0
        AND f.rating IS NOT NULL   -- Eliminar ratings nulos
        AND f.title IS NOT NULL;   -- Integridad básica