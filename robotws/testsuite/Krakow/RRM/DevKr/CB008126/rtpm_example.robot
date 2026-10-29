*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This subfeature introduces....
...
...      TEST SET NAME: CB008126
...
...      TESTING SCOPE:
...          CB008126-A TODO
...
...      CONTACTS:
...          CFAM Leader        : TODO
...          ET owner (LPO/APO) : Karolina Zwierz (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...          Entity Testing L3  :   (Nokia - PL/Krakow) <.@nokia.com>
...
...      MAINTAINER:
...          I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:
...          CFAM link:        [TODOGATES_LINK]
...          FTS link:         [TODO_LINK]
...          L3 ET Test Plan:  [TODO_LINK]
...
...      HISTORY:
...          History, current status and TC description is available in repository:
...          https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008126
...
...          [27.11.2023] - Create Test Suite
...          [xx.xx.TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=xxxxxx)

Resource    ./resources/CB008126_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO

#Suite Setup  Run Setup

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_1c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008126_TODO
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure...
    ...
    ...  PRECONDITION:
    ...     - 
    ...
    ...  POSTCONDITION:
    ...     - 
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIL + ABIO)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:
    ...       *BACKLOG ID:
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...      Test owner:   <.@nokia.com>
    ...      ET team   : I_EXT_ETK4_GMS (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link: [TODOGATES_LINK]
    ...      Sub-feature refinement: [TODOCONFLUENCE_LINK]
    ...
    ...  HISTORY:
    ...      History, current status and TC description is available in repository:
    ...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008126
    ...
    ...      [27.11.2023] - Create first Test Case shape

    [Tags]    TODO

    [Setup]    Prepare test environment
    rtpm activate
    start rtpm collection interval    wait_for_next_minute_start=True
#    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    log to console    do some actions, sleeping
    sleep    30
    add_rtpm_for_validation   M55139C04505  NRCELL-1  >=0  SA_DU_ADM_ATT_GBR_BWP1
    add_rtpm_for_validation   M55139C04508  NRCELL-1  >=0  SA_DU_ADM_SUCC_GBR_BWP2
    add_rtpm_for_validation   M55139C04506  NRCELL-1  >=0  SA_DU_ADM_SUCC_GBR_BWP1
    add_rtpm_for_validation   M55139C04507  NRCELL-1  >=0  SA_DU_ADM_ATT_GBR_BWP2
    stop rtpm collection interval
    verify_rtpm_counters
    rtpm deactivate

    [Teardown]    Cleanup after test


*** Keywords ***
Prepare test environment
    Log to console    TODO

Cleanup after test
    Log to console    TODO
