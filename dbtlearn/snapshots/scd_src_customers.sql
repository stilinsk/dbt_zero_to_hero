{% snapshot scd_src_customers %}

{{
   config(
       target_schema='DEV',
       unique_key='CustomerID',
       strategy='timestamp',
       updated_at='TIMESTAMP_COLUMN',
       invalidate_hard_deletes=True
   )
}}

select * FROM {{ source('shop', 'customers') }}

{% endsnapshot %}