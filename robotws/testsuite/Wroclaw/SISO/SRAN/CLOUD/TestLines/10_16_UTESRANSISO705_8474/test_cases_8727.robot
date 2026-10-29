*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_LTE_vDU_Reset.robot
Resource    ../../TestCases/CM/Cloud_CM_LTE_vDU_Commissioning.robot
Resource    ../../resources/Robot/lte_cloud_setup_teardown.robot
Resource    ../../resources/variables.robot

Suite Setup       Lte Cloud Suite Setup
Suite Teardown    Lte Cloud Suite Teardown
                  ...  get_logs=${False}
                  ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}

*** Variables ***
${LTE_VDU_SCF_PATH}=    ${CURDIR}/SCF_8727/SCFC_vDU.xml
${DELTA_FILE_PATH}=     ${CURDIR}/SCF/SCFC_vDU_delta.json
@{RMOD_SN_LIST}=        RW232600741
${TEST_RUN_COUNT}=      2

*** Test Cases ***
[1][1.0] General_SiSo_Auto_Cloud_LTE_vDU_Reset
    [Setup]  Lte Cloud Test Setup
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
    TC__Cloud_STARTUP_LTE_vDU_Reset
    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
    [Teardown]  Lte Cloud Test Teardown
    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}

#[1][1.0] General_SiSo_Auto_Cloud_LTE_vDU_Commissioning
#    [Setup]  Lte Cloud Test Setup
#    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
#    TC__Cloud_CM_LTE_vDU_Commissioning
#    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
#    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
#    [Teardown]  Lte Cloud Test Teardown
#    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
#
#[1][1.0] General_SiSo_Auto_Cloud_LTE_vDU_Reset_Loop
#    [Setup]  Lte Cloud Test Setup
#    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
#    LTE vDU Reset Operation Loop Execution
#    ...  lte_scfc_file_path=${LTE_VDU_SCF_PATH}
#    ...  run_count=${TEST_RUN_COUNT}
#    ...  get_teardown_logs=${True}
#    ...  lte_vdu_connection=${LTE_VDU_CONNECTION_DEFAULT}
