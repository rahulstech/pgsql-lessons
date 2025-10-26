set search_path to backend;

create table employees (id serial, name text, doj date, dept text);

INSERT INTO employees (name, doj, dept) VALUES
('Amit Sharma', '2017-06-12', 'Finance'),
('Pooja Verma', '2018-09-23', 'Health'),
('Rahul Mehta', '2019-03-15', 'Education'),
('Sneha Nair', '2020-01-08', 'Information Technology'),
('Vikram Singh', '2021-07-19', 'Defence'),
('Anjali Das', '2017-11-02', 'Agriculture'),
('Sandeep Reddy', '2018-04-28', 'Railways'),
('Neha Gupta', '2019-10-10', 'Finance'),
('Rohan Chatterjee', '2020-12-05', 'Tourism'),
('Priya Iyer', '2021-02-16', 'Health'),
('Arjun Patel', '2022-05-21', 'Education'),
('Divya Sahu', '2023-01-11', 'Information Technology'),
('Kiran Kumar', '2024-03-29', 'Public Works'),
('Manisha Roy', '2017-08-24', 'Agriculture'),
('Rajesh Tiwari', '2018-12-13', 'Transport'),
('Swati Mishra', '2019-10-10', 'Finance'),
('Deepak Yadav', '2020-09-14', 'Defence'),
('Meera Joshi', '2021-11-27', 'Health'),
('Harish Babu', '2022-08-09', 'Railways'),
('Shweta Kulkarni', '2023-10-17', 'Tourism'),
('Kartik Aryan', '2019-03-15', 'Education');

--------------------------------------------
---         Window Function              ---
--------------------------------------------

-- row_number() assigns serial no to each row on each partition.
-- for example: in the following example for each dept the oldest one will get dept_rank 1 and newest one will get the highest rank
--              for different dept the rank will reset. i.e. there will be multiple dept_rank 1 but all are them obviously from different dept
-- NOTE: if multiple in the same dept have same doj rows are given row_number arbitrarily
select id, name, dept, doj, row_number() over (partition by dept order by doj) dept_rank from employees
                                                                                         order by dept, doj; -- order by is not necessary for row_number(), used for formatting the output

-- rank() assigns rank to each row on each partition.
-- more than one rows can get same ranks if they have same "ordered by" column value.
-- but rank() skips rank value.for example if there are 3 rows with rank 1 then the 4th row will get rank 4, not 2
select id, name, dept, doj, rank() over (partition by dept order by doj) from employees
                                                                         where dept in('Education', 'Finance')
                                                                         order by dept, doj;
-- dense_rank() assigns rank to each row on each partition.
--  dense_rank() mostly same as rank(); but instead of skipping rank it assigns the next rank
-- for example if there are 3 rows with rank 1 then the 4th row will get rank 2
select id, name, dept, doj, dense_rank() over (partition by dept order by doj) from employees
                                                                         where dept in('Education', 'Finance')
                                                                         order by dept, doj;

-- LAG() window function
-- Syntax: LAG(column, [, offset, default]) OVER([PARTITION BY column] ORDER BY column)
-- returns "offset" numbers of rows previous of current row from "column". returns null if no value found and no default provided
-- offset is integer and by default offset = 1

-- find the doj of the previous joiner in the whole office
select name, doj,
       lag(doj) over(order by doj asc) prev_in_ofc
from employees;

select name, doj,
       lag(doj, 1, '2016-01-01') over(order by doj asc) prev_in_ofc -- default value provided for null.
from employees;

select name, doj,
       -- offset = 2, so for each row in main query it returns 2 rows behind value. NOTE: two results contains two nulls
       lag(doj, 2) over(order by doj asc) prev_in_ofc
from employees;

insert into employees (name, doj, dept) VALUES ('Rakesh Sk', '2017-06-14', 'Education');

-- find the doj of previous joiner in same department
select name, dept, doj,
       lag(doj) over (partition by dept order by doj asc) prev_in_dept -- partition by dept lags by 1 row per department
from employees;

-- LEAD window function
-- Syntax: LEAD(column[, offset, default]) OVER([PARTITION BY column] ORDER BY column )
-- returns "offset" numbers of rows ahead of current row from "column". returns null if no value found and no default provided
-- offset is integer and by default offset = 1

-- find the doj of the next joiner in the whole office
select name, doj,
       lead(doj) over(order by doj asc) next_in_ofc
from employees;

-- find the doj of the next joiner in the same dept
select name, doj,
       lead(doj) over(partition by dept order by doj asc) next_in_dept
from employees;

-- SUM, AVG, COUNT Window function
-- SUM/AVG/COUNT(column1) OVER(PARTITION BY column2): calculate the sum, average or count over column1 values for individual group in column2
with cte1 as (
    select id, name, dept, (current_date-doj) as days_served from employees
)
select dept,
       sum(days_served) over(partition by dept) total_days_served_dept,
       count(id) over(partition by dept) total_emp_dept,
       avg(days_served) over (partition by dept) avg_days_served_dept
from cte1;

-- framed window
-- < RANGE | ROWS > BETWEEN < <UNBOUNDED | n> PRECEDING | CURRENT ROW> AND < < UNBOUNDED | n > FOLLOWING | CURRENT ROW>
-- UNBOUNDED PRECEDING / FOLLOWING = from beginning or till end respectively
-- n PRECEDING / FOLLOWING = n rows before or n rows after from current row respectively
-- example:
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW = from beginning till current row
-- ROWS BETWEEN n PRECEDING AND n FOLLOWING = from n rows before to n rows after of current row
-- NOTE: end means the partition

-- list employees with salary, cumulative salary in the dept up to him/her and difference between salary and average salary up to hin in the dept
select name, salary,
       sum(salary) over(
           partition by dept
           order by salary
           rows between unbounded preceding and current row ) as cumulative_dept_salary,
       salary - avg(salary) over (
           partition by dept
           order by salary
           rows between unbounded preceding and current row) as salary_diff
from employees;

-- list employees with average days served by him/her and two employees joined before him/her
with cte1 as (
    select name, dept, doj, current_date - doj as days_serverd from employees
)
select name, dept,
       avg(days_serverd) over (
           partition by dept
           order by doj
           rows between 2 preceding and current row) as avg_days_served
from cte1;

-- list employees with total joined before him/her in the same dept
select name, dept, doj,
       count(id) over (
           partition by dept
           order by doj
           rows between unbounded preceding and current row) - 1 as total_joined_before
from employees;