*** Settings ***
Documentation  Test Suite for TL10836
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.fdsw.rc    WITH NAME    fdsw
Library    Collections
Resource    ../resources/ssh_utils.robot
Resource    ../resources/ping_utils.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/taf_coam.robot

*** Variables ***
${STARTUP_TIMEOUT}  20
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu


*** Keywords ***
TC__LOGS_CB010969_CB008329_CRT_adapted
    [Documentation]
    ...  [CASE LINK]:
    ...  ******************
    ...  Author: Maria Popescu
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2025-10-14 - TC adapted. version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check if Sanity Checker detects NetbootEnabled and a CP to check file removal
    ...  *******************

    Step 0: Preconditions
    Step 1: Set Netboot on SMOD
    Step 2: Trigger Diagnostic Check with no service impact
    Step 3: Delete Netboot Variable and check it's not present
    Step 4: 002_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Active_Partition
    Step 5: Restore files
Step 0: Preconditions
    [Documentation]
    ...   in this step we are verifying if BTS is up and running
    Log    \nStep 0: Preconditions      console=${True}
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable    ${BTS_ID}    ${btsid}

Step 1: Set Netboot on SMOD
    [Documentation]
    ...   in this step we are connecting on SMOD and  setting Netboot variable
    SSH Connection
    Log    \nStep 1.1: Connected to SMOD and setting netboot variable      console=${True}
    ${output_1}   ssh.Execute   command=uboot_env set netboot=netboot_only
    Should Contain Any   ${output_1}   Added 1 variable   Added 0 variable

    Log    \nStep 1.2: Check the value has been set      console=${True}
    ${output}   ssh.Execute   command=uboot_env get netboot
    Should Contain   ${output}   netboot=netboot_only

Step 2: Trigger Diagnostic Check with no service impact
    [Documentation]
    ...   In this step Diagnostic Check for CP4 (netboot) will run with allow_service_impact=False and check that the supplementary
    ...   information of the alarm contains CP4

    Log    \nStep 2.1: Trigger Diagnostic Check with no service impact    console=${True}

    ${DC1_result}    coam.Run Diagnostic Check    allow_service_impact=${False}    timeout=930
    Log    \nStep 2.2: Check fault Supplementary information of FID: 4681
    Check Netboot Detection Alarm

Step 3: Delete Netboot Variable and check it's not present
    [Documentation]
    ...   In this Step we delete Netbood variable and we test the deletion worked
    SSH Connection
    ${output_1}   ssh.Execute   command=uboot_env del netboot
    Should Contain Any   ${output_1}   Deleted netboot   Variable netboot not found

    ${output}   ssh.Execute   command=uboot_env get netboot
    Should Contain   ${output}  Variable netboot not found
    Sleep   30s
    Log    \nStep 3: Trigger Diagnostic Check and no presence of FID:4681    console=${True}
    ${DC1_result}    coam.Run Diagnostic Check    allow_service_impact=${False}    timeout=930
    Check No Netboot Detection Alarm


Step 4: 002_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Active_Partition
    [Documentation]
    ...   In this step we move some files in a different directory to simulate their deletion and then we perform a DC
    Log    \nStep 4: Delete/Move the files and perform and DC   console=${True}
    Delete Active FileDirectory
    ${DC1_result}    coam.Run Diagnostic Check    allow_service_impact=${False}    timeout=930
    Check Active Missing Files Detection Alarm

Step 5: Restore files
    [Documentation]
    ...   In this step the files are restored and a check is performed
    Log    \nStep 5: Restore the files and perform a DC   console=${True}
    Restore Active FileDirectory
    Sleep   30s
    ${DC1_result}    coam.Run Diagnostic Check    allow_service_impact=${False}    timeout=930
    Check Active No Missing Files Detection Alarm



Check Netboot Detection Alarm
    Log To Console   "Check Netboot Detection Alarm"
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Contain   ${supplAlarmInfo}   4
    Should Contain Any   ${severity}   Warning   Minor

Get SC Active Alarm
    ${active_alarms}   coam.Get Active Alarms
    ${supplAlarmInfo}   Set Variable   NONE
    ${severity}   Set Variable   NONE
    ${alarm_id}   Set Variable   NONE
    ${fault_id}   Set Variable   NONE
    FOR   ${alarm}   IN   @{active_alarms}
        Continue For Loop If   '${alarm['faultId']}'!='4681' or '${alarm['alarmId']}'!='7115'
        ${alarm_id}   Set Variable   ${alarm['alarmId']}
        ${fault_id}   Set Variable   ${alarm['faultId']}
        ${severity}   Set Variable   ${alarm['severity']}
        ${supplAlarmInfo}   Set Variable   ${alarm['supplAlarmInfo']}
        # ${supplAlarmInfo}   Get Regexp Matches   ${supplAlarmInfo}   {(.*)}
        # ${supplAlarmInfo}   Convert To String   ${supplAlarmInfo}
        Exit For Loop If   '${alarm['faultId']}'!='4681' or '${alarm['alarmId']}'!='7115'
    END
    [Return]   ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}

Check No Netboot Detection Alarm
    Log To Console   "Check No Netboot Detection Alarm"
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Not Contain   ${supplAlarmInfo}   4
    Sleep   10s

Delete Active FileDirectory
    SSH Connection
    ssh.Execute   command=mkdir -p /user/toor4nsn/test
    ssh.Execute   command=mv -f /rom/swpool/OAM/radioMappingFiles/beamforming* /user/toor4nsn/test/

Check Active Missing Files Detection Alarm
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Contain Any   ${supplAlarmInfo}   5a   5
    Should Contain Any   ${severity}   Warning   Minor

Restore Active FileDirectory
    SSH Connection
    ssh.Execute   command=mv -f /user/toor4nsn/test/beamforming* /rom/swpool/OAM/radioMappingFiles/

Check Active No Missing Files Detection Alarm
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Not Contain Any   ${supplAlarmInfo}   5a   5
    Sleep   10s

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown

