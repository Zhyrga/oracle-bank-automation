--------- Индексы на внешние ключи (account_id, customer_id, branch_id). -----------

-- accounts (customer_id, branch_id), 
-- cards(account_id), 
-- loans(customer_id), 
-- transactions(account_id)

create index idx_cards_account_id 
    on cards(account_id);
create index idx_transactions_account_id
    on transactions(account_id);
create index idx_accounts_customer_id
    on accounts(customer_id);
create index idx_loans_customer_id
    on loans(customer_id);
create index idx_accounts_branch_id
    on accounts(branch_id);

-- Проверка
select index_name, table_name, column_name
from user_ind_columns
where table_name in ('ACCOUNTS', 'CARDS', 'TRANSACTIONS', 'LOANS')
order by table_name, index_name;
