*** Settings ***
Documentation  Test for 6506 alarm
Library    XML    use_lxml=${TRUE}
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library    SSHLibrary
Library     ute_syslog
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  2700
${ip_MSM}    192.168.255.129
${password_MSM}    oZPS0POrRieRtu
${user_name_MSM}    toor4nsn
${trigger_FID6506_MSM}    cd /ffs/run/logs/oam/asm/auditlog; fallocate -l 1.9G test1.txt # create file test.txt
${check_trigger_FID6506}    ls -lah /ffs/run/logs/oam/asm/auditlog | grep test1.txt #check if trigger file is created
${clear_FID6506}    rm -rf /ffs/run/logs/oam/asm/auditlog/test1.txt

#${trigger_FID6504_MSM_ASOG_ASOH}    cd /ffs/run/logs; fallocate -l 1990M test2.txt     #set variable for trigger FID 6504
#${check_trigger_FID6504}    ls -la /ffs/run/logs | grep test2.txt    # variable check if trigger file is created successfully
#${cancel_6504_MSM}    rm -rf /ffs/run/logstest2.txt    #set variable for cancel FID 6504

${big_file_present}    False
*** Keywords ***
TC__LOGS__Trigger_RD_fault_6506_about_utilization_of_log_quota_value
    [Documentation]

    ...  ******************
    ...  Author: Dan Moldovan
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.07.2024 -
    ...  ******************
    ...  Basic information
    ...  ******************
    ...  This Test Case check if R&D FID 6506 is available in RawAlarmHistory, after exceeding the quota under subfolder
    ...  /ffs/run/logs/oam/asm/auditlog
    ...  *******************
    ...  Test case flowchart:
    ...  *******************

    Set Tags    CA-LOGS    OWNER-stepan.radysh@okia.com    AUTHOR-stepan.radysh@okia.com
    ...    MAINTAINER-dan.moldovan@okia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...    PHASE-CRT    SW-SBTS23R2    FEATURE-CB008390-C

     Step 0: Precondition
     Step 1: Exceed quota for 6506
     Step 2: Check Syslog File
     Step 3: Collect Snapshot
     Step 4: Check Snapshot Content
     Step 5: Clear alarm due to lower quota

Step 0: Precondition
    [Documentation]
    ...  In this test step test check if NMS connection is active, if no integrate BTS to NetAct
    ...  Create Snapshot name

    Log  \nStep 0: Preconditions  console=${True}
    Run    mkdir ${BTS_Files}/syslog
    Run    mkdir ${BTS_Files}/snapshot

    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Log    Syslog start    console=${True}
    ute_syslog.Start Syslog    log_dir=${BTS_Files}/syslog    log_name=syslog    ip=${SMOD1["UDP_IP"]}  ports=@{UDP ports}

Step 1: Exceed quota for 6506
    [Documentation]
    ...  In this test step test check if AASYSINFO_FS_OVERLOAD_IND_MSG exist in syslog

    Log  \nStep 1: Exceed quota for 6506   console=${True}
    Exceed qouta in folder under /ffs/run/logs/oam/asm/auditlog
#    Trigger FID:6504

Step 2: Check Syslog File
    [Documentation]
    ...  In this test step test check if AASYSINFO_FS_OVERLOAD_IND_MSG begin exist in syslog

    Log  \nStep 2: Check Syslog File   console=${True}

    ### 6506
    Log    Wait for AASYSINFO_FS_OVERLOAD_IND_MSG appear in syslog  console=${True}

    Wait Until Keyword Succeeds  20m  30s  Check AASYSINFO_FS_OVERLOAD_IND_MSG

Step 3: Collect Snapshot
    [Documentation]
    ...    This step check if Snapshot collected successfully

    Log    \Step 3: Collect Snapshot   console=${True}
    @{time}=    Get Time    year month day hour min
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/Snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded  ${time}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}

