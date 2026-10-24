-- Запрет операций по счёту, у которого нет действующей карты.
-- Запрет отрицательного баланса сделан ограничением chk_accounts_balance
-- (см. 01_schema/02_constraints.sql), отдельный триггер для него не нужен.
CREATE OR REPLACE TRIGGER trg_check_card_status
BEFORE INSERT ON transactions
FOR EACH ROW
DECLARE
    v_cards  NUMBER;
    v_active NUMBER;
BEGIN
    SELECT COUNT(*),
           COUNT(CASE WHEN status = 'Активна'
                       AND expiry_date >= TRUNC(SYSDATE) THEN 1 END)
    INTO   v_cards, v_active
    FROM   cards
    WHERE  account_id = :NEW.account_id;

    IF v_cards > 0 AND v_active = 0 THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Операция запрещена: по счёту ' || :NEW.account_id ||
            ' нет действующей карты');
    END IF;
END trg_check_card_status;
/
