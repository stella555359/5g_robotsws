-- Copyright (c) 2024 Nokia. All rights reserved.

-- UPDATE insert_dummy_testcase() in db_interface_insert.py to whenever there is change in schema!

--------------------------------------------------
-- WITH GREAT POWER COMES WITH GREAT RESPONSIBILITY !!
-- Be careful :)
--------------------------------------------------
-- BEGIN TRANSACTION;
-- DROP TABLE testcase;
-- -- DROP TABLE testresults_cell;
-- DROP TABLE testline;
-- DROP TABLE testline_type;
-- DROP TABLE testcase_parameter;
-- DROP TABLE testcase_parameter2;
-- DROP TABLE software;
-- DROP TABLE testcase_results;
-- DROP TABLE testcase_flags;
-- DROP TABLE pmcounter;
-- DROP TABLE testcase_jenkins_data;
-- DROP TABLE kpi;
-- DROP TABLE emperf;
-- DROP TABLE disp;
-- DROP TABLE emperf_map;
-- DROP TABLE pmcounter_map;
-- DROP TABLE hash;
-- COMMIT;


BEGIN TRANSACTION;


CREATE TABLE testcase (
    testcase_id                                 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testdate                                    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    testname                                    VARCHAR(64) NOT NULL,
    pass                                        INTEGER DEFAULT -1
);


CREATE TABLE testline (
    testline_id                                 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_id                                 INTEGER NOT NULL,
    testline_type_id                            INTEGER DEFAULT 0 REFERENCES testline_type(testline_type_id),
    testline_name                               VARCHAR(16) NOT NULL,
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE
);


CREATE TABLE testline_type (
    testline_type_id                            INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testline_topology                           VARCHAR(16) NOT NULL,
    testline_variant                            VARCHAR(16) NOT NULL,
    UNIQUE(testline_topology, testline_variant) ON CONFLICT REPLACE
);


CREATE TABLE testcase_parameter (
    testcase_parameter_id                       INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_id                                 INTEGER NOT NULL,
    trf_direction                               VARCHAR(4),
    lua                                         VARCHAR(64),
    'entry'                                     VARCHAR(64),
    ue_per_cell                                 INTEGER,
    start_cell                                  INTEGER,
    end_cell                                    INTEGER,
    traffic_sleep                               INTEGER,
    active_cells                                VARCHAR(32),
    ul_datarate                                 FLOAT,
    dl_datarate                                 FLOAT,
    rate                                        VARCHAR(5),
    tolerance                                   FLOAT,
    end_ue                                      INTEGER,
    num_cells                                   INTEGER,
    total_active_cells                          INTEGER,
    total_active_ue                             INTEGER,
    duplex                                      VARCHAR(8),
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE
);


CREATE TABLE software (
    software_id                                 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_id                                 INTEGER NOT NULL,
    gnb_load                                    VARCHAR(32),
    gnb_hw                                      VARCHAR(32),
    ap_load                                     VARCHAR(32),
    ap_hw                                       VARCHAR(32),
    vcu_oc_version                              VARCHAR(32),
    duplex_mode                                 VARCHAR(8),
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE
);


CREATE TABLE testcase_results (
    testcase_results_id                         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_results_name                       VARCHAR(32),
    testcase_results_value                      VARCHAR(32),
    testcase_id                                 INTEGER NOT NULL,
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE,
    UNIQUE(testcase_results_name, testcase_id) ON CONFLICT REPLACE
);


CREATE TABLE testcase_parameter2 (
    testcase_parameter2_id                      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_parameter2_name                    VARCHAR(32),
    testcase_parameter2_value                   VARCHAR(32),
    testcase_id                                 INTEGER NOT NULL,
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE,
    UNIQUE(testcase_parameter2_name, testcase_id) ON CONFLICT REPLACE
);


CREATE TABLE testcase_flags (
    testcase_flags_id                           INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_flags_name                         VARCHAR(32),
    testcase_flags_value                        VARCHAR(32),
    testcase_id                                 INTEGER NOT NULL,
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE,
    UNIQUE(testcase_flags_name, testcase_id) ON CONFLICT REPLACE
);