Step 4: Check Snapshot Content
    [Documentation]
    ...    In this step check if file RawAlarmHistory.txt is available in Snapshot
    ...    File RawAlarmHistory.txt should include FID:6506
    Log    \Step 4: Check Snapshot Content   console=${True}
    Set Test Variable    ${SNAPSHOT_LOCATION}    ${BTS_Files}
    Set Test Variable    ${raw_file_name}   BTS${BTS_ID}_*011_RawAlarmHistory.txt.xz

    ${zip_part}    ${raw_file_name_list}  PartCheck

    ${zip_part_number}  Fetch From Left  ${zip_part}  /
    ${raw_archive_xz}  Fetch From Right  ${zip_part}  /
    ${filename_row}  Fetch From Left  ${raw_archive_xz}   .xz
    Log    File ${filename_row} is available in ${zip_part_number}  console=${True}

    unpacking.Unpack Archive Content To Directory  ${snapshot_path}   ${SNAPSHOT_LOCATION}/Unpack
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/Unpack/${zip_part_number}  ${SNAPSHOT_LOCATION}/Unpack/Raw_xz
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/Unpack/Raw_xz/${raw_archive_xz}  ${SNAPSHOT_LOCATION}/Unpack/Raw_xz/Raw_txt

    ${file_content}    OperatingSystem.Get File    ${SNAPSHOT_LOCATION}/Unpack/Raw_xz/Raw_txt/${filename_row}
    ${active_faults}    Fetch from left  ${file_content}    Inactive faults
    Should Contain    ${active_faults}    6506
    Log    File contain FID:6506    console=${True}
    Run    rm -rf ${SNAPSHOT_LOCATION}/Unpack

Step 5: Clear alarm due to lower quota
    [Documentation]
    ...  In this test step test check if AASYSINFO_FS_OVERLOAD_IND_MSG end exist in syslog

    Log  \nStep 5: Clear alarm due to lower quota   console=${True}

    Check FID:6504 in WebEm
    Run Keyword If  ${big_file_present}    Run Keywords
    ...    SSHLibrary.Execute Command  ${clear_FID6506}
    ...    AND     Wait Until Keyword Succeeds    20min    30s    Clear 6506
    ...    AND     Check Clear 6504

Check FID:6504 in WebEm
    [Documentation]
    ...    Check if FID 6504 is available in WebEm

#    Log    \Step 2: Check FID:6504 in WebEm    console=${True}
    Log  Wait up to 15 min in order to check if alarm 6504 raised.  console=${True}
    ${expected_fault}=  Create Dictionary  faultId=6504
    ${expected_fault}=  Create List  ${expected_fault}
    ${status}=  Run keyword and return status  Wait Until Keyword Succeeds  15 min  30 sec
    ...  bts_states.Check Active Alarms  print_alarms=${False}  expected_patterns=${expected_fault}
    Run keyword unless  ${status}  Fail  Fault 6504 was not received.
    Log  Fault 6504 is reported  console=${True}


Clear 6506

    ${overloadStatusend}    Run    awk '/AASYSINFO_FS_OVERLOAD_IND_MSG END/' ${BTS_Files}/syslog/syslog
    ${isEmpty}  Get length  ${overloadStatusend}
    Run Keyword If  ${isEmpty}==0    Run Keywords
    ...   Log    Snapshot path: ${BTS_Files}/snapshot/snapshot.zip
    ...   AND    Log   overloadStatusend is present
    ...   ELSE   Run Keywords
    ...   Log    overloadStatus doesn't exist
    ...   AND    Fail    overloadStatusend doesn't exist

