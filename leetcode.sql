
create table employee (id serial, salary int);

insert into employee (salary) values (100),(200),(300);

select * from employee;

create function getNthGreatestSalary(n int) returns int language plpgsql as $$
    begin
        return (select case when n-1 < 0 then null else salary end from employee limit 1 offset case when n-1 < 0 then 0 else n-1 end);
    end;
    $$;

drop function getNthGreatestSalary;

select getNthGreatestSalary(4);


-- Table: RequestAccepted

-- +----------------+---------+
-- | Column Name    | Type    |
-- +----------------+---------+
-- | requester_id   | int     |
-- | accepter_id    | int     |
-- | accept_date    | date    |
-- +----------------+---------+
-- (requester_id, accepter_id) is the primary key (combination of columns with unique values) for this table.
-- This table contains the ID of the user who sent the request, the ID of the user who received the request, and the date when the request was accepted.
-- Write a solution to find the people who have the most friends and the most friends number.
-- The test cases are generated so that only one person has the most friends.
-- The result format is in the following example.
-- Example 1:
-- Input: 
-- RequestAccepted table:
-- +--------------+-------------+-------------+
-- | requester_id | accepter_id | accept_date |
-- +--------------+-------------+-------------+
-- | 1            | 2           | 2016/06/03  |
-- | 1            | 3           | 2016/06/08  |
-- | 2            | 3           | 2016/06/08  |
-- | 3            | 4           | 2016/06/09  |
-- +--------------+-------------+-------------+
-- Output: 
-- +----+-----+
-- | id | num |
-- +----+-----+
-- | 3  | 3   |
-- +----+-----+
-- Explanation: 
-- The person with id 3 is a friend of people 1, 2, and 4, so he has three friends in total, which is the most number than any others.
-- Follow up: In the real world, multiple people could have the same most number of friends. Could you find all these people in this case?



create table RequestAccepted (requester_id int, accepter_id int, accept_date date, primary key(requester_id,accept_date));

insert into RequestAccepted (requester_id, accepter_id, accept_date) values
                                                                         (1,2,'2016-06-03'),
                                                                         (1,3,'2016-06-08'),
                                                                         (2,3,'2016-06-08'),

-- Solution 1                                                                         (3,4,'2016-06-09');
with cte1 as (
    select distinct requester_id, count(requester_id) over(partition by requester_id) total_sent from RequestAccepted
),
cte2 as (
    select distinct accepter_id, count(accepter_id) over(partition by accepter_id) total_received from RequestAccepted
),
cte3 as (
    select coalesce(requester_id,accepter_id) as id,
           coalesce(total_sent,0)+coalesce(total_received,0) num
    from cte1 full join cte2 on cte1.requester_id = cte2.accepter_id
)
select id,num from cte3 order by num desc limit 1;

-- Solution 2
select id, count(*) as num from (
select requester_id as id from RequestAccepted
                                 union all
                                 select accepter_id as id
                                 from RequestAccepted
                                 ) t group by id order by num desc limit  1;

-- select requester_id as id1, '' as id2 from RequestAccepted
--                                  union all
--                                  select 0 as id1, accepter_id::text as id3
--                                  from RequestAccepted;

-- what does union do: union merges same column (by name and data type) from queries vertically
-- in the above  example: all accepted_id is appended below requester_id and returned as single column named id
-- the name and data type is picked from first query. even if the second query(s) have different name(s) but same
-- data type as first one, they are appended accordingly. however number of rows in final result is the least no of
-- rows in all queries.
-- union returns distinct result whereas union all returns all results
