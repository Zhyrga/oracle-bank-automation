---v_monthly_turnover: оборот по месяцам и типам операций.
create or replace view v_monthly_turnover as 
select to_char(transaction_date, 'YYYY-MM') as month_number,
    transaction_type,
    sum(amount) as volume
from transactions
group by 
    to_char(transaction_date, 'YYYY-MM'),
    transaction_type
order by to_char(transaction_date, 'YYYY-MM');

--Проверка
select sum(amount)
from transactions;

select sum(volume) from v_monthly_turnover;
