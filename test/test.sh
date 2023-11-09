#!/usr/bin/env bash

set -Eeo pipefail

# this test requires running clickhouse server and configured ~/.odbc.ini
# cp -n /usr/share/doc/clickhouse-odbc/examples/odbc.ini ~/.odbc.ini
# apt install unixodbc

# to build and install package:
# cd .. && debuild -us -uc -i --source-option=--format="3.0 (native)" && sudo dpkg -i `ls ../clickhouse-odbc_*_amd64.deb | tail -n1`

# test https:
# cd .. && debuild -eDH_VERBOSE=1 -eCMAKE_FLAGS="-DFORCE_STATIC_LINK=" -us -uc -i --source-option=--format="3.0 (native)" && sudo dpkg -i `ls ../clickhouse-odbc_*_amd64.deb | tail -n1`

# Usage: ./test.sh CMD ARGS
# where test queries will be fed to the stdin of the `CMD ARGS` run.

# Should not have any errors:
# ./test.sh | grep -i error

#using trap to preserve error exit code
#trap "printf '\n\n\nLast log:\n'; tail -n200 /tmp/clickhouse-odbc.log" EXIT

RUNNER=$@
echo "Using: $RUNNER"

function q {
    echo "Asking [$*]"
    # DYLD_INSERT_LIBRARIES=/usr/local/opt/gcc/lib/gcc/8/libasan.5.dylib
    # export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libasan.so.5
    echo "$*" | eval $RUNNER
}

q "SELECT * FROM system.build_options;"
q "CREATE DATABASE IF NOT EXISTS test;"
q "DROP STREAM IF EXISTS test.odbc1;"
q "CREATE STREAM test.odbc1 (ui64 uint64, str string, date_col Date, datetime_col datetime)"
q "INSERT INTO test.odbc1 (* except _tp_time) VALUES (1, '2', 3, 4);"
q "INSERT INTO test.odbc1 (* except _tp_time) VALUES (10, '20', 30, 40);"
q "INSERT INTO test.odbc1 (* except _tp_time) VALUES (100, '200', 300, 400);"
sleep 2s
q "SELECT  (* except _tp_time) FROM test.odbc1 WHERE ui64=1;"

q 'SELECT {fn CONVERT(1, SQL_BIGINT)}'
q "SELECT {fn CONVERT(100000, SQL_TINYINT)}"
q "SELECT {fn CONCAT('a', 'b')}"
q 'SELECT cast({fn TRUNCATE(1.1 + 2.4, 1)} AS INTEGER) AS `yr_date_ok`'

q $'SELECT count({fn ABS(`test`.`odbc1`.`ui64`)}) FROM test.odbc1'

q $'SELECT {fn TIMESTAMPDIFF(SQL_TSI_DAY,cast(`test`.`odbc1`.`datetime_col` AS DATE),cast(`test`.`odbc1`.`date_col` AS DATE))} AS `Calculation_503558746242125826`, sum({fn CONVERT(1, SQL_BIGINT)}) AS `sum_Number_of_Records_ok` FROM `test`.`odbc1` WHERE (cast(`test`.`odbc1`.`datetime_col` AS DATE) <> {d \'1970-01-01\'}) GROUP BY `Calculation_503558746242125826`'

q $'SELECT count({fn ABS(`test`.`odbc1`.`ui64`)}) AS `TEMP_Calculation_559572257702191122__2716881070__0_`, sum({fn ABS(`test`.`odbc1`.`ui64`)}) AS `TEMP_Calculation_559572257702191122__3054398615__0_`  FROM test.odbc1;'

q $'SELECT sum((CASE WHEN (`test`.`odbc1`.`ui64` * `test`.`odbc1`.`ui64`) < 0 THEN NULL ELSE {fn SQRT((`test`.`odbc1`.`ui64` * `test`.`odbc1`.`ui64`))} END)) AS `TEMP_Calculation_559572257701634065__1464080195__0_`, count((CASE WHEN (`test`.`odbc1`.`ui64` * `test`.`odbc1`.`ui64`) < 0 THEN NULL ELSE {fn SQRT((`test`.`odbc1`.`ui64` * `test`.`odbc1`.`ui64`))} END)) AS `TEMP_Calculation_559572257701634065__2225718044__0_` FROM test.odbc1;'

