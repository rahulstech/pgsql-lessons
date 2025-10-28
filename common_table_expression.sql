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
('Swati Mishra', '2019-07-30', 'Finance'),
('Deepak Yadav', '2020-09-14', 'Defence'),
('Meera Joshi', '2021-11-27', 'Health'),
('Harish Babu', '2022-08-09', 'Railways'),
('Shweta Kulkarni', '2023-10-17', 'Tourism');



-- filter the employees who joined the year when at least 2 employees joined.
-- i used common table expression (CTE) for this query
-- CTE is temporary table, syntax for creating CTE is
-- WITH <cte-name> AS ( <query for cte> ) <this main query>
-- CTE is used with insert, select, update, delete
-- CTE in Postgresql available since 12
with tmp_emp as (
    select extract(year from doj) yoj, count(id) total_joining from employees group by yoj
)
select name, doj from employees inner join tmp_emp on extract(year from doj) = yoj where total_joining > 1 order by doj desc;

-- without cte i can achieve the same result using sub-query
select name, doj from employees t
                 where (select count(id) from employees e
                                         where extract(year from e.doj) = extract(year from t.doj)) > 1
                 order by doj desc;

-- between cte and sub-query, the cte version is more efficient. because in case of sub-query for each row in employees table the sub-query
-- scans the whole table. therefore, if there is n rows in employees for the n x n iteration will occur. which is significantly large for large tables
-- but in case of CTE, it creates a temporary table containing year of join and total_joining from employee table.
-- in the main query i joined the employee table and cte based on year of joining and filtered only those entries where total_joinin is more than 1.
-- this time the total iteration become m+n where m is the iterations for creating the cte.
-- in short the biggest advantage of CTE over sub-query is that, sub-query runs per row, whereas CTE runs once.

---------------------------------------------
---       example of CTE chaining         ---
---------------------------------------------
-- get the result for department wise average tenures only for employees tenure more than 5 years
-- CASE1:
with
    -- get the tenures for each employee
    cte1 as (
        select id, extract(year from age(current_date, doj)) tenure, dept from employees
    ),
    -- filter the employees with tenure more than 5 years
    cte2 as (
      select id, tenure, dept from cte1 where tenure > 5
    ),
    -- calculate the dept wise average tenures
    cte3 as (
        select dept, avg(tenure)::numeric(12,2) dept_avg_tenure
            from cte2
            group by dept
    )
select * from cte3;

-- CASE2:
with
    -- get the tenures for each employee
    cte1 as (
        select id, extract(year from age(current_date, doj)) tenure, dept from employees
    ),
    -- calculate the dept wise average tenures
    cte3 as (
        select dept, avg(tenure)::numeric(12,2) dept_avg_tenure
            from cte1
            where tenure > 5 group by dept
    )
select * from cte3;

-- let's compare these
-- CASE2 is more efficient than CASE1. CASE1 has more CTEs than CASE2.
-- which means CASE1 uses more memory than CASE2. this is an issue for very large table.

---------------------------------------------
---               Exercise                ---
---------------------------------------------
-- Question1: Top 1 Employee by Tenure per Department

-- inefficient way
-- here for each row, sub-query runs to find the employee with oldest doj in that particular depart
-- sub-query first finds all the rows with the given dept, then orders the rows by ascending order of doj and descending order of id as tie braker
-- finally returns the first row i.e. the older doj row
-- it is inefficient because of the sub-query, it runs multiple time a for hug numbers of rows the overall query will become very slow
select name, dept, 1 as rank_highest_tenure_in_dept from employees t
                                                    where t.id = (select id from employees e where t.dept = e.dept order by e.doj asc, e.id desc limit 1)
                                                    order by dept asc ;

-- efficient way
-- here i used CTE and row_number() window function.
-- cte sets serial number to each row in each dept, oldest doj gets serial no. 1 and goes on
-- the main query filters out the rows with row number = 1 only
with cte1 as (
    select *, row_number() over (partition by dept order by doj) rank_highest_tenure_in_dept from employees
)
select name, dept from cte1 where rank_highest_tenure_in_dept = 1;


---------------------------------------------
---            Recursive CTE              ---
---------------------------------------------
drop table employees;

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name TEXT,
    manager_id INT REFERENCES employees(id)
);

INSERT INTO employees (name, manager_id) VALUES
('CEO', NULL),
('Manager A', 1),
('Manager B', 1),
('Dev 1', 2),
('Dev 2', 2),
('Dev 3', 3);

with recursive emm_hierchy as (

    -- base case filters the top level manager, without a base case recursion will not start
    select id, name, manager_id, 1 as level from employees where manager_id is null

    union all -- union all required otherwise duplicates will vanish

    -- now filter employees where the above one is the manager
    -- for example:
    -- first it finds the CEO
    -- the for finds employees where CEO is the manager. it finds 2 new rows. so it will recurse again for each of these employees but as manager
    -- again 2 employees found where 'Manager A' is manager. one manager still left.
    -- found 1 employee where 'Manager B' is manager.
    -- so at these point there are 3 new rows. for each of these new rows it will recurse again
    -- since no more employees available where 'Dev 1', 'Dev 2', 'Dev 3' are manager so recursion stops.
    -- in short recursive cte recurse till new rows available
    select e.id, e.name, e.manager_id, eh.level + 1 as level
    from employees e inner join emm_hierchy eh on e.manager_id = eh.id
)
select * from emm_hierchy;
