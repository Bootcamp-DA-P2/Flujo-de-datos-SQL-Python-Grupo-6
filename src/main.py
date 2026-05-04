from sqlalchemy import create_engine, text
from config import *
import pandas as pd



# Create a database connection
def conection_bd():
    """Crear conexión a la base de datos"""
    # 1. Construir la URL de conexión completa
    url_db = f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
    # 2. Crear el objeto 'motor' (engine) usando la URL
    engine = create_engine(url_db)
    return engine.connect()


def test_connection():
    """Probar la conexión a la base de datos"""
    connection = conection_bd()
    try:
        with connection:
            print("Conexión exitosa a la base de datos.")
            result = connection.execute(text("SELECT * FROM actor;"))
            print(result.fetchone())

    except Exception as e:
        print(f"Error al conectar a la base de datos: {e}")
        

def get_data_list_from_join():
    """Obtener datos de la unión de tablas rental, payment, customer, address y city, y exportar a CSV"""
    connection = conection_bd()
    with connection:
        join_query_sql = """ 
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
    AND r.rental_date < r.return_date;"""
    
        result = connection.execute(text(join_query_sql))
        rows = result.fetchall()
        columns = result.keys()

            # 2. Create the Pandas DataFrame
        df = pd.DataFrame(rows, columns=columns)
            
            # --- 3. EXPORTAR A CSV (Paso Nuevo) ---
        df.to_csv(
                "data/dataframe1.csv", # ruta y Nombre del archivo de salida
                index=False, # Evita escribir el índice del DataFrame en el archivo
                encoding='utf-8' # Asegura que caracteres especiales (como acentos) se guarden bien
        )

        print(f"✅ DataFrame successfully created and saved to: {'data/dataframe1.csv'}")

        return df
        
if __name__ == "__main__":
    test_connection()
    get_data_list_from_join()