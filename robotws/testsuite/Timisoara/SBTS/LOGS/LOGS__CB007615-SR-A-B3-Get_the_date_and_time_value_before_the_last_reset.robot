*** Settings ***
Resource    ../resources/unpacking.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pdu.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource   ../resources/ping_utils.robot
#Resource   ../common_resources/sbts_netact.robot
Library    OperatingSystem
Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot

*** Variables ***
${SNAPSHOT_EXTRACTED}  ${FALSE}
${DISABLE_NETACT_CHECK}    False
${RESET_TYPE}
${RESET_DATE}
${MATCHES}
${STARTUP_TIMEOUT}  10  # Timeout value in minutes after startup for all modules to reach working state.
${SECOND_ALARM_TIMEOUT}  600  # [in seconds] Timeout for WebEm and NetAct alarms (alarm may appear later than the first)
${DATE_TIME_FILE}   /ffs/run/config/lifedata/date_time.txt
${DATE_TIME_FILE_FROM_LAST_RESET}   /var/run/clksync_rtc/date_time_from_previous_reset.txt

*** Keywords ***
TC__LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Documentation]
    ...  [CASE LINK]:
    ...  ******************
    ...  Author: Alexandru Tancau
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-09-24 - TC created. version 1.0
    ...  - 2024-10-07 - TC adapted to check fault 4592 Additional Information
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check if the date and time value is the one before the last reset
    ...  *******************

    Step 0: Preconditions
    Step 1: Get date_time value before reset
    Step 2: Perform Power Reset
    Step 3: Get last date_time known value
    Step 4: Wait for Fault 4592
    Step 5: Check Fault 4592 in NetAct

Step 0: Preconditions
    [Documentation]
    ...  In this step needed test variables are declared

    Log  \nPreconditions  console=${True}

    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
#    Set MRBTS Dist Name
    coam.Reset Site
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    Log    Reset site done    console=${TRUE}
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}


Step 1: Get date_time value before reset
    Log  Check if date_time.txt file exists on BTS and if it is NOT empty  console=yes
    ${dir_exists}=  ssh_utils.Check if directory exists  ${DATE_TIME_FILE}
    Run keyword unless  ${dir_exists}  Return from keyword
    Set Connection Parameters   ip_address=${msm_ip}  user_name=${user_name}  password=${password}
    ${cmd_return}=      Run Command     cmd=cat ${DATE_TIME_FILE}
    Set Connection Parameters   ip_address=${msm_ip}  user_name=${user_name}  password=${password}
    ${date_return}=     Run Command     cmd=date -d ${cmd_return}
    Log    ${date_return}

Step 2: Perform Power Reset
    Power Reset

Step 3: Get last date_time known value
    Log  Check if date_time.txt file exists on BTS and if it is NOT empty  console=yes
    ${dir_exists}=  ssh_utils.Check if directory exists  ${DATE_TIME_FILE_FROM_LAST_RESET}
    Run keyword unless  ${dir_exists}  Return from keyword
    Set Connection Parameters   ip_address=${msm_ip}  user_name=${user_name}  password=${password}
    ${cmd_return}=      Run Command     cmd=cat ${DATE_TIME_FILE_FROM_LAST_RESET}
    Set Connection Parameters   ip_address=${msm_ip}  user_name=${user_name}  password=${password}
    ${date_return}=     Run Command     cmd=date -d ${cmd_return}
    Log    ${date_return}
    Set Test Variable    ${date_return}

Step 4: Wait for Fault 4592
    ${FAULT_4592}   Create Dictionary    fault_id=4592
                    ...                  fault_name='BTS Reset Cause'
                    ...                  alarm_id=7115
                    ...                  alarm_name='BASE STATION INFORMATION'
                    ...                  severity='Warning'
    ${fault_4592_params}  Get String With Alarm Parameters  ${FAULT_4592}
    coam.Assert Alarm Inactive  parameters=${fault_4592_params}  timeout=${SECOND_ALARM_TIMEOUT}
    Log  Fault 4592 "${FAULT_4592}[fault_name]" is reported in WebEm.  console=true
#    Check Fault 4592 Information In WebEM Alarm History  PowerOn

Step 5: Check Fault 4592 in NetAct
    Run Keyword if     '${DISABLE_NETACT_CHECK}' == 'True'
    ...  Run Keywords    Wait Until Keyword Succeeds  ${SECOND_ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4592}  time_from=${START_TIME}
    ...  AND    Log  Fault 4592 "${FAULT_4592}[fault_name]" is reported & cleared from NetAct.  console=true
    ...  AND    Check Fault 4592 Information In Netact Alarm History  PowerOn    #${date_return}
    ...  Else      Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR

