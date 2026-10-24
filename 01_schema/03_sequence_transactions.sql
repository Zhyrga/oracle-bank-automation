-- Автогенерация transaction_id через последовательность (нужен Oracle 12c+).
-- Последовательность продолжает текущую нумерацию.
-- Перед запуском проверьте: SELECT MAX(transaction_id) FROM transactions;
-- и поставьте START WITH = максимум + 1 (в нашей базе было 35 строк).
CREATE SEQUENCE seq_transactions START WITH 36 INCREMENT BY 1;

-- Значение по умолчанию для ключа
ALTER TABLE transactions MODIFY (transaction_id DEFAULT seq_transactions.NEXTVAL);

-- Проверка: ключ подставился сам, потом вставка откатывается
INSERT INTO transactions (account_id, transaction_type, amount, transaction_date)
VALUES (1001, 'Пополнение', 111, SYSDATE);

SELECT * FROM transactions ORDER BY transaction_id DESC FETCH FIRST 3 ROWS ONLY;

ROLLBACK;
