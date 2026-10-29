*** Settings ***
Documentation
    ...  This test case is created to trigger BBPOOL recovery.
    ...  Test will randomly select BBMOD which contains LTE cells.
    ...  Fault generation method will be used to trigger fault id 6710 with fault name "BBPOOL autonomous reset as recovery action".
    ...  Also recovery action will pe checked.
    ...  Send second fault and check:
    ...  1. If actForceAutoReset is False check Buffer Overflow Alarm and perform site reset as recovery.
    ...  2. If actForceAutoReset is true check Site Reset.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  200  # Timeout for SBTS to recover after BBPOOL reset
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after site reset
${ALARM_TIMEOUT}  600  # Timeout for alarm to appear in WebEM


*** Keywords ***
TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18543
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  11.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18543 - Initial TAT creation
    ...  05.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19650 - Update FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    ...  25.08.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20101 - Modify test implementation
    ...  14.12.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20627 - Modify Get allowBbPoolRecoveryReset value from infomodel KW
    ...  15.12.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20638 - Add check for duration time of alarm
    ...  27.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21633 - FastPass improvement - add Netact check in different scenarios
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22360 - Remove stateInfo from check bbmod KW
    ...  11.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22471 - Fix kw set test restriction name
    ...  28.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22560 - Fix for param type difference from trunk and branch
    ...  01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  12.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22776 - Change power group to Power Group 2
    ...  07.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23221 - Fix for BBMOD selection to be ABIA
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26921 - Increase alarm timeout
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  11.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27559 - Alarm not found within timeout
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28418 - Test fails because fault 6710 is not found
    ...  20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-29565 - Add another crash
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP002187

    Step0: Check All Required States
    Step1: Perform Site Reset
    Step2: Set Sender And Reciver
    Step3: Send Fault 6710 And Verify Fault
    Step4: Verify SBTS After Recovery
    Step5: Send Second Fault 6710


Step0: Check All Required States
    Log  \nStep0: Check all required states.  console=true

    Check Commissioned Technologies  LTE
    Change Parameter AllowBbPoolRecoveryReset  true


Step1: Perform Site Reset
    Log  \nStep1: Perform site reset.  console=true

    Perform Site Reset


Step2: Set Sender And Reciver
    Log  \nStep2: Set sender and reciver.  console=true

    ${core}  ${id_bbmod}  ${bbmod_l}  Get BBMOD
    ${dsp}  Evaluate  random.choice([5,6])  random
    ${dsp_core}  Evaluate  random.randint(1,8)  random
    ${sender}  Set Variable  0X${core}${id_bbmod}${dsp}${dsp_core}0240
    ${reciver}  Set Variable If  '${core}'=='1'  0x10110009  0x20110009
    ${node_id}  Convert To Integer  0X${core}${id_bbmod}${dsp}${dsp_core}
    Log  Sender is: ${sender}  console=true
    Log  Reciver is: ${reciver}  console=true
    Log  NodeId is: ${node_id}  console=true
    Set Test Variable  ${SENDER}
    Set Test Variable  ${RECIVER}
    Set Test Variable  ${NODE_ID}
    Set Test Variable  ${BBMOD_L}


