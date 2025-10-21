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