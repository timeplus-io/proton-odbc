-- net stop MSSQLSERVER && net start MSSQLSERVER
-- sqlcmd -i mssql.linked.server.sql

EXEC master.dbo.sp_dropserver N'proton_link_test';
EXEC master.dbo.sp_addlinkedserver
        @server = N'proton_link_test'
       ,@srvproduct=N'Proton'
       ,@provider=N'MSDASQL'
       ,@provstr=N'Driver={Proton ODBC Driver (Unicode)};Url=http://example:3218;Database=default;Uid=default;Pwd=;stringmaxlength=8000;'
go
EXEC sp_serveroption 'proton_link_test','rpc','true';
EXEC sp_serveroption 'proton_link_test','rpc out','true';
go
EXEC('select * from system.numbers limit 10;') at [proton_link_test];
go
select count(*) as cnt from OPENQUERY(proton_link_test, 'select * from system.numbers limit 10;') 
go
EXEC('select ''Just string''') at [proton_link_test];
go
EXEC('select name from system.databases;') at [proton_link_test];
go
EXEC('select * from system.build_options;') at [proton_link_test];
go

exec('CREATE STREAM IF NOT EXISTS default.fixedstring ( xx fixed_string(100))') at [proton_link_test];
go
exec(N'INSERT INTO default.fixedstring (* except _tp_time) VALUES (''a''), (''abcdefg''), (''абвгдеёжзийклмнопрстуфх'');') at [proton_link_test];
go
--exec('INSERT INTO test.fixedstring VALUES (''a''),(''abcdefg'');') at [proton_link_test];
--go
exec('select sleep(2);') at [proton_link_test];
exec('select xx as x from default.fixedstring;') at [proton_link_test];
go
exec('DROP STREAM default.fixedstring;') at [proton_link_test];
go
exec('SELECT -127,-128,-129,126,127,128,255,256,257,-32767,-32768,-32769,32766,32767,32768,65535,65536,65537,-2147483647,-2147483648,-2147483649,2147483646,2147483647,2147483648,4294967295,4294967296,4294967297,-9223372036854775807,-9223372036854775808,-9223372036854775809,9223372036854775806,9223372036854775807,9223372036854775808,18446744073709551615,18446744073709551616,18446744073709551617;') at [proton_link_test];
go
exec('SELECT *, (CASE WHEN (number == 1) THEN ''o'' WHEN (number == 2) THEN ''two long string'' WHEN (number == 3) THEN ''r'' WHEN (number == 4) THEN NULL ELSE ''-'' END)  FROM system.numbers LIMIT 6') at [proton_link_test];
go

exec('CREATE STREAM IF NOT EXISTS default.number (a int64, b float64)') at [proton_link_test];
go
exec(N'INSERT INTO default.number (* except _tp_time) VALUES (1000, 1.1), (1200, 100.19), (-1000, -99.1);') at [proton_link_test];
go
exec('select sleep(2);') at [proton_link_test];
exec('select (* except _tp_time) from default.number;') at [proton_link_test];
go
exec('DROP STREAM default.number;') at [proton_link_test];
go
