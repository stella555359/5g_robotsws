*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.1.godlewski@nokia.com
...   Test cases execute on T-Mobile US #17 setup

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Resource        ./regression_keywords.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB014045/CB014045.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB014045/CVR_14045.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py
Variables        testsuite/Wroclaw/RRM/VRF_WRO2_T04/TOL_TMO_DALLAS/resources/test_constants.py

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/TOL_TMO_DALLAS/resources/sfp_monitoring.py

#Suite Setup    Set Global Variable    ${CURRENT_SCF}    SCF_DEFAULT


Test Setup      Run Keywords
...    Set TESTNAME without spaces  AND
...    Start Collecting Syslog

Test Teardown   Collect Syslog
#...    Run Keyword If Test Failed    AdminUtils.Collect Snapshot    ${OUTPUT_DIR}/${TEST_NAME}/snapshot.zip    timeout=600    AND
#...    Add Scout Data Info To Testcase    AND
#...    Run Keyword If Test Passed    Find Suspicious Prints In Passed Test

*** Test Cases ***
CB014045-A_B3_One_cell_one_UE_TDD_FR1_CP-OFDM_MCS_256QAM_Table_without_MPR_aware_UL_LA
    CB014045-A_B3_One_cell_one_UE_TDD_FR1_CP-OFDM_MCS_256QAM_Table_without_MPR_aware_UL_LA

CB014045_B_B2_online_modification_flag_UL_for_new_users
    CB014045_B_B2_online_modification_flag_UL_for_new_users

CB014045_Interworking_with_UL_Service_Aware_Scheduler
    CB014045_Interworking_with_UL_Service_Aware_Scheduler

CVR_CB014045_Interworking_with_Nominal_Bit_Rate
    CVR_CB014045_Interworking_with_Nominal_Bit_Rate

CB014045_Interworking_with_UL_2cc_CA
    CB014045_Interworking_with_UL_2cc_CA

