with raw_products as(
    select * from {{source ('shop','products')}}
)
select
ProductID,
Product,
Category,
Segment
from raw_products