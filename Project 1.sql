set serveroutput on;
declare
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- To get all the sequences
            cursor tables_sequences is
                select object_name
                from user_objects
                where object_type = 'SEQUENCE';
                
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- To get the table name and the primay key column from table "And exclude the table that have composite keys (Job_history)"
                cursor tables_primary_keys is
                    select distinct c.table_name , cons.column_name as primary_key_column , cols.data_type
                    from user_constraints c join  user_cons_columns cons 
                    on c.constraint_name = cons.constraint_name
                    join user_tab_columns cols
                    on cons.column_name = cols.column_name
                    where c.constraint_type = 'P' and c.table_name in 
                    (
                        select table_name
                        from (
                                    select c.table_name , cons.column_name as primary_key_column
                                    from user_constraints c join user_cons_columns cons 
                                    on c.constraint_name = cons.constraint_name
                                    where c.constraint_type = 'P')
                                    group by table_name
                                    having COUNT(table_name) = 1
                    ) and cols.data_type = 'NUMBER';
                


            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            v_sql varchar2(500);
            v_max_id number(10);
            counter number(3) := 1;
            seq_name varchar2(500);
begin
        
        -- First thing drop all sequences
        for v_record in tables_sequences loop
            execute IMMEDIATE 'drop sequence ' || v_record.object_name;
        end loop;

      for v_record in tables_primary_keys loop
            
            -- Get the maximum value of the primary key of the table
            v_sql := 'select max(' || v_record.primary_key_column ||  ') from ' || v_record.table_name;
            -- DBMS_output.put_line('Create sequence ' || v_record.primary_key_column || ' start with ' || v_max_id);
            execute immediate v_sql into v_max_id;
            if v_max_id is null then
                    v_max_id := 0;
            end if;
            
            -- To create the new sequence
           seq_name := v_record.primary_key_column || '_SEQ' || counter;
           v_sql := 'Create sequence ' || seq_name || ' start with ' || (v_max_id + 1);
           execute immediate v_sql;
            
           v_sql := 'create or replace trigger ' || v_record.primary_key_column || '_TRIG' || counter ||
           ' before insert
           on ' ||  v_record.table_name ||
           ' for each row
           begin 
                    :new.' || v_record.primary_key_column ||  ' := ' || seq_name || '.NEXTVAL;'  ||
           'end;';
           execute immediate v_sql;
           counter := counter + 1;
           
      end loop;


end;

insert into employees(FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, COMMISSION_PCT, 
MANAGER_ID, DEPARTMENT_ID)
values ( 'Omar' ,'Hassan' , 'Omar_hasssan@example.com' , '1234' , to_date('17/6/2003' , 'DD/MM/YYYY'),  'AD_ASST' , 4000 , 0.1 , 103 , 60);
