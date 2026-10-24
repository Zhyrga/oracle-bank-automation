---v_branch_performance: по филиалам число счетов, сумма балансов, оборот транзакций.
create or replace view v_branch_performance as 
with bal as (
    select b.BRANCH_ID,
    sum(a.balance) as total_balance
    from accounts a 
    join branches b on b.branch_id = a.branch_id 
    group by b.branch_id
)
select b.branch_id, 
    b.branch_name,
    count(distinct a.account_id) as total_accounts,
    bal.total_balance,
    sum(t.amount) as transaction_volume
from branches b
left join accounts a on a.branch_id = b.branch_id 
left join transactions t on t.account_id = a.account_id 
left join bal on bal.branch_id = b.branch_id
group by b.branch_id, 
    b.branch_name,
    bal.total_balance
order by b.branch_id;
