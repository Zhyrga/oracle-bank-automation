-- Для создания задания нужно право CREATE JOB:
--   GRANT CREATE JOB TO <ваш_пользователь>;   (выдаёт администратор)
-- Без него будет ORA-27486. Саму процедуру можно проверить вручную: EXEC expire_cards;
-- 3. Ночное задание: каждый день в 02:00

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_EXPIRE_CARDS',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'EXPIRE_CARDS',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=2; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => 'Ночной перевод просроченных карт в статус Истекла'
    );
END;
/