# SELECT (CASE WHEN (NOT = 'True') OR (`test`.`odbc1`.`str` = 'True') OR (`test`.`odbc1`.`string2` = 'True') THEN 1 WHEN NOT (NOT = 'True') OR (`test`.`odbc1`.`str` = 'True') OR (`test`.`odbc1`.`str` = 'True') OR (`test`.`odbc1`.`string2` = 'True') THEN 0 ELSE NULL END) AS `Calculation_597289912116125696`,
# sum({fn CONVERT(1, SQL_BIGINT)}) AS `sum_Number_of_Records_ok` FROM `test`.`odbc1` GROUP BY `Calculation_597289912116125696`, `str`, `ui64`

q "DROP STREAM IF EXISTS test.purchase_stat;"
q "CREATE STREAM test.purchase_stat (purchase_id uint64, purchase_date datetime, offer_category uint64, amount uint64);"
q $'SELECT sum({fn CONVERT(Custom_SQL_Query.amount, SQL_BIGINT)}) AS sum_amount FROM (SELECT purchase_date, offer_category, sum(amount) AS amount, count(DISTINCT purchase_id) AS purchase_id FROM test.purchase_stat WHERE (offer_category = 1) GROUP BY purchase_date, offer_category) Custom_SQL_Query HAVING (count(1) > 0)'
q $'SELECT (CASE WHEN (`test`.`odbc1`.`ui64` > 0) THEN 1 WHEN NOT (`test`.`odbc1`.`ui64` > 0) THEN 0 ELSE NULL END) AS `Calculation_162692564973015040`, sum({fn CONVERT(1, SQL_BIGINT)}) AS `sum_Number_of_Records_ok` FROM `test`.`odbc1` GROUP BY (CASE WHEN (`test`.`odbc1`.`ui64` > 0) THEN 1 WHEN NOT (`test`.`odbc1`.`ui64` > 0) THEN 0 ELSE NULL END)'
q $"SELECT {d '2017-08-30'}"
q 'SELECT cast(cast(`odbc1`.`date_col` AS DATE) AS DATE) AS `tdy_Calculation_687361904651595777_ok` FROM `test`.`odbc1`'

q 'SELECT {fn CURDATE()}'

q $'SELECT `test`.`odbc1`.`ui64` AS `bannerid`, sum((CASE WHEN `test`.`odbc1`.`ui64` = 0 THEN NULL ELSE `test`.`odbc1`.`ui64` / `test`.`odbc1`.`ui64` END)) AS `sum_Calculation_582934706662502402_ok`, sum(`test`.`odbc1`.`ui64`) AS `sum_clicks_ok`, sum(`test`.`odbc1`.`ui64`) AS `sum_shows_ok`, sum(`test`.`odbc1`.`ui64`) AS `sum_true_installs_ok`, cast(cast(`test`.`odbc1`.`date_col` AS DATE) AS DATE) AS `tdy_Calculation_582934706642255872_ok` FROM `test`.`odbc1` WHERE (`test`.`odbc1`.`str` = \'YandexBrowser\') GROUP BY `test`.`odbc1`.`ui64`, cast(cast(`test`.`odbc1`.`date_col` AS DATE) AS DATE)'


q $'SELECT test.odbc1.ui64 AS BannerID,   sum((CASE WHEN test.odbc1.ui64 = 0 THEN NULL ELSE test.odbc1.ui64 / test.odbc1.ui64 END)) AS sum_Calculation_500744014152380416_ok,   sum(test.odbc1.ui64) AS sum_ch_installs_ok,   sum(test.odbc1.ui64) AS sum_goodshows_ok FROM test.odbc1 GROUP BY test.odbc1.ui64'
q $'SELECT test.odbc1.ui64 AS BannerID,   sum((CASE WHEN test.odbc1.ui64 > 0 THEN NULL ELSE test.odbc1.ui64 / test.odbc1.ui64 END)) AS sum_Calculation_500744014152380416_ok,   sum(test.odbc1.ui64) AS sum_ch_installs_ok,   sum(test.odbc1.ui64) AS sum_goodshows_ok FROM test.odbc1 GROUP BY test.odbc1.ui64'


q "DROP STREAM IF EXISTS test.test_tableau;"
q "create stream test.test_tableau (country string, clicks uint64, shows uint64)"
q "insert into test.test_tableau (* except _tp_time) values ('ru',10000,100500),('ua',1000,6000),('by',2000,6500),('tr',100,500)"
q "insert into test.test_tableau (* except _tp_time) values ('undefined',0,2)"
q "insert into test.test_tableau (* except _tp_time) values ('injected',1,0)"
sleep 2s
q 'SELECT test.test_tableau.country AS country, sum((CASE WHEN test.test_tableau.shows = 0 THEN NULL ELSE cast(test.test_tableau.clicks AS FLOAT) / test.test_tableau.shows END)) AS sum_Calculation_920986154656493569_ok, sum({fn POWER(cast(test.test_tableau.clicks AS FLOAT),2)}) AS sum_Calculation_920986154656579587_ok FROM test.test_tableau GROUP BY test.test_tableau.country;'
q "DROP STREAM test.test_tableau;"

