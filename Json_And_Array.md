**Json and Jsonb:**

  usage difference between `json` and `jsonb` (json binary) is
  - use json when storing and getting the whole value is the only intension
  - use jsonb when partial update, query based on json attribute, indexing etc. are required

  ```postgresql
  drop table if exists A;

  create table A (id serial, data jsonb);

  insert into A (data) values
                  ('{"language": "english", "age": 30}'), -- i have inserted the josnb value as text
                  ('{"language": "english", "age": 28}'),
                  ('{"language": "spanish", "age": 25}'),
                  ('{"language": "french", "age": 28}'),
                  ('{"language": "russian", "age": 27}'),
                  ('{"language": "french", "age": 29}'),
                  ('{"language": "english", "age": 22}'),
                  ('{"language": "english", "age": 27}'),
                  ('{"language": "spanish", "age": 32}'),
                  ('{"language": "french", "age": 24}'),
                  ('{"language": "russian", "age": 29}'),
                  ('{"language": "french", "age": 24}');
  ```

  - Accessing jsonb attributes
    - -> return type is jsonb
    - ->> return type is text
    - #> return type is jsonb
    - #>> return type is text
    - ->, ->> used for top level attribute
    - #>, #>> used for nested attribute, ex: {"attr1": {"child1": "value1"}} then to get the value of attr.child1 use #> or #>>

  - filter by jsonb attribute
  
    **NOTE:** for json/jsonb attribute single quote ('') is used, but for alias name double quote ("") is used

    ```postgresql
    select
      data->>'language' "language_as_text", -- returns as english (without double quote)
      data->'language' "language_as_jsonb"  -- returns as "english" (inside double quote)
    from A where
              (data->>'age')::numeric >= 28; -- since data->>'age' is text type, cast it to number type (numeric, decimal, int) for arithmetic comparison
    ```

  - returns the value of `attr1.child1` i.e. _value1_. return type is _jsonb_
    ```postgresql
    insert into A (data) values ('{"attr1": {"child1": "value1", "child2": "value2"}}');

    select data#>'{attr1,child1}' "attr1-child1" from A;
    ```

  - returns value of attr1.child2 i.e. value2. return type is text.

    ```postgresql
    select data#>>'{attr1,child2}' "attr1-child2" from A;
    ```

  - the following query shows the return types
  
    ```postgresql
    select pg_typeof(data#>'{attr1,child1}') "typeof_attr1-child1", -- returns jsonb
          pg_typeof(data#>>'{attr1,child2}') "typeof_attr1-child2" -- returns text
    from A;
    ```

  - print each key-value pair of json in data column as separate row. for example: {"age": 30, "language": "english"} become (age,30), (language, english) in tow rows
  
    **NOTE:** each record item is text type
    
    ```postgresql
    select jsonb_each_text(data) "record", -- returns in record type, ex: (key, value)
          pg_typeof(jsonb_each_text(data)) "type" -- returns record
    from A;
    ```

  - update single attribute in jsonb

    **NOTE:** jsonb_set updates only single attribute at a time
    
    ```postgresql
    update A set
                data = jsonb_set(data, '{age}', '23')
            where id = 8;

    select * from A where id = 8;
    ```

  - update a multiple attribute in jsonb,
    
    **NOTE:** following will fail because here i am trying to update the data twice
    
    ```postgresql
    update A set
                data = jsonb_set(data, '{age}', '23'),
                data = jsonb_set(data,'{language}', '"hindi"')
            where id = 8;
    ```

  - solution 1: updating multiple attributes. i will use it only when the jsonb has multiple attributes but will change 2 or 3 attributes only
    
    ```postgresql
    update A set
                data = jsonb_set(
                      jsonb_set(data, '{age}', '24'), -- it returns updated age then i apply language update
                      '{language}', '"hindi"'
                      )
            where id = 8;

    select * from A where id = 8;
    ```

  - solution 2: updating multiple attributes. i will use it when there are limited attributes, i need to update 2 or more attribute together and everytime i know the unchanged attribute values too
    
    ```postgresql
    update A set
                data = '{"age": 25, "language": "bengali"}'::jsonb -- NOTE: cast it to jsonb for safety
            where id = 8;

    select * from A where id = 8;
    ```

  - update a single nested attribute in jsonb,
    
    ```postgresql
    update A set
                data = jsonb_set(data, '{attr1,child1}', '"updated-child1"'::jsonb)
            where id = 13;

    select * from A where id = 13;
    ```

  - update a jsonb attribute or add if not exists
    
    **NOTE:** the optional fourth parameter adds the attribute if not exists, by default it is true
  
    ```postgresql
    update A set
                data = jsonb_set(data,'{experience}','5', true) 
            where id = 8;

    select * from A where id = 8;
    ```