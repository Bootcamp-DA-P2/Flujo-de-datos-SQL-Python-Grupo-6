-- Dataframe 1: Actividad de clientes realizazada por M. Ángel Moreno

-- Uso de la base de datos sakila para obtener información sobre la actividad de los clientes, 
-- incluyendo detalles de alquileres y pagos, con limpieza y estandarización de datos.
use sakila;

-- Creación del dataframe con las columnas solicitadas, aplicando limpieza y estandarización
SELECT 
    -- Estandarización a minúsculas
    LOWER(c.first_name) AS first_name,
    LOWER(c.last_name) AS last_name,
    LOWER(c.email) AS email,
    LOWER(ci.city) AS city,
    
    -- Datos del alquiler y pago
    r.rental_id,
    r.rental_date,
    r.return_date,
    p.payment_id,
    p.amount,
    
    -- Columna derivada: Duración en días
    DATEDIFF(r.return_date, r.rental_date) AS rental_duration
-- Tabla principal: rental, que contiene la información de los alquileres
FROM rental r

-- Joins definidos por llaves primarias/foráneas
-- Se unen las tablas rental, payment, customer, address y city para obtener toda la información relevante
INNER JOIN payment p ON r.rental_id = p.rental_id
INNER JOIN customer c ON r.customer_id = c.customer_id
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id

-- Filtros de limpieza y consistencia lógica
WHERE 
    -- Filtros de limpieza solicitados
    r.rental_id IS NOT NULL 
    AND p.payment_id IS NOT NULL
    -- Asegurar que el monto del pago sea positivo
    AND p.amount > 0
    AND r.return_date IS NOT NULL
    -- Consistencia lógica de fechas
    AND r.rental_date < r.return_date;