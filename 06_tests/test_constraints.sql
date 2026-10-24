-- Негативные тесты ограничений: каждая вставка должна упасть (PASS).
-- Значения в INSERT зависят от данных (например, телефон из таблицы customers).
SET SERVEROUTPUT ON

    create or replace PROCEDURE expect_error(p_label IN VARCHAR2, p_sql IN VARCHAR2) AS
    BEGIN
        EXECUTE IMMEDIATE p_sql;
        DBMS_OUTPUT.PUT_LINE('FAIL (вставка прошла, а не должна): ' || p_label);
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('PASS: ' || p_label || ' -> ' || SQLERRM);
    END expect_error;
    /

    BEGIN
    expect_error('отрицательная сумма транзакции',
        q'[INSERT INTO transactions VALUES (9001, 1001, 'Пополнение', -100, SYSDATE)]');
    expect_error('неизвестный тип транзакции',
        q'[INSERT INTO transactions VALUES (9002, 1001, 'Обмен', 100, SYSDATE)]');
    expect_error('неизвестный тип счёта',
        q'[INSERT INTO accounts VALUES (9001, 1, 1, 'Депозит', 100, SYSDATE)]');
    expect_error('отрицательный баланс',
        q'[INSERT INTO accounts VALUES (9002, 1, 1, 'Текущий', -1, SYSDATE)]');
    expect_error('неизвестный статус карты',
        q'[INSERT INTO cards VALUES (9001, 1001, 'Visa Debit', SYSDATE + 365, 'Утеряна')]');
    expect_error('неизвестный статус кредита',
        q'[INSERT INTO loans VALUES (9001, 1, 1000, 10, 'Отменён', SYSDATE)]');
    expect_error('дубликат телефона',
        q'[INSERT INTO customers VALUES (9001, 'Тест Тестов', DATE '1990-01-01', 'Бишкек', '+996700111001')]');
    expect_error('пустое имя клиента',
        q'[INSERT INTO customers VALUES (9002, NULL, DATE '1990-01-01', 'Бишкек', '+996700999999')]');
END;
/
