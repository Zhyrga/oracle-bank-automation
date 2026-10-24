-- Исправление: карты с истёкшим сроком, но статусом «Активна», переводим в «Истекла».
-- Что будет исправлено (в нашей базе: card_id 2, 3, 6, 7, 12, 15):
SELECT card_id, status, expiry_date
FROM   cards
WHERE  status = 'Активна' AND expiry_date < TRUNC(SYSDATE)
ORDER  BY card_id;

UPDATE cards
SET    status = 'Истекла'
WHERE  status = 'Активна' AND expiry_date < TRUNC(SYSDATE);

COMMIT;

-- Проверка: должно вернуть 0 строк
SELECT * FROM cards
WHERE  status = 'Активна' AND expiry_date < TRUNC(SYSDATE);
