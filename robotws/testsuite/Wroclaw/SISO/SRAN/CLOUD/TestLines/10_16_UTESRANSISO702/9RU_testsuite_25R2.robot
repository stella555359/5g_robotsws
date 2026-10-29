*** Settings ***
Documentation    Suite documentation
...  Author: marek.oleksiewicz@nokia.com
...  Maintainer: marek.oleksiewicz@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
#Resource    ../../resources/black_box/Automated_AIC_RU_BlackBox_enhancements_testing_for_POST_data.robot
Resource    ../../TestCases/LOGS/Cloud_LOGS_BlackBox_enhancements_testing_for_POST_data.robot
Resource    ../../TestCases/PM/Cloud_PM_PIM_Alarms_Triggering.robot
Resource    ../../TestCases/PM/Cloud_PM_PIMC_Counters.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot
Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Fan_Speed_Counters_Monitoring.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=True

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/25R2/vCU_25R2.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/25R2/vDU_25R2.xml

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
[CB011178][1.0] Automated_AIC_RF_Power_Reset
    [Setup]   AiC Test Setup
    RMODs Power Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    [Teardown]   AiC Test Teardown

[CB011178][1.0] Automated_AIC_RF_hot_remove_insert
    [Setup]   AiC Test Setup
    RMODs Hot Remove Hot Insert Loop Execution
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  switch_settings_off=${SWITCH_OFF_ALL_DICT}
    ...  switch_settings_on=${SWITCH_ON_ALL_DICT}
    ...  run_count=${TEST_RUN_COUNT}
    [Teardown]   AiC Test Teardown

[CB011178][1.0] Automated_AIC_SiSo_PM_PIMC_Counters
    [Setup]   AiC Test Setup
    TC__Cloud_PM_PIMC_Counters   scfc_file_path=${VDU_SCF_PATH}  rmod_sn=DC1946001U2
    [Teardown]   AiC Test Teardown

[CB011178][1.0] Automated_AIC_ PIM_Alarms_Triggering
    [Setup]   AiC Test Setup
    TC__Cloud_PM_PIM_Alarms_Triggering    scfc_file_path=${VDU_SCF_PATH}  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]   AiC Test Teardown

[CB012144][1.0] General_SiSo_Auto_Cloud_RU_BlackBox_enhancements_testing_for_POST_data
    [Setup]   AiC Test Setup
    TC__Cloud_LOGS_BlackBox_enhancements_testing_for_POST_data    scfc_file_path=${VDU_SCF_PATH}    rmod_ids=K9190632475
    [Teardown]   AiC Test Teardown

[CB008967][1.0] General_SiSo_Auto_Cloud_Radio_Module_Fan_Speed_Counters_Monitoring
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Radio_Module_Fan_Speed_Counters_Monitoring
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST_FAN}
    [Teardown]   AiC Test Teardown

