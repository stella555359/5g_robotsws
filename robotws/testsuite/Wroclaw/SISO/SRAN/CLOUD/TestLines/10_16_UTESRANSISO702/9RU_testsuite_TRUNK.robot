*** Settings ***
Documentation    Suite documentation
...  Author: marek.oleksiewicz@nokia.com
...  Maintainer: marek.oleksiewicz@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/LOGS/Cloud_LOGS_BlackBox_enhancements_testing_for_POST_data.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot
Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Fan_Speed_Counters_Monitoring.robot
Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering.robot
Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Thermal_Counters_Monitoring.robot
Resource    ../../TestCases/LOGS/Cloud_LOGS_Snapshot_Collection_During_Fail_Safe_Mode.robot
Resource    ../../TestCases/SWM/Cloud_SWM_Radio_unit_software_update_during_fail_safe_mode.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=True

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/TRUNK/vCU_TRUNK.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/TRUNK/vDU_TRUNK.xml

${CCR_LOCATION}      wg

${FHGW_IP}=          10.42.185.86
${FHGW_USERNAME}=    toor4nsn
${FHGW_PASSWORD}=    Fhgw@nokia1243
${FHGW_PORT}=        22

${VDU_URL}    https://10.42.126.78/
${vDU_OAM_password}  Nokia@123
${TEST_RUN_COUNT}=      10
${TEST_RUN_COUNT_2}=    3
@{RMOD_SN_LIST}=  DC1946001U2
@{RMOD_SN_LIST_FAN}=
...    LR241802190
...    DC1946001U2
...    K9200215156
@{RMOD_SN_LIST_FAN_T}=
...    1M202303622
...    LR241802190
...    DC1946001U2
...    K9200215156
...    L1181111027
...    K9190632475
...    EA202151829
...    K9200215156
...    BL2106G109T

@{L1181111027_OFF}   4  1  1  1  1  1
@{K9190632475_OFF}   1  4  1  1  1  1
@{DC1946001U2_OFF}   1  1  4  1  1  1
@{EA202151829_OFF}   1  1  1  4  1  1
@{LR241802190_OFF}   1  1  1  1  4  1
@{1M202303622_OFF}   1  1  1  1  1  4

@{L1181111027_ON}   1  1  1  1  1  1
@{K9190632475_ON}   1  1  1  1  1  1
@{DC1946001U2_ON}   1  1  1  1  1  1
@{EA202151829_ON}   1  1  1  1  1  1
@{LR241802190_ON}   1  1  1  1  1  1
@{1M202303622_ON}   1  1  1  1  1  1

&{SWITCH_OFF_ALL_DICT}    L1181111027=@{L1181111027_OFF}
...  K9190632475=@{K9190632475_OFF}
...  DC1946001U2=@{DC1946001U2_OFF}
...  EA202151829=@{EA202151829_OFF}
...  LR241802190=@{LR241802190_OFF}
...  1M202303622=@{1M202303622_OFF}

&{SWITCH_ON_ALL_DICT}    L1181111027=@{L1181111027_ON}
...  K9190632475=@{K9190632475_ON}
...  DC1946001U2=@{DC1946001U2_ON}
...  EA202151829=@{EA202151829_ON}
...  LR241802190=@{LR241802190_ON}
...  1M202303622=@{1M202303622_ON}

*** Test Cases ***
[CB011178][1.0] Automated_AIC_RF_reset_from_GUI
    [Setup]  AiC Test Setup
    RMODs Reset From GUI Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    [Teardown]   AiC Test Teardown

[CB011178][1.0] Automated_AIC_RF_Power_Reset
    [Setup]   AiC Test Setup
    RMODs Power Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    [Teardown]   AiC Test Teardown

[CB011178][1.0] Automated_AIC_vDU_reset
    [Setup]   AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT_2}
    [Teardown]   AiC Test Teardown

[CB011178][1.0] Automated_AIC_vDU_commissioning
    [Setup]   AiC Test Setup
    TC__Cloud_CM_vDU_Commissioning  ${VDU_SCF_PATH}
    [Teardown]   AiC Test Teardown

[CB011178][1.0] Automated_AIC_RF_hot_remove_insert
    [Setup]   AiC Test Setup
    RMODs Hot Remove Hot Insert Loop Execution
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  switch_settings_off=${SWITCH_OFF_ALL_DICT}
    ...  switch_settings_on=${SWITCH_ON_ALL_DICT}
    ...  run_count=${TEST_RUN_COUNT}
    [Teardown]   AiC Test Teardown

[CB012144][1.0] General_SiSo_Auto_Cloud_RU_BlackBox_enhancements_testing_for_POST_data
    [Setup]   AiC Test Setup
    TC__Cloud_LOGS_BlackBox_enhancements_testing_for_POST_data    scfc_file_path=${VDU_SCF_PATH}    rmod_ids=K9190632475
    [Teardown]   AiC Test Teardown

[CB008967][2.0] General_SiSo_Auto_Cloud_Radio_Module_Fan_Speed_Counters_Monitoring
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Radio_Module_Fan_Speed_Counters_Monitoring
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST_FAN}
    [Teardown]   AiC Test Teardown

[CB008967][1.0] General_SiSo_Auto_Cloud_Radio_Module_Thermal_Counters_Monitoring
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Radio_Module_Thermal_Counters_Monitoring
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST_FAN_T}
    [Teardown]   AiC Test Teardown

[CB011178][1.0] General_SiSo_Auto_Cloud_PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST_FAN_T}
    [Teardown]  AiC Test Teardown

[CNI-129368][1.0] Automated_AIC_SiSo_TEST_Radio_unit_snapshot_collection_and SM_Radio_unit_remote_during_fail_safe_mode
    [Setup]  AiC Test Setup
    TC__LOGS_Snapshot_Collection_During_Fail_Safe_Mode
    ...  rmod_ids=L1181111027
    ...  scfc_file_path=${VDU_SCF_PATH}
    [Teardown]   AiC Test Teardown

[CNI-129368][1.0] Automated_AIC_SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
    [Setup]  AiC Test Setup
    TC__Cloud_SWM_Radio_Unit_Software_Update_During_Fail_Safe_Mode
    ...  rmod_ids=L1181111027
    ...  scfc_file_path=${VDU_SCF_PATH}
    [Teardown]   AiC Test Teardown
