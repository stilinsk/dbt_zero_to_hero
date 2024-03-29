with raw_dates as(
    select * from {{source ('shop','dates')}}
)
select
Date

from raw_dates