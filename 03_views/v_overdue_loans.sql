---v_overdue_loans: просроченные кредиты с именем и телефоном клиента.
create or replace view v_overdue_loans as
select c.full_name,
    c.phone,
    l.loan_id,
    l.status
 from customers c
 join loans l on l.customer_id = c.customer_id 
 where l.status = 'Просрочен';

--Проверка
 select * from v_overdue_loans;