CREATE TABLE pmcounter (
    pmcounter_id                                INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_id                                 INTEGER NOT NULL,
    piid_name                                   VARCHAR(16),
    piid_value                                  INTEGER,
    distname                                    VARCHAR(32) NOT NULL,
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE,
    UNIQUE(piid_name, distname, testcase_id) ON CONFLICT REPLACE
);


CREATE TABLE testcase_jenkins_data (
    testcase_jenkins_id                         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_id                                 INTEGER NOT NULL,
    JOB_NAME                                    VARCHAR(16) NOT NULL,
    JOB_URL                                     VARCHAR(16) NOT NULL,
    BUILD_ID                                    INTEGER NOT NULL,
    JOB_DESCRIPTION                             VARCHAR(16) NOT NULL,
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE
);


CREATE TABLE kpi (
    kpi_uid                                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_id                                 INTEGER NOT NULL,
    kpi_id                                      VARCHAR(6) NOT NULL,
    kpi_name                                    VARCHAR(6) NOT NULL,
    kpi_distname                                VARCHAR(32) NOT NULL,
    kpi_value                                   FLOAT,
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE,
    UNIQUE(kpi_name, kpi_distname, testcase_id) ON CONFLICT REPLACE
);


CREATE TABLE emperf (
    emperf_id                                   INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    testcase_id                                 INTEGER NOT NULL,
    container                                   VARCHAR(6) NOT NULL,
    FOREIGN KEY(testcase_id)                    REFERENCES testcase(testcase_id)
                                                ON DELETE CASCADE,
    UNIQUE(emperf_id, container, testcase_id) ON CONFLICT REPLACE
);


CREATE TABLE disp (
    disp_id                                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    emperf_id                                   INTEGER NOT NULL,
    disp_number                                 VARCHAR(10) NOT NULL,
    average                                     FLOAT NOT NULL,
    minimum                                     FLOAT NOT NULL,
    maximum                                     FLOAT NOT NULL,
    FOREIGN KEY(emperf_id)                      REFERENCES emperf(emperf_id)
                                                ON DELETE CASCADE
);


CREATE TABLE emperf_map (
    container                                  VARCHAR(6) DEFAULT 'n/a',
    disp_number                                VARCHAR(10) DEFAULT 'n/a',
    disp_name                                  VARCHAR(10) DEFAULT 'n/a',
    UNIQUE(container, disp_number, disp_name) ON CONFLICT REPLACE
);

CREATE TABLE pmcounter_map (
    piid                                       VARCHAR(16) DEFAULT 'n/a',
    desciption                                 VARCHAR(32) DEFAULT 'n/a',
    category                                   VARCHAR(8) DEFAULT 'n/a',
    UNIQUE(piid) ON CONFLICT REPLACE
);

CREATE TABLE pass_map (
    pass                                       INTEGER PRIMARY KEY NOT NULL,
    mapping                                    VARCHAR(12) NOT NULL,
    UNIQUE(pass, mapping) ON CONFLICT REPLACE
);

CREATE TABLE hash (
    hash_id                                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    hash_name                                   VARCHAR(8),
    hash_value                                  VARCHAR(16),
    hash_content                                VARCHAR(256),
    hash_date                                   Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(hash_name, hash_value) ON CONFLICT REPLACE
);

COMMIT;

--------------------------------------------------
-- INSERT ALTER TABLE COMMANDS HERE
--------------------------------------------------
BEGIN TRANSACTION;

INSERT INTO pass_map (pass, mapping) VALUES
 (-1, 'NOT_COMPLETED')
,( 0, 'FAILED')
,( 1, 'PASSED')
,( 2, 'TEST_DATA')
;

INSERT INTO pmcounter_map(piid, category, desciption) VALUES
 ('dummy',        'n/a',        'n/a')
