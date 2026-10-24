-- Пакет bank_pkg: deposit, withdraw, transfer, apply_interest, get_customer_balance
CREATE OR REPLACE PACKAGE bank_pkg AS
 
    e_insufficient_funds EXCEPTION;   -- не хватает денег на счёте
    e_invalid_amount     EXCEPTION;   -- сумма <= 0, пустая или с лишними знаками
    e_account_not_found  EXCEPTION;   -- такого счёта нет
    e_transfer_to_yourself EXCEPTION;   -- перевод себе (на свой счет) 
    e_customer_not_found EXCEPTION;   -- такого клиента нет
    PRAGMA EXCEPTION_INIT(e_insufficient_funds, -20001);
    PRAGMA EXCEPTION_INIT(e_invalid_amount,     -20002);
    PRAGMA EXCEPTION_INIT(e_account_not_found,  -20003);
    PRAGMA EXCEPTION_INIT(e_transfer_to_yourself, -20004);
    PRAGMA EXCEPTION_INIT(e_customer_not_found, -20005);
 
    PROCEDURE deposit  (p_account_id IN NUMBER, p_amount IN NUMBER);
    PROCEDURE withdraw (p_account_id IN NUMBER, p_amount IN NUMBER);
    PROCEDURE transfer (p_from_acc in NUMBER, p_to_acc in NUMBER, p_amount in NUMBER);
    PROCEDURE apply_interest (p_account_id in NUMBER, p_rate in NUMBER);
    FUNCTION get_customer_balance (p_customer_id number) return NUMBER;

END bank_pkg;
/
 
CREATE OR REPLACE PACKAGE BODY bank_pkg AS
 
    -- Внутренняя проверка суммы (снаружи не видна)
    PROCEDURE check_amount(p_amount IN NUMBER) IS
    BEGIN
        IF p_amount IS NULL
           OR p_amount <= 0
           OR p_amount <> ROUND(p_amount, 2) THEN
            RAISE_APPLICATION_ERROR(-20002,
                'Сумма должна быть больше нуля и иметь не более двух знаков после запятой');
        END IF;
    END check_amount;
 
 ---------------------------------------------------------------------------
    -- Пополнение: баланс растёт, в transactions добавляется "Пополнение"
    PROCEDURE deposit(p_account_id IN NUMBER, p_amount IN NUMBER) IS
    BEGIN
        SAVEPOINT sp_deposit;

        check_amount(p_amount);
 
        UPDATE accounts
        SET    balance = balance + p_amount
        WHERE  account_id = p_account_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Счёт ' || p_account_id || ' не найден');
        END IF;
 
        INSERT INTO transactions (account_id, transaction_type, amount, transaction_date)
        VALUES (p_account_id, 'Пополнение', p_amount, SYSDATE);

    EXCEPTION 
        WHEN OTHERS THEN
        ROLLBACK to sp_deposit;
            RAISE; -- поднимает ошибку на вверх    
    END deposit;
 
 -------------------------------------------------------------------------------
    -- Снятие: сначала проверки, потом изменения
    PROCEDURE withdraw(p_account_id IN NUMBER, p_amount IN NUMBER) IS
        v_balance accounts.balance%TYPE;
    BEGIN
        SAVEPOINT sp_withdraw;

        check_amount(p_amount);
 
        BEGIN
            SELECT balance
            INTO   v_balance
            FROM   accounts
            WHERE  account_id = p_account_id
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20003, 'Счёт ' || p_account_id || ' не найден');
        END;
 
        IF v_balance < p_amount THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Недостаточно средств на счёте ' || p_account_id ||
                ': баланс ' || v_balance || ', запрошено ' || p_amount);
        END IF;
 
        UPDATE accounts
        SET    balance = balance - p_amount
        WHERE  account_id = p_account_id;
 
        INSERT INTO transactions (account_id, transaction_type, amount, transaction_date)
        VALUES (p_account_id, 'Снятие', p_amount, SYSDATE);

        EXCEPTION 
        WHEN OTHERS THEN
        ROLLBACK to sp_withdraw;
            RAISE;
    END withdraw;

----------------------------------------------------------------------------- 
    PROCEDURE transfer (p_from_acc in NUMBER, p_to_acc in NUMBER, p_amount in NUMBER) AS
    v_balance accounts.balance%TYPE;
BEGIN
    SAVEPOINT sp_transfer;

    check_amount(p_amount);

IF p_from_acc is NULL
 OR p_to_acc is NULL THEN 
    RAISE_APPLICATION_ERROR(-20003, 'Счет не найден, проверьте ID отправителя или получателя');
end if;

if p_from_acc = p_to_acc THEN
    RAISE_APPLICATION_ERROR(-20004, 'Нельзя переводить на тот же счет');
end if;

-- блокируем счёт отправителя и читаем баланс
BEGIN
SELECT balance
            INTO   v_balance
            FROM   accounts
            WHERE  account_id = p_from_acc
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20003, 'Счёт ' || p_from_acc || ' не найден');
        END;
 
        IF v_balance < p_amount THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Недостаточно средств на счёте ' || p_from_acc ||
                ': баланс ' || v_balance || ', запрошено ' || p_amount);
        END IF;

UPDATE accounts 
SET balance = balance - p_amount 
where account_id = p_from_acc;

UPDATE accounts 
SET balance = balance + p_amount 
where account_id = p_to_acc;

IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Счет ' || p_to_acc || ' не найден');
END IF;

-- одна строка "Перевод" по счёту отправителя
insert into transactions (account_id, transaction_type, amount, transaction_date)
values (p_from_acc, 'Перевод', p_amount, SYSDATE);

EXCEPTION 
    WHEN OTHERS THEN
    ROLLBACK TO sp_transfer;
    RAISE;

end transfer;

---------------------------------------------------------------------------
PROCEDURE apply_interest (p_account_id in NUMBER, p_rate in NUMBER)
AS
    BEGIN
        SAVEPOINT sp_interest;

IF p_rate is null or p_rate <= 0 THEN
RAISE_APPLICATION_ERROR(-20002, 'Ставка должна быть больше нуля');
end IF;

        update accounts
        set balance = ROUND(balance * (1 + p_rate/100),2) -- 2 знака
        where account_id = p_account_id;

IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Счет ' || p_account_id || ' не найден');
end IF;

EXCEPTION 
        WHEN OTHERS THEN
        ROLLBACK to sp_interest;
            RAISE;

end apply_interest; -- в транзакции не пишется потому, что нету подходящего типа операции.

-----------------------------------------------------------------------
FUNCTION get_customer_balance (p_customer_id IN NUMBER) RETURN NUMBER IS
    v_exists  NUMBER;
    v_balance NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM   customers
    WHERE  customer_id = p_customer_id;

    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Клиент ' || p_customer_id || ' не найден');
    END IF;

    SELECT NVL(SUM(balance), 0)
    INTO   v_balance
    FROM   accounts
    WHERE  customer_id = p_customer_id;

    RETURN v_balance;
END get_customer_balance;

END bank_pkg;
/
