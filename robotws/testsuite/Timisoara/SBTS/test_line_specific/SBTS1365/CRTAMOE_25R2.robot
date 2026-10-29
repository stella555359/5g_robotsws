*** Settings ***
Documentation  FM suite
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R2  SRAN  CLOUD_SRAN_N_1365_ASIM_2ABIP_3AQQJ_AHPJ_AHPB STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_feature_deactivated.robot
Resource    ../../FM/test_resources/FM__B_5G_RAT_reset_counter_exceeded.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1365

*** Test Cases ***

[1]FM__B_L1Soc_NR_UL_DSP_feature_deactivated
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set additional ignored alarms variable
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9101
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${HW_VARIANT}    regex"Loki|Thor"
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIP
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044041600 64 1
    ...    AND    FM__B_L1Soc_NR_UL_DSP_feature_deactivated.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_feature_deactivated
    TC__FM__B_L1Soc_NR_UL_DSP_feature_deactivated
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_feature_deactivated.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_5G_RAT_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set additional ignored alarms variable
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    180
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300
    ...    AND    FM__B_5G_RAT_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_5G_RAT_reset_counter_exceeded
    TC__FM__B_5G_RAT_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__B_5G_RAT_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate
    ...  [['faultId', '7311', 'alarmId', '7107'],
    ...  ['faultId', '7306', 'alarmId', '7107'],
    ...  ['faultId', '7307', 'alarmId', '7107'],
    ...  ['faultId', '7300', 'alarmId', '7107']]
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}