,('M55326C00501', 'nrbts',      'PDCP SDU user DL data volume per PLMN-ID for SA user - SA_DL_TPUT_COUNTER')
,('M55326C00502', 'nrbts',      'PDCP SDU user UL data volume per PLMN-ID for SA user - SA_UL_TPUT_COUNTER')
,('M55308C17002', 'nrcell',     'n/a')
,('M55308C18002', 'nrcell',     'n/a')
,('M55308C02000', 'nrcell',     'Accumulated number of UEs with DL DRB data buffered')
,('M55308C02002', 'nrcell',     'Accumulated number of UEs with UL DRB data buffered')
,('M55310C05001', 'nrcell',     'DL RLC delay - QoS Group 01')
,('M55328C00006', 'nrcell',     'DL PDCP SDU delay per slice per PLMN')
,('M55305C01001', 'nrcell',     'UL_SERV_BEAM_ID_BEAM_00')
,('M55305C01002', 'nrcell',     'UL_SERV_BEAM_ID_BEAM_01')
,('M55305C00001', 'nrcell',     'DL_SERV_BEAM_ID_BEAM_00')
,('M55305C00002', 'nrcell',     'DL_SERV_BEAM_ID_BEAM_01')
;

INSERT INTO emperf_map(container, disp_number, disp_name) VALUES
 ("0x1730" , "disp_0", "L2-LO")
,("0x1730" , "disp_1", "L2-LO")
,("0x1730" , "disp_2", "L2-PS")
,("0x1730" , "disp_3", "L2-PS")
,("0x1730" , "disp_4", "L2-PS")
,("0x1730" , "disp_5", "L2-PS")
,("0x1730" , "disp_6", "L2-PS")
,("0x1730" , "disp_7", "L2-PS")
,("0x1730" , "disp_8", "L2-PS")

,("0x1731" , "disp_1", "L2-HI")
,("0x1731" , "disp_2", "L2-HI")

,("0x1732" , "disp_0", "L2-LO")
,("0x1732" , "disp_1", "L2-LO")
,("0x1732" , "disp_2", "L2-PS")
,("0x1732" , "disp_3", "L2-PS")
,("0x1732" , "disp_4", "L2-PS")
,("0x1732" , "disp_5", "L2-PS")
,("0x1732" , "disp_6", "L2-PS")
,("0x1732" , "disp_7", "L2-PS")
,("0x1732" , "disp_8", "L2-PS")

,("0x1733" , "disp_1", "L2-HI")
,("0x1733" , "disp_2", "L2-HI")
;

COMMIT;

--------------------------------------------------
-- ALTER TABLE COMMANDS HERE
--------------------------------------------------
BEGIN TRANSACTION;

ALTER TABLE kpi RENAME COLUMN kpi_id TO kpi_uid;

ALTER TABLE kpi RENAME COLUMN kpi_name TO kpi_id;

ALTER TABLE kpi ADD COLUMN kpi_name TEXT;

ALTER TABLE software ADD COLUMN sw_release TEXT;

COMMIT;

--------------------------------------------------
--  CREATE VIEW COMMANDS HERE
--------------------------------------------------
BEGIN TRANSACTION;

CREATE VIEW view_kpi_tc_sw
AS
select kpi_testcase.testcase_id,
       kpi_testcase.testname,
       kpi_testcase.testdate,
       kpi_testcase.kpi_id,
       kpi_testcase.kpi_name,
       kpi_testcase.kpi_distname,
       kpi_testcase.kpi_value,
	   software.gnb_load, 
	   software.sw_release
from
(	
    SELECT  testcase.testcase_id,
            testname,
            testdate,
            kpi_id,
            kpi_name,
            kpi_distname,
            kpi_value
    FROM testcase
        LEFT JOIN kpi
            ON kpi.testcase_id=testcase.testcase_id
        ORDER BY testdate DESC, kpi_name ASC
) as kpi_testcase
left join software
on kpi_testcase.testcase_id=software.testcase_id

COMMIT;
