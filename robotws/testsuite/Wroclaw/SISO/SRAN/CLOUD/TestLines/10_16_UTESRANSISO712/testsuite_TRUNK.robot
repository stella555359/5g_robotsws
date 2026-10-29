*** Settings ***
Documentation
...  Author: kamil.gralinski@nokia.com
...  Maintainer: kamil.gralinski@nokia.com

Library    BuiltIn


Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Delta_Recommissioning.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=False

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/vCU_TRUNK.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/vDU_TRUNK.xml
${DELTA_SCF_PATH}   ${CURDIR}/SCF/vDU_TRUNK.xml
${VDU_URL}    https://10.44.192.222/
${vDU_OAM_password}  Nokia@123
${TEST_RUN_COUNT}=      1


*** Test Cases ***
[CB013302][1.0] Automated_AIC_RF_Module_lock_unlock
    [Setup]  AiC Test Setup
    RMOD Lock Unlock And Check Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB013302][1.0] Automated_AIC_Cell_block_unblock
    [Setup]  AiC Test Setup
    Cell Block Unblock And Check Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB010259-CR-C.1][1.0] Automated_AIC_RF_reset_from_GUI
    [Setup]  AiC Test Setup
    RMODs Reset From GUI Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB013302][1.0] Automated_AIC_RF_reset_from_GUI
    [Setup]  AiC Test Setup
    RMODs Reset From GUI Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB013302][1.0] Automated_AIC_RF_Power_Reset
    [Setup]   AiC Test Setup
    RMODs Power Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB013302][1.0] Automated_AIC_vDU_reset
    [Setup]   AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB013302][1.0] Automated_AIC_vDU_delta_recommissioning
    [Setup]   AiC Test Setup
    TC__Cloud_vDU_Delta_Recommissioning  ${VDU_SCF_PATH}  ${DELTA_SCF_PATH}
    [Teardown]   AiC Test Teardown

[CB013302][1.0] Automated_AIC_vDU_commissioning
    [Setup]   AiC Test Setup
    TC__Cloud_CM_vDU_Commissioning  ${VDU_SCF_PATH}
    [Teardown]   AiC Test Teardown

[CB013302][1.0] Automated_AIC_RF_hot_remove_insert
    [Setup]   AiC Test Setup
    RMODs Hot Remove Hot Insert Loop Execution
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  switch_settings_off=${SWITCH_OFF_ALL_DICT}
    ...  switch_settings_on=${SWITCH_ON_ALL_DICT}
    ...  run_count=${TEST_RUN_COUNT}
