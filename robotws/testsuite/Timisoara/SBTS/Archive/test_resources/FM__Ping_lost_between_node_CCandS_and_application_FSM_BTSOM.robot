*** Settings ***
Documentation
    ...  The purpose of this testcase is to verify that site and unit recovers back to operational state after some application is killed from FCM.
    ...  At the beginning, test will check if eNB is onAir and no unallowed alarms are visible.
    ...  Testing method is log in by SSHLibrary to MPlane and kill the process BTSOMexe.
    ...  Test will check recovery after killing process and reset parameters change. Checked reset parameters will be resetReason and restartCause.
    ...  Parameters are checked at the beginning of the test and after recovery action.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${PROCESS_NAME}  BTSOMexe
${ENB_ROOT_USER}  toor4nsn
${ENB_ROOT_PASS}  oZPS0POrRieRtu
${RECOVERY_TIMEOUT}  960


*** Keywords ***
TC__FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21649
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21649 - New TC
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  *******************

    Set Tags  CA-FM  PHASE-CRT  GROUP_IN_CHARGE-TIM_4_Vrf  SW-SBTS21  OWNER-laura.craciunel@nokia.com  AUTHOR-george.chincea@nokia.com
    ...  MAINTAINER-george.chincea@nokia.com

    Step0: Check First Value For Reset Parameters
    Step1: Log By SSHLibrary To MPlane And Kill The Process BTSOMexe
    Step2: Wait For 90 Seconds And Then Check ENB State
    Step3: Check Reset Count On UTE Admin
    Step4: Check ENB State


Step0: Check First Value For Reset Parameters
    Log  Step0: Check first value for reset parameters  console=true
    Check If Single Core Or Dual Core
    ${reset_site}  Check First Reset Parameters
    Run Keyword If  ${reset_site} == ${FALSE}
    ...  Reset Site To Clear Counters


Step1: Log By SSHLibrary To MPlane And Kill The Process BTSOMexe
    Log  Step1: Log by SSHLibrary to MPlane and kill the process BTSOMexe  console=true
    Kill Process  ${PROCESS_NAME}


Step2: Wait For 90 Seconds And Then Check ENB State
    Log  Step2: Wait for 90 seconds and then check eNB state  console=true
    Sleep  90
    Log  Wait for SBTS recovery.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells  ${ON_AIR_DONE}  ${ENABLED}  ${ACTIVE}


Step3: Check Reset Count On UTE Admin
    Log  Step3: Check reset count on UTE Admin  console=true
    Check If Reset Counter Parameters Changed


Step4: Check ENB State
    Log  Step4: Check eNB state  console=true
    ${status}  Run Keyword And Return Status
    ...  Check All Cells  ${ON_AIR_DONE}  ${ENABLED}  ${ACTIVE}
    Run Keyword If  ${status}
    ...  Log  All cells are onAir [OK].  console=true
    ...  ELSE
    ...  Set Test Failed  All cells are not onAir [NOK].


Reset Site To Clear Counters
    Log  Reset site to clear counters  console=true
    Perform Site Reset


Check If Unallowed Alarms Are Present
    ${alarms_status}  ${alarms_msg}  Run Keyword If  ${ALARMS_CHECK}
    ...  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Log  Critical fail while checking alarms: ${alarms_msg}  console=true
    ...  ELSE IF  ${alarms_msg}
    ...  Set Test Restriction  Unexpected alarms are present: ${alarms_msg}


Check First Reset Parameters
    ${reset_reason}  ${restart_cause}  Get Reset Parameters
    ${reset_reason_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${reset_reason}  User
    ${restart_cause_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${restart_cause}  SoftwareReset
    ${status}  Run Keyword If  ${reset_reason_status} and ${restart_cause_status}
    ...  Set Variable  ${TRUE}
    ...  ELSE
    ...  Set Variable  ${FALSE}

    [Return]  ${status}


Get Reset Parameters
    ${smod_object}  Query Infomodel  get object /MRBTS-1/RAT-1/${VAR_BTS_L}/EQM_L-1/CABINET_L-1/SMOD_L-1

    [Return]  ${smod_object.resetReason}  ${smod_object.restartCause}


Check If Reset Counter Parameters Changed
    ${reset_reason_after_kill}  ${restart_cause_after_kill}  Get Reset Parameters
    ${reset_reason_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${reset_reason_after_kill}  Unknown
    ${restart_cause_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${restart_cause_after_kill}  Spurious
    Run Keyword If  ${reset_reason_status} and ${restart_cause_status}
    ...  Log  Counter changed.[OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Counter didn't changed.[NOK]


Kill Process
    [Arguments]  ${process_name}

    SSHLibrary.Open Connection  host=${MPLANE_IP}
    Sleep  5s
    SSHLibrary.Login  username=${ENB_ROOT_USER}  password=${ENB_ROOT_PASS}
    Sleep  5s
    SSHLibrary.Execute Command  killall -9 ${process_name}


TC Setup
    Common Test Setup  tc_name=FM__Ping_lost_between_node_CCandS_and_FSM_BTSOM


TC Teardown
    Common Test Teardown
