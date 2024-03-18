-- ++++++++++++++++++++++++++++++++++++ Creation Code ++++++++++++++++++++++++++++++++++++++++++++++++
--CREATE TABLE Employees_temp (
--    Serial number(4) primary key,
--    First_name VARCHAR2(100),
--    Last_name VARCHAR2(100),
--    Hire_date VARCHAR2(100),
--    Job_title VARCHAR2(100),
--    Salary VARCHAR2(100),
--    Email VARCHAR2(100),
--    Department_name VARCHAR2(100),
--    City VARCHAR2(100)
--);
-- alter table employees modify email varchar2(200);                                        -- Becuase there are some long emails that will cause some errors (as the old data type is varchar2 25)

-- ++++++++++++++++++++++++++++++++++++ Procedure Code ++++++++++++++++++++++++++++++++++++++++++++++++
set serveroutput on
create or replace procedure main_program
is
        cursor employees_temp_rec is
            select *
            from employees_temp;
            
        v_count_job number(4) := 0;
        v_count_dep number(4) := 0;
        v_count_city number(4) := 0;
        v_location_id number(6);
        v_job_id varchar(200);
        v_department_id number(8);
        v_job_id2 varchar(200);
        v_hire_date date;
            
begin
        for v_employees_temp_rec in employees_temp_rec loop
            if v_employees_temp_rec.email like '%@%' then                    -- To drop the rows that don't contain the @ sign
                --DBMS_output.put_line(v_employees_temp_rec.email);
                select count(*) 
                   into v_count_job                                                           -- To check if the job_title is exist or we need to insert it
                from jobs
                where job_title = v_employees_temp_rec.job_title;
                
                if v_count_job != 1 then                                                         -- The job_title is not exist (Insert it)
                    insert into jobs(job_id , job_title) values(substr(v_employees_temp_rec.job_title , 1 , 3) , v_employees_temp_rec.job_title);
                end if;
                
                 select count(*)                                                                    -- To check if the department_name is exist or we need to insert it
                    into v_count_dep
                 from departments
                 where department_name = v_employees_temp_rec.department_name;
                 
                if v_count_dep != 1 then                                                         -- The department_name is not exist (Insert it)
                
                    select count(*)
                        into v_count_city                                       -- To check if the city is exist or we need to insert it (Because we need to insert the corresponding city with the new department)
                    from locations
                    where city = v_employees_temp_rec.city;
                        
                    if v_count_city != 1 then                                                   -- The city is not exist (Insert it)
                    
                        insert into locations(LOCATION_ID , CITY) values(LOCATION_ID_SEQ7.nextval , v_employees_temp_rec.city);
                        
                        insert into departments(DEPARTMENT_ID, DEPARTMENT_NAME , LOCATION_ID)           -- Insert the new department along with the new city
                        values(DEPARTMENT_ID_SEQ4.nextval , v_employees_temp_rec.department_name , LOCATION_ID_SEQ7.currval);
                            
                    else                                                                              -- The city is already exist (Get its corresponding ID)
                        select location_id
                            into v_location_id
                        from locations
                        where city = v_employees_temp_rec.city;
                        
                        insert into departments(DEPARTMENT_ID, DEPARTMENT_NAME , LOCATION_ID)       -- Insert the new department along with the corresponding old city that is already exist
                        values(DEPARTMENT_ID_SEQ4.nextval , v_employees_temp_rec.department_name , v_location_id);    
                        
                    end if;
                end if;
                
                select  department_id                                                                           -- Get the department_id that is corresponding to the department_name in the row
                    into v_department_id
                from departments
                where department_name = v_employees_temp_rec.department_name;
                
                select  job_id                                                                                      -- Get the job_id that is corresponding to the job_title in the row
                    into v_job_id2
                from jobs
                where job_title = v_employees_temp_rec.job_title;
                
                v_hire_date := to_date(v_employees_temp_rec.hire_date , 'dd/mm/yyyy');
                
                insert into employees(EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, SALARY , DEPARTMENT_ID)         -- Insert the new employee
                values(EMPLOYEE_ID_SEQ9.nextval , v_employees_temp_rec.first_name , v_employees_temp_rec.last_name , v_employees_temp_rec.email ,
                v_hire_date , v_job_id2 , v_employees_temp_rec.salary , v_department_id);
                
            end if;
            
        
        
        end loop;
end;
show errors;


-- ++++++++++++++++++++++++++++++++++++ Programm run ++++++++++++++++++++++++++++++++++++++++++++++++
declare
        
begin
        main_program;
end;
