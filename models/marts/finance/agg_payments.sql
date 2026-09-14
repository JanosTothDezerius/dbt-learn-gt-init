{% set methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card']%}

with payments as (

    select * from {{ ref('stg_jaffle_shop_payments')}}
    where status = 'success'

),

agg as (

    select
        order_id,

        {%- for method in methods -%}
            {% if not loop.last %}
                sum(case when payment_method = '{{method}}' then amount else 0 end) as {{method}}_amount,
            {%- else -%}
                sum(case when payment_method = '{{method}}' then amount else 0 end) as {{method}}_amount
            {%- endif -%}
        {% endfor %}

    from payments
    group by order_id

)

select * from agg