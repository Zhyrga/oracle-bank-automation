-- Проверка данных ПЕРЕД добавлением ограничений.
-- В каждой строке результата violations должно быть 0.
SELECT 'NULL: branches' AS check_name, COUNT(*) AS violations FROM branches
 WHERE branch_name IS NULL OR city IS NULL
UNION ALL SELECT 'NULL: customers', COUNT(*) FROM customers
 WHERE full_name IS NULL OR birth_date IS NULL OR phone IS NULL
UNION ALL SELECT 'NULL: accounts', COUNT(*) FROM accounts
 WHERE customer_id IS NULL OR branch_id IS NULL OR account_type IS NULL
    OR balance IS NULL OR open_date IS NULL
UNION ALL SELECT 'NULL: cards', COUNT(*) FROM cards
 WHERE account_id IS NULL OR card_type IS NULL OR expiry_date IS NULL OR status IS NULL
UNION ALL SELECT 'NULL: transactions', COUNT(*) FROM transactions
 WHERE account_id IS NULL OR transaction_type IS NULL OR amount IS NULL OR transaction_date IS NULL
UNION ALL SELECT 'NULL: loans', COUNT(*) FROM loans
 WHERE customer_id IS NULL OR amount IS NULL OR interest_rate IS NULL
    OR status IS NULL OR issue_date IS NULL
UNION ALL SELECT 'customers: дубли телефона', COUNT(*) FROM
 (SELECT phone FROM customers GROUP BY phone HAVING COUNT(*) > 1)
UNION ALL SELECT 'accounts: неизвестный тип', COUNT(*) FROM accounts
 WHERE account_type NOT IN ('Текущий', 'Сберегательный')
UNION ALL SELECT 'accounts: баланс < 0', COUNT(*) FROM accounts WHERE balance < 0
UNION ALL SELECT 'cards: неизвестный тип', COUNT(*) FROM cards
 WHERE card_type NOT IN ('Visa Debit', 'Visa Credit', 'MasterCard Debit', 'MasterCard Credit')
UNION ALL SELECT 'cards: неизвестный статус', COUNT(*) FROM cards
 WHERE status NOT IN ('Активна', 'Заблокирована', 'Истекла')
UNION ALL SELECT 'transactions: неизвестный тип', COUNT(*) FROM transactions
 WHERE transaction_type NOT IN ('Пополнение', 'Снятие', 'Перевод')
UNION ALL SELECT 'transactions: сумма <= 0', COUNT(*) FROM transactions WHERE amount <= 0
UNION ALL SELECT 'loans: неизвестный статус', COUNT(*) FROM loans
 WHERE status NOT IN ('Активен', 'Закрыт', 'Просрочен')
UNION ALL SELECT 'loans: сумма <= 0', COUNT(*) FROM loans WHERE amount <= 0
UNION ALL SELECT 'loans: ставка вне 0..100', COUNT(*) FROM loans
 WHERE interest_rate < 0 OR interest_rate > 100;
