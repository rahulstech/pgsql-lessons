
**Schema:**
 - schema are like directory. two tables with same name can exist in two different schemas
 - default schemas name is _public_

 **Example 1:**
  ```postgresql
    create schema auth;
    
    -- an users table in auth schema
    create table auth.users (id serial primary key, username varchar(30) unique  not null, name varchar(100) not null, email text not null);

    create schema orders;

    -- an users table in orders schema
    create table orders.users (id numeric not null, name varchar(100) not null, email text not null);

    insert into auth.users (username, name, email) values
    ('username1','name 1', 'name1@email.com'),
    ('username2','name 2', 'name2@email.com'),
    ('username3','name 3', 'name3@email.com');

    select * from auth.users;

    insert into orders.users (id, name, email) values
    (1,'name 1', 'name1@email.com'),
    (2,'name 2', 'name2@email.com'),
    (3,'name 3', 'name3@email.com');

    select * from orders.users;
  ```
 **Example 2:**
  ```postgresql
    create table auth.C (c varchar(30));

    insert into auth.C values ('abc'),('def');

    select * from C; -- search the table C in the default schema which is currently public, must fail

    set search_path to auth; -- change the default schema to auth

    select * from C; -- search the table C in the default schema which is currently auth, must succeed
  ```