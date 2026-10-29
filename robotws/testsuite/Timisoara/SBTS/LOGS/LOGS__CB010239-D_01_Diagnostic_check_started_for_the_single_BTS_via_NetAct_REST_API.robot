*** Settings ***
Documentation  Tests for CB010239
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pdu.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${netAct_user_name}    omc
${netAct_user_password}    Medsql!_1893

*** Keywords ***
TC__LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26074
    ...  ******************
    ...  Author: Jakub Kokoszka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-08-28 - TC created. version 1.0
    ...  - 2023-12-27 - TC mod after change FID severity to warning
    ...  - 2023-01-03 - change NetAct integration KW and variables
    ...  - 2024-03-20 - change coam.Run Diagnostic Check timeout in accordance to updated req OM_GEN_SFS_PERF_CAP.10677
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies the full Diagnostic Check execution and report download via NetAct REST API.
    ...  Two diagnostic cases will be checked: without service impact and with service impact.
    ...  Scenario verifies also if fault 4681 (EFaultId_SanityCheckErrAl) will be correctly raised and cleared.
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/
    ...  LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API.png
    ...  *******************



    Set Tags    CA-LOGS    OWNER-joanna.wolnicka@nokia.com    AUTHOR-jakub.kokoszka@nokia.com
    ...    MAINTAINER-jakub.kokoszka@nokia.com     PHASE-CRT    SW-SBTS24R1    FEATURE-CB010239-D

    Step 0: Preconditions
    Step 1: Turn off RMOD to generate FID:10
    Step 2: Run Diagnostic Check allow_service_impact=False
    Step 3: Check if FaultID 4681 appeared on NetAct
    Step 4: Turn on RMOD


Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set. BTS is connected do NetAct lab with support CB010239

    Log    Step 0: Preconditions    console=${True}

    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Set Test Variable  ${NETACT_CONNECTERD}  ${False}
    Set Test Variable  ${RMOD_OFF}  ${False}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}
    Set Test Variable  ${NETACT_CONNECTERD}  ${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable    ${bts_id}
    ${dist_name}    Set Variable    PLMN-PLMN/MRBTS-${bts_id}
    Set Test Variable  ${DIST_NAME}    ${dist_name}


Step 1: Turn off RMOD to generate FID:10
    [Documentation]
    ...   In this step RMOD will turn off to generate FID:10

    Log    Step 1: Turn off RMOD to generate FID:10  console=${True}

    ${rmod_param}    coam.Get Parameters For All    RMOD
    @{rmod_serial_number_list}=    Create List

    FOR  ${mod}  IN  @{rmod_param}
        Append To List  ${rmod_serial_number_list}  RMOD_${mod.serialNumber}
    END
    Set Test Variable    ${rmod_serial_number_list}
    pdu.Pdu BTS Interface Off    ${rmod_serial_number_list}[0]
    Log    ${rmod_serial_number_list}[0]: power turn OFF    console=${True}
    Set Test Variable  ${RMOD_OFF}  ${True}

    ${fault_status}  Run keyword and return status  Wait until keyword succeeds  420  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7116, faultId=10, faultName="No connection to unit", severity=Critical    timeout=120
    Run keyword if  ${fault_status}
    ...  Log  Fault 10 "No connection to unit" - severity=Critical - appeared  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Fault 10 "No connection to unit - did not not appear    ${True}


Step 2: Run Diagnostic Check allow_service_impact=False
    [Documentation]
    ...   In this step Diagnostic Check will run from NetAct with allow_service_impact=False
    ...   test check if checkpoint 31 Active critical alarms NOK and "Diagnostic Check Error" is active on BTS

    Log    Step 2: Run Diagnostic Check allow_service_impact=False    console=${True}
    ${start_time}  Get current date  time_zone=UTC  result_format=datetime
    Set test variable  ${START_TIME}  ${start_time}
    Sleep    30s
    add_node   service_name=cmwas   hostname=${NETACT_LAB.cmwas}
    ...        username=${netAct_user_name}  password=${netAct_user_password}    alias=netactlab
    ${web_url}   Detect WEB URL    alias=netactlab
    Set Test Variable   ${web_url}
    ${DC_output}    taf.nms.netact.Run Diagnostic Check  ${DIST_NAME}  allow_service_impact=false  verbose=true  timeout=930    alias=netactlab
    Log    Check if Check point 31 Active critical alarms NOK    console=${True}
    Should Contain Any   ${DC_output}   Details: Check point failure: 31    Check point failure,31

   ${fault_status}  Run keyword and return status  Wait until keyword succeeds  420  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7115, faultId=4681, faultName="Diagnostic Check Error", severity=Warning    timeout=120

    Run keyword if  ${fault_status}
    ...  Log  WebEM: Fault 4681 "Diagnostic Check Error" is active on BTS. [OK]  console=${True}
    ...  ELSE  Set Test Failed  WebEM: Fault 4681 "Diagnostic Check Error" is not active on BTS. [NOK]    ${True}


Step 3: Check if FaultID 4681 appeared on NetAct
    [Documentation]
    ...   In this step test check if FaultID 4681 appeared on NetAct severity = MINOR, reason
    ...   DC points with NOK result = 31

    Log    Step 3: Check if FaultID 4681 appeared on NetAct    console=${True}

    Sleep    360s
    add_web_url    web_url=${web_url}   username=${netAct_user_name}    password=${netAct_user_password}
    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    ${cleared_alarms_list}=    taf.nms.netact.Get Cleared Alarms    PLMN-PLMN/MRBTS-${bts_id}    time_from=${START_TIME}  time_to=${time_to}

    Set Test Variable  ${CONDITION_NOT_MET}  ${True}
    FOR  ${alarm}  IN  @{cleared_alarms_list}
      ${perceivedSeverity}=     Get From Dictionary    ${alarm}   additionalText1
      ${supplAlarmInfo}=     Get From Dictionary    ${alarm}   additionalText3
      ${contains}    Run Keyword And Return Status
      ...    Should Contain    ${perceivedSeverity}    Diagnostic Check Error
      ${contains2}    Run Keyword And Return Status
      ...    Should Contain    ${supplAlarmInfo}    31
      ${contains3}    Run Keyword And Return Status
      ...    Should Contain    ${supplAlarmInfo}    4681

      Run Keyword If    '${contains}' == 'True' and '${contains2}' == 'True' and '${contains3}' == 'True'    Run Keywords
      ...  Log    Fault 4681 was found on netact severity==WARNING  console=${True}
      ...  AND    Set Test Variable  ${CONDITION_NOT_MET}  ${False}
      ...  AND    Exit For Loop
    END
    Run Keyword if    ${CONDITION_NOT_MET}   verdicts.Set Test Failed    Fault 4681 was not found on netact.    ${True}

Step 4: Turn on RMOD
    [Documentation]
    ...   In this step RMOD will turn on

    Log    Step 4: Turn on RMOD    console=${True}

    Log    ${rmod_serial_number_list}[0]: power turn ON    console=${True}
    pdu.Pdu BTS Interface On    ${rmod_serial_number_list}[0]
    Set Test Variable  ${RMOD_OFF}  ${False}
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    Run Keyword If  ${NETACT_CONNECTERD}  Run Keywords
    ...  Log  Deintegrate NetAct  console=${True}
    ...  AND  Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}
    ...  AND  Set Test Variable  ${NETACT_CONNECTERD}  ${False}


    Run Keyword If  ${RMOD_OFF}  Run Keywords
    ...    pdu.Pdu BTS Interface On    ${rmod_serial_number_list}[0]
    ...    AND    Log  power on ${rmod_serial_number_list}[0] was turned ON  console=${True}
    ...    AND    Set Test Variable  ${RMOD_OFF}  ${False}
    ...    AND    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Custom Test Teardown
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