q 'SELECT NULL'
q 'SELECT [NULL]'

q "DROP STREAM IF EXISTS test.adv_watch;"
q "create stream test.adv_watch (rocket_date Date, rocket_datetime dateTime, ivi_id uint64)"
q "insert into test.adv_watch (* except _tp_time) values (1,2,3)"
q "insert into test.adv_watch (* except _tp_time) values (1, {fn TIMESTAMPADD(SQL_TSI_DAY,-8,cast({fn CURRENT_TIMESTAMP(0)} AS DATE))}, 3)"
sleep 2s
q 'SELECT `test`.`adv_watch`.`rocket_date` AS `rocket_date`, count(DISTINCT `test`.`adv_watch`.`ivi_id`) AS `usr_Calculation_683139814283419648_ok` FROM `test`.`adv_watch` WHERE ((`adv_watch`.`rocket_datetime` >= {fn TIMESTAMPADD(SQL_TSI_DAY,-9,cast({fn CURRENT_TIMESTAMP(0)} AS DATE))}) AND (`test`.`adv_watch`.`rocket_datetime` < {fn TIMESTAMPADD(SQL_TSI_DAY,1,cast({fn CURRENT_TIMESTAMP(0)} AS DATE))})) GROUP BY `test`.`adv_watch`.`rocket_date`'
q 'SELECT cast({fn TRUNCATE(EXTRACT(YEAR FROM `test`.`adv_watch`.`rocket_date`),0)} AS INTEGER) AS `yr_rocket_date_ok` FROM `test`.`adv_watch` GROUP BY cast({fn TRUNCATE(EXTRACT(YEAR FROM `test`.`adv_watch`.`rocket_date`),0)} AS INTEGER)'
q "DROP STREAM test.adv_watch;"

# https://github.com/yandex/clickhouse-odbc/issues/43
q 'DROP STREAM IF EXISTS test.gamoraparams;'
q 'CREATE STREAM test.gamoraparams ( user_id int64, date_col Date, dt datetime, p1 nullable(int32), platforms nullable(int32), max_position nullable(int32), vv nullable(int32), city nullable(string), third_party nullable(int8), mobile_tablet nullable(int8), mobile_phone nullable(int8), desktop nullable(int8), web_mobile nullable(int8), tv_attach nullable(int8), smart_tv nullable(int8), subsite_id nullable(int32), view_in_second nullable(int32), view_in_second_presto nullable(int32))'
q 'insert into test.gamoraparams (* except _tp_time) values (1, {fn CURRENT_TIMESTAMP }, cast({fn CURRENT_TIMESTAMP(0)} AS DATE), Null, Null,Null,Null,Null, Null,Null,Null,Null,Null,Null,Null,Null,Null,Null);'
sleep 2s
q 'SELECT `Custom_SQL_Query`.`platforms` AS `platforms` FROM (select platforms from test.gamoraparams where platforms is null limit 1) `Custom_SQL_Query` GROUP BY `platforms`'
q 'SELECT cast({fn TRUNCATE(EXTRACT(YEAR FROM `test`.`gamoraparams`.`dt`),0)} AS INTEGER) AS `yr_date_ok` FROM `test`.`gamoraparams` GROUP BY `yr_date_ok`';
q 'DROP STREAM test.gamoraparams;'

q $'SELECT cast(EXTRACT(YEAR FROM `odbc1`.`date_col`) AS INTEGER) AS `yr_date_ok` FROM `test`.`odbc1`'
q $'SELECT cast({fn TRUNCATE(EXTRACT(YEAR FROM `odbc1`.`date_col`),0)} AS INTEGER) AS `yr_date_ok` FROM `test`.`odbc1`'
q $'SELECT sum({fn CONVERT(1, SQL_BIGINT)}) AS `sum_Number_of_Records_ok`, cast({fn TRUNCATE(EXTRACT(YEAR FROM `odbc1`.`date_col`),0)} AS INTEGER) AS `yr_date_ok` FROM `test`.`odbc1` GROUP BY cast({fn TRUNCATE(EXTRACT(YEAR FROM `odbc1`.`date_col`),0)} AS INTEGER)'

