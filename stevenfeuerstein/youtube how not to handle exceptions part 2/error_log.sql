CREATE TABLE error_log (
    id               NUMBER
        GENERATED ALWAYS AS IDENTITY
    PRIMARY KEY,
    title            VARCHAR2(200),
    info             CLOB,
    created_on       DATE DEFAULT SYSDATE,
    created_by       VARCHAR2(100),
    callstack        CLOB,
    errorstack       CLOB,
    errorbacktrace   CLOB
)
/

CREATE OR REPLACE PROCEDURE log_error (
    title_in   IN         error_log.title%TYPE,
    info_in    IN         error_log.info%TYPE
)
    AUTHID definer
IS
    PRAGMA autonomous_transaction;
BEGIN
    INSERT INTO error_log (
        title,
        info,
        created_by,
        callstack,
        errorstack,
        errorbacktrace
    ) VALUES (
        title_in,
        info_in,
        user,
        dbms_utility.format_call_stack,
        dbms_utility.format_error_stack,
        dbms_utility.format_error_backtrace
    );

    COMMIT;
END;
/

create or replace procedure p_demo_log_error (value_in in INTEGER)
   AUTHID DEFINER
IS
   l_local_variable date;
begin
   l_local_variable :=
       case when value_in > 100 then sysdate -10 else sysdate + 10 end;
       
   update employees
     set salary = value_in;
     
     raise program_error;
exception
   when others
       then
           log_error (
                  'demo_log_error example',
                  'value_in = '
                  || value_in
                  || 'l_local_variable = '
                  || TO_CHAR(l_local_variable, 'YYYY-MM-DD HH24:MI:SS'));
                  
                  RAISE;
END;
/
   