Power Reset
    Log  Step1: Perform BTS power reset  console=yes
    ${START_TIME}    Get Current Date  time_zone=UTC  result_format=datetime
    set test variable    ${START_TIME}
    ${interfaces}  bts_states.Get Modules For Interfaces
    FOR  ${module_distname}  IN  @{interfaces}
        ${match}  run keyword and ignore error  should contain  ${module_distname}  SMOD_
        run keyword if  '${match[0]}'=='PASS'  run keywords
        ...  pdu.Pdu BTS Interface Off  ${module_distname}
        ...  AND  log  power on pdu interface ${module_distname} is turned OFF  console=yes
        ...  AND  sleep  1s
        ...  AND  pdu.Pdu BTS Interface On  ${module_distname}
        ...  AND  log  power on pdu interface ${module_distname} is turned ON  console=yes
    END
    ${RESET_DATE}  DateTime.get current date  time_zone=UTC
    set test variable  ${RESET_DATE}
    ping_utils.Wait For Target IP To Be Reachable    ${SMOD1['IP']}    10
    Sleep  180s
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    Wait Until Keyword Succeeds    15min    30s    coam.Assert alarm inactive    faultId=7300, severity=Major
    Wait Until Keyword Succeeds    1min    30s    coam.Assert alarm inactive    faultId=7319, severity=Major
    bts_states.Check Active Alarms

Get String With Alarm Parameters
    [Documentation]  This KW is returning one string obtained from alarm parameters dictionary.
    ...  *AUTHOR* andrada-lavinia.baleti@nokia.com
    [Arguments]  ${alarm_dict}

    ${new_keys}  Create Dictionary  fault_id=faultId  fault_name=faultName  alarm_id=alarmId  alarm_name=alarmName  severity=severity
    ${string}  Set Variable  ${EMPTY}
    FOR  ${param}  IN  @{alarm_dict}
        ${param_value}  Run Keyword If  '${param}'=='fault_name' or '${param}'=='alarm_name'
        ...  Catenate  SEPARATOR=  "  ${alarm_dict}[${param}]  "
        ...  ELSE
        ...  Set Variable  ${alarm_dict}[${param}]
        ${string}  Catenate  ${string}  ${new_keys}[${param}]=${param_value},
    END
    ${string}  Get Substring  ${string}  1  -1

    [Return]  ${string}

Check Fault 4592 Information In WebEM Alarm History
    [Documentation]  Keyword designed to check duration and reason for fault 4592 in WebEM alarm history.
    ...  Alarm should appear 5 minutes after BTS reset and it should be active in WebEm for the time defined by fault4592CancellationTimer parameter.
    ...  Alarm duration is calculated as the diference between clearedTime and btsObservationTime fields.
    ...  Alarm duration time is checked to be in fault4592CancellationTimer-10s and fault4592CancellationTimer10s time period.
    [Arguments]  ${fault_reason}  ${fault_id}=4592

    ${list}  Create List  fault4592CancellationTimer
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${timer}  Set Variable  ${parameter}[0][parameters][fault4592CancellationTimer]
    ${timer}  Convert To Integer  ${timer}
    Log  Getting alarm history from WebEM.  console=true
    ${historic_alarms}  coam.Get Historic Alarms
    FOR  ${item}  IN  @{historic_alarms}
        ${alarm}  Set Variable If  ${item}[faultId]==${fault_id}  ${item}
        Exit For Loop If  ${item}[faultId]==${fault_id}
    END
    ${observation_time}  Set Variable  ${alarm}[btsObservationTime]
    ${cleared_time}  Set Variable  ${alarm}[clearedTime]
    Log  ${observation_time}  console=true
    Log  ${cleared_time}  console=true
    ${time}  Convert To List  ${observation_time}
    ${hour_time_stamp}  Catenate  SEPARATOR=  ${time}[8]${time}[9]  :${time}[10]${time}[11]  :${time}[12]${time}[13]
    ${time_stamp_observation_time}  Convert To String  ${hour_time_stamp}
    ${time}  Convert To List  ${cleared_time}
    ${hour_time_stamp}  Catenate  SEPARATOR=  ${time}[8]${time}[9]  :${time}[10]${time}[11]  :${time}[12]${time}[13]
    ${time_stamp_cleared_time}  Convert To String  ${hour_time_stamp}
    ${alarm_duration}  Subtract Time From Time  ${time_stamp_cleared_time}  ${time_stamp_observation_time}
    ${alarm_duration}  Convert To Integer  ${alarm_duration}
    ${alarm_total_time}  Evaluate  ${timer}-10 <= ${alarm_duration} <= ${timer}+10
    Run Keyword If  ${alarm_total_time}
    ...  Log  Duration of fault 4592 BTS Reset is: ${alarm_duration}. Value within tolerance defined by fault4592CancellationTimer=${timer}.
    ...  console=true
    ...  ELSE
    ...  Fail  Duration of fault 4592 BTS Reset is: ${alarm_duration}. Value not within tolerance defined by fault4592CancellationTimer=${timer}.
    Check Supplementary Alarm Information  ${alarm}  ${fault_reason}

Check Supplementary Alarm Information
    [Arguments]  ${alarm}  ${reason}

    ${suplementary_info}  Get From Dictionary  ${alarm}[alarmText][alarmAdditionalInfo]  supplAlarmInfo
    Should Contain  ${suplementary_info}  ${reason}  Reset reason not OK.
    Log  Reset reason OK.  console=true

Set MRBTS Dist Name
    [Documentation]  This keyword is used to set MRBTS dist name

    ${bts_info_result}  Get Bts Info
    Set Test Variable  ${MRBTS_DN}  PLMN-PLMN/${bts_info_result}[id][configuration]

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
