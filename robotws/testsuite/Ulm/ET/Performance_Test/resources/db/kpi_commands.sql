-- Copyright (c) 2024 Nokia. All rights reserved.

-- For easy interface with linux
--     1. Install the sqlite browser (open source)
--         sudo apt-get install sqlitebrowser
--     2. load the performance.sqlite3

--------------------------------------------------
-- CREATE
--------------------------------------------------
BEGIN TRANSACTION;

INSERT INTO testcase (testname)
    VALUES ('testcase_dummy_1');
SELECT last_insert_rowid();

-- insert KPI data
INSERT INTO kpi (testcase_id, kpi_name, kpi_value)
    VALUES (1, 'kpi_test_dummy1', 1);

-- insert an emperf data
INSERT INTO emperf (testcase_id, container)
    VALUES (1, '0x1730');
SELECT last_insert_rowid();
-- insert disps
INSERT INTO disp (emperf_id, disp_number, average, minimum, maximum)
    VALUES (1, 'disp_0', 0,0,0);

COMMIT;


--------------------------------------------------
-- RETRIEVE
--------------------------------------------------
.headers on
.mode column

SELECT *
    FROM testcase
    WHERE
        testname='testcase_dummy_1'
        ORDER BY testdate DESC
    LIMIT 1;

----- EMEPERF DISPS-----
SELECT *
    FROM view_emperf
    WHERE
        testcase_id=1;


----- TESTCASE PARAMETER -----
SELECT *
    FROM view_testcase_parameter
    WHERE
        testname='testcase_dummy_1'
    LIMIT 1;


----- KPI -----
SELECT *
    FROM kpi_view_kpiview
    WHERE
        testname='testcase_dummy_1'
        -- AND kpi.kpi_name = '<kpi_name>'
    LIMIT 1;


--------------------------------------------------
-- UPDATE
--------------------------------------------------
UPDATE testcase
    SET pass='2'
    WHERE testcase_id=1;

--------------------------------------------------
-- DELETE
--------------------------------------------------
PRAGMA foreign_keys = ON;  -- ALWAYS Execute this to enable delete cascade
DELETE FROM testcase
    WHERE testcase.testname='testcase_dummy_1'
    AND testcase.testcase_id=1;