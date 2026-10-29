*** Settings ***
Documentation
...  Author: ka
...  Maintainer: ka

Library    BuiltIn

Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../resources/Robot/lte_cloud_setup_teardown.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_LTE_vDU_Reset.robot
Resource    ../../TestCases/CALL/Cloud_CALL_LTE_Data_Transfer.robot

Suite Setup       Lte Cloud Suite Setup
Suite Teardown    Lte Cloud Suite Teardown

*** Variables ***
${LTE_VDU_SCF_PATH}     ${CURDIR}/scfc_du.xml
${TEST_RUN_COUNT}=      12


*** Test Cases ***
[CB00XXXX][1.0] LTE_CALL
    [Setup]   Lte Cloud Test Setup
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
    TC__Cloud_CALL_LTE_Data_Transfer
    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
    ...  cells_yaml_path=${CURDIR}/cells.yaml
    [Teardown]   Lte Cloud Test Teardown
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}


#[1.0] Automated_AIC_vDU_Reset
#    [Setup]   Lte Cloud Test Setup
#    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
#    TC__Cloud_STARTUP_LTE_vDU Reset
#    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
#    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
#    [Teardown]   Lte Cloud Test Teardown
#    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}

[1][1.0] General_SiSo_Auto_Cloud_LTE_vDU_Reset
    LTE vDU Reset Operation Loop Execution
    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    ...  get_teardown_logs=${False}
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
