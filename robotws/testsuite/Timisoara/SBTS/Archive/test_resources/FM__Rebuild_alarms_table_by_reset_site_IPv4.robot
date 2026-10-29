*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${RECOVERY_TIMEOUT}   900
${PING_TIMEOUT}       180
${ONAP_IP}                       #ip to connect to ONAP
${WORKER_IP}                     #any WORKER IP can be chosen (from ONAP)
${ONAP_USERNAME}                 #user name for ONAP connection (usually root)
${ONAP_PASSWORD}

*** Keywords ***
FM__Rebuild_alarms_table_by_reset_site_IPv4
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23483
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test is created to check FM events in ONAP tool
    ...  First, connection to ONAP is established and needed parameters are changed(actForceAutoReset, activateSendingFmEvents)
    ...  Multiple types of faults are triggered(61652, 2080, 49, 4654)
    ...  After every fault triggering, FM event is checked in ONAP and must be visible. Also WebEm alarm is checked.
    ...  Types of events that must appear: notifyAlarmListRebuilt, notifyNewAlarm, notifyClearedAlarm
    ...  During the test reset site is also performed.
    ...  History of changes
    ...  ******************
    ...  27.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23374 - Initial TAT creation
    ...  09.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24443 - Change connection type
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  ******************

    Set Tags        CA-FM  OWNER-virgil.blot@nokia.com  AUTHOR-anna.benzar@nokia.com
    ...             MAINTAINER-anna.benzar@nokia.com    GROUP_IN_CHARGE-TIM_1_Vrf    PHASE-CRT  SW-SBTS22

    Step0: Open conection and set initial variables
    Step1: Configuration of VESENDPOINTS
    Step2: Trigger fault 61652 on BTS
    Step3: Change activateSendingFmEvents parameter
    Step4: Check FM event is visible in ONAP
    Step5: BTS Site reset
    Step6: Check FM event is visible in ONAP
    Step7: Trigger fault for BTS autorecovery
    Step8: Check FM event is visible in ONAP
    Step9: Check ping to SBTS
    Step10: Check FM event is visible in ONAP
    Step11: Trigger fault 49
    Step12: Check FM event is visible in ONAP
    Step13: Trigger fault 4654 on BTS
    Step14: Check FM event is visible in ONAP
    Step15: BTS Site reset
    Step16: Check FM event is visible in ONAP

Step0: Open conection and set initial variables
    Log  \nStep0: Open conection and set initial variables  console=true
    Connect to ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}
    Set date and time from ONAP
    Set actForceAutoReset value  true
    ${BTS_ID}  Admin Get BTS ID
    Set test variable  ${BTS_ID}

Step1: Configuration of VESENDPOINTS
    Log  \nStep1: Configuration of VESENDPOINT 3  console=true
    ${object}  coam.Get Managed Objects  MPLANEONAP_R
    ${status_object}  Run Keyword And Return Status  Should Be Empty  ${object}
    ${status_parameter}  Run Keyword And Return Status  Should Be Empty  ${object}[0][parameters][sftpServerHostPublicKey]
    Run Keyword If  ${status_object} or ${status_parameter}
    ...  Run keywords  Log  Creating MPLANONAP object  console=true  AND  Create MPLANEONAP object
    ...  ELSE
    ...  Delete and recreate MPLANEONAP object  ${RECOVERY_TIMEOUT}
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  30  Check modules and cells
    Log  Adding VESENDPOINTS  console=true
    Add certificates to CMP object
    Add VESENDPOINT-ID  1
    Add VESENDPOINT-ID  2
    Add VESENDPOINT-ID  3
    VES Endpoint reference change    vesFaultCollectorEndpointDN    3

Step2: Trigger fault 61652 on BTS
    Log  \nStep2: Trigger fault 61652 on BTS  console=true
    Trigger Fault 61652  true
    Log  Fault 61652 sent.  console=true
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_61652}
    Assert alarm active  parameters=${alarm_parameters}
    ...                  timeout=180
    Log  Alarm "${FAULT_61652}[fault_name]", with fault id ${FAULT_61652}[fault_id] reported in WebEm.  console=true

Step3: Change activateSendingFmEvents parameter
    Log  \nStep3: Change activateSendingFmEvents parameter  console=true
    ONAP parameter change  activateSendingFmEvents  true

