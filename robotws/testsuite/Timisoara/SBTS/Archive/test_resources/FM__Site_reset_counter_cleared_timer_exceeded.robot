*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${PING_TIMEOUT}  120     # Timeout for ping regain during site reset

*** Keywords ***
TC__FM__Site_reset_counter_cleared_timer_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14623
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to trigger site reset as recovery action multiple times to verify the counter reset.
    ...  It will be done by triggerring fault 2080 using Fault Generator method. Recovery action will be checked against faultID 2080 with
    ...  alarmId=7101 BTS site autonomous reset as recovery action and the occurence of BTS site reset presence.
    ...  TC will pause for 1 hour to check if the reset counter will be cleared.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  -  04.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-14623 - Initial TAT creation
    ...  -  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  -  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  -  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  ******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-bogdan.boldurean@nokia.com   MAINTAINER-bogdan.boldurean@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS20    FEATURE-RP001534



    Step 0: Check all required states

    FOR    ${loop}    IN RANGE    0    3
        Step ${loop+1}: Trigger fault 2080
    END

    Step 4: Wait for counter to be cleared

    Step 5: Trigger fault 2080

    Step 6: Perform site reset to clear counters


Step 0: Check all required states
    Log  Step0:\n Check all required states   console=${TRUE}

    ${bts_l_list}    Query Infomodel  get list /MRBTS-1/RAT-1/BTS_L-*
    ${length_bts_l_list}   Get Length  ${bts_l_list}
    Run Keyword if  '${length_bts_l_list}'=='1'   Checking Hwapi_Domain if One Core
    ...   ELSE
    ...   Checking Hwapi_Domain If Dual Core
    reset counter value at start

    ${fault_2080}  Catenate  SEPARATOR=${SPACE}  faultId=2080,
    ...                                          faultName="BTS site autonomous reset as recovery action",
    ...                                          alarmId=7101
    Set test Variable  ${FAULT_2080}

Checking Hwapi_Domain If One Core
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-*
    Set Test Variable  ${hwapi_domain}
    Run Keyword if  '${hwapi_domain.hwapiDomainId}' == '1'  run keyword
    ...   BTS_L and receiver value for hwapiDomain1
    ...   ELSE
    ...   BTS_L and receiver value for hwapiDomain2

Checking Hwapi_Domain If Dual Core
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Active]
    Set Test Variable  ${hwapi_domain}
    Run Keyword if  '${hwapi_domain.hwapiDomainId}' == '1'  run keyword
    ...   BTS_L and receiver value for hwapiDomain1
    ...   ELSE
    ...   BTS_L and receiver value for hwapiDomain2

BTS_L and receiver value for hwapiDomain1
    ${var_BTS_L}=  Set Variable  BTS_L-1
    Set Test Variable  ${var_BTS_L}
    ${receiver}  Set Variable  269554178
    Set Test Variable  ${receiver}
    ${sender}  Set Variable  269550144
    Set Test Variable  ${sender}
    ${domain_id}  Set Variable  16
    Set Test Variable  ${domain_id}

BTS_L and receiver value for hwapiDomain2
    ${var_BTS_L}=  Set Variable  BTS_L-4
    Set Test Variable  ${var_BTS_L}
    ${receiver}  Set Variable  537989634
    Set Test Variable  ${receiver}
    ${sender}  Set Variable  537985600
    Set Test Variable  ${sender}
    ${domain_id}  Set Variable  32
    Set Test Variable  ${domain_id}

Checking the value of reset counter
    ${smodObject}=  Query Infomodel  get object /MRBTS-1/RAT-1/${var_BTS_L}/EQM_L-1/CABINET_L-1/SMOD_L-1
    ${resetCounter}  Set variable  ${smodObject.restartCounter}
    [Return]  ${resetCounter}


