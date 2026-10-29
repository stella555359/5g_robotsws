*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1014    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${NEED_TO_CHECK_LTE_RAT_STATUS}    True
@{IGNORED_ALARMS}    {'alarmId': 7220, 'faultId': 4655}    {'alarmId': 7109, 'faultId': 61524}    {'alarmId': 7115, 'faultId': 6450}
...    {'alarmId': 7220, 'faultId': 4654}    {'alarmId': 7220, 'faultId': 61652}    {'alarmId': 7220, 'faultId': 61649}
@{UNEXPECTED_ALARMS}    {'faultId': 4383}

*** Keywords ***
SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    New case for RAN_ST_CB008708_001_CM_SR_Verify NE3S feedback when recovery reset is executed via NMS action provision
    ...    This case target is to trigger recovery reset via action command and check whether NE3S feedback is correct
    ...    when recovery reset is executed.
    ...    Pass criteria: Provision request success and message is correct from wireshark
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.06.2025 - New case
    Set Tags    SyVe    AUTHOR-lixin.kang@nokia.com    PHASE-CRT    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_4@internal.nsn.com
    Step 1: Make BTS Exists Failure Alarms
    Step 2: Trigger Recovery Reset Action Provision
    Step 3: Check Wireshark Messages As Expected
    Step 4: Check No RECOVERY_RESET From Actual Configuration
    Step 5: Check BTS Status

Step ${index}: Make BTS Exists Failure Alarms
    Log To Console    Step ${index}: Make BTS Exists Failure Alarms
    Trigger Fault 4383

Trigger Fault 4383
    ${ssh_index}    Establish SSH to SBTS    ${SMOD1['IP']}
    FOR    ${index}    IN RANGE    0    4
        Log To Console    kill process ${index+1} time(s)
        ${output}    Execute CMD Via SSH connection    ps -ef | grep lxc-start | grep LTE/C_CPNODE    root\@
        ${parts}    Split String    ${output}
        ${pid}    Set Variable     ${parts[1]}
        Log To Console    kill process id:${pid}
        Execute CMD Via SSH connection    kill -11 ${pid}   root\@
        Wait Until Keyword Succeeds    5m    10s    coam.Assert Any    LNCEL    ${cells_LTE_offline_state}
        ${critical_alarm_appear}    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    1m   10s    coam.Assert Alarm Active    faultId=4383, severity=Critical
        Exit For Loop If    ${critical_alarm_appear}
        Wait Until Keyword Succeeds    10m   10s   coam.Assert Every    LNCEL    ${cells_LTE_expected_state}    60s
    END
    Log To Console    Fault 4383 raised.

Step ${index}: Trigger Recovery Reset Action Provision
    Log To Console    Step ${index}: Trigger Recovery Reset Action Provision
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${lnbts_id}    Fetch LNBTS ID
    Start TCPDump On SBTS Common
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmd_part1}    Set Variable    racclimx.sh -op Reset_NE -DN PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ${cmd_part2}    Set Variable    -parameters com.nokia.srbts.mnl:FMCADM.gracefulCellShutdown=no -v
    ${cmd}    Set Variable    ${cmd_part1} ${cmd_part2}
    Log To Console    Trigger Recovery Reset
    ${output}    SSHLibrary.Execute Command    ${cmd}
    Should Contain    ${output}    RAT recovery reset:MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
    Sleep    10s
    Stop TCPDump On SBTS Common
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Check Wireshark Messages As Expected
    Log To Console    Step ${index}: Check Wireshark Messages As Expected
    ${file_content}    Save TCPDump File On Local And Get Content
    #NE3S::OperationStatusReport message with completed element set to "true"
    Should Match Regexp    ${file_content}    </ne3scommon:reportOperationStatus>
    Should Match Regexp    ${file_content}    <ne3scommon:completed>\\s+true\\s+</ne3scommon:completed>
    #check NE3S feedback document
    Should Match Regexp    ${file_content}    <NE3SFeedback\\s+status = "ok"\\s+successful = "1"\\s+unsuccessful = "0"\\s+version="1.0"
    ${msg_str1}    Set Variable    <message_result>\\s+RAT recovery reset:MRBTS-${mrbts_id}/LNBTS-${lnbts_id}\\s+</message_result>
    ${msg_str2}    Set Variable    <managedObjects>\\s+<managedObject\\s+status = "ok"
    ${msg_str3}    Set Variable    distName = "MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1/RECOVERY_RESET-1"
    ${msg_str4}    Set Variable    class = "com.nokia.actions:RECOVERY_RESET"
    ${msg_str5}    Set Variable    operation="create">\\s+</managedObject>\\s+</managedObjects>\\s+</NE3SFeedback>
    Should Match Regexp    ${file_content}    ${msg_str1}\\s+${msg_str2}\\s+${msg_str3}\\s+${msg_str4}\\s+${msg_str5}

Step ${index}: Check No RECOVERY_RESET From Actual Configuration
    Log To Console    Step ${index}: Check No RECOVERY_RESET From Actual Configuration
    ${current_scf}    coam.Get SCF
    Should Not Contain    ${current_scf}    RECOVERY_RESET
    ${actual_plan_name}    Set Variable    ${TEST_NAME}_${mrbts_id}
    NetAct CM Upload    dist_names=${MRBTS_DN}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${actual_plan_name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=None    operation_type=actual
    ${file_content}    OperatingSystem.Get File    ${Test Results Dir}/NetActLogs/${actual_plan_name}.csv
    Should Not Contain    ${file_content}    RECOVERY_RESET

Step ${index}: Check BTS Status
    Log To Console    Step ${index}: Check BTS Status
    Wait Until Keyword Succeeds    10m   10s   Check SBTS SMOD RMOD Cells Alarms

Particular Teardown
    ${status}    Run Keyword And Return Status    Check SBTS SMOD RMOD Cells Alarms
    Run Keyword If    not ${status}    coam.Reset_Site    timeout=300
    Wait Until Keyword Succeeds    15m    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown