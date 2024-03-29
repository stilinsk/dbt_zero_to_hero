WITH src_dates AS (
    SELECT 
        *,
        {{ dbt_utils.generate_surrogate_key(['Date']) }} AS date_id
    FROM 
        {{ ref("src_date") }}
    WHERE 
        Date IS NOT NULL -- Filter out rows with null dates
)
SELECT 
    date_id,
    Date,
    TO_DATE(
        CONCAT_WS('-', CAST(EXTRACT(YEAR FROM Date) AS STRING), 
                        CAST(EXTRACT(MONTH FROM Date) AS STRING), 
                        CAST(EXTRACT(DAY FROM Date) AS STRING)
        )
    ) AS sales_date
    
FROM
    src_dates