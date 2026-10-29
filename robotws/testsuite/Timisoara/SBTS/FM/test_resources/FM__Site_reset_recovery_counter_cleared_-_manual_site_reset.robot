*** Settings ***
Documentation
    ...  This test case is created to trigger site reset as recovery action multiple times to verify the counter reset.
    ...  It will be done by triggerring fault 2080 using Fault Generator method. Recovery action will be checked against faultID 2080 with
    ...  alarmId=7101 BTS site autonomous reset as recovery action and the occurence of BTS site reset presence, as well as alarmId=7116
    ...  SRIO host link down when reset counter is exceeded.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${PING_TIMEOUT}  120  # Timeout for ping regain during site reset
${STARTUP_TIMEOUT}  600  # Timeout for SBTS startup after site reset


*** Keywords ***
TC__FM__Site_reset_recovery_counter_cleared_-_manual_site_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10432
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  -  11.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-10432 - Initial TAT creation
    ...  -  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  -  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  -  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  -  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    Step0: Check All Required States
    Step1: Trigger Fault 2080
    Step2: Verify SBTS After Recovery
    Step3: Perform Site Reset To Clear Counters

    FOR  ${loop}  IN RANGE  0  3
        Step1: Trigger Fault 2080
        Step2: Verify SBTS After Recovery
    END


Step0: Check All Required States
    Log  Step0:\n Check all required states  console=true

    ${bts_l_list}  Query Infomodel  get list /MRBTS-1/RAT-1/BTS_L-*
    ${length_bts_l_list}  Get Length  ${bts_l_list}
    Run Keyword If  '${length_bts_l_list}'=='1'
    ...  Checking Hwapi_Domain If One Core
    ...  ELSE
    ...  Checking Hwapi_Domain If Dual Core


Checking Hwapi_Domain If One Core
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-*
    Set Test Variable  ${HWAPI_DOMAIN}
    Run Keyword If  '${HWAPI_DOMAIN.hwapiDomainId}' == '1'
    ...  Run Keyword
    ...  BTS_L And Receiver Value For HwapiDomain1
    ...  ELSE
    ...  BTS_L And Receiver Value For HwapiDomain2


Checking Hwapi_Domain If Dual Core
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Active]
    Set Test Variable  ${HWAPI_DOMAIN}
    Run Keyword If  '${HWAPI_DOMAIN.hwapiDomainId}' == '1'
    ...  Run Keyword
    ...  BTS_L And Receiver Value For HwapiDomain1
    ...  ELSE
    ...  BTS_L And Receiver Value For HwapiDomain2


BTS_L And Receiver Value For HwapiDomain1
    ${var_bts_l}  Set Variable  BTS_L-1
    Set Test Variable  ${VAR_BTS_L}
    ${receiver}  Set Variable  269554178
    Set Test Variable  ${RECEIVER}
    ${sender}  Set Variable  269550144
    Set Test Variable  ${SENDER}
    ${domain_id}  Set Variable  16
    Set Test Variable  ${DOMAIN_ID}
    Reset Counter Value At Start


BTS_L And Receiver Value For HwapiDomain2
    ${var_bts_l}  Set Variable  BTS_L-4
    Set Test Variable  ${VAR_BTS_L}
    ${receiver}  Set Variable  537989634
    Set Test Variable  ${RECEIVER}
    ${sender}  Set Variable  537985600
    Set Test Variable  ${SENDER}
    ${domain_id}  Set Variable  32
    Set Test Variable  ${DOMAIN_ID}
    Reset Counter Value At Start


Checking The Value Of Reset Counter
    ${smod_object}  Query Infomodel  get object /MRBTS-1/RAT-1/${VAR_BTS_L}/EQM_L-1/CABINET_L-1/SMOD_L-1
    Set Test Variable  ${RESET_COUNTER}  ${smod_object.restartCounter}
    Log  Current value of reset counter: ${RESET_COUNTER}  console=true


Reset Counter Value At Start
    ${smod_object}  Query Infomodel  get object /MRBTS-1/RAT-1/${VAR_BTS_L}/EQM_L-1/CABINET_L-1/SMOD_L-1
    Set Test Variable  ${RESET_COUNTER}  ${smod_object.restartCounter}
    Log  Value of reset counter at test start: ${RESET_COUNTER}  console=true
    Run Keyword If  '${RESET_COUNTER}' != '0'  Perform Site Reset


Step1: Trigger Fault 2080
    Log  Step1:\n Trigger fault 2080  console=true

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=alarmCheck
    ${alarm_parameters}  Catenate  SEPARATOR=${SPACE}  faultId=2080,  faultName="BTS site autonomous reset as recovery action",  alarmId=7101
    ${send_fault}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=400  alias=alarmCheck
    Run Keyword And Ignore Error
    ...  Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  2080  ${DOMAIN_ID}  timeout=75
    ${states}  Catenate  SEPARATOR=  stateInfo.availabilityStatus=Failed, stateInfo.operationalState=Disabled,
    ...  stateInfo.reasoningStatus[0]=SrioHostLinkDown
    ${status_ccu_l}  ${im_ccu_l_object}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //CCU_L-1 is [${states}]  timeout=60
    Run Keyword If  '${status_ccu_l}'=='FAIL'
    ...  Set Test Restriction  message=StateInfo of CCU_L is different than expected [NOK]
    ...  ELSE
    ...  Log  StateInfo: availabilityStatus, operationalState, reasoningStatus for CCU_L is as expected [OK]  console=true
    ${status}  ${dict_result}  Run Keyword And Ignore Error
    ...  Collect Keyword Result  ${send_fault}  timeout=400
    Run Keyword If  '${status}'=='FAIL'
    ...  Set Test Failed  message=Fault 2080 with alarm 7101 BTS site autonomous reset as recovery action didn't occurW.  fail_fast=${True}
    Log  Fault 2080 with alarm 7101 'BTS site autonomous reset as recovery action' is visible  console=true
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}
    Run Keyword If  ${ping_loss_status}==${False}
    ...  Set Test Failed  Ping has not been lost within timeout=${PING_TIMEOUT}
    ...  ELSE
    ...  Log  Ping is lost  console=true
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_TIMEOUT}
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  Target is Reachable  console=true
    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=alarmCheck
    Sleep  180


Step2: Verify SBTS After Recovery
    Log  Step2:\n Verify SBTS after Recovery  console=true

    ${smod_object}  Query Infomodel  get object /MRBTS-1/RAT-1/${VAR_BTS_L}/EQM_L-1/CABINET_L-1/SMOD_L-1
    ${reset_counter_after_recovery}  Set Variable  ${smod_object.restartCounter}
    Log  Reset counter value after recovery: ${reset_counter_after_recovery}  console=true

    Wait Until Keyword Succeeds  600  10
    ...  Check All Cells
    Check Links Status  Available
    Admin Check Active Alarms Taf
    Checking The Value Of Reset Counter


Step3: Perform Site Reset To Clear Counters
    Log  step3:\n Site reset will be performed to clear all counters  console=true
    Perform Site Reset
    Checking The Value Of Reset Counter


TC Setup
    Common Test Setup


TC Teardown
    Run Keywords
    ...  Step3: Perform Site Reset To Clear Counters
    ...  AND
    ...  Common Test Teardown
