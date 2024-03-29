with raw_customers as (select * from {{source ('shop','customers')}}
)
select 
CustomerID,
EmailName,
City,
State,
Region,
District,
Country,
ZipCode,
TIMESTAMP_COLUMN



from raw_customers


 	 					