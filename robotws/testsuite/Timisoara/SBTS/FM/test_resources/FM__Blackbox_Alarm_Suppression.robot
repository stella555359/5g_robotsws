*** Settings ***
Documentation
    ...  This test was designed to test feature CB010788 Enabling/Disabling minor/warning alarms.
    ...  CB010788 introduces control over alarm notifications on the BTS level to prevent alarm flooding and provide flexibility in alarm management.
    ...  It allows operator to suppress undesired minor/warning alarms based on alarm ID, fault ID, severity level, hardware Managed Object Class(MOC)
    ...  or on MOC Distinguished Name (DN), while still allowing desired alarms to be reported to network management system and Web Element Manager.

    ...  In first step current SCF will be collected for backup purpuse. Allowed and suppressed parameters will be removed from ALARMSUPP.
    ...  In second step faults 4592 and 1400 with severity minor will be triggered. Alarm presence will be verified in WebEM and NMS.
    ...  In third step faults 4592 and 1400 will be added to suppressedFaultList with severity minor and warning.
    ...  Alarm suppression will be verified in WebEM and NMS. Site reset will be performed and blackbox reset file will be verified for update.
    ...  rawSuppressedAlarmHistory from blackbox will be verified for fault 4592 and 1400.
    ...  In fourth step full mocDN of primary SMOD will be added to suppressAlarmsByMOCList with severity critical.
    ...  Fault 1400 critical will be triggered. Alarm suppression will be verified in WebEM and NMS.
    ...  In fifth step fault 2080 will be triggered and BTS autonomous reset will be tested. Blackbox reset file will be verified after for update.
    ...  In sixth step full snapshot will be collected and presence of blackbox_reset and blackbox_rawSuppresedAlarmHistory files will be verified.
    ...  In seventh step full recomisioning with backup SCF will be performed.
    ...  Throughout testcase steps alarms presence/supression will be verified in WebEM and NMS.
    ...  Throughout testcase steps RawSuppressedAlarmHistory.txt and RawAlarmHistory.txt files will be checked.
    ...  Throughout testcase blackbox_reset and blackbox_rawSuppresedAlarmHistory files will be checked.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  420  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.


*** Keywords ***
TC__FM__Blackbox_Alarm_Suppression
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29503
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29503 - Initial TAT creation
    ...  *******************


    Set Tags  CA-FM  OWNER-corneliu.marcu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R2  FEATURE-CB010788


     Step 1: Test Case Specific Preconditions
     Step 2: Trigger Fault 4592 And Fault 1400 With Minor Severity
     Step 3: Add Fault 4592 And Fault 1400 To SuppressedFaultList With Severity Minor And Warning
     Step 4: Add SMOD MOC DN To SuppressAlarmsByMOCList And Verify Supression For Fault 1400 Critical On System Module
     Step 5: Trigger Autonomous Site Reset And Verify Blackbox Reset File
     Step 6: Collect Snapshot And Verify Content


Step 1: Test Case Specific Preconditions
    Log  \nStep 1: Test case specific preconditions.  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R2'  Fail  Software release is ${ENB_BRANCH}. Test is supported on software release equal to or higher than 25R2.
    ${current_date_time_raw}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${CURRENT_DATE_TIME_RAW}
    ${smods_list}  coam.Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
        ${status_active_role}  Run Keyword And Return Status  Should Not Be Empty  ${smod}[activeRole]
        IF  ${status_active_role}==${FALSE}
            Set Test Variable  ${SMOD}  ${smod}
            BREAK
        END
        IF  '${smod}[activeRole]' == 'Primary'
            Set Test Variable  ${SMOD}  ${smod}
            BREAK
        END
    END
    Log  Collect current SCF for backup purpose.  console=true
    Get Current Scf File  local_dir_path=${BTS_FILES}  file_name=backup_scf.xml  timeout=60  export_type=configurationAndRuntimeObjects
    ...  parameters_save_variant=actualValues
    ${initial_blackbox_reset}  Get Blackbox Reset File
    Remove Allowed And Suppressed Parameters From ALARMSUPP


Step 2: Trigger Fault 4592 And Fault 1400 With Minor Severity
    Log  \nStep 2: Trigger fault 4592 and fault 1400 with minor severity.  console=true
    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    ${blackbox_time_utc}  Get Current Date  time_zone=UTC  result_format=%Y-%m-%d %H:%M:%S
    Set Test Variable  ${RAW_SUPPRESED_1}  ${date_time_raw_suppresed}
    Set Test Variable  ${RAW_HISTORY_1}  ${date_time_raw_history}
    Set Test Variable  ${BLACKBOX_TIME}  ${blackbox_time_utc}
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    Modify EAC_IN Object And Verify Fault 1400  operation=create  system_module=${SMOD}  status_fault_1400=active  severity_fault=Minor


