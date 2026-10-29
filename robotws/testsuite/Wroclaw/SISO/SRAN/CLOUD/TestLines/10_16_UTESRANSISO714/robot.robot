*** Settings ***
Documentation
...  Author: ka
...  Maintainer: ka

Library    BuiltIn


Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot
Resource    ../../TestCases/CALL/Cloud_CALL_LTE_Data_Transfer.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=False

*** Variables ***
${VDU_SCF_PATH}     ${CURDIR}/scfc_du.xml
${VDU_URL}    https://10.44.192.151/
${vDU_OAM_password}  Nokia@123
${TEST_RUN_COUNT}=      1


*** Test Cases ***
[CB00XXXX][1.0] LTE_CALL
    [Setup]   Lte Cloud Test Setup
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
    TC__Cloud_CALL_LTE_Data_Transfer
    ...  lte_scfc_file_path=${VDU_SCF_PATH}
    ...  cells_yaml_path=${CURDIR}/cells.yaml
    [Teardown]   Lte Cloud Test Teardown
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}

#[1.0] Automated_AIC_vDU_commissioning
#    [Setup]   AiC Test Setup
#    TC__Cloud_CM_vDU_Commissioning  ${VDU_SCF_PATH}
#    [Teardown]   AiC Test Teardown
#
#[1.0] Automated_AIC_vDU_reset
#    [Setup]   AiC Test Setup
#    vDU Reset Operation Loop Execution
#    ...  scfc_file_path=${VDU_SCF_PATH}
#    ...  run_count=${TEST_RUN_COUNT}

