{{
    config(
        store_failures = true
    )    
}}

select
    sum(amount) as total_amount
from {{ ref("fct_orders") }}
having sum(amount) < 0