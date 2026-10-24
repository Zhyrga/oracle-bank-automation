---v_customer_360: клиент, счета, карты, кредиты, общий баланс.

CREATE OR REPLACE VIEW v_customer_360 AS
WITH acc AS (
    -- счета: количество и общий баланс по клиенту
    SELECT customer_id,
           COUNT(*)     AS total_accounts,
           SUM(balance) AS total_balance
    FROM   accounts
    GROUP  BY customer_id
),
crd AS (
    -- карты: привязаны к счетам, поэтому customer_id берём из accounts
    SELECT a.customer_id,
           COUNT(*) AS total_cards
    FROM   cards cr
    JOIN   accounts a ON a.account_id = cr.account_id
    GROUP  BY a.customer_id
),
lns AS (
    -- кредиты: количество по клиенту
    SELECT customer_id,
           COUNT(*) AS total_loans
    FROM   loans
    GROUP  BY customer_id
)
SELECT c.customer_id,
       c.full_name,
       c.phone,
       NVL(acc.total_accounts, 0) AS total_accounts,
       NVL(crd.total_cards,    0) AS total_cards,
       NVL(lns.total_loans,    0) AS total_loans,
       NVL(acc.total_balance,  0) AS total_balance
FROM   customers c
LEFT JOIN acc ON acc.customer_id = c.customer_id
LEFT JOIN crd ON crd.customer_id = c.customer_id
LEFT JOIN lns ON lns.customer_id = c.customer_id;
 
 -- Проверка

 SELECT * FROM v_customer_360 ORDER BY customer_id;


 SELECT (SELECT COUNT(*)     FROM v_customer_360)                  AS customers_in_view,   -- 20
       (SELECT SUM(total_accounts) FROM v_customer_360)           AS accounts_in_view,    -- 25
       (SELECT SUM(total_cards)    FROM v_customer_360)           AS cards_in_view,       -- 15
       (SELECT SUM(total_loans)    FROM v_customer_360)           AS loans_in_view,       -- 15
       (SELECT SUM(total_balance)  FROM v_customer_360)           AS balance_in_view,
       (SELECT SUM(balance)        FROM accounts)                 AS balance_in_accounts  -- должно совпасть
FROM   dual;
