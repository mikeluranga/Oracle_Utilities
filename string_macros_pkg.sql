/*
https://blogs.oracle.com/sql/post/split-comma-separated-values-into-rows-in-oracle-database    
SQL queries to split CSV or other delimited strings into rows
Chris Saxon (Oracle)
*/


create or replace package string_macros_pkg as 
  function split_string ( 
    tab dbms_tf.table_t,
    col dbms_tf.columns_t,
    separator varchar2 default ','
  ) return clob sql_macro;
  
  function split_string ( 
    delimited_string varchar2,
    separator        varchar2 default ','
  ) return clob sql_macro;
end;
/


create or replace package body string_macros_pkg as 
  function split_string ( 
    tab dbms_tf.table_t,
    col dbms_tf.columns_t,
    separator varchar2 default ','
  ) return clob sql_macro as
    sql_text clob;
  begin
    sql_text := 'select t.*, 
         regexp_substr (
           ' || col ( 1 ) || ',
           ''[^'' || separator || '']+'',
           1,
           pos
         ) str,
         pos
  from   tab t,
         lateral (
           select level pos
           from   dual
           connect by level <= 
             length ( ' || col ( 1 ) || ' ) 
               - length ( replace ( ' || col ( 1 ) || ', separator ) ) 
               + 1
         )';
  
    return sql_text;
    
  end split_string;
  
  function split_string ( 
    delimited_string varchar2,
    separator        varchar2 default ','
  ) return clob sql_macro as
      sql_text clob;
  begin
    
    sql_text := 'select 
         regexp_substr (
           delimited_string,
           ''[^'' || separator || '']+'',
           1,
           level
         ) str,
         level pos
  from   dual
  connect by level <= 
    length ( delimited_string ) 
      - length ( replace ( delimited_string, separator ) ) 
      + 1';
  
    return sql_text;
    
  end split_string;

end;
/
