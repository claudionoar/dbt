with customers as (
    select * from {{ ref('stg_customers') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix as zip_code_prefix,
    cidade as cidade,
    estado as estado
from customers
