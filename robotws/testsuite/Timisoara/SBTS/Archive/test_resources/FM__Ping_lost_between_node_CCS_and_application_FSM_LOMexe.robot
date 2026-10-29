*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${STARTUP_TIMEOUT}   600     # Timeout for SBTS startup after site reset
${PING_TIMEOUT}      300     # Timeout for ping regain during site reset

*** Keywords ***
TC__FM__Ping_lost_between_node_CCS_and_application_FSM_LOMexe
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21650
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this tescase is to verify that site and unit recovers back to operational state after some application is killed from FCT.
    ...  Testing method is by killing all LOMexe processes running on FCT.
    ...  Test will also verify restart counter increment, reasoning of restartCause and resetReason.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.09.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21650 - Initial TAT creation
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-laura.craciunel@nokia.com    MAINTAINER-laura.craciunel@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS17A    FEATURE-RP001534

    Step 0: Check all required states
    Step 1: Trigger recovery by killing process and verify recovery
    Step 2: Perform site reset to clear recovery counters


Step 0: Check all required states
    Log  Step 0: Check all required states.    console=${TRUE}
    ${bts_cores}=  Run Keyword And Return Status  Query Infomodel  check //BTS_L-* is [storedRole=Single]
    Run keyword if  ${bts_cores}
    ...  Get single core domain id
    ...  ELSE
    ...  Get dual core domain id

    ${restartCounter}=  Get value of restart counter
    Log  Initial restartCounter is : ${restartCounter}.    console=${TRUE}
    Run Keyword Unless  '${restartCounter}'=='0'
    ...  Step 2: Perform site reset to clear recovery counters


Step 1: Trigger recovery by killing process and verify recovery
    Log  Step 1: Trigger recovery by killing process and verify recovery.    console=${TRUE}
    Log  LOMexe process will be killed.    console=${TRUE}

    Connect to SMOD  ${SMOD1['IP']}
    ssh.Execute  killall -9 LOMexe

    ${ping_loss_status}=  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${SMOD1['IP']}   timeout=${PING_TIMEOUT}
    Run Keyword If  ${ping_loss_status}
    ...   Log  Ping is lost, test will continue.   console=${TRUE}
    ...   ELSE
    ...   Set Test Failed  Ping has not been lost within timeout=${PING_TIMEOUT}s.

    ${ping_regain_status}=  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${SMOD1['IP']}   timeout=${PING_TIMEOUT}
    Run Keyword If  ${ping_regain_status}
    ...   Log   Target is Reachable, test will continue.   console=${TRUE}
    ...   ELSE
    ...   Set Test Failed  Ping has not been regained within timeout=${PING_TIMEOUT}s.

    Verify SBTS After Recovery
    Check restartCause and resetReason

    ${reset_counter}=  Get value of restart counter
    Log  Current value of reset counter is: ${reset_counter}   console=${TRUE}
    ${status}=  Run Keyword And Return Status  Should Be Equal As Integers  ${reset_counter}  1
    Run Keyword If  ${status}
    ...   Log   Reset counter has been incremented, recovery reset has been performed.   console=${TRUE}
    ...   ELSE
    ...   Set Test Failed  Recovery reset was not performed or multiple resets.


Step 2: Perform site reset to clear recovery counters
    Log  Step 2: Site reset will be performed to clear recovery reset counters.   console=${TRUE}
    coam.Reset Site
    Log  Site reset has been performed [OK].   console=${TRUE}
    Wait Until Keyword Succeeds  2 min  0 sec  check_if_target_is_stable  ${SMOD1['IP']}  30  30  120
    Log  Ping to SBTS is back, test will be continued [OK].   console=${TRUE}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT} sec  60 sec  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

Verify SBTS After Recovery
    Log  Verify SBTS after Recovery.   console=${TRUE}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check links status  Available
    Admin Check Active Alarms TAF

Check restartCause and resetReason
    ${smod_object}=  Query Infomodel  get object /MRBTS-1/RAT-1/${VAR_BTS_L}/EQM_L-1/CABINET_L-1/SMOD_L-1
    Run Keyword If  '${smod_object.restartCause}'=='SoftwareReset'
    ...  Log  restartCause was SoftwareReset.   console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  restartCause is different than expected.
    Run Keyword If  '${smod_object.resetReason}'=='Recovery'
    ...  Log  resetReason was Recovery.   console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  resetReason is different than expected.

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
