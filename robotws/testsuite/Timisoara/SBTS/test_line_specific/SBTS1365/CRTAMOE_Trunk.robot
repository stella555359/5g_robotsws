*** Settings ***
Documentation  FM suite
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_N_1365_ASIM_2ABIP_3AQQJ_AHPJ_AHPB STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_feature_deactivated.robot
Resource    ../../FM/test_resources/FM__B_5G_RAT_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw.robot
Resource    ../../FM/test_resources/FM__eCPRI_RU_Fault_10_information_enriched_case_1.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1365

*** Test Cases ***

[1]FM__B_5G_RAT_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set additional ignored alarms variable
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    180
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300
    ...    AND    FM__B_5G_RAT_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_5G_RAT_reset_counter_exceeded
    TC__FM__B_5G_RAT_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__B_5G_RAT_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__eCPRI_RU_Fault_10_information_enriched_case_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1900
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1900
    ...    AND    Set Test Variable  ${RMOD_SN}    K9234908771
    ...    AND    FM__eCPRI_RU_Fault_10_information_enriched_case_1.TC Setup
    ...    AND    Modify Resource Search Order    FM__eCPRI_RU_Fault_10_information_enriched_case_1
    TC__FM__eCPRI_RU_Fault_10_information_enriched_case_1
    [Teardown]    Run Keywords    FM__eCPRI_RU_Fault_10_information_enriched_case_1.TC Teardown
    ...    AND    Restore Resource Search Order

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

[1]Automated__FM__RMOD_hot_remove_hot_insert
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable  ${RMOD_SN}    K9234908772
    ...    AND    FM__RF_hot_remove_hot_insert.TC Setup
    ...    AND    Modify Resource Search Order    FM__RF_hot_remove_hot_insert
    TC__FM__RF_hot_remove_hot_insert
    [Teardown]    Run Keywords    FM__RF_hot_remove_hot_insert.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__CNI-132903_improvement_for_ASIM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STEP_WAIT}    11
    ...    AND    Set additional ignored alarms variable
    ...    AND    FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw.TC Setup
    ...    AND    Modify Resource Search Order    FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw
    TC__FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw
    [Teardown]    Run Keywords    FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate
    ...  [['faultId', '7311', 'alarmId', '7107'],
    ...  ['faultId', '7306', 'alarmId', '7107'],
    ...  ['faultId', '4569', 'alarmId', '7115'],
    ...  ['faultId', '4298', 'alarmId', '7115'],
    ...  ['faultId', '7307', 'alarmId', '7107'],
    ...  ['faultId', '7300', 'alarmId', '7107']]
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}
