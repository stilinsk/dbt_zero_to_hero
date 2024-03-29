with src_products as (
   SELECT 
        *
    
    
     from {{ ref("src_products") }}
)
select 
   ProductID,
    NVL(Product, 'Anonymous') AS Product,
    NVL(Category, 'Anonymous') AS Category,
    NVL(Segment, 'Anonymous') AS Segment
   
FROM src_products


