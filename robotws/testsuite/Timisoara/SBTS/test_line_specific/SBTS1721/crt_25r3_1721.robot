*** Settings ***
Documentation  This suite contains the FM test cases of SBTS10721 for the 25R3 branch regression.

Force Tags  QCD_MN_SRAN  QCP_SRAN_SBTS  SBTS25R3  SRAN  CLOUD_SRAN_NLWG_1721_2ASIL_4ABIO_1ABIA_3AHLOA_3AHFIG_3AEHC  STATE_COMMISSIONED

Library           XML  use_lxml=True
Resource    ../../common_resources/ca_SBTS_general.robot
Resource    ../../common_resources/ca_FM_general.robot
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../FM/test_resources/FM__C1_RF_Recovery_Reset_in_Maintenance_Window.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__B_5G_RAT_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case.robot
Resource    ../../FM/test_resources/FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case.robot
Resource    ../../FM/test_resources/FM__FID4592_fault_available_in_NMS_with_late_integration.robot
Resource    ../../FM/test_resources/FM__Alarm_suppression_by_mocDN_all_severity.robot
Resource    ../../FM/test_resources/FM__Update_alarm_fault_ID_online_suppressed_allowed_list.robot
Resource    ../../FM/test_resources/FM__Alarm_suppression_based_on_faultID.robot
Resource    ../../FM/test_resources/FM__Fault_instructions_improved_FID7317

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD44243
${SKIP_RU_POWER_CHECK}    ${TRUE}

*** Test Cases ***
[1]FM__US009504_C1_RF_Recovery_Reset_in_Maintenance_Window
    [Tags]  QC_210081
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

[1]FM__Fault_instructions_improved_with_RAT_reset_recommended_recovery_action_7317
    [Tags]  QC_210095
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}  180
    ...    AND    FM__Fault_instructions_improved_FID7317.TC setup
    ...    AND    Modify Resource Search Order    FM__Fault_instructions_improved_FID7317
    TC__FM__Fault_instructions_improved_FID7317
    [Teardown]    Run Keywords    FM__Fault_instructions_improved_FID7317.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__eCPRI_RU_resiliency_to_BTS_DU_Capacity_unit_reset_Controlled_case
    [Tags]  QC_210087
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${BBMOD_SN}    L1233704116
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD}    bdS%ztWG3v7%SjreCVA79wTPb
    ...    AND    FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case.TC Setup
    ...    AND    Modify Resource Search Order    FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case
    TC__FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case
    [Teardown]    Run Keywords    FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__CPRI_RU_resiliency_to_BTS_DU_L1SOC_Capacity_unit_reset_Uncontrolled_case
    [Tags]  QC_210092
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

[1]FM__FID4592_fault_available_in_NMS_with_late_integration
    [Tags]  QC_210094
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    FM__FID4592_fault_available_in_NMS_with_late_integration.TC Setup
    ...    AND    Modify Resource Search Order    FM__FID4592_fault_available_in_NMS_with_late_integration
    TC__FM__FID4592_fault_available_in_NMS_with_late_integration
    [Teardown]    Run Keywords    FM__FID4592_fault_available_in_NMS_with_late_integration.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM_UpdateAlarmID_faultID_Online_in_suppressedAlarmList_AllowAlarmList_minor_warning
    [Tags]  QC_210091
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

[1]FM_Alarm_suppression_by_MOC_critical_major_minor_severity
    [Tags]  QC_210090
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
    [Tags]  QC_210089
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
