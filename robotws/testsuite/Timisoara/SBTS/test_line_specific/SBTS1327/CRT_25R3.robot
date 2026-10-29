*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R3  SRAN
...  CLOUD_SRAN_NLWG_1327_1ASIL_1ABIO_1ABIA_1ASIM_1ABIP_1ABIO_1AZQU_1FXDB_1AEHC_1AHFIB_1AHEGA_1AQQJ_1AVQE STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case.robot
Resource    ../../FM/test_resources/FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case.robot

Documentation  CRT Branch 25R3 SBTS10327.

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${251}  ${252}
${WCDMAVlan}          ${454}
${LTEVlan}            ${451}
${Switch_IP}          10.255.10.118
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       9
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1327


*** Test Cases ***

[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    180
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIO
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180

    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E0441C1600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044E01600 64 1

    ...    AND    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__eCPRI_RU_resiliency_to_BTS_DU_Capacity_unit_reset_Controlled_case
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${BBMOD_SN}    L1204101514
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=

    ...    AND    FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case.TC Setup
    ...    AND    Modify Resource Search Order    FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case
    TC__FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case
    [Teardown]    Run Keywords    FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__CPRI_RU_resiliency_to_BTS_DU_L1SOC_Capacity_unit_reset_Uncontrolled_case
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