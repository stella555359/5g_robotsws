*** Settings ***
Documentation  This suite contains the FM test cases of SBTS10721 for 26R1 regression.

Force Tags  QCD_MN_SRAN  QCP_SRAN_SBTS  SBTS26R1  SRAN  CLOUD_SRAN_NLWG_1721_2ASIL_4ABIO_1ABIA_3AHLOA_3AHFIG_3AEHC  STATE_COMMISSIONED

Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__C1_RF_Recovery_Reset_in_Maintenance_Window.robot
Resource    ../../FM/test_resources/FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case.robot
Resource    ../../FM/test_resources/FM__Alarm_suppression_by_mocDN_all_severity.robot
Resource    ../../FM/test_resources/FM__Update_alarm_fault_ID_online_suppressed_allowed_list.robot
Resource    ../../FM/test_resources/FM__Alarm_suppression_based_on_faultID.robot
Resource    ../../FM/test_resources/FM__Fault_instructions_improved_FID7317.robot
Resource    ../../FM/test_resources/FM__AEHC_noncritical_DFE_runtime_crash.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD44243
${SKIP_RU_POWER_CHECK}    ${TRUE}

*** Test Cases ***
[1]FM_RMOD_power_off_on_FID4589
    [Tags]  QC_257250
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AEHC
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    FM__RMOD_crash_fault_signature_check.TC setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__eCPRI_RU_resiliency_to_BTS_DU_L1SOC_Capacity_unit_reset_Uncontrolled_case
    [Tags]  QC_257254
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case.TC Setup
    ...    AND    Modify Resource Search Order    FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case
    TC__FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case
    [Teardown]    Run Keywords    FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_Alarm_suppression_by_MOC_critical_major_minor_severity
    [Tags]  QC_257258
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to appear in WebEM.
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after test scenario.
    ...    AND    Set Test Variable    ${RMOD_1_SN}  L1212614401  # Mandatory. Serial number of RMOD that support fault 4589.
    ...    AND    Set Test Variable    ${RMOD_2_SN}  L1212614403  # Mandatory. Serial number of RMOD that support fault 4589.
    ...    AND    FM__Alarm_suppression_by_mocDN_all_severity.TC Setup
    ...    AND    Modify Resource Search Order    FM__Alarm_suppression_by_mocDN_all_severity
    TC__FM__Alarm_suppression_by_mocDN_all_severity
    [Teardown]    Run Keywords    FM__Alarm_suppression_by_mocDN_all_severity.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM_Alarm_suppression_based_on_faultID
    [Tags]  QC_257260
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to appear in WebEM.
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after test scenario.
    ...    AND    FM__Alarm_suppression_based_on_faultID.TC Setup
    ...    AND    Modify Resource Search Order    FM__Alarm_suppression_based_on_faultID
    TC__FM__Alarm_suppression_based_on_faultID
    [Teardown]    Run Keywords    FM__Alarm_suppression_based_on_faultID.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM_UpdateAlarmID_faultID_Online_in_suppressedAlarmList_AllowAlarmList_minor_warning
    [Tags]  QC_257261
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to appear in WebEM.
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after test scenario.
    ...    AND    Set Test Variable    ${RMOD_SN}   L1212614401
    ...    AND    FM__Update_alarm_fault_ID_online_suppressed_allowed_list.TC Setup
    ...    AND    Modify Resource Search Order    FM__Update_alarm_fault_ID_online_suppressed_allowed_list
    TC__FM__Update_alarm_fault_ID_online_suppressed_allowed_list
    [Teardown]    Run Keywords    FM__Update_alarm_fault_ID_online_suppressed_allowed_list.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__US009504_C1_RF_Recovery_Reset_in_Maintenance_Window
    [Tags]  QC_257262
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AHFIG
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    FM__C1_RF_Recovery_Reset_in_Maintenance_Window.TC setup
    ...    AND    Modify Resource Search Order    FM__C1_RF_Recovery_Reset_in_Maintenance_Window
    TC__FM__C1_RF_Recovery_Reset_in_Maintenance_Window
    [Teardown]    Run Keywords    FM__C1_RF_Recovery_Reset_in_Maintenance_Window.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM_AEHC_noncritical_DFE_runtime_crash
    [Tags]  QC_277514
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    FM__AEHC_noncritical_DFE_runtime_crash.TC setup
    ...    AND    Modify Resource Search Order    FM__AEHC_noncritical_DFE_runtime_crash
    TC__FM__AEHC_noncritical_DFE_runtime_crash
    [Teardown]    Run Keywords    FM__AEHC_noncritical_DFE_runtime_crash.TC Teardown
    ...    AND    Restore Resource Search Order