Step${index}: Check FM event is visible in ONAP
    Log  \nStep${index}: Check FM event is visible in ONAP  console=true
    Run Keyword If  ${index}==4 or ${index}==6 or ${index}==16
    ...  Wait until keyword succeeds  120  10  Check FM event VES  notifyAlarmListRebuiltAlarm
    ...  ELSE IF  ${index}==8 or ${index}==12 or ${index}==14
    ...  Wait until keyword succeeds  120  10  Check FM event VES  notifyNewAlarm
    ...  ELSE
    ...  Run keywords  Wait until keyword succeeds  120  10  Check FM event VES  notifyClearedAlarm  AND
    ...  Wait until keyword succeeds  120  10  Check FM event VES  notifyAlarmListRebuiltAlarm

Step${index}: BTS Site reset
    Log  \nStep${index}: BTS Site reset  console=true
    Set date and time from ONAP
    coam.Reset site  ${RECOVERY_TIMEOUT}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  20  Check modules, cells and alarms
    Run keyword if  ${status}
    ...  Log  Site reached on air state after performing site reset.  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air state.

Step7: Trigger fault for BTS autorecovery
    Log  \nStep7: Trigger fault for BTS autorecovery  console=true
    Set date and time from ONAP
    Prepare faultId 2080
    Send Hwapi Api2 Alarm msg  ${SENDER}  ${RECEIVER}  1  2080  ${DOMAIN_ID}  timeout=80
    Log  Fault 2080 sent.  console=${TRUE}
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_2080_SITE_AUTO_RST}
    Assert alarm active  parameters=${alarm_parameters}
    ...                  timeout=180
    Log  Alarm "${FAULT_2080_SITE_AUTO_RST}[fault_name]", with fault id ${FAULT_2080_SITE_AUTO_RST}[fault_id] reported in WebEm.  console=true

Step9: Check ping to SBTS
    Log  \nStep9: Check ping to SBTS  console=true
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${SMOD1['IP']}   timeout=${PING_TIMEOUT}
    Run Keyword If  ${ping_loss_status}==${False}
    ...  Set Test Failed  Ping has not been lost within timeout=${PING_TIMEOUT}
    ...  ELSE
    ...  Log  Ping is lost   console=${TRUE}
    Set date and time from ONAP
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${SMOD1['IP']}   timeout=${PING_TIMEOUT}
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Set Test Failed  Ping has not been regained within timeout=${PING_TIMEOUT}
    ...  ELSE
    ...  Log   Target is Reachable   console=${TRUE}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  20  Check modules, cells and alarms
    Run keyword if  ${status}
    ...  Log  Site reached on air state after autorecovery.  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air state.

Step11: Trigger fault 49
    Log  \nStep11: Trigger fault 49   console=true
    Set date and time from ONAP
    ${cells_dn}  Get Ids for all  LNCEL
    ${cell}  Evaluate  random.choice(${cells_dn})  random
    Set test variable  ${CELL}  ${cell}
    coam.Block Cell  ${cell}
    Log  Fault 49 sent.  console=true
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_49}
    Assert alarm active  parameters=${alarm_parameters}
    ...                  timeout=180
    Log  Alarm "${FAULT_49}[fault_name]", with fault id ${FAULT_49}[fault_id] reported in WebEm.  console=true

Step13: Trigger fault 4654 on BTS
    Cancel fault 49
    Log  \nStep13: Trigger fault 4654 on BTS  console=true
    Set date and time from ONAP
    Trigger fault 4654  false
    Log  Fault 4654 sent.  console=true
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_4654}
    Assert alarm active  parameters=${alarm_parameters}
    ...                  timeout=180
    Log  Alarm "${FAULT_4654}[fault_name]", with fault id ${FAULT_4654}[fault_id] reported in WebEm.  console=true

Set actForceAutoReset value
    [Arguments]  ${value}
    ${actForceAutoReset}  Get actForce(Unit)AutoReset value from infomodel   actForceAutoReset
    Log  actForceAutoReset value is ${actForceAutoReset}  console=true
    ${status}  Run Keyword And Return Status   Change parameter actForce(Unit)AutoReset  ${value}  actForceAutoReset
    ${parameter_after_change}=   Get actForce(Unit)AutoReset value from infomodel   actForceAutoReset
    Run Keyword if   ${status}
    ...   Should be equal  ${parameter_after_change}   ${value}

Trigger Fault 61652
    [Arguments]  ${value}
    Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=actServicePortState
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${True}
    ...    should_activate=${True}
    ...    timeout=180

