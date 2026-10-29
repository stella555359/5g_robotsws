*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown

*** Variables ***
# EXAMPLE VARIABLES USED IN TEST CASES.
# REMEMBER TO ALWAYS DECLARE ONLY THOSE VARIABLES THAT YOU USE IN TEST CASES.

# Configuration files
${VDU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vDU.xml
${VCU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vCU.xml

# Used with "TC__Cloud_vDU_Delta_Recommissioning"
${VDU_DELTA_FILE_PATH}=      ${CURDIR}/SCF/SCFC_vDU_delta.json

# Radio modules serial numbers list
# Used with, for example:
@{RMOD_SN_LIST}=  K9181046216  K9175116255

# Optical switch settings
# Used with "TC__Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert"
@{K9181046216_OFF}=      1  1  4  1  1  1
@{K9181046216_ON}=       1  1  1  1  1  1
&{SWITCH_OFF_ALL_DICT}=  K9181046216=@{K9181046216_OFF}
&{SWITCH_ON_ALL_DICT}=   K9181046216=@{K9181046216_ON}

# Count of test case executions
${TEST_RUN_COUNT}=      2

#IN THE EXAMPLE TEST SUITE IN THE TEST CASES THE MOST FREQUENTLY USED ARGUMENTS WERE SHOWN.
#IF YOU WANT TO CHECK WHAT ARGUMENTS CAN BE USED, ALWAYS CHECK THE TEST CASE DOCUMENTATION SECTION
*** Test Cases ***
# Example without logs collection when test case PASSED
[1][1.0] Automated_AIC_Cell_Block_Unblock
    Cell Block Unblock And Check Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  get_kpi=${True}
    ...  run_count=${TEST_RUN_COUNT}
    ...  get_teardown_logs=${True}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}

# Example with always logs collection
[1][1.0] Automated_AIC_RF_Module_Lock_Unlock
    RMOD Lock Unlock And Check Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_rmods_sn=${RMOD_SN_LIST}
    ...  run_count=${TEST_RUN_COUNT}
    ...  get_teardown_logs=${True}

[1][1.0] General_SiSo_Auto_Cloud_Radio_Modules_Reset
    Radio Modules Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_rmod_sn_list=${RMOD_SN_LIST}
    ...  get_kpi=${True}
    ...  run_count=${TEST_RUN_COUNT}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}

# All CBTS radio modules from SCF file
[1][1.0] Automated_AIC_RF_Reset_From_GUI_Example_1
    RMODs Reset From GUI Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  reset_timeout=400
    ...  jwt_expiration_time=125
    ...  run_count=${TEST_RUN_COUNT}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}

# CBTS radio modules listed in ${RMOD_SN_LIST}
[1][1.0] Automated_AIC_RF_Reset_From_GUI_Example_2
    RMODs Reset From GUI Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_rmod_sn_list=${RMOD_SN_LIST}
    ...  reset_timeout=400
    ...  jwt_expiration_time=125
    ...  run_count=${TEST_RUN_COUNT}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}

# Random radio modules from SCF file
[1][1.0] Automated_AIC_RF_Reset_From_GUI_Example_3
    RMODs Reset From GUI Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_rmod_sn_count=3
    ...  reset_timeout=400
    ...  jwt_expiration_time=125
    ...  run_count=${TEST_RUN_COUNT}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}

[1][1.0] Automated_AIC_RF_Hot_Remove_Insert
    RMODs Hot Remove Hot Insert Loop Execution
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  switch_settings_off=${SWITCH_OFF_ALL_DICT}
    ...  switch_settings_on=${SWITCH_ON_ALL_DICT}
    ...  run_count=${TEST_RUN_COUNT}

[1][1.0] Automated_AIC_RF_Power_Reset
    RMODs Power Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
    ...  run_count=${TEST_RUN_COUNT}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}

[1][1.0] Automated_AIC_vDU_Reset
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}

[1][1.0] Automated_AIC_vCU_Reset
    vCU Reset Operation Loop Execution
    ...  vcu_scfc_file_path=${VCU_SCF_PATH}
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  vcu_connection=${VCU_CONNECTION_DEFAULT}

[1][1.0] Automated_AIC_vDU_commissioning
    vDU Commissioning Loop Execution
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    ...  get_teardown_logs=${False}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}

[1][1.0] Automated_AIC_vDU_Delta_Recommissioning
    vDU Delta Recommissioning Loop Execution
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  delta_file_path=${VDU_DELTA_FILE_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    ...  get_teardown_logs=${False}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}

[1][1.0] General_SiSo_Auto_Cloud_Rannic_Reset
    Rannic Reset Loop Execution
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
