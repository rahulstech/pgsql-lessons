-------------------------------------------------------------------------
--                              Basic                                  --
-------------------------------------------------------------------------

-- NOTE: function with return type void is similar to procedure. but it does not mean i can call it using 'call' like procedure
create function add_two(a numeric, b numeric) -- function may or may not have parameters
returns numeric -- function must have a return type, if it returns nothing then the type must be void
    as $$ -- this is a delimiter for multi line statement i can use anything like $body$ etc.
begin -- beginning of the function body

    return a+b;

end -- enf of function body
    $$ LANGUAGE plpgsql; -- i can place it here or after the returns statement, default language plpgsql is used if not mentioned

select add_two(12,25) "result";

create table B (b int);

create procedure insert_sum(a int, b int) -- procedures never returns but may or may not have parameters
    language plpgsql -- just like function i can place it after the final delimiter $$
    as $$
    declare
        total int; -- declare variable (optional) to store result temporarily, NOTE: DECLARE is before function body starts
    begin
        total := a+b; -- := is assignment operation = is comparison operator used in for example if condition statement
        insert into B values (total);
        commit; -- it is optional
    end
    $$;

call insert_sum(10,15); -- inserts 25

call insert_sum(21, 75); -- inserts 96

call insert_sum(24, 84); -- inserts 108

select * from B; -- two rows 25, 96, 108

create function get_sum_b() returns bigint
    language plpgsql -- it also works fine
    as $$
    declare sum bigint;
    begin
        sum := (select sum(b) from B);
        return sum;
    end;
    $$;

select get_sum_b();

-- dropping functions and procedures
-- NOTE: two functions or procedures have same name but different signature (different parameters list) must mention the parameter types also
-- for example: drop function add_tow(numeric,numeric)

drop function if exists add_two;
drop procedure if exists insert_sum;
drop function if exists get_sum_b;

-------------------------------------------------------------------------
--                  Function Returns Table                             --
-------------------------------------------------------------------------

create table employees (id serial, name varchar(30), experience int);

insert into employees (name, experience) values
                                             ('Rahul', 5),
                                             ('Rivu',3),
                                             ('Rounak', 7),
                                             ('Puspa', 4),
                                             ('Poulomi', 5),
                                             ('Ritvik', 10),
                                             ('Aakash', 2),
                                             ('Aashish', 3);
select * from employees;


create function employee_with_experience_more_than_year(year int)
returns table(
        id int,
        name text, -- NOTE: name in return is text but in employees table it is varchar
        experience int
    )
as $$
begin
    return query -- to return query result "return query"
        (
            -- NOTE: here comes the more important thing. when the return type is table
            -- pgsql creates variables in the same names. for example: here pgsql create id, name, experience variable.
            -- therefore if i use select id, name, experience ... or even select "id", "name", "experience" ... it will throw error about ambiguity
            -- pgsql is confused here that in the id in the select query is from table column or the id variable which is declared.
            -- same ambiguity goes for other variables too. therefore a simple solution is use <table-name>.<column-name> in the select query
            -- interesting part is the error will be thrown during function invocation not during creation
            select emp.id,
                   emp.name::text, -- in the table name is varchar but in the return type it is text, therefore i have to cast otherwise there will an error
                   emp.experience
            from employees emp
            where  emp.experience >= year -- like here i simply used the function argument year for comparison
            order by emp.experience desc
        );
end;
$$ language plpgsql;

-------------------------------------------------------------------------
--                          Alternative                                --
-------------------------------------------------------------------------
-- one alternate solution is to use the return type "setof <table-name>",
-- but i have to return all the columns
create function employee_with_experience_more_than_year(year int)
returns setof employees
as $$
begin
    return query -- to return query result "return query"
        (
            select id,
                   name,
                   experience
            from employees
            where  experience >= year
            order by experience desc
        );
end;
$$ language plpgsql;

-- the results are shown in multiple rows but in single column. the only column contains the entire row as record type i.e. (col1, col2, col3, ...)
select employee_with_experience_more_than_year(7);

-- the results are shown just like a normal select query, multiple rows and multiple columns
select * from employee_with_experience_more_than_year(7);

drop function employee_with_experience_more_than_year;

-------------------------------------------------------------------------
--                          IN, OUT, INOUT                             --
-------------------------------------------------------------------------

create table employee_performance (
    id serial,
    name varchar(30),
    rating int
);

insert into employee_performance (name, rating) values
('Rahul', 7),
('Rivu', 5),
('Rounak', 9),
('Puspa', 6),
('Poulomi', 8),
('Ritvik', 10),
('Aakash', 4),
('Aashish', 3);

-- functions parameters can be of three types in, out and inout
-- in: this is the default type. i can explicitly mention it or remove it.
--      these parameters are used to pass values to the function.
-- out: use these parameter to return values from function. return type
--      is not necessary if out parameter is available
-- inout: use these parameter to pass value to function as well as
--        return value from the function. its behaviour is in + out
create function calculate_performance_bonus(
    in emp_id int,
    inout current_salary int,
    out emp_name varchar(30),
    out emp_rating int,
    out performance_score numeric(5,2)
)
language plpgsql
as $$
    begin
        select name, rating
        into emp_name, emp_rating
        from employee_performance where id = emp_id;

        if not found then
            raise notice 'emp with id % not found', emp_id;
            return ;
        end if;
        performance_score := emp_rating * 1.5;
        current_salary :=  emp_rating * 1000;
    end;
$$;

drop function calculate_performance_bonus;

select * from calculate_performance_bonus(2,10000);

select * from calculate_performance_bonus(10,20000);

-- here the intention is to output salary_hike for all the employees. but it returns only one row not all
create function calculate_salary_hike(
    out emp_id int,
    out emp_name varchar(30),
    out emp_rating int,
    out salary_hike int
) language plpgsql
as $$
    begin
       select id, name,  rating, rating * 1000
        into emp_id, emp_name, emp_rating, salary_hike -- NOTE: into returns only the first row not all the rows
        from employee_performance;
    end;
    $$;

select * from calculate_salary_hike();