Step 3: Add Fault 4592 And Fault 1400 To SuppressedFaultList With Severity Minor And Warning
    Log  \nStep 3: Add fault 4592 and fault 1400 to suppressedFaultList with severity minor and warning.  console=true
    Log  Set ActAlarmsSuppression to suppressAlarms and configure faults to suppressedFaultList.  console=true
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_fault_dict_1}  faultId  4592,1400
    Set To Dictionary  ${suppress_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict_1}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}
    Sleep  ${ALARM_TIMEOUT}s  Wait for fault to be supressed.
    Log  Check fault absence.  console=true
    Verify Fault 4592 Presence  system_module=${SMOD}  status_fault_4592=inactive
    ...  time_raw_suppresed=${RAW_SUPPRESED_1}  time_raw_history=${RAW_HISTORY_1}
    Verify Fault 1400 Presence  inactive  Minor  ${RAW_SUPPRESED_1}  ${RAW_HISTORY_1}
    coam.Reset Site
    Log  Site reset has been performed.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  1min  Check Modules And Cells
    ${site_reset_regexp}  Set Variable  .*'Oam' System module site reset rapid : User.*(Execute reset.)
    Verify Blackbox Reset File Content  time_filtering=${BLACKBOX_TIME}  regexp_syntax=${site_reset_regexp}
    Verify Alarm In Blackbox RawSuppressedAlarmHistory File  fault_number=4592  current_date_time=${RAW_SUPPRESED_1}
    Verify Alarm In Blackbox RawSuppressedAlarmHistory File  fault_number=1400  current_date_time=${RAW_SUPPRESED_1}
    Log  Blackbox rawSuppressedAlarmHistory file updated after site reset.  console=true


Step 4: Add SMOD MOC DN To SuppressAlarmsByMOCList And Verify Supression For Fault 1400 Critical On System Module
    Log  \nStep 4: Add SMOD MOC DN to suppressAlarmsByMOCList and verify supression for fault 1400 critical on system module.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_moc_list}  Create List
    ${suppress_moc_smod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_smod_dict}  moc  MRBTS/EQM/APEQM/CABINET/SMOD
    Set To Dictionary  ${suppress_moc_smod_dict}  alarmSeverity  CRITICAL
    Append To List  ${suppress_moc_list}  ${suppress_moc_smod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Modify EAC_IN Under Object With Given Severity  operation=update  managment_object_dn=${SMOD}[id][configuration]
    ...  severity=Critical
    Verify Fault 1400 Presence  status_fault_1400=inactive  severity_fault=Critical  time_raw_suppresed=${RAW_SUPPRESED_1}
    ...  time_raw_history=${RAW_HISTORY_1}
    Delete EAC_IN Object  managment_object_dn=${SMOD}[id][configuration]


Step 5: Trigger Autonomous Site Reset And Verify Blackbox Reset File
    Log  \nStep 5: Trigger autonomous site reset and verify blackbox reset file.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    Log  Prepare fault 2080.  console=true
    IF  "${SMOD}[positionInSubrack]"=="LeftSide"
        ${sender}  ${receiver}  ${domain}  Set Variable  269550144  269554178  16
    ELSE
        ${sender}  ${receiver}  ${domain}  Set Variable  537985600  537989634  32
    END
    Send Hwapi Api2 Alarm Msg  ${sender}  ${receiver}  1  2080  ${domain}  timeout=120
    Log  Fault sent.  console=true
    ${date_autonomous_reset}  Get Current Date  time_zone=UTC  result_format=datetime
    ${fault_site_auto_reset_parameters}  Get String With Alarm Parameters  ${FAULT_2080_SITE_AUTO_RST}
    ${fault_site_reset}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_site_auto_reset_parameters}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${fault_site_reset}  Fault ${FAULT_2080_SITE_AUTO_RST} was not active in WebEM.
    Log  Fault ${FAULT_2080_SITE_AUTO_RST} is active in WebEM.  console=true
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=300
    IF  ${ping_loss_status}
        Log  Ping is lost.  console=true
    ELSE
        Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=300
    IF  ${ping_regain_status}
        Log  Target is reachable.  console=true
    ELSE
        Set Test Restriction  Ping has not been regained within timeout.
    END
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  1min  Check Modules And Cells
    ${recovery_reset_regexp}  Set Variable  .*'Oam' System module site reset : Recovery.*(Execute reset.)
    Verify Blackbox Reset File Content  time_filtering=${BLACKBOX_TIME}  regexp_syntax=${recovery_reset_regexp}
    Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2080_SITE_AUTO_RST}  time_from=${date_autonomous_reset}
    ...  additional_fault_id=${FAULT_2080_SITE_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_2080_SITE_AUTO_RST} was reported and cleared in Netact.  console=true


Step 6: Collect Snapshot And Verify Content
    Log  \nStep 6: Collect snapshot and verify content.  console=true
    Collect Snapshot And Verify Content


