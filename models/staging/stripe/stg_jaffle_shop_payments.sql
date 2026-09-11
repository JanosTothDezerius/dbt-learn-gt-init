select
    ID as payment_id,
    ORDERID as order_id,
    PAYMENTMETHOD as payment_method,
    STATUS as status,
    AMOUNT / 100.0 as amount, -- stored in cents, convert to dollars
    CREATED as created_at

from {{source('stripe', 'payments')}}