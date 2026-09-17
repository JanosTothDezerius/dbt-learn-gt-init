{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

with orders as (

    select * from {{ ref('stg_jaffle_shop_orders') }}

),

payments as (

    select * from {{ ref('stg_jaffle_shop_payments') }}

),

order_payments as (
    select
        order_id,
        sum(case when status = 'success' then amount end) as amount

    from payments
    group by order_id
),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        coalesce(order_payments.amount + 1000, 0) as amount

    from orders

    left join order_payments on orders.order_id = order_payments.order_id

)

select * from final
{% if is_incremental() %}
  where final.order_date >= (select max(this.order_date) from {{ this }} as this)
{% endif %}