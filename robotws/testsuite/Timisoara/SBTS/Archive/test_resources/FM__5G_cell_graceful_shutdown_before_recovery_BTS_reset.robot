*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${PING_TIMEOUT}      120  # Timeout for SBTS startup after site reset


*** Keywords ***
TC__FM__5G_cell_graceful_shutdown_before_recovery_BTS_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-20224
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to check gracefully shutdown of the NR cells. actForceAutoReset and actFaultSignature will be set to true.
    ...  Crash will be done by sending fault 2080 to primary core.
    ...  Recovery action will be tested by checking faultID 2080 with alarmId=7101 BTS site autonomous reset as recovery action
    ...  and the occurance of BTS site reset.
    ...  Fault 2080 should have correct fault signature, gracefully shutdown to the NR cell should appear.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  18.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20224 - Initial TAT creation
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-bogdan.boldurean@nokia.com
    ...  MAINTAINER-laura.craciunel@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS21    FEATURE-RP002956

    Step0: Verify all required states of SBTS
    Step1: Perform site reset
    Step2: Prepare faultId 2080
    Step3: Send fault
    Step4: Verify Recovery Action


Step0: Verify all required states of SBTS
    Log  Step0: Verify all required states of SBTS  console=${TRUE}

    ${actForceAutoReset}=    Get actForce(Unit)AutoReset value from infomodel   actForceAutoReset
    Log  actForceAutoReset value is ${actForceAutoReset}  console=true
    ${status}=   Run Keyword And Return Status   Change parameter actForce(Unit)AutoReset  true  actForceAutoReset
    ${parameter_after_change}=   Get actForce(Unit)AutoReset value from infomodel   actForceAutoReset
    Run Keyword if   ${status}
    ...   should be equal  ${parameter_after_change}   true

    Set actFaultSignature value  true

Step1: Perform site reset
    Log   Step1: Site reset will be performed to clear all counters   console=${TRUE}
    coam.Reset site
    Wait Until Keyword Succeeds  600  10  Check SBTS is up

Check SBTS is up
    Check links status  Available
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

Step2: Prepare faultId 2080
    Log  Step2: Prepare fault 2080  console=${TRUE}
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Active]
    Run Keyword if  '${hwapi_domain.hwapiDomainId}' == '1'  run keyword
    ...   Receiver value for hwapiDomain1
    ...   ELSE
    ...   Receiver value for hwapiDomain2

Receiver value for hwapiDomain1
    ${receiver}  Set Variable  269554178
    Set Test Variable  ${receiver}
    ${sender}  Set Variable  269550144
    Set Test Variable  ${sender}
    ${domain_id}  Set Variable  16
    Set Test Variable  ${domain_id}

Receiver value for hwapiDomain2
    ${receiver}  Set Variable  537989634
    Set Test Variable  ${receiver}
    ${sender}  Set Variable  537985600
    Set Test Variable  ${sender}
    ${domain_id}  Set Variable  32
    Set Test Variable  ${domain_id}

Step3: Send fault
    Log  Step3: Send fault  console=${TRUE}

    Send Hwapi Api2 Alarm msg  ${SENDER}  ${RECEIVER}  1  2080  ${DOMAIN_ID}  timeout=80
    Log  Fault 2080 sent.  console=${TRUE}
    ${states}=  Catenate  stateInfo.availabilityStatus=Failed, stateInfo.operationalState=Disabled, stateInfo.reasoningStatus[0]=SrioHostLinkDown
    ${status_ccu_l}  ${im_ccu_l_object}  Run Keyword And Ignore Error  Query Infomodel  get object //CCU_L-1 is [${states}]   timeout=45
    Run Keyword If  '${status_ccu_l}'=='FAIL'
    ...   Set Test Restriction   message=StateInfo of CCU_L is different than expected [NOK]
    ...   ELSE
    ...   Log  StateInfo: availabilityStatus, operationalState, reasoningStatus for CCU_L is as expected [OK]  console=${TRUE}

    Check fault signature

Check fault signature
    [Documentation]  In this step fault signature is checked for the correct values.
    Log  Check fault signature  console=true

    ${alarm_status}  Assert Alarm Active  parameters=alarmId=7101, faultId=2080, faultName="BTS site autonomous reset as recovery action"  timeout=300
    ${date}  get current date  result_format=%Y%m%d
    ${alarm}  set variable  ${alarm_status}[-1]
    ${faultsig}  set variable  ${alarm}[faultSignature]

    Log  '${faultsig}[extraInfo]'  console=true
    Should Match Regexp  '${faultsig}[extraInfo]'  gracefully_shutdown_cells=.*NR:[0-9]+.*  msg=NR cell did not gracefully shutdown.
    Run Keyword if  '${faultsig}[scope]' != 'Site'  Set test failed  Scope did not mached.
    Should Match Regexp  ${faultsig}[date]  (${date})[0-9]{6}\.  msg=Date not ok.


Step4: Verify Recovery Action
    Log  step4:\n Verify if recovery was performed   console=${TRUE}
    ${ping_loss_status}=  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${SMOD2['IP']}   timeout=${PING_TIMEOUT}
    ...  remote_host=${PC_IP2}
    Run Keyword If  ${ping_loss_status}==${False}  Set Test Failed  Ping has not been lost within timeout=${PING_TIMEOUT}
    ...   ELSE  log  Ping is lost   console=${TRUE}

    ${ping_regain_status}=  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${SMOD2['IP']}   timeout=${PING_TIMEOUT}
    ...  remote_host=${PC_IP2}
    Run Keyword If  ${ping_regain_status}==${False}  Set Test Failed  Ping has not been regained within timeout=${PING_TIMEOUT}
    ...   ELSE   log   Target is Reachable   console=${TRUE}
    Log  Verify SBTS after Recovery   console=${TRUE}

    ${fault_7300}  Run Keyword And Return Status  Assert Alarm Active  parameters=alarmId=7107, faultId=7300, faultName="No X2 link available"
    ...  timeout=300
    ${fault_7319}  Run Keyword And Return Status  Assert Alarm Active  parameters=alarmId=7107, faultId=7319,
    ...  faultName="No X2 link available for a specific LTEENB"  timeout=300
    Run keyword if  ${fault_7300} or ${fault_7319}  Set Test Restriction  Unexpected alarms appeared.

    Wait Until Keyword Succeeds  600  10  Check SBTS is up
    Assert Alarm Inactive  parameters=alarmId=7107, faultId=7300, faultName="No X2 link available"  timeout=600
    Assert Alarm Inactive  parameters=alarmId=7107, faultId=7319, faultName="No X2 link available for a specific LTEENB"  timeout=600
    Admin Check Active Alarms Taf


Change parameters to false
    ${status}=   Run Keyword And Return Status   Change parameter actForce(Unit)AutoReset  false  actForceAutoReset
    ${parameter_after_change}=   Get actForce(Unit)AutoReset value from infomodel   actForceAutoReset
    Run Keyword if   ${status}
    ...   should be equal  ${parameter_after_change}   false  msg=actForceAutoReset is not false

TC Setup
    Common Test Setup

TC Teardown
    Change parameters to false
    Common Test Teardown