Step3: Send Fault 6710 And Verify Fault
    Log  \nStep3: Send fault 6710 and verify fault.  console=true

    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=true  alias=check_alarm
    ${fid_6710_params}  Get String With Alarm Parameters  ${FAULT_6710_BBPOOL_AUTO_RST}
    ${alarm_status}  Run Keyword In Background  Assert alarm active  parameters=${fid_6710_params}  timeout=${ALARM_TIMEOUT}  alias=check_alarm
    Sleep  10
    Send Fault Ind Msg  ${SENDER}  ${RECIVER}  6710  1
    ${bbmod_status}  Run Keyword And Return Status  Assert Any  BBMOD  availabilityStatus=${DEGRADED}  timeout=60

    ${core}  Query Infomodel  get object //CORE_L-* is [nodeId=${NODE_ID}]
    ${condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}  '${core.stateInfo}[administrativeState]'=='Unlocked'
    ...  '${core.stateInfo}[availabilityStatus]'=='Offline'  '${core.stateInfo}[operationalState]'=='Disabled'
    ...  '${core.stateInfo}[proceduralState]'=='Resetting'
    IF  ${condition}
        Log  Core is resetting.  console=true
    ELSE
        Set Test Restriction  msg=Core status not ok after triggering fault.
    END
    IF  ${bbmod_status}
        Log  BBMOD was degraded [OK].  console=true
    ELSE
        Set Test Restriction  msg=BBMOD was not degraded.
    END
    ${alarm_result}  Collect Keyword Result  ${alarm_status}  timeout=${ALARM_TIMEOUT}
    IF  ${alarm_result}
        Log  Fault ${FAULT_6710_BBPOOL_AUTO_RST}[fault_id] "${FAULT_6710_BBPOOL_AUTO_RST}[fault_name]" appeared.  console=true
    ELSE
        Set Test Failed  Fault ${FAULT_6710_BBPOOL_AUTO_RST}[fault_id] "${FAULT_6710_BBPOOL_AUTO_RST}[fault_name]" did not occur.
    END


Step4: Verify SBTS After Recovery
    Log  \nStep4: Verify SBTS after recovery.  console=true

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    Log  Check if cells status from other RATs remained unchanged.  console=true
    Check Links Status  Available
    ${fid_6710_params}  Get String With Alarm Parameters  ${FAULT_6710_BBPOOL_AUTO_RST}
    ${alarm_cleared}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fid_6710_params}
    IF  ${alarm_cleared}
        Log  Fault ${FAULT_6710_BBPOOL_AUTO_RST}[fault_id] "${FAULT_6710_BBPOOL_AUTO_RST}[fault_name]" is cleared. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_6710_BBPOOL_AUTO_RST}[fault_id] "${FAULT_6710_BBPOOL_AUTO_RST}[fault_name]" is still visible.
    END
    Check Active Alarm Time
    Admin Check Active Alarms TAF
    ${check_fault_na}  Run Keyword And Return Status
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6710_BBPOOL_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_6710_BBPOOL_AUTO_RST}[fault_id]
    IF  ${check_fault_na}
        Log  Given alarm and fault fields are correct in NA, alarm is present in NA [OK].  console=true
    ELSE
        Fail  Given alarm and fault fields are incorrect in NA or alarm is missing in NA [NOK].
    END


Step5: Send Second Fault 6710
    Log  \nStep5: Send Second Fault 6710  console=true

    ${actForceAutoReset_status}  Get FMCADM Parameter Value  actForceAutoReset
    Send Fault Ind Msg  ${SENDER}  ${RECIVER}  6710  1
    IF  ${actForceAutoReset_status}
        Log  Parameter actForceAutoReset: ${actForceAutoReset_status} \nChecking site reset.  console=true
        Check Site Reset
    ELSE
        Log  Parameter actForceAutoReset: ${actForceAutoReset_status} \nChecking Buffer Overflow Alarm.  console=true
        Check Buffer Overflow Alarm
    END


Get FMCADM Parameter Value
    [Arguments]    ${parameter}

    ${list}  Create List  ${parameter}
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${actual_value}  Set Variable  ${object}[0][parameters][${parameter}]

    RETURN  ${actual_value}


Check Buffer Overflow Alarm
    ${6710_aif2_buff_overflow}  Get String With Alarm Parameters  ${FAULT_6710_AIF2_BUFF_OVERFLOW}
    Assert Alarm Active  parameters=${6710_aif2_buff_overflow}  timeout=${ALARM_TIMEOUT}
    Log  Check FAULT 6710 AIF2 BUFF OVERFLOW in Mantaray active alarms.  console=true
    Wait Until Keyword Succeeds  5m  1m  Check Additional Information For Given Alarm And Fault  &{FAULT_6710_AIF2_BUFF_OVERFLOW}
    Perform Site Reset