Collect Snapshot And Verify Content
    [Documentation]  This keyword collects snapshot from SBTS and verifies content.
    ...  Keyword searches for blackbox_reset file and rawSuppressedAlarmHistory in blackbox in snapshot.
    ...  *AUTHOR* laura.craciunel@nokia.com

    IF  "${SMOD}[positionInSubrack]"=="LeftSide"
        ${side}  Set Variable  1011
    ELSE
        ${side}  Set Variable  2011
    END

    Wait Until Keyword Succeeds  10min  2min  Collect Snapshot  ${BTS_FILES}/snapshot.zip
    Create Directory  ${BTS_FILES}/snapshot
    ${return_code}  OperatingSystem.Run And Return Rc  unzip ${BTS_FILES}/snapshot.zip -d ${BTS_FILES}/snapshot
    IF  ${return_code} != 0  Fail  Not able to unzip snapshot file.
    ${snapshot_files}  Get Data From Snapshot  ${BTS_FILES}/snapshot.zip
    ${all_blackbox_reset_files}  Create List
    ${all_blackbox_raw_suppressed_files}  Create List
    FOR  ${item}  IN  @{snapshot_files}
        ${status_blackbox_reset}  Run Keyword And Return Status  Should Contain  ${item}  ${side}_blackbox_reset
        IF  ${status_blackbox_reset}  Append To List  ${all_blackbox_reset_files}  ${snapshot_files}[${item}][0]
        ${status_blackbox_raw_suppressed_files}  Run Keyword And Return Status  Should Contain  ${item}  ${side}_blackbox_RawSuppressedAlarmHistory
        IF  ${status_blackbox_raw_suppressed_files}  Append To List  ${all_blackbox_raw_suppressed_files}  ${snapshot_files}[${item}][0]
    END
    Should Not Be Empty  ${all_blackbox_reset_files}  msg=No blackbox reset files found in snapshot.
    Should Not Be Empty  ${all_blackbox_raw_suppressed_files}  msg=No blackbox RawSuppressedAlarmHistory files found in snapshot.

    ${full_blackbox_reset_path}  Get From List  ${all_blackbox_reset_files}  -1
    ${part_directory_zip}  Fetch From Left  ${full_blackbox_reset_path}  /
    ${part_directory}  Fetch From Left  ${part_directory_zip}  .zip
    ${bts_xz_file}  Fetch From Right  ${full_blackbox_reset_path}  /
    ${blackbox_reset_file}  Fetch From Left  ${bts_xz_file}  .xz
    Create Directory  ${BTS_FILES}/snapshot_${part_directory}
    OperatingSystem.Run  unzip ${BTS_FILES}/snapshot/${part_directory_zip} -d ${BTS_FILES}/snapshot_${part_directory}
    OperatingSystem.Run  unxz ${BTS_FILES}/snapshot_${part_directory}/${blackbox_reset_file}.xz
    OperatingSystem.Move File  ${BTS_FILES}/snapshot_${part_directory}/${blackbox_reset_file}  ${BTS_FILES}
    OperatingSystem.Remove Directory  path=${BTS_FILES}/snapshot_${part_directory}  recursive=True

    ${full_blackbox_suppressed_path}  Get From List  ${all_blackbox_raw_suppressed_files}  -1
    ${part_directory_zip}  Fetch From Left  ${full_blackbox_suppressed_path}  /
    ${part_directory}  Fetch From Left  ${part_directory_zip}  .zip
    ${bts_xz_file}  Fetch From Right  ${full_blackbox_suppressed_path}  /
    ${blackbox_suppressed_file}  Fetch From Left  ${bts_xz_file}  .xz
    Create Directory  ${BTS_FILES}/snapshot_${part_directory}
    OperatingSystem.Run  unzip ${BTS_FILES}/snapshot/${part_directory_zip} -d ${BTS_FILES}/snapshot_${part_directory}
    OperatingSystem.Run  unxz ${BTS_FILES}/snapshot_${part_directory}/${blackbox_suppressed_file}.xz
    OperatingSystem.Move File  ${BTS_FILES}/snapshot_${part_directory}/${blackbox_suppressed_file}  ${BTS_FILES}
    OperatingSystem.Remove Directory  path=${BTS_FILES}/snapshot_${part_directory}  recursive=True

    OperatingSystem.File Should Not Be Empty  ${BTS_FILES}/${blackbox_reset_file}  Blackbox reset file from snapshot is empty.
    OperatingSystem.File Should Not Be Empty  ${BTS_FILES}/${blackbox_suppressed_file}  Blackbox RawSuppresedAlarmHistory file from snapshot is empty.

    [TEARDOWN]  Run Keywords
    ...  OperatingSystem.Remove Directory  path=${BTS_FILES}/snapshot  recursive=True
    ...  AND
    ...  OperatingSystem.Remove File  ${BTS_FILES}/snapshot.zip


TC Setup
    Common Test Setup  tc_name=FM__Blackbox_Alarm_Suppression
    Setup NetAct


TC Teardown
    Performing Commisioning With Backup SCF
    Teardown Netact
    Common Test Teardown