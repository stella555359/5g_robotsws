*** Settings ***
Documentation
...  Author: mateusz.blicharski@nokia.com
...  Maintainer: mateusz.blicharski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/LOGS/Cloud_LOGS_BlackBox_enhancements_testing.robot
Resource    ../../TestCases/LOGS/Cloud_LOGS_BlackBox_enhancements_testing_for_POST_data.robot
Resource   ../../TestCases/CALL/Cloud_CALL_NR_Data_Transfer.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Delta_Recommissioning.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/25R1/vCU_8486.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/25R1/vDU_8486.xml
${DELTA_SCF_PATH}   ${CURDIR}/SCF/RU_recommision_25R1.xml

@{BL2331N478A_OFF}        1  1  1  4  1  2
@{BL2331N478A_ON}         1  1  1  1  1  2

@{L1241203650_OFF}        1  1  1  1  1  4
@{L1241203650_ON}         1  1  1  1  1  2

@{K9181522902_OFF}        1  1  1  1  4  2
@{K9181522902_ON}         1  1  1  1  1  2

&{SWITCH_OFF_ALL_DICT}   BL2331N478A=@{BL2331N478A_OFF}
...    L1241203650=@{L1241203650_OFF}
...    K9181522902=@{K9181522902_OFF}
&{SWITCH_ON_ALL_DICT}   BL2331N478A=@{BL2331N478A_ON}
...    L1241203650=@{L1241203650_ON}
...    K9181522902=@{K9181522902_ON}

${TEST_RUN_COUNT}=      3
${vDU_OAM_password}  Nokia@123
${VDU_URL}           https://10.44.169.52/
${CELLS_YAML_PATH}  ${CURDIR}/cells.yaml
#@{cell_list}    MRBTS-8486/NRBTS-8486/NRCELL-3
#...    MRBTS-8486/NRBTS-8486/NRCELL-5
@{cell_ids}    139034627  139034629
${CELLS_COUNT}=   18

*** Test Cases ***
[CB010259-CR-C.1][1.0] Automated_AIC_RF_Module_lock_unlock
    [Setup]  AiC Test Setup
    RMOD Lock Unlock And Check Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}

[CB010259-CR-C.1][1.0] Automated_AIC_Cell_block_unblock
    [Setup]  AiC Test Setup
    Cell Block Unblock And Check Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB010259-CR-C.1][1.0] Automated_AIC_RF_reset_from_GUI
    [Setup]  AiC Test Setup
    RMODs Reset From GUI Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB010259-CR-C.1][1.0] Automated_AIC_vDU_delta_recommissioning
    [Setup]   AiC Test Setup
    TC__Cloud_vDU_Delta_Recommissioning  ${VDU_SCF_PATH}  ${DELTA_SCF_PATH}  False
    [Teardown]   AiC Test Teardown

[CB010259-CR-C.1][1.0] Automated_AIC_vDU_commissioning
    [Setup]   AiC Test Setup
    TC__Cloud_CM_vDU_Commissioning  ${VDU_SCF_PATH}
    [Teardown]   AiC Test Teardown

[CB010259-CR-C.1][1.0] Automated_AIC_RF_hot_remove_insert
    [Setup]   AiC Test Setup
    RMODs Hot Remove Hot Insert Loop Execution
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  switch_settings_off=${SWITCH_OFF_ALL_DICT}
    ...  switch_settings_on=${SWITCH_ON_ALL_DICT}
    ...  run_count=10

[CB010259-CR-C.1][1.0] Automated_AiC_CALL_NR_Data_Transfer
    [Setup]   AiC Test Setup
    TC__Cloud_CALL_NR_Data_Transfer
    ...    scfc_file_path=${VDU_SCF_PATH}
    ...    cells_yaml_path=${CELLS_YAML_PATH}
    ...    cell_ids=@{cell_ids}
    [Teardown]   AiC Test Teardown

[CB010259-CR-C.1][1.0] Automated_AIC_RF_Power_Reset
    [Setup]   AiC Test Setup
    RMODs Power Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=10

[CB010259-CR-C.1][1.0] Automated_AIC_vDU_reset
    [Setup]   AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=10

[CB010259-CR-C.1][1.0] Automated_AIC_RU_BlackBox_enhancements_testing
    [Setup]  AiC Test Setup
    TC__Cloud_LOGS_BlackBox_enhancements_testing  scfc_file_path=${VDU_SCF_PATH}  rmod_ids=BL2331N478A

[AHFII][1.0] Automated_AIC_SiSo_TEST_Radio_unit_snapshot_collection_and SM_Radio_unit_remote_during_fail_safe_mode
    [Setup]  AiC Test Setup
    Snapshot Collection During Fail Safe Mode Loop Execution
    ...  rmod_ids=BL2331N478A
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=1
    [Teardown]   AiC Test Teardown

[ARPB][1.0] Automated_AIC_SiSo_TEST_Radio_unit_snapshot_collection_and SM_Radio_unit_remote_during_fail_safe_mode
    [Setup]  AiC Test Setup
    Snapshot Collection During Fail Safe Mode Loop Execution
    ...  rmod_ids=L1241203650
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=1
    [Teardown]   AiC Test Teardown

[AHFII][1.0] Automated_AIC_SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
    [Setup]  AiC Test Setup
    Radio Unit Software Update During Fail Safe Mode Loop Execution
    ...  rmod_ids=BL2331N478A
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=1
   [Teardown]   AiC Test Teardown

[ARPB][1.0] Automated_AIC_SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
    [Setup]  AiC Test Setup
    Radio Unit Software Update During Fail Safe Mode Loop Execution
    ...  rmod_ids=L1241203650
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=1
    [Teardown]   AiC Test Teardown

[CB010648][1.0] Automated_AIC_RU_BlackBox_enhancements_testing_for_POST_data
    [Setup]  AiC Test Setup
    TC__Cloud_LOGS_BlackBox_enhancements_testing_for_POST_data  scfc_file_path=${VDU_SCF_PATH}  rmod_ids=BL2331N478A
