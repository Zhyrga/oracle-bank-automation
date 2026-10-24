-- Качество данных: поиск проблем (карта считается просроченной, если срок < сегодня)
---Найти проблемы: 1) карты с истёкшим сроком, но статусом «Активна», 2) клиенты без счетов или карт.
-- 1)
select * from cards
where status = 'Активна' and expiry_date < TRUNC(SYSDATE)
order by card_id;

-- 2) 
select c.customer_id,
    c.full_name
from customers c
where not exists (
    select 1 from accounts a
    where a.customer_id = c.customer_id
) or not exists (
    select 1 from accounts a
    join cards cr on cr.account_id = a.account_id 
    where a.customer_id = c.customer_id 
)
order by c.customer_id;
