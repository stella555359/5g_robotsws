*** Settings ***
Documentation  This suite contains the FM test cases of SBTS10721 for 26R2 regression.

Force Tags  QCD_MN_SRAN  QCP_SRAN_SBTS  SBTS26R2  SRAN  CLOUD_SRAN_NLWG_1721_2ASIL_4ABIO_1ABIA_3AHLOA_3AHFIG_3AEHC  STATE_COMMISSIONED

Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__B_5G_RAT_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case.robot
Resource    ../../FM/test_resources/FM__C1_RF_Recovery_Reset_in_Maintenance_Window.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD44243
${SKIP_RU_POWER_CHECK}    ${TRUE}

*** Test Cases ***

[1]FM__FSP_common_reset_counter_exceeded
    [Tags]  QC_300766
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    120
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60
    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__B_5G_RAT_reset_counter_exceeded
    [Tags]  QC_300767
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    180
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300
    ...    AND    FM__B_5G_RAT_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_5G_RAT_reset_counter_exceeded
    TC__FM__B_5G_RAT_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__B_5G_RAT_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__FM__VN_CCplane_LTE_reset_counter_exceeded
    [Tags]  QC_300765
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__VN_CCplane_LTE_reset_counter_exceeded
    TC__FM_VN_CCplane_LTE_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__US009504_C1_RF_Recovery_Reset_in_Maintenance_Window
    [Tags]  QC_300778
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


[1]FM__eCPRI_RU_resiliency_to_BTS_DU_L1SOC_Capacity_unit_reset_Uncontrolled_case
    [Tags]  QC_300768
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