Check Site Reset
    ${fault_6710}  Get String With Alarm Parameters  ${FAULT_6710_SITE_RESET}
    Assert Alarm Active  parameters=${fault_6710}  timeout=${ALARM_TIMEOUT}
    Wait For Target To Be Not Reachable  ${SMOD1['IP']}  timeout=300
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  1m  Check Modules And Cells


Get BBMOD
    ${bbmod_l_list}  Get BBMODs For RAT  LTE
    ${bbmod_l}  Evaluate  random.choice(${bbmod_l_list})  random
    ${core}  ${id_bbmod}  Get BBMOD Position  ${bbmod_l}

    RETURN  ${core}  ${id_bbmod}  ${bbmod_l}


Get BBMODs For RAT
    [Documentation]
    ...  This KW returns a list of BBMODs dist_name for the given RAT.
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${rat}

    ${soc_list}  Query Infomodel  get list //BBMOD_L-*/BBU_L-1/POWER_GROUP_L-2/SOC_L-*
    ${bbmod_rat}  Create List
    FOR  ${bbmod}  IN  @{soc_list}
        ${rat_type}  Get RAT As String  ${bbmod.rat}
        IF  '${rat_type}'=='${rat}'  Append To List  ${bbmod_rat}  ${bbmod.dist_name}
    END
    ${bbmod}  Create List
    FOR  ${distname}  IN  @{bbmod_rat}
        ${dist}  Fetch From Left  ${distname}  /BBU_L
        ${bbmod_variant}  coam.Get Parameters  ${dist}
        IF  "${bbmod_variant}[productName]" == "ABIA AirScale Capacity"  Append To List  ${bbmod}  ${dist}
    END
    ${bbmod_list}  Remove Duplicates  ${bbmod}
    Log  List of BBMODs for ${rat} is: ${bbmod_list}  console=true

    RETURN  ${bbmod_list}


Get BBMOD Position
    [Arguments]  ${bbmod_l}

    ${bbmod}  Query Infomodel  get object ${bbmod_l}
    ${bbmod_r}  Query Infomodel  get object //BBMOD_R-* is [serialNumber=${bbmod.serialNumber}]

    RETURN  ${bbmod_r.horizontalPosition}  ${bbmod_r.verticalPosition}


Check Active Alarm Time
    [Documentation]  This keyword calculates the active time for alarm fault 6710.
    ...  *AUTHOR* cosmina.rebenciuc@nokia.com

    ${alarm_hist}  Get Historic Alarms
    FOR  ${alarm}  IN  @{alarm_hist}
        IF  '${alarm.faultId}' == '6710'  BREAK
    END
    ${timestamp_appeared}  Fetch From Left  ${alarm}[btsObservationTime]  .
    ${timestamp_cleared}  Fetch From Left  ${alarm}[clearedTime]  .
    ${date_time_appeared}  Convert Date  ${timestamp_appeared}  exclude_millis=yes
    Log  Alarm appeared at: ${date_time_appeared}.  console=true
    ${date_time_cleared}  Convert Date  ${timestamp_cleared}  exclude_millis=yes
    Log  Alarm cleared at: ${date_time_cleared}.  console=true
    ${time_appeared}  Fetch From Right  ${date_time_appeared}  ${SPACE}
    ${time_cleared}  Fetch From Right  ${date_time_cleared}  ${SPACE}
    ${active_time}  Subtract Time From Time  ${time_cleared}  ${time_appeared}
    Log  Alarm was active for: ${active_time} seconds.  console=true


TC Setup
    Common Test Setup  tc_name=FM__BBPOOL_reset_allowBbPoolRecoveryReset_true
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Perform Site Reset
    Teardown NetAct
    Common Test Teardown
