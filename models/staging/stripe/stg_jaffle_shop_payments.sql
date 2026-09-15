select
    ID as payment_id,
    ORDERID as order_id,
    PAYMENTMETHOD as payment_method,
    STATUS as status,
    {{ cents_to_dollars("AMOUNT") }} as amount, -- stored in cents, convert to dollars
    CREATED as created_at

from {{source('stripe', 'payments')}}