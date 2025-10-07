-------------------------------------------------------------------------
--                    Conditional Statement                            --
-------------------------------------------------------------------------
create function is_even(n numeric) returns text as $$
begin
    if n%2 = 0 then
        return concat(n, ' is even');
    else
        return concat(n, ' is odd');
    end if;
end;
$$ language plpgsql;

select is_even(5);

select is_even(4);

-------------------------------------------------------------------------
--                               Loops                                 --
-------------------------------------------------------------------------

create table friends (id serial, name text, gender char(1), since date);

insert into friends (name, gender, since) values
('Rahul','M', '1997-03-17'), ('Rivu','M', '2002-04-01'), ('Ratul','M', '2012-06-01'),
('Ratnadeep','M', '2007-02-10'), ('Poulomi','F', '2004-07-09'), ('Mahuya','F', '2010-04-13'),
('Poshali', 'F','2007-04-14'), ('Anushree','F','2008-09-05'), ('Shrimanta','M','2007-08-04'),
('Rimi','F','2003-08-06');

create table results (name text, year_known int); -- will store the following results into this table

do $$ -- use do to run pl/pgsql statements
declare
--     friend_rec record;
    years_known int;
    name text;
begin
    -- for friend_rec in -- here friend_rec will contain the name and years_known
    --      select name, age(current_date, since)) years_known from friends
    -- loop
    for name, years_known in -- here i destructured the returned record and stored the corresponding values into the variables

        select friends.name, extract(year from age(current_date, since)) years_known from friends
                                                                                     where friends.gender = 'M'
    loop
        insert into results values
                                (
                                 name, -- friend_rec.name
                                 years_known -- friend_rec.years_known
                                );
    end loop;
end;
$$;

select * from results;

delete from results;

-- same as above but the table is returned from a function
-- in the following example rows are processed one by one and returned one by one
-- therefore if an error occurred after 3 rows then three rows are returned but rest of the rows are declined
-- to avoid this i can create a temp table, populate it and then return it
-- create temp table results (name text, years_known int) on commit drop;
-- and inside the loop insert into the results as normally inserted int a table
-- on commit drop drops the table as soon as the function ends
-- in this approach partial results are not returned
create function get_friend_known_more_than_years(years int)
returns table(name text, years_known int)
as $$
begin
    for name, years_known in -- name, years_known are declared in table definition of return type, so no need to declare the variables again
        select f.name, extract(year from age(current_date, f.since)) from friends f
    loop
        if years_known < years then
            continue ; -- keep going as i need to record in the output
        end if;
        return next; -- returns the current row to the output, this line is important
    end loop;
end;
$$ language plpgsql;

select * from get_friend_known_more_than_years(15);

drop function get_friend_known_more_than_years;

