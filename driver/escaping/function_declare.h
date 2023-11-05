
// https://docs.faircom.com/doc/sqlref/33391.htm
// https://docs.microsoft.com/en-us/sql/odbc/reference/appendixes/appendix-e-scalar-functions

// clang-format off

    // Numeric
    DECLARE2(ABS, "abs"),
    DECLARE2(ACOS, "acos"),
    DECLARE2(ASIN, "asin"),
    DECLARE2(ATAN, "atan"),
    // DECLARE2(ATAN2, ""),
    DECLARE2(CEILING, "ceil"),
    DECLARE2(COS, "cos"),
    // DECLARE2(COT, ""),
    // DECLARE2(DEGREES, ""),
    DECLARE2(EXP, "exp"),
    DECLARE2(FLOOR, "floor"),
    DECLARE2(LOG, "log"),
    DECLARE2(LOG10, "log10"),
    DECLARE2(MOD, "modulo"),
    DECLARE2(PI, "pi"),
    DECLARE2(POWER, "pow"),
    // DECLARE2(RADIANS, ""),
    DECLARE2(RAND, "rand"),
    DECLARE2(ROUND, "round"),
    // DECLARE2(SIGN, ""),
    DECLARE2(SIN, "sin"),
    DECLARE2(SQRT, "sqrt"),
    DECLARE2(TAN, "tan"),
    DECLARE2(TRUNCATE, "trunc"),

    // String
    // ASCII
    // BIT_LENGTH
    // CHAR
    DECLARE2(CHAR_LENGTH, "length_utf8"),
    DECLARE2(CHARACTER_LENGTH, "length_utf8"),
    DECLARE2(CONCAT, "concat"),
    // DIFFERENCE
    // INSERT
    DECLARE2(LCASE, "lower_utf8"),
    DECLARE2(LOWER, "lower_utf8"),
    // LEFT  substring(s, 0, length)
    DECLARE2(LENGTH, "lengthUTF8"),
    DECLARE2(LOCATE, "" /* "position" */), // special handling
    DECLARE2(CONVERT, ""), // special handling
    DECLARE2(LTRIM, ""), // special handling
    DECLARE2(OCTET_LENGTH, "length"),
    // POSITION
    // REPEAT
    DECLARE2(REPLACE, "replace_all"),
    // RIGHT
    // RTRIM
    // SOUNDEX
    // SPACE
    DECLARE2(SUBSTRING, "substringUTF8"),
    DECLARE2(UCASE, "upper_utf8"),
    DECLARE2(UPPER, "upper_utf8"),


    // Date
    DECLARE2(CURRENT_TIMESTAMP, ""), // special handling
    DECLARE2(CURDATE, "today"),
    DECLARE2(CURRENT_DATE, "today"),
    DECLARE2(DAYOFMONTH, "to_day_of_month"),
    DECLARE2(DAYOFWEEK, "" /* "toDayOfWeek" */), // special handling
    DECLARE2(DAYOFYEAR, " to_day_of_year"), // Supported by ClickHouse since 18.13.0
    DECLARE2(EXTRACT, "EXTRACT"), // Do not touch extract inside {fn ... }
    DECLARE2(HOUR, "to_hour"),
    DECLARE2(MINUTE, "to_minute"),
    DECLARE2(MONTH, "to_month"),
    DECLARE2(NOW, "now"),
    DECLARE2(SECOND, "to_second"),
    DECLARE2(TIMESTAMPADD, ""), // special handling
    DECLARE2(TIMESTAMPDIFF, "date_diff"),
    DECLARE2(WEEK, "toISOWeek"),
    DECLARE2(SQL_TSI_QUARTER, "to_quarter"),
    DECLARE2(YEAR, "to_year"),

    // DECLARE2(DATABASE, ""),
    DECLARE2(IFNULL, "if_null"),
    // DECLARE2(USER, ""),

    // TODO.
