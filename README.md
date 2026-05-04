

# 📈 Dataframe 1: Actividad de Clientes - Limpieza y Transformación

Este módulo documenta el proceso de limpieza del **Dataframe 1**, centrado en la actividad de los clientes. El proceso se basa estrictamente en la eliminación de inconsistencias transaccionales y la estandarización de datos de la base de datos **Sakila**.

## 📋 Proceso de Limpieza Basado en Reglas SQL

Para este conjunto de datos, se ejecutó un protocolo de limpieza diseñado para eliminar registros inválidos y asegurar la coherencia de los datosa:

### 1. Limpieza de Registros Nulos y Valores Inválidos
*   **Eliminación de Nulos:** Se filtraron todos los registros con `rental_id` o `payment_id` inexistentes para asegurar la integridad de la transacción.
*   **Validación de Montos:** Se aplicó el filtro `amount > 0` en la tabla `payment` para excluir transacciones fallidas o registros sin valor comercial.
*   **Alquileres Completados:** Se filtraron exclusivamente los registros donde `rental.return_date` no es nula, garantizando que solo analizamos ciclos de alquiler terminados.

### 2. Consistencia Lógica y Fechas
*   **Validación Temporal:** Se aseguró que la fecha de alquiler fuera siempre anterior a la de devolución (`rental_date < return_date`), eliminando posibles errores de entrada de datos.
*   **Cálculo de Duración:** Se creó la columna derivada `rental_duration` mediante `DATEDIFF` para cuantificar la duración real en días del préstamo.

### 3. Estandarización de Textos
*   **Normalización con LOWER():** Para evitar duplicados y mejorar la calidad de los datos, se transformaron a minúsculas los campos de nombres, apellidos, emails y ciudades.

---

## 🛠️ Consulta SQL de Limpieza y Extracción
*Realizada por M. Ángel Moreno*

# 🎬 Dataframe 2: Catálogo de Películas - Limpieza y Transformación

Este módulo documenta el proceso de limpieza, normalización y enriquecimiento del **Dataframe 2**, el cual consolida la información técnica, categorización y disponibilidad de inventario del catálogo de **Sakila**.

## 📋 Proceso de Limpieza Basado en Reglas SQL

El objetivo de esta etapa fue garantizar un catálogo libre de errores de duración y asegurar que la clasificación de las películas fuera consistente para el análisis estadístico.

### 1. Normalización de Cadenas y Textos
*   **Limpieza de Títulos y Descripciones:** Se utilizaron de forma combinada `LOWER()` y `TRIM()` para eliminar espacios innecesarios en los extremos y estandarizar todo el texto a minúsculas.
*   **Categorías y Lenguaje:** Se unificaron los nombres de los géneros y los idiomas para mantener una estética coherente en el reporte final.

### 2. Filtros de Integridad y Calidad
*   **Validación de Duración:** Se aplicó el filtro `length > 0` para eliminar registros con duraciones imposibles o errores de carga.
*   **Consistencia de Clasificación:** Se eliminaron registros con `rating` nulo y se aseguró la integridad básica verificando que el título no fuera nulo.
*   **Verificación de Categorías:** Mediante `LEFT JOIN` con `film_category`, se aseguró que la relación entre films y sus géneros fuera procesada correctamente.

### 3. Columnas Derivadas y Agrupaciones
*   **Clasificación de Metraje (`is_long_film`):** Se implementó una lógica de `CASE WHEN` para marcar con un indicador binario (1 o 0) aquellas películas con una duración igual o superior a 120 minutos.
*   **Disponibilidad en Inventario:** Se integró una subconsulta para obtener el `inventory_count` en tiempo real por cada película, permitiendo conocer el volumen de copias disponibles.

---

## 🛠️ Consulta SQL de Limpieza y Extracción
```sql
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
    -- Columna derivada: Identificación de películas largas
    CASE WHEN f.length >= 120 THEN 1 ELSE 0 END AS is_long_film,
    -- Agrupación: Conteo de copias en inventario
    (SELECT COUNT(*) FROM inventory i WHERE i.film_id = f.film_id) AS inventory_count
FROM film f
INNER JOIN language l ON f.language_id = l.language_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category cat ON fc.category_id = cat.category_id
WHERE 
    f.length > 0               -- Filtro de duraciones válidas
    AND f.rating IS NOT NULL    -- Filtro de integridad en rating
    AND f.title IS NOT NULL;    -- Garantía de presencia de título

## 🛠️ Consulta SQL de Limpieza y Extracción
*Realizada por M. Ángel Moreno*

# 🎞️ Dataframe 3: Elenco y Popularidad - Limpieza y Transformación

Este apartado detalla el proceso de limpieza y consolidación de datos para el análisis de los actores y su impacto en el catálogo de películas de **Sakila**.

## 📋 Proceso de Limpieza (SQL)

Se aplicó una estrategia de limpieza directa en MySQL para asegurar que el dataframe final sea consistente y no requiera pre-procesamiento adicional.

### 1. Estandarización y Columnas Derivadas
*   **Normalización:** Se aplicó `LOWER()` a los campos `first_name` y `last_name` para evitar duplicidades por diferencias de capitalización.
*   **Columna Derivada:** Se generó la columna `actor_full_name` utilizando `CONCAT()` para unificar la identidad del actor.

### 2. Integridad y Filtros
*   **Joins Consistentes:** Se utilizaron `INNER JOIN` entre `film`, `film_actor` y `actor` para garantizar que el dataframe solo contenga registros con integridad referencial completa.
*   **Limpieza de Huérfanos:** Se filtraron automáticamente todas las películas que no cuentan con actores asociados en la tabla intermedia.

### 3. Agregaciones de Popularidad
Se integraron subconsultas para calcular métricas clave de volumen:
*   **Densidad de elenco:** Total de actores por película.
*   **Frecuencia de actor:** Total de películas en las que ha participado cada actor.

---

## 🛠️ Consulta SQL Consolidada
```sql
SELECT 
    f.film_id,
    f.title AS titulo_pelicula,
    a.actor_id,
    CONCAT(LOWER(a.first_name), ' ', LOWER(a.last_name)) AS actor_full_name,
    -- Número de actores por película (Agregación)
    (SELECT COUNT(*) 
     FROM film_actor fa2 
     WHERE fa2.film_id = f.film_id) AS total_actores_pelicula,
    -- Número de películas por actor (Popularidad)
    (SELECT COUNT(*) 
     FROM film_actor fa3 
     WHERE fa3.actor_id = a.actor_id) AS total_peliculas_actor
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
INNER JOIN actor a ON fa.actor_id = a.actor_id
ORDER BY f.title ASC;

## 🛠️ Consulta SQL de Limpieza y Extracción
*Realizada por M. Ángel Moreno*