Prepare faultId 2080
    ${bts_l-1}  coam.Get Parameters  /MRBTS-1/RAT-1/BTS_L-1
    ${status}  ${bts_l-4}  Run Keyword And Ignore Error  coam.Get Parameters  /MRBTS-1/RAT-1/BTS_L-4
    Run keyword if  '${bts_l-1}[storedRole]' == 'Active' or '${bts_l-1}[storedRole]' == 'Single'
    ...  Set sender and receiver values  ${bts_l-1}[hwapiDomainId]
    ...  ELSE
    ...  Set sender and receiver values  ${bts_l-4}[hwapiDomainId]

Set sender and receiver values
    [Arguments]  ${hwapiDomainId}
    Run Keyword if  '${hwapiDomainId}' == '1'
    ...   Set values for hwapiDomain1
    ...   ELSE
    ...   Set values for hwapiDomain2

Set values for hwapiDomain1
    ${receiver}  Set Variable  269554178
    Set Test Variable  ${RECEIVER}  ${receiver}
    ${sender}  Set Variable  269550144
    Set Test Variable  ${SENDER}  ${sender}
    ${domain_id}  Set Variable  16
    Set Test Variable  ${DOMAIN_ID}  ${domain_id}

Set values for hwapiDomain2
    ${receiver}  Set Variable  537989634
    Set Test Variable  ${RECEIVER}  ${receiver}
    ${sender}  Set Variable  537985600
    Set Test Variable  ${SENDER}  ${sender}
    ${domain_id}  Set Variable  32
    Set Test Variable  ${DOMAIN_ID}  ${domain_id}

Check cell blocking state
    ${cell_parameters}  coam.Get parameters  ${CELL}
    ${status_cell}  Run Keyword and Return Status  Should contain  ${Blocked_}  ${cell_parameters}[blockingState]
    Run keyword if  ${status_cell}
    ...  Cancel fault 49
    ...  ELSE
    ...  Log  Fault 49 already canceled.  console=true

Cancel fault 49
    Log  Canceling fault 49.  console=true
    coam.Unblock Cell  ${CELL}
    ${status_cell}  Run keyword and return status  Wait until keyword succeeds  180  10  Check cell operational state
    Run keyword if  ${status_cell}
    ...  Log  Fault 49 canceled(cell unblocked).  console=true
    ...  ELSE
    ...  Fail  Didn't manage to cancel fault 49(cell is still blocked).
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_49}
    Assert alarm inactive  parameters=${alarm_parameters}
    ...                    timeout=180
    Log  Alarm "${FAULT_49}[fault_name]", with fault id ${FAULT_49}[fault_id] reported in WebEm.  console=true

Check cell operational state
     ${cell_parameters}  coam.Get parameters  ${CELL}
     ${status}  Run Keyword and Return Status  Should contain  ${Enabled_}  ${cell_parameters}[operationalState]
     Run keyword unless  ${status}
     ...  Fail  Cell still blocked.

Trigger fault 4654
    [Arguments]  ${value}
    Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=ethernetPortSecurityEnabled
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${True}
    ...    should_activate=${True}
    ...    timeout=180

Check modules, cells and alarms
    ${list_modules}  Create List  SMOD  BBMOD  RMOD
    FOR  ${module}  IN  @{list_modules}
        Assert every  ${module}  operationalState=${Enabled_}
    END
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Admin Check Active Alarms TAF

Restore initial values
    ONAP parameter change  activateSendingFmEvents  false
    Set actForceAutoReset value  false
    Trigger Fault 61652  false
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_61652}
    Assert alarm inactive  parameters=${alarm_parameters}
    ...                    timeout=180
    Log  Alarm "${FAULT_61652}[fault_name]", with fault id ${FAULT_61652}[fault_id] reported in WebEm.  console=true
    ${status_cell_exists}  Run keyword and return status  Variable Should Exist  ${CELL}
    Run keyword if  ${status_cell_exists}
    ...  Check cell blocking state
    Trigger fault 4654  true
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_4654}
    Assert alarm inactive  parameters=${alarm_parameters}
    ...                    timeout=180
    Log  Alarm "${FAULT_4654}[fault_name]", with fault id ${FAULT_4654}[fault_id] reported in WebEm.  console=true
    SSHLibrary.Close Connection

TC Setup
    Common Test Setup  tc_name=FM__Rebuild_alarms_table_by_reset_site_IPv4

TC Teardown
    Restore initial values
    Common Test Teardown
