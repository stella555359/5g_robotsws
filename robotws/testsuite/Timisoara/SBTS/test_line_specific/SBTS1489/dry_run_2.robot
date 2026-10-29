*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R2  SRAN  CLOUD_SRAN_NLWG_1489_2ASIB_2ABIA_1ABIO_1ABIN_2FXCB_1AHDB_1AHHB_1AHFIB STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__FSP_Lom_Fault_Service_crash.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${251}  ${252}
${WCDMAVlan}          ${351}
${LTEVlan}            ${451}
${Switch_IP}          10.255.6.18
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       9
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1489


*** Test Cases ***
[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_6
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_7
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_8
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_9
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_10
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_11
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_12
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_13
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_14
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA_15
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order
