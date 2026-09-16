WITH paid_orders as (
    select 
        o.ID as order_id,
        o.USER_ID as customer_id,
        o.ORDER_DATE as order_placed_at,
        o.STATUS as order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        c.FIRST_NAME as customer_first_name,
        c.LAST_NAME as customer_last_name
    from raw.orders o
    left join (
        select 
            ORDERID as order_id, 
            max(CREATED) as payment_finalized_date, 
            sum(AMOUNT) / 100.0 as total_amount_paid
        from raw.payments
        where STATUS <> 'fail'
        group by ORDERID
    ) p on o.ID = p.order_id
    left join raw.customers c on o.USER_ID = c.ID
),

customer_orders as (
    select 
        c.ID as customer_id,
        min(o.ORDER_DATE) as first_order_date,
        max(o.ORDER_DATE) as most_recent_order_date,
        count(o.ID) as number_of_orders
    from raw.customers c 
    left join raw.orders o on o.USER_ID = c.ID 
    group by c.ID
)

select
    p.*,
    ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
    ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.order_id) as customer_sales_seq,
    CASE WHEN c.first_order_date = p.order_placed_at
    THEN 'new'
    ELSE 'return' END as nvsr,
    x.clv_bad as customer_lifetime_value,
    c.first_order_date as fdos
from paid_orders p
left join customer_orders c on p.customer_id = c.customer_id
left join (
    select
        p2.order_id,
        sum(t2.total_amount_paid) as clv_bad
    from paid_orders p2
    left join paid_orders t2 on p2.customer_id = t2.customer_id and p2.order_id >= t2.order_id
    group by p2.order_id
) x on x.order_id = p.order_id