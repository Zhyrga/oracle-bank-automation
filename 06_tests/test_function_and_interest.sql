-- Тесты get_customer_balance и apply_interest
-- Ручной тест: запускайте в одной сессии, смотрите результат и сравнивайте с комментарием «Ожидаем».
-- Процедуры пакета не делают COMMIT, поэтому в конце файла стоит ROLLBACK: данные возвращаются как были.
-- Номера счетов и балансы в комментариях взяты из тестовых данных проекта.

---Проверка функции get_customer_balance
-- Ожидаем: успешно, общий баланс клиента с айди 1
select bank_pkg.get_customer_balance(1) from dual;

select sum(balance) from accounts where customer_id = 1;

-- Ожидаем: Ошибку, что клиент не найден
select bank_pkg.get_customer_balance(60) from dual;

---Проверка процедуры apply_interest
-- Ожидаем, что у счета 1010 было 25000, станет 30000
exec bank_pkg.apply_interest(1010, 20);

-- Ожидаем ошибку, что счет не найден
exec bank_pkg.apply_interest(1099, 20);

-- Ожидаем ошибку, что ставка должна быть больше нуля
exec bank_pkg.apply_interest(1010, 0);

ROLLBACK;
