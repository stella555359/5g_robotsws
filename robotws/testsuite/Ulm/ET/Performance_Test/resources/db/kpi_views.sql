
-- Copyright (c) 2024 Nokia. All rights reserved.

-- UPDATE db_interface_retrieve.py to whenever there is change in schema!

BEGIN TRANSACTION;


DROP VIEW view_testline_with_type;
CREATE VIEW view_testline_with_type
AS
    SELECT testline_name,
           testline_topology,
           testline_variant
    FROM testline
        LEFT JOIN testline_type
            ON testline_type.testline_type_id=testline.testline_type_id;


DROP VIEW view_detailed_testcase;
CREATE VIEW view_detailed_testcase
AS
    SELECT
    DISTINCT testcase.testcase_id,
    BUILD_ID, JOB_DESCRIPTION,
    testcase.testname,pass_map.mapping as 'verdict',
    view_testcase_results.scout_id as 'scout',
    view_testcase_results.hash_scf as 'hash_scf',
    view_testcase_results.hash_run_parameters as 'hash_run_parameters',
    view_testcase_results.hash_testcase as 'hash_testcase',
    view_testcase_results.failure_cause, view_testcase_results.total_ue_attached,
        view_testcase_results.cell_stats_nr_ul_mbps as '[egate] ul mbps',view_testcase_results.cell_stats_nr_dl_mbps as '[egate] dl mbps',
    view_testcase_results.kpi_nr_5095a as '[kpi] ul mbps', view_testcase_results.kpi_nr_5094a as '[kpi] dl mbps',
    trf_direction,lua,view_testcase_parameter.entry,ue_per_cell,start_cell,end_cell,traffic_sleep,active_cells,
        ul_datarate,dl_datarate,rate,tolerance,end_ue,num_cells,total_active_cells,total_active_ue,duplex,
    testline_name,
    testline_topology, testline_variant,
    gnb_load, gnb_hw, ap_load, ap_hw, vcu_oc_version, duplex_mode,
    JOB_NAME,testcase.testdate

    FROM testcase
        LEFT JOIN view_testcase_parameter
            ON testcase.testcase_id=view_testcase_parameter.testcase_id
        LEFT JOIN testline
            ON testline.testcase_id=view_testcase_parameter.testcase_id
        LEFT JOIN testline_type
            ON testline_type.testline_type_id=testline.testline_type_id
        LEFT JOIN software
            ON software.testcase_id=view_testcase_parameter.testcase_id
        LEFT JOIN testcase_jenkins_data
            ON testcase_jenkins_data.testcase_id=view_testcase_parameter.testcase_id
        LEFT JOIN view_testcase_results
            ON view_testcase_results.testcase_id=view_testcase_parameter.testcase_id
        LEFT JOIN pass_map
            ON pass_map.pass=testcase.pass
        ORDER BY
            view_testcase_parameter.testdate DESC;


DROP VIEW view_testnames;
CREATE VIEW view_testnames
AS
    SELECT DISTINCT testname, testline_topology, testline_variant
    FROM testcase
        LEFT JOIN testline
            ON testline.testcase_id = testcase.testcase_id
        LEFT JOIN testline_type
            ON testline_type.testline_type_id=testline.testline_type_id
    ORDER BY testname;