q 'SELECT cast({fn TRUNCATE(EXTRACT(YEAR FROM cast(`test`.`odbc1`.`date_col` AS DATE)),0)} AS INTEGER) AS `yr_Calculation_860750537261912064_ok` FROM `test`.`odbc1` GROUP BY `yr_Calculation_860750537261912064_ok`'
q 'SELECT {fn TIMESTAMPADD(SQL_TSI_DAY,cast({fn TRUNCATE((-1 * ({fn DAYOFYEAR(`test`.`odbc1`.`date_col`)} - 1)),0)} AS INTEGER),cast(`test`.`odbc1`.`date_col` AS DATE))} AS `tyr__date_ok` FROM `test`.`odbc1` GROUP BY `tyr__date_ok`'

q 'SELECT {fn TIMESTAMPADD(SQL_TSI_DAY,(-1 * ({fn MOD((7 + {fn DAYOFWEEK(cast(`test`.`odbc1`.`date_col` AS DATE))} - 2), 7)})),cast(cast(`test`.`odbc1`.`date_col` AS DATE) AS DATE))} AS `twk_date_ok` FROM `test`.`odbc1` GROUP BY `twk_date_ok`'
q 'SELECT {fn TIMESTAMPADD(SQL_TSI_DAY,cast({fn TRUNCATE((-1 * ({fn DAYOFYEAR(cast(`test`.`odbc1`.`date_col` AS DATE))} - 1)),0)} AS INTEGER),cast(cast(`test`.`odbc1`.`date_col` AS DATE) AS DATE))} AS `tyr_Calculation_681450978608578560_ok` FROM `test`.`odbc1` GROUP BY `tyr_Calculation_681450978608578560_ok`'
q 'SELECT {fn TIMESTAMPADD(SQL_TSI_MONTH,cast({fn TRUNCATE((3 * (cast({fn TRUNCATE({fn QUARTER(cast(`test`.`odbc1`.`date_col` AS DATE))},0)} AS INTEGER) - 1)),0)} AS INTEGER),{fn TIMESTAMPADD(SQL_TSI_DAY,cast({fn TRUNCATE((-1 * ({fn DAYOFYEAR(cast(`test`.`odbc1`.`date_col` AS DATE))} - 1)),0)} AS INTEGER),cast(cast(`test`.`odbc1`.`date_col` AS DATE) AS DATE))})} AS `tqr_Calculation_681450978608578560_ok` FROM `test`.`odbc1` GROUP BY `tqr_Calculation_681450978608578560_ok`'
q 'SELECT {fn TIMESTAMPADD(SQL_TSI_DAY,cast({fn TRUNCATE((-1 * (EXTRACT(DAY FROM cast(`test`.`odbc1`.`date_col` AS DATE)) - 1)),0)} AS INTEGER),cast(cast(`test`.`odbc1`.`date_col` AS DATE) AS DATE))} AS `tmn_Calculation_681450978608578560_ok` FROM `test`.`odbc1` GROUP BY `tmn_Calculation_681450978608578560_ok`'

q $'SELECT (CASE WHEN (`test`.`odbc1`.`ui64` < 5) THEN replaceRegexpOne(toString(`test`.`odbc1`.`ui64`), \'^\\s+\', \'\') WHEN (`test`.`odbc1`.`ui64` < 10) THEN \'5-9\' WHEN (`test`.`odbc1`.`ui64` < 20) THEN \'10-19\' WHEN (`test`.`odbc1`.`ui64` >= 20) THEN \'20+\' ELSE NULL END) AS `Calculation_582653228063055875`, sum(`test`.`odbc1`.`ui64`) AS `sum_traf_se_ok` FROM `test`.`odbc1` GROUP BY `Calculation_582653228063055875` ORDER BY `Calculation_582653228063055875`'
q $"SELECT *, (CASE WHEN (number == 1) THEN 'o' WHEN (number == 2) THEN 'two long string' WHEN (number == 3) THEN 'r' WHEN (number == 4) THEN NULL ELSE '-' END)  FROM system.numbers LIMIT 6"

# todo: test with fail on comparsion:
q $"SELECT {fn DAYOFWEEK(cast('2018-04-16' AS DATE))}, 7, 'sat'"
q $"SELECT {fn DAYOFWEEK(cast('2018-04-15' AS DATE))}, 1, 'sun'"
q $"SELECT {fn DAYOFWEEK(cast('2018-04-16' AS DATE))}, 2, 'mon'"
q $"SELECT {fn DAYOFWEEK(cast('2018-04-17' AS DATE))}, 3, 'thu'"
q $"SELECT {fn DAYOFWEEK(cast('2018-04-18' AS DATE))}, 4, 'wed'"
q $"SELECT {fn DAYOFWEEK(cast('2018-04-19' AS DATE))}, 5, 'thu'"
q $"SELECT {fn DAYOFWEEK(cast('2018-04-20' AS DATE))}, 6, 'fri'"
q $"SELECT {fn DAYOFWEEK(cast('2018-04-21' AS DATE))}, 7, 'sat'"
q $"SELECT {fn DAYOFWEEK(cast('2018-04-22' AS DATE))}, 1, 'sun'"