Check Clear 6504
    ${fault_status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   60   10
    ...   coam.Assert Alarm Active   parameters=alarmId=7115, faultId=6450   timeout=120
    Run Keyword If    ${fault_status}    Run Keywords
    ...   Log    Wait alram to be cleared
    ...   AND    Wait Until Keyword Succeeds    15min    30    coam.Assert alarm inactive    faultId=6504, severity=Minor
    ...   ELSE
    ...   Log    Alarm 6504 is cleared

Check AASYSINFO_FS_OVERLOAD_IND_MSG
    ${overloadStatusbegin}    Run    awk '/AASYSINFO_FS_OVERLOAD_IND_MSG BEGIN/' ${BTS_Files}/syslog/syslog

    ${isEmpty}  Get length  ${overloadStatusbegin}
    Run Keyword If  ${isEmpty}!=0    Run Keywords
    ...   Log    Snapshot path: ${BTS_Files}/snapshot/snapshot.zip
    ...   AND    Log   overloadStatusbegin is present
    ...   ELSE   Run Keywords
    ...   Log    overloadStatus doesn't exist
    ...   AND    Fail    overloadStatusbegin doesn't exist

Collecting Snapshot Succeeded
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded    console=yes
    Set Test Variable    ${snapshot_path}    ${BTS Files}/Snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip


Exceed qouta in folder under /ffs/run/logs/oam/asm/auditlog
    [Documentation]
    ...  In this test step connect via SSH to MSM
    ...  and create file for exceed the quota on folder ffs/run/logs/oam/asm/auditlog.

#    Log  \nStep 2: Exceed qouta in folder under /ffs/run/logs/oam/asm/auditlog  console=${True}
#    Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200
    SSHLibrary.Open Connection    ${ip_MSM}
    SSHLibrary.Login    ${user_name_MSM}    ${password_MSM}
    SSHLibrary.Execute Command    ${trigger_FID6506_MSM}
    Set Test Variable    ${big_file_present}    ${True}
    ${exceeded_quota}    SSHLibrary.Execute Command    ${check_trigger_FID6506}
    ${isEmpty}  Get length  ${exceeded_quota}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  File was not created.  ${TRUE}
    ...  ELSE  Log    file exist ${exceeded_quota}    console=${True}
#    sleep    300s
#    Run Keyword If  ${big_file_present}   SSHLibrary.Write    ${clear_FID6506}

Collect Snapshot
    [Documentation]
    ...  This keyword collects snapshot (full coverage), monitors collection status and sets path to snapshot as variable.
    Log   \nCollecting Snapshot   console=${True}
    ${timestamp}   Get time
    ${timestamp}   Replace String Using Regexp   ${timestamp}   (${SPACE}|:|-)  _
    Set Test Variable   ${timestamp}
    ${log_status}   Run Keyword And Ignore Error   coam.Collect snapshot   ${BTS_Files}/snapshot_${timestamp}.zip   timeout=1800
    Run Keyword If   '${log_status[0]}'=='FAIL'
    ...    Fail   Collecting snapshot failed
    ...    ELSE
    ...    Log   Full snapshot is successfully collected   console=${True}
    Set Test Variable   ${path_to_snapshot}   ${BTS_Files}/snapshot_${timestamp}.zip

Check Expected Print In Syslog
    [Documentation]
    ...   This keyword checks if expected print is present in syslog.
    [Arguments]   ${expected_print}
    ${msg}   ute_syslog.Message Should Exist In Syslog File   regexp=${expected_print}    alias=monitoring_syslog
    [Return]   ${msg}
Get SM variant
 	[Documentation]
    ...  Return list of System Module variants in use. First is primary core, second (if exist) - secondary core
    ...
    ...  | **Author:** iuliia.taupeka@nokia.com
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  infomodel.Get SM variant with full name
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (ASIB|ASOE|ASIL|ASIM|ASOF AirScale Core|ASOH AirScale Core|ASOG AirScale Core)
	    Append To List  ${sm_variant}  ${match}
	END
	[Return]  ${sm_variant[0]}

PartCheck
    ${found_file_dict}    snapshot.Get Data From Snapshot    ${snapshot_path}
    ${temp}   Create List
    FOR  ${log_file}  IN  @{found_file_dict.keys()}
        Append to List   ${temp}    ${log_file}
        ${raw_zip_file}  Get Matches  ${temp}  ${raw_file_name}
        Remove From List   ${temp}   0
        ${raw_zip_file_len}   Get Length   ${raw_zip_file}
        Exit For Loop If  ${raw_zip_file_len}>0

    END
    [Return]  ${found_file_dict["${log_file}"][0]}    ${raw_zip_file}

Check If Snapshot Is Collected
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by syslog substring and collection is finished.

    Log  Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]  timeout=900  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by syslog substring.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by syslog substring.  ${TRUE}
    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel
    ...  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal]  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Custom Test Teardown
    Run Keyword If  ${big_file_present}    Run Keywords
    ...    SSHLibrary.Write    ${clear_FID6506}
    ...    AND     SSHLibrary.Write    ${cancel_6504_MSM}
    ...    AND     ute_syslog.Stop Syslog

    SSHLibrary.Close Connection


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
