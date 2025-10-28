create table friends (name text);

-- savepoint remembers the changes in a transaction up to that point. after that if rolling back up to certain point is required
-- then rollback to <save point name> is used. NOTE: there is nothing like commit to.

begin;

insert into friends values ('Rahul'); -- this will add
savepoint insert_rahul;

insert into friends values ('Rivu'); -- this will not add

rollback to insert_rahul; -- discard all changed since savepoint insert_rahul to this rollback

commit; -- save all pending changes

select * from friends;

--------------------------------------------
---      Transaction Isolation Level     ---
--------------------------------------------

-- NOTE all changes is same transaction are visible within the transaction if not rollback to a savepoint
begin; -- transaction isolation level read committed;

select * from friends;

insert into friends values ('Rivu');

select  * from friends; -- this query will list 'Rivu' though change is not commited

rollback;

-- isolation level: READ COMMITTED (default
-- here during a ongoing transaction some other session (connection, terminal etc.) commit some changes
-- then those successful changes also visible in this transaction
-- use case: when queries needs most updated stated

-- session 1
begin; -- transaction isolation level read committed;
select * from friends;

-- complete the session 2 transaction before executing the following lines

select  * from friends; -- this query will list 'Rivu' though change is not commited
rollback;

-- session 2: run this transaction in another terminal
begin;
insert into friends values ('Rivu');
commit;



-- isolation: REPEATABLE READ
-- here transaction at the beginning keeps a snapshot of the database
-- therefore changes made is other transaction is not visible from this transaction
-- use case: when a particular state is required. for example: analytics, auditing, or any report generation

-- session 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM friends;  -- snapshot created here, Rahul visible

insert into friends values ('Rakesh'); -- <- though snapshot is taken but changes in same transaction is visible obvious

SELECT * FROM friends;  -- still shows Rahul ✅
ROLLBACK;

-- session 2
BEGIN;
DELETE FROM friends WHERE name = 'Rahul';
COMMIT;

-- isolation: serializable
-- At BEGIN ISOLATION LEVEL SERIALIZABLE, Postgres takes a consistent snapshot of the database (like Repeatable Read).
-- But unlike Repeatable Read, Serializable adds conflict detection to prevent anomalies.
-- It ensures the outcome is as if all serializable transactions ran one after another — never overlapping — even though they did.

create table accounts (id int, balance numeric);

insert into accounts (id, balance) values (1,2000), (2,1000);

-- session 1
begin isolation level serializable;
-- here transaction makes a snapshot
select sum(balance) from accounts;
-- session 2 starts here, see below
update accounts set balance = balance - 500 where id = 2; -- it will fail because session 2 already successfully alter the db state
commit; -- it throws a warning and fails first time, successful

-- session 2
begin isolation level serializable;
-- this transaction makes its snapshot here
update accounts set balance = balance - 500 where id = 1; -- here it changes the state of the database
commit; -- commit is successful here because there is no conflict i.e. no on altered the db state since the transaction start i.e. snapshot created
