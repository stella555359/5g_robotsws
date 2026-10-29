*** Settings ***
Documentation
...  Author: marek.oleksiewicz@nokia.com
...  Maintainer: marek.oleksiewicz@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/PM/Cloud_PM_PIM_Alarms_Triggering.robot
Resource    ../../TestCases/PM/Cloud_PM_PIMC_Counters.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=False

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/25R1/vCU_25R1.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/25R1/vDU_25R1.xml
${DELTA_SCF_PATH}   ${CURDIR}/SCF/6RU_recommision_24R3.xml
${FHGW_IP}=          10.42.185.86
${FHGW_USERNAME}=    toor4nsn
${FHGW_PASSWORD}=    Fhgw@nokia1243
${FHGW_PORT}=        22
${VDU_URL}    https://10.42.126.78/
${vDU_OAM_password}  Nokia@123
@{gnb_cells}=    MRBTS-8435/NRBTS-8435/NRCELL-1    MRBTS-8435/NRBTS-8435/NRCELL-2    MRBTS-8435/NRBTS-8435/NRCELL-3
...      MRBTS-8435/NRBTS-8435/NRCELL-4    MRBTS-8435/NRBTS-8435/NRCELL-5    MRBTS-8435/NRBTS-8435/NRCELL-6
...      MRBTS-8435/NRBTS-8435/NRCELL-7    MRBTS-8435/NRBTS-8435/NRCELL-8    MRBTS-8435/NRBTS-8435/NRCELL-9
...      MRBTS-8435/NRBTS-8435/NRCELL-10    MRBTS-8435/NRBTS-8435/NRCELL-11    MRBTS-8435/NRBTS-8435/NRCELL-12
${TEST_RUN_COUNT}=      10
${TEST_RUN_COUNT_2}=      3
@{RMOD_SN_LIST}=  DC1946001U2

@{L1181111027_OFF}   4  1  1  1  1  1
@{K9190632475_OFF}   1  4  1  1  1  1
@{DC1946001U2_OFF}   1  1  4  1  1  1
@{L1180105528_OFF}   1  1  1  4  1  1
@{F7203610645_OFF}   1  1  1  1  4  1
@{1M202303622_OFF}   1  1  1  1  1  4

@{L1181111027_ON}   1  1  1  1  1  1
@{K9190632475_ON}   1  1  1  1  1  1
@{DC1946001U2_ON}   1  1  1  1  1  1
@{L1180105528_ON}   1  1  1  1  1  1
@{F7203610645_ON}   1  1  1  1  1  1
@{1M202303622_ON}   1  1  1  1  1  1

&{SWITCH_OFF_ALL_DICT}    L1181111027=@{L1181111027_OFF}
...  K9190632475=@{K9190632475_OFF}
...  DC1946001U2=@{DC1946001U2_OFF}
...  L1180105528=@{L1180105528_OFF}
...  F7203610645=@{F7203610645_OFF}
...  1M202303622=@{1M202303622_OFF}

&{SWITCH_ON_ALL_DICT}    L1181111027=@{L1181111027_ON}
...  K9190632475=@{K9190632475_ON}
...  DC1946001U2=@{DC1946001U2_ON}
...  L1180105528=@{L1180105528_ON}
...  F7203610645=@{F7203610645_ON}
...  1M202303622=@{1M202303622_ON}

*** Test Cases ***
[CB011178][1.0] Automated_AIC_RF_Module_lock_unlock
    [Setup]  AiC Test Setup
    RMOD Lock Unlock And Check Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT_2}

[CB011178][1.0] Automated_AIC_RF_reset_from_GUI
    [Setup]  AiC Test Setup
    RMODs Reset From GUI Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB011178][1.0] Automated_AIC_RF_Power_Reset
    [Setup]   AiC Test Setup
    RMODs Power Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB011178][1.0] Automated_AIC_vDU_reset
    [Setup]   AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT_2}

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

[CB011178][1.0] Automated_AIC_SiSo_PM_PIMC_Counters
    [Setup]   AiC Test Setup
    TC__Cloud_PM_PIMC_Counters   scfc_file_path=${VDU_SCF_PATH}  rmod_sn=DC1946001U2
    [Teardown]   AiC Test Teardown

[CB011178][1.0] Automated_AIC_ PIM_Alarms_Triggering
    [Setup]   AiC Test Setup
    TC__Cloud_PM_PIM_Alarms_Triggering    scfc_file_path=${VDU_SCF_PATH}  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]   AiC Test Teardown
