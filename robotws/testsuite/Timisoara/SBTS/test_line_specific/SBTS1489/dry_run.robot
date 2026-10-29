*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R2  SRAN  CLOUD_SRAN_NLWG_1489_2ASIB_2ABIA_1ABIO_1ABIN_2FXCB_1AHDB_1AHHB_1AHFIB STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__Secondary_core_power_off_on.robot


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
[1]FM__Secondary_core_power_off_on
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on6
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on7
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on8
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on9
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on10
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on11
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on12
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on13
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on14
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on15
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order
