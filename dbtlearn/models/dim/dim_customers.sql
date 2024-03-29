WITH src_customers AS (
    SELECT 
        *
    FROM {{ ref("src_customers") }}
)
SELECT  
    CustomerID,
    NVL(EmailName, 'Anonymous') AS EMAIL,
    NVL(District, 'Anonymous') AS District,
    NVL(City, 'Anonymous') AS City,
    NVL(State, 'Anonymous') AS State,
    NVL(Region, 'Anonymous') AS Region,
    NVL(Country, 'Anonymous') AS Country,
    ZipCode,
    TIMESTAMP_COLUMN  
FROM src_customers 
{% if is_incremental() %}
WHERE TIMESTAMP_COLUMN > (SELECT MAX(TIMESTAMP_COLUMN) FROM src_customers)
{% endif %}