DROP VIEW view_testcase_results;
CREATE VIEW view_testcase_results
AS
    SELECT DISTINCT testcase.testcase_id, testcase.testdate, testcase.testname,
        failure_cause.testcase_results_value as 'failure_cause',
        scout_id.testcase_parameter2_value as 'scout_id',
        hash_scf.testcase_parameter2_value as 'hash_scf',
        hash_testcase.testcase_parameter2_value as 'hash_testcase',
        hash_run_parameters.testcase_parameter2_value as 'hash_run_parameters',
        cell_stats_nr_ul_mbps.testcase_results_value as 'cell_stats_nr_ul_mbps',
        cell_stats_nr_dl_mbps.testcase_results_value as 'cell_stats_nr_dl_mbps',
        total_ue_attached.testcase_results_value as 'total_ue_attached',
        kpi_nr_5094a.kpi_value as 'kpi_nr_5094a', kpi_nr_5095a.kpi_value as 'kpi_nr_5095a'
        FROM testcase
            LEFT JOIN (
                SELECT DISTINCT testcase_results.testcase_results_value, testcase_results.testcase_id
                    FROM testcase_results
                    WHERE testcase_results_name='total_ue_attached'
            ) as total_ue_attached
                ON total_ue_attached.testcase_id=testcase.testcase_id
            LEFT JOIN (
                SELECT DISTINCT testcase_results.testcase_results_value, testcase_results.testcase_id
                    FROM testcase_results
                    WHERE testcase_results_name='failure_cause'
            ) as failure_cause
                ON failure_cause.testcase_id=testcase.testcase_id
            LEFT JOIN (
                SELECT DISTINCT testcase_results.testcase_results_value, testcase_results.testcase_id
                    FROM testcase_results
                    WHERE testcase_results_name='cell_stats_nr_ul_mbps'
            ) as cell_stats_nr_ul_mbps
                ON cell_stats_nr_ul_mbps.testcase_id=testcase.testcase_id
            LEFT JOIN (
                SELECT DISTINCT testcase_results.testcase_results_value, testcase_results.testcase_id
                    FROM testcase_results
                    WHERE testcase_results_name='cell_stats_nr_dl_mbps'
            ) as cell_stats_nr_dl_mbps
                ON cell_stats_nr_dl_mbps.testcase_id=testcase.testcase_id
            LEFT JOIN (
                SELECT DISTINCT kpi.kpi_value, kpi.testcase_id
                    FROM kpi
                    WHERE kpi.kpi_name LIKE '%_5095a'
            ) as kpi_nr_5095a
                ON kpi_nr_5095a.testcase_id=testcase.testcase_id
            LEFT JOIN (
                SELECT DISTINCT kpi.kpi_value, kpi.testcase_id
                    FROM kpi
                    WHERE kpi.kpi_name LIKE '%_5094a'
            ) as kpi_nr_5094a
                ON kpi_nr_5094a.testcase_id=testcase.testcase_id
            LEFT JOIN (
                SELECT DISTINCT testcase_parameter2.testcase_parameter2_name, testcase_parameter2.testcase_parameter2_value, testcase_parameter2.testcase_id
                    FROM testcase_parameter2
                    WHERE testcase_parameter2.testcase_parameter2_name='scout_id'
            ) as scout_id
                ON scout_id.testcase_id=testcase.testcase_id
            LEFT JOIN (
                SELECT DISTINCT testcase_parameter2.testcase_parameter2_name, testcase_parameter2.testcase_parameter2_value, testcase_parameter2.testcase_id
                    FROM testcase_parameter2
                    WHERE testcase_parameter2.testcase_parameter2_name='hash_scf'
            ) as hash_scf
                ON hash_scf.testcase_id=testcase.testcase_id
            LEFT JOIN (
                SELECT DISTINCT testcase_parameter2.testcase_parameter2_name, testcase_parameter2.testcase_parameter2_value, testcase_parameter2.testcase_id
                    FROM testcase_parameter2
                    WHERE testcase_parameter2.testcase_parameter2_name='hash_testcase'
            ) as hash_testcase
                ON hash_testcase.testcase_id=testcase.testcase_id
            LEFT JOIN (
                SELECT DISTINCT testcase_parameter2.testcase_parameter2_name, testcase_parameter2.testcase_parameter2_value, testcase_parameter2.testcase_id
                    FROM testcase_parameter2
                    WHERE testcase_parameter2.testcase_parameter2_name='hash_run_parameters'
            ) as hash_run_parameters
                ON hash_run_parameters.testcase_id=testcase.testcase_id
        ORDER BY testcase.testcase_id DESC;


DROP VIEW view_testcase_parameter;
CREATE VIEW view_testcase_parameter
AS
    SELECT  testcase.testcase_id,
            testcase.testdate,
            trf_direction,
            lua,
            testcase_parameter.entry,
            ue_per_cell,
            start_cell,
            end_cell,
            traffic_sleep,
            active_cells,
            ul_datarate,
            dl_datarate,
            rate,
            tolerance,
            end_ue,
            num_cells,
            total_active_cells,
            total_active_ue,
            duplex
    FROM testcase
        LEFT JOIN testcase_parameter
            ON testcase_parameter.testcase_id=testcase.testcase_id
        ORDER BY
            testdate DESC;


DROP VIEW view_testcase_flags;
CREATE VIEW view_testcase_flags
AS
    SELECT testcase.testcase_id,
           testdate,
           testname,
           pass,
           testcase_flags_name,
           testcase_flags_value
    FROM testcase
        JOIN testcase_flags
            ON testcase_flags.testcase_id=testcase.testcase_id
        ORDER BY testdate DESC;


DROP VIEW view_kpi;
CREATE VIEW view_kpi
AS
    SELECT  testcase.testcase_id,
            testname,
            testdate,
            kpi_name,
            kpi_distname,
            kpi_value
    FROM testcase
        LEFT JOIN kpi
            ON kpi.testcase_id=testcase.testcase_id
        ORDER BY testdate DESC, kpi_name ASC;


DROP VIEW view_emperf;
CREATE VIEW view_emperf
AS
    SELECT  testcase.testcase_id,
            testname,
            testdate,
            emperf.container,
            disp.disp_number,
            emperf_map.disp_name,
            average,
            minimum,
            maximum
    FROM testcase
        LEFT JOIN emperf
            ON emperf.testcase_id=testcase.testcase_id
        LEFT JOIN disp
            ON disp.emperf_id=emperf.emperf_id
        LEFT JOIN emperf_map
            ON emperf.container=emperf_map.container
            AND disp.disp_number=emperf_map.disp_number
        ORDER BY
            testdate DESC, emperf.container ASC;

DROP VIEW view_pmcounters;
CREATE VIEW view_pmcounters
AS
    SELECT testcase.testcase_id,
           testcase.testdate,
           testcase.testname,
           testcase.pass,
           pmcounter.piid_name,
           pmcounter.distname,
           pmcounter.piid_value,
           pmcounter_map.category,
           pmcounter_map.desciption
    FROM testcase
        LEFT JOIN pmcounter
            ON pmcounter.testcase_id=testcase.testcase_id
        LEFT JOIN pmcounter_map
            ON pmcounter_map.piid=pmcounter.piid_name
        ORDER BY testcase.testdate DESC, pmcounter.piid_name ASC, pmcounter.distname ASC;

COMMIT;
