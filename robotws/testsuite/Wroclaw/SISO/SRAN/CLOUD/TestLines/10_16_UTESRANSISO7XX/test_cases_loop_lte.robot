*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/lte_cloud_setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot

Suite Setup       Lte Cloud Suite Setup
Suite Teardown    Lte Cloud Suite Teardown

*** Variables ***
# EXAMPLE VARIABLES USED IN TEST CASES.
# REMEMBER TO ALWAYS DECLARE ONLY THOSE VARIABLES THAT YOU USE IN TEST CASES.

# Configuration files
${LTE_VDU_SCF_PATH}=         ${CURDIR}/SCF_LTE/SCFC_vDU.xml

# Count of test case executions
${TEST_RUN_COUNT}=      2

#IN THE EXAMPLE TEST SUITE IN THE TEST CASES THE MOST FREQUENTLY USED ARGUMENTS WERE SHOWN.
#IF YOU WANT TO CHECK WHAT ARGUMENTS CAN BE USED, ALWAYS CHECK THE TEST CASE DOCUMENTATION SECTION
*** Test Cases ***
# Example without logs collection when test case PASSED
[1][1.0] General_SiSo_Auto_Cloud_LTE_vDU_Reset_Loop_Example_1
    LTE vDU Reset Operation Loop Execution
    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    ...  get_teardown_logs=${False}
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}

# Example with always logs collection
[1][1.0] General_SiSo_Auto_Cloud_LTE_vDU_Reset_Loop_Example_2
    LTE vDU Reset Operation Loop Execution
    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    ...  get_teardown_logs=${True}
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
