*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS26R2  SRAN  CLOUD_SRAN_NLWG_1327_1ASIL_2ABIO_1ABIA_1AZQJ_1FXDB_1AEHC STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot
Resource    ../../FM/test_resources/FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case.robot
Resource    ../../FM/test_resources/FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case.robot

Documentation  CRT Trunk SBTS10327

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

[1]FM_RMOD_power_off_on_FID4589
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AZQU
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600

    ...    AND    FM__RMOD_crash_fault_signature_check.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AZQU
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120

    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
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

