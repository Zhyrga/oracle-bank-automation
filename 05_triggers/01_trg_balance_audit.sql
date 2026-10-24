---Аудит: любое изменение accounts.balance записывается в balance_audit (кто, когда, старое и новое значение).
CREATE or REPLACE trigger trg_balance_audit
after update of balance ON accounts
FOR EACH ROW

WHEN (old.balance <> new.balance)
BEGIN

insert into balance_audit (account_id, old_balance, new_balance, changed_at, changed_by)
values (:old.account_id, :old.balance, :new.balance, SYSDATE, USER);

END trg_balance_audit;
/
