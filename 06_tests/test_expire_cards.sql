-- Тест expire_cards: просроченная «Активна» карта должна стать «Истекла»,
-- а в card_status_log должна появиться новая строка.
-- expire_cards делает COMMIT, поэтому ROLLBACK не поможет: данные возвращаются вручную.
SET SERVEROUTPUT ON
DECLARE
    v_card_id    CONSTANT NUMBER := 1;   -- подставьте существующий card_id
    v_old_status cards.status%TYPE;
    v_old_expiry cards.expiry_date%TYPE;
    v_new_status cards.status%TYPE;
    v_log_before NUMBER;
    v_log_after  NUMBER;
BEGIN
    SELECT status, expiry_date INTO v_old_status, v_old_expiry
    FROM   cards WHERE card_id = v_card_id;
    SELECT COUNT(*) INTO v_log_before FROM card_status_log;

    UPDATE cards
    SET    status = 'Активна', expiry_date = TRUNC(SYSDATE) - 1
    WHERE  card_id = v_card_id;
    COMMIT;

    expire_cards;

    SELECT status INTO v_new_status FROM cards WHERE card_id = v_card_id;
    SELECT COUNT(*) INTO v_log_after FROM card_status_log;

    DBMS_OUTPUT.PUT_LINE(CASE WHEN v_new_status = 'Истекла'
        THEN 'PASS: карта стала Истекла'
        ELSE 'FAIL: статус карты = ' || v_new_status END);
    DBMS_OUTPUT.PUT_LINE(CASE WHEN v_log_after = v_log_before + 1
        THEN 'PASS: в логе новая строка'
        ELSE 'FAIL: новой строки в логе нет' END);

    -- возвращаем карту как было
    UPDATE cards SET status = v_old_status, expiry_date = v_old_expiry
    WHERE  card_id = v_card_id;
    COMMIT;
END;
/
