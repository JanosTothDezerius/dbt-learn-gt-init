with customers as (

    select * from {{ ref("stg_jaffle_shop_customers") }}

),

orders as (

    select * from {{ ref("stg_jaffle_shop_orders") }}

),

payments as (

    select * from {{ ref("stg_jaffle_shop_payments") }}

),

payments_aggregated as (

    select
        order_id,
        sum(amount) as total_amount_paid,
        max(created_at) as payment_finalized_date
    
    from payments
    where status <> 'fail'
    group by order_id

),

orders_aggregated as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        payments_aggregated.total_amount_paid,
        payments_aggregated.payment_finalized_date
    
    from orders
    left join payments_aggregated  
        on orders.order_id = payments_aggregated.order_id

),

customers_aggregated as (

    select
        customers.customer_id,
        customers.first_name as customer_first_name,
        customers.last_name as customer_last_name,
        sum(orders_aggregated.total_amount_paid) as customer_lifetime_value,
        min(orders_aggregated.order_date) as first_order_date

    from customers
    left join orders_aggregated
        on customers.customer_id = orders_aggregated.customer_id
    group by customers.customer_id, customers.first_name, customers.last_name

),

final as (

    select
        orders_aggregated.order_id,
        customers_aggregated.customer_id,
        orders_aggregated.order_date as order_placed_at,
        orders_aggregated.status as order_status,
        orders_aggregated.total_amount_paid,
        orders_aggregated.payment_finalized_date,
        customers_aggregated.customer_first_name,
        customers_aggregated.customer_last_name,
        case
            when customers_aggregated.first_order_date = orders_aggregated.order_date
            then 'new'
            else 'return'
        end as nvsr,
        customers_aggregated.customer_lifetime_value,
        customers_aggregated.first_order_date as fdos

    from orders_aggregated
    left join customers_aggregated
        on orders_aggregated.customer_id = customers_aggregated.customer_id

)

select * from final
order by customer_id, order_id