q $"SELECT {fn DAYOFYEAR(cast('2018-01-01' AS DATE))}, 1"
q $"SELECT {fn DAYOFYEAR(cast('2018-04-20' AS DATE))}, 110"
q $"SELECT {fn DAYOFYEAR(cast('2018-12-31' AS DATE))}, 365"

q $'SELECT name, {fn REPLACE(`name`, \'E\',\'!\')} AS `r1` FROM system.build_options'
q $'SELECT {fn REPLACE(\'ABCDABCD\' , \'B\',\'E\')} AS `r1`'

q $"SELECT (CASE WHEN 1>0 THEN 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ELSE NULL END);"
q $'SELECT {fn REPLACE(\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\', \'E\',\'!\')} AS `r1`'

q $"SELECT 'абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'"

q "SELECT to_nullable(42), to_nullable('abc'), NULL"
q "SELECT 1, 'string', NULL"
q "SELECT 1, NULL, 2, 3, NULL, 4"
q "SELECT 'stringlong', NULL, 2, NULL"

q $"SELECT -127,-128,-129,126,127,128,255,256,257,-32767,-32768,-32769,32766,32767,32768,65535,65536,65537,-2147483647,-2147483648,-2147483649,2147483646,2147483647,2147483648,4294967295,4294967296,4294967297,-9223372036854775807,-9223372036854775808,-9223372036854775809,9223372036854775806,9223372036854775807,9223372036854775808,18446744073709551615,18446744073709551616,18446744073709551617"
q $"SELECT 2147483647, 2147483648, 2147483647+1, 2147483647+10, 4294967295"

q "DROP STREAM if exists fixedstring;"
q "CREATE STREAM IF NOT EXISTS test.fixedstring ( xx fixed_string(100));"
q "INSERT INTO test.fixedstring (* except _tp_time) VALUES ('a'), ('abcdefg'), ('абвгдеёжзийклмнопрстуфхцч')";
sleep 2s
q "select xx as x from test.fixedstring;"
q "DROP STREAM test.fixedstring;"


q 'DROP STREAM IF EXISTS test.increment;'
q 'CREATE STREAM test.increment (n uint64);'

NUM=${NUM=100}
for i in `seq 1 ${NUM}`; do
    q "insert into test.increment (* except _tp_time) values ($i);" > /dev/null
    q 'select * from test.increment;' > /dev/null
done
sleep 2s
q 'select * from test.increment;'

echo "should be ${NUM}:"
q 'select count(*) from test.increment;'

q 'DROP STREAM test.increment;'


q "DROP STREAM IF EXISTS test.decimal;"
q "CREATE STREAM IF NOT EXISTS test.decimal (a DECIMAL(9,0), b DECIMAL(18,0), c DECIMAL(38,0), d DECIMAL(9, 9), e Decimal64(18), f Decimal128(38), g Decimal32(5), h Decimal64(9), i Decimal128(18), j decimal(4,2));"
q "INSERT INTO test.decimal (a, b, c, d, e, f, g, h, i, j) VALUES (42, 42, 42, 0.42, 0.42, 0.42, 42.42, 42.42, 42.42, 42.42);"
q "INSERT INTO test.decimal (a, b, c, d, e, f, g, h, i, j) VALUES (-42, -42, -42, -0.42, -0.42, -0.42, -42.42, -42.42, -42.42, -42.42);"
sleep 2s
q "SELECT * FROM test.decimal;"

q "drop stream if exists test.lc;"
q "create stream test.lc (b low_cardinality(string)) order by b;"
q "insert into test.lc (* except _tp_time) select '0123456789' from numbers(100);"
sleep 2s
q "select count(), b from test.lc group by b;"
q "select * from test.lc limit 10;"
q "drop stream test.lc;"

# These queries can only be executed within session
q "SET max_threads=10;"
q "CREATE TEMPORARY STREAM increment (n uint64) ENGINE = Memory;"

# q "SELECT number, toString(number), toDate(number) FROM system.numbers LIMIT 10000;"
