-- 2. Процедура: переводит просроченные карты в "Истекла"
create or replace PROCEDURE expire_cards as
v_rows NUMBER;
v_err varchar2(4000);
BEGIN

    update cards
    set status = 'Истекла'
    where status = 'Активна' and expiry_date < TRUNC(sysdate);

v_rows := SQL%ROWCOUNT;

insert into card_status_log(status_name, rows_update, status, message)
values('JOB_EXPIRE_CARDS', v_rows, 'Успешно', 'Карт переведено в статус "Истекла": ' || v_rows);

COMMIT;

EXCEPTION
    WHEN others then 
    rollback;
    
    v_err := substr(SQLERRM, 1, 4000);
    
    insert into card_status_log(status_name, rows_update, status, message)
    values('JOB_EXPIRE_CARDS', 0, 'Ошибка', v_err);

    Commit;
    RAISE;
END expire_cards;
/
