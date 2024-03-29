WITH fct_sales AS (
    SELECT 
        CustomerID,
        ProductID,
        {{ dbt_utils.generate_surrogate_key(['Date']) }} AS date_id,
        {{ dbt_utils.generate_surrogate_key(['Date','CustomerID','ProductID','Product','CampaignID']) }} as sales_id,
        UnitCost,  
        UnitPrice, 
        CampaignID
    FROM SHOP.RAW.SHOP
)

SELECT  DISTINCT
    fs.sales_id,
    c.CustomerID,
    p.ProductID,
    d.date_id,
    fs.UnitCost AS unit_cost, 
    fs.UnitPrice AS unit_price, 
    fs.CampaignID
FROM fct_sales fs
INNER JOIN {{ ref('dim_dates') }} d ON fs.date_id = d.date_id
INNER JOIN {{ ref('dim_products') }} p ON fs.ProductID = p.ProductID
INNER JOIN {{ ref('dim_customers') }} c ON fs.CustomerID = c.CustomerID