Reset counter value at start
    ${resetCounter}  checking the value of reset counter
    Log  Value of reset counter at test start: ${resetCounter}  console=${TRUE}
    Run Keyword if  '${resetCounter}' != '0'  Run Keywords
    ...    Log   Site reset will be performed to clear all counters before test starts   console=${TRUE}
    ...    AND   coam.Reset Site
    ...    AND   Wait Until Keyword Succeeds  600  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    ...    AND   Check Links Status  Available


Step ${index}: Trigger fault 2080
    Log  Step ${index}:\n Trigger fault 2080   console=${TRUE}

    Setup admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=alarmCheck
    ${send_fault} =   Run Keyword in Background   Assert Alarm Active   parameters=${FAULT_2080}   timeout=400  alias=alarmCheck
    ${states}=  Catenate  SEPARATOR=  stateInfo.availabilityStatus=Failed, stateInfo.operationalState=Disabled,
    ...  stateInfo.reasoningStatus[0]=SrioHostLinkDown
    Run Keyword And Ignore Error  Send Hwapi Api2 Alarm msg  ${sender}  ${receiver}  1  2080  ${domain_id}  timeout=75
    ${status_ccu_l}  ${im_ccu_l_object}  Run Keyword And Ignore Error    Query Infomodel
    ...  get object //CCU_L-1 is [${states}]   timeout=60
    Run Keyword If  '${status_ccu_l}'=='FAIL'
    ...   Set Test Restriction   message=StateInfo of CCU_L is different than expected [NOK]
    ...   ELSE
    ...   Log  StateInfo: availabilityStatus, operationalState, reasoningStatus for CCU_L is as expected [OK]  console=${TRUE}
    ${status}   ${dict_result}=  Run Keyword And Ignore Error  Collect Keyword Result   ${send_fault}   timeout=400
    Run Keyword if   '${status}'=='FAIL'
    ...  Set Test Failed  message=Fault 2080 with alarm 7101 BTS site autonomous reset as recovery action didn't occure.  fail_fast=${True}
    Log   Fault 2080 with alarm 7101 'BTS site autonomous reset as recovery action' is visible  console=${TRUE}
    ${ping_loss_status}=  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}
    Run Keyword If  ${ping_loss_status}==${False}  Set Test Failed  Ping has not been lost within timeout=${PING_TIMEOUT}
    ...   ELSE  log  Ping is lost   console=${TRUE}
    ${ping_regain_status}=  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=${PING_TIMEOUT}
    Run Keyword If  ${ping_regain_status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ...   ELSE   log   Target is Reachable   console=${TRUE}
    Run keyword and continue on failure  Teardown admin  alias=alarmCheck
    Sleep  180
    Verify SBTS After Recovery

Verify SBTS After Recovery
    Log  Verify SBTS after Recovery   console=${TRUE}

    Wait Until Keyword Succeeds  600  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check links status  Available
    Admin Check Active Alarms Taf
    ${reset_counter}  Checking the value of reset counter
    Log  Current value of reset counter: ${reset_counter}  console=true

Step 4: Wait for counter to be cleared
    Log   Step 4: Wait for counter to be cleared   console=${TRUE}

    ${resetCounter}   Checking the value of reset counter
    Log  Reset counter value before timer exceeded: ${resetCounter}  console=${TRUE}

    Log  TC will sleep for 1 Hour for reset counter to be cleared.  console=true
    Sleep  1H

    ${resetCounter}  Checking the value of reset counter
    Log  Reset counter value after 1 hour: ${resetCounter}  console=${TRUE}

    Run keyword if  '${resetCounter}' != '0'
    ...  Set test failed  msg=Counter is different than 0.
    ...  ELSE
    ...  Log  Counter was reset.  console=true

Step 6: Perform site reset to clear counters
    Log   Step 6:\n Site reset will be performed to clear all counters   console=${TRUE}
    coam.Reset site
    Wait Until Keyword Succeeds  600  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check links status  Available
    ${reset_counter}  Checking the value of reset counter
    Log  Reset counter value after site reset: ${reset_counter}  console=true

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Step 6: Perform site reset to clear counters
    Common Test Teardown
