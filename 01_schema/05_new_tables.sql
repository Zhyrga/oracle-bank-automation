-----Новая таблица loan_payments (платежи по кредитам) и таблица аудита balance_audit.
create table loan_payments (
    payment_id number generated always as identity primary key,
    loan_id number not null references loans(loan_id),
    payment_date date default sysdate not null,
    amount number(12,2) not null CHECK (amount > 0)
);

create table balance_audit (
    audit_id number generated always as identity primary key,
    account_id number not null references ACCOUNTS(account_id),
    old_balance number(12,2),
    new_balance number(12,2) not null,
    changed_at timestamp default systimestamp not null,
    changed_by varchar2(50) default USER not null
);

create INDEX idx_loan_payments_loan_id 
on loan_payments(loan_id);

create INDEX idx_balance_audit_account_id 
on balance_audit(account_id);

-- Лог ночного задания (используется процедурой expire_cards)
-- Длина колонок в символах (CHAR): русские буквы занимают по 2 байта,
-- и без CHAR слово «Успешно» не влезло бы в VARCHAR2(10).
CREATE TABLE card_status_log (
    log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status_name VARCHAR2(50 CHAR) NOT NULL,
    run_date    DATE DEFAULT SYSDATE NOT NULL,
    rows_update NUMBER,
    status      VARCHAR2(20 CHAR) NOT NULL,
    message     VARCHAR2(4000)
);
