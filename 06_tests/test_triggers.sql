-- Тесты триггеров trg_balance_audit и trg_check_card_status
-- Ручной тест: запускайте в одной сессии, смотрите результат и сравнивайте с комментарием «Ожидаем».
-- Процедуры пакета не делают COMMIT, поэтому в конце файла стоит ROLLBACK: данные возвращаются как были.
-- Номера счетов и балансы в комментариях взяты из тестовых данных проекта.

--Проверка триггера trg_balance_audit
-- Ожидаем: успешная запись данных в таблицу balance_audit, на счету 1007 баланс станет с 45000 - 46000 и это запишется в таблицу balance_audit
exec bank_pkg.deposit(1007, 1000);

-- Ожидаем на балансе 45000 у счета 1007, +1 строка в balance_audit
exec bank_pkg.withdraw(1007, 1000);

-- Ожидаем, у 1007 на балансе -1000, у 1003 на балансе + 1000, и в balance_audit +2 строки.
exec bank_pkg.transfer(1007, 1003, 1000);

-- Ожидаем ошибку, что у счета 1003 нет действующей карты.
exec bank_pkg.transfer(1003, 1007, 1000);

select * from balance_audit;

--Проверка триггера trg_check_card_status
-- Ожидаем: ошибку, что карта заблокирована или срок истек (нет активной карты у этого счета)
exec bank_pkg.deposit(1003, 1000);

select * from cards
order by account_id;

select * from accounts;

select * from balance_audit;

ROLLBACK;
