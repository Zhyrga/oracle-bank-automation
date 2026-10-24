-- Ограничения: NOT NULL, UNIQUE, CHECK (типы, статусы, суммы).
-- Процедура run_ddl выполняет команду и пропускает её, если ограничение уже есть.
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE run_ddl(p_sql IN VARCHAR2) AS
BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK:   ' || p_sql);
EXCEPTION
    WHEN OTHERS THEN
        -- 1442: колонка уже NOT NULL; 2261: такой UNIQUE уже есть;
        -- 2264: имя ограничения уже занято
        IF SQLCODE IN (-1442, -2261, -2264) THEN
            DBMS_OUTPUT.PUT_LINE('SKIP: ' || p_sql);
        ELSE
            RAISE;
        END IF;
END run_ddl;
/

BEGIN
    -- NOT NULL (customers.city оставляем необязательным)
    run_ddl('ALTER TABLE branches     MODIFY (branch_name       NOT NULL)');
    run_ddl('ALTER TABLE branches     MODIFY (city              NOT NULL)');
    run_ddl('ALTER TABLE customers    MODIFY (full_name         NOT NULL)');
    run_ddl('ALTER TABLE customers    MODIFY (birth_date        NOT NULL)');
    run_ddl('ALTER TABLE customers    MODIFY (phone             NOT NULL)');
    run_ddl('ALTER TABLE accounts     MODIFY (customer_id       NOT NULL)');
    run_ddl('ALTER TABLE accounts     MODIFY (branch_id         NOT NULL)');
    run_ddl('ALTER TABLE accounts     MODIFY (account_type      NOT NULL)');
    run_ddl('ALTER TABLE accounts     MODIFY (balance           NOT NULL)');
    run_ddl('ALTER TABLE accounts     MODIFY (open_date         NOT NULL)');
    run_ddl('ALTER TABLE cards        MODIFY (account_id        NOT NULL)');
    run_ddl('ALTER TABLE cards        MODIFY (card_type         NOT NULL)');
    run_ddl('ALTER TABLE cards        MODIFY (expiry_date       NOT NULL)');
    run_ddl('ALTER TABLE cards        MODIFY (status            NOT NULL)');
    run_ddl('ALTER TABLE transactions MODIFY (account_id        NOT NULL)');
    run_ddl('ALTER TABLE transactions MODIFY (transaction_type  NOT NULL)');
    run_ddl('ALTER TABLE transactions MODIFY (amount            NOT NULL)');
    run_ddl('ALTER TABLE transactions MODIFY (transaction_date  NOT NULL)');
    run_ddl('ALTER TABLE loans        MODIFY (customer_id       NOT NULL)');
    run_ddl('ALTER TABLE loans        MODIFY (amount            NOT NULL)');
    run_ddl('ALTER TABLE loans        MODIFY (interest_rate     NOT NULL)');
    run_ddl('ALTER TABLE loans        MODIFY (status            NOT NULL)');
    run_ddl('ALTER TABLE loans        MODIFY (issue_date        NOT NULL)');
 
    -- UNIQUE
    run_ddl('ALTER TABLE customers ADD CONSTRAINT uq_customers_phone UNIQUE (phone)');
    -- CHECK: типы и статусы
    run_ddl(q'[ALTER TABLE accounts ADD CONSTRAINT chk_accounts_type
               CHECK (account_type IN ('Текущий', 'Сберегательный'))]');
    run_ddl(q'[ALTER TABLE cards ADD CONSTRAINT chk_cards_type
               CHECK (card_type IN ('Visa Debit', 'Visa Credit', 'MasterCard Debit', 'MasterCard Credit'))]');
    run_ddl(q'[ALTER TABLE cards ADD CONSTRAINT chk_cards_status
               CHECK (status IN ('Активна', 'Заблокирована', 'Истекла'))]');
    run_ddl(q'[ALTER TABLE transactions ADD CONSTRAINT chk_trn_type
               CHECK (transaction_type IN ('Пополнение', 'Снятие', 'Перевод'))]');
    run_ddl(q'[ALTER TABLE loans ADD CONSTRAINT chk_loans_status
               CHECK (status IN ('Активен', 'Закрыт', 'Просрочен'))]');
 
    -- CHECK: числовые значения
    run_ddl('ALTER TABLE accounts     ADD CONSTRAINT chk_accounts_balance CHECK (balance >= 0)');
    run_ddl('ALTER TABLE transactions ADD CONSTRAINT chk_trn_amount       CHECK (amount > 0)');
    run_ddl('ALTER TABLE loans        ADD CONSTRAINT chk_loans_amount     CHECK (amount > 0)');
    run_ddl('ALTER TABLE loans        ADD CONSTRAINT chk_loans_rate       CHECK (interest_rate BETWEEN 0 AND 100)');
END;
/
-- 4. Проверка: какие ограничения теперь есть
-- ---------------------------------------------------------------------
SELECT table_name, constraint_name, constraint_type, search_condition
FROM   user_constraints
WHERE  table_name IN ('BRANCHES', 'CUSTOMERS', 'ACCOUNTS', 'CARDS', 'TRANSACTIONS', 'LOANS')
  AND  constraint_type IN ('C', 'U')
ORDER  BY table_name, constraint_type, constraint_name;
