*** Settings ***
Documentation
...    Author: cristina.aionesei@nokia.com
...    Description: CRT CSV_UUF

Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_NL_10482_1ASIB_2ABIL_3AEQE
Library           XML  use_lxml=True

Resource    ../../FM/test_resources/FM__link_break_X2.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${Switch_IP}          10.255.10.108
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       14
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1482

*** Test Cases ***
[1]FM__link_break_X2_long
    [Tags]  QC_650226
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    360
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    240
    ...    AND    FM__link_break_X2.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_X2
    TC__FM__link_break_X2
    [Teardown]    Run Keywords    FM__link_break_X2.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__link_break_X2_short
    [Tags]  QC_650227
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    360
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    240
    ...    AND    FM__link_break_X2.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_X2
    TC__FM__link_break_X2
    [Teardown]    Run Keywords    FM__link_break_X2.TC Teardown
    ...    AND    Restore Resource Search Order
