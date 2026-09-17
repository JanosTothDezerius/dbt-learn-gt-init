{{ config(enabled = false) }}

select
    customer_id,
    avg(amount) as average_amount
from {{ ref("fct_orders") }}
group by customer_id
having count(customer_id) > 1 and avg(amount) < 1