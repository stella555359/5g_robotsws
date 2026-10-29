*** Settings ***
Documentation
...   Test cases run on 7_16_UTE5GHASTROTL23 (multi gNB with TL26)

Resource        ../CB007517/CB007517-B.robot
Resource        ../CB009205/CB009205-B.robot
Resource        ./regression_keywords.robot
Library        ./python_functions.py
Library        ../../VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py
Library         testsuite/Wroclaw/RRM/resources/csv4all_helpers.py

Suite Setup     Setup Inter Gnb Configuration

Suite Teardown    Disable Inter Gnb Configuration

Test Setup      Run Keywords
...    Set TESTNAME without spaces    AND
...    Start Collecting Syslog    AND
...    Check onAir BTS status


Test Teardown   Run Keywords
...    Collect Syslog    AND
...    Run Keyword If Test Failed    AdminUtils.Collect Snapshot    ${OUTPUT_DIR}/${TEST_NAME}/snapshot.zip    timeout=600    AND
...    Add Scout Data Info To Testcase    AND
...    Run Keyword If Test Passed    Find Suspicious Prints In Passed Test

Test Timeout    60 minutes


*** Test Cases ***
[1]CB007517-C_07_A4_reconfig_after_re-establishment
    [Tags]    SCF_7517
    CB007517-C_07_A4_reconfig_after_re-establishment

[1]CB007517-C_08_A4_meas_triggered_Xn_HO_and_NG_HO_counters_PCMD
    [Tags]    SCF_7517
    CB007517-C_08_A4_meas_triggered_Xn_HO_and_NG_HO_counters_PCMD

[1]CB009205-B_04_Xn_HO_with_A1_meas_configured
    [Tags]    SCF_7517
    CB009205-B_04_Xn_HO_with_A1_meas_configured

[1]CB007517-C_30_A4_meas_triggered_Xn_HO_and_NG_HO_barred_cell
    [Tags]    SCF_7517
    CB007517-C_30_A4_meas_triggered_Xn_HO_and_NG_HO_barred_cell
