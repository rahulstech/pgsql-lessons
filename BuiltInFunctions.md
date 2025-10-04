### Built in functions
  - **string functions**
    ```sql
    select upper('hello');           -- 'HELLO'
    select lower('HELLO');           -- 'hello'
    select substring('abcdef', 2, 3);-- 'bcd'
    select concat('pg','sql');       -- 'pgsql'
    select trim('  hi  ');           -- 'hi'
    ```

  - **numuber functions**
    ```sql
    select round(15.678, 2);   -- 15.68
    select round(15.674, 2);   -- 15.67
    select floor(15.9);        -- greatest integer  less than then number i.e. 15
    select ceil(15.1);         -- least integer greater than then number i.e. 16
    select mod(17, 5);         -- 17 % 5 = 2
    ```
  - **date time functions**
    
    ```sql
    select now();                            -- current complete timestamp (date, time and timezone)  in GTM timezone
    select current_date;                     -- today’s date
    select current_time;                     -- current time in GMT with timezone value in minutes
    select current_timestamp;                -- current date and time same now()
    ```

    - **NOTE1:** extract returns number type value
    - **NOTE2:** i can use any function or constants that return date time timestamp interval type in the extract. for example current_date, current_time etc
    - **NOTE3:** both singular and plural are accepted since pgsql 12. so hours and hour, year or years etc. has same effect. but it is recommended to use singular.
    - **NOTE4:** extract can extract the follows
      | Field                | Description                                          |
      | -------------------- | ---------------------------------------------------- |
      | `year` / `years`     | Year of the date                                     |
      | `month` / `months`   | Month of the year (1–12)                             |
      | `day` / `days`       | Day of the month (1–31)                              |
      | `hour` / `hours`     | Hour of the day (0–23)                               |
      | `minute` / `minutes` | Minute of the hour (0–59)                            |
      | `second` / `seconds` | Seconds of the minute (0–59, can include fractional) |
      | `millennium`         | Millennium number (year/1000)                        |
      | `century`            | Century number (year/100)                            |
      | `decade`             | Decade number (year/10)                              |
      | `dow`                | Day of week (0 = Sunday, 6 = Saturday)               |
      | `isodow`             | ISO day of week (1 = Monday, 7 = Sunday)             |
      | `doy`                | Day of year (1–365/366)                              |
      | `epoch`              | Seconds since 1970-01-01 00:00:00 UTC                |
      | `week`               | Week number of the year (ISO standard, 1–53)         |
      | `quarter`            | Quarter of the year (1–4)                            |
      | `timezone`           | Timezone offset in seconds                           |
      | `tz`                 | Alias for `timezone`                                 |

    
      ```sql
      select extract(year from now());         -- 2025
      ```

    - NOTE1: in the following example i am trying to extract time related valued; but instead of now() if i use current_date or anything that does not return time, extract will fail

      ```sql
      select extract(hour from now());         -- returns value 0-23
      select extract(minutes from now());      -- returns value 0-59
      ```

    - `age(to-date, from-date)` returns **INTERVAL** type

      ```sql
      select age('2025-10-04 06:55', '2000-01-01 10:28');  -- 25 years 9 mons 2 days 20 hours 27 mins 0.0 secs
      ```