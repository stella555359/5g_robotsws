*** Settings ***
Documentation
    ...  This test was designed to test feature CB010788 Enabling/Disabling minor/warning alarms.
    ...  CB010788 introduces control over alarm notifications on the BTS level to prevent alarm flooding and provide flexibility in alarm management.
    ...  It allows operator to suppress undesired minor/warning alarms based on alarm ID, fault ID, severity level, hardware Managed Object Class(MOC)
    ...  or on MOC Distinguished Name (DN), while still allowing desired alarms to be reported to network management system and Web Element Manager.

    ...  In first step current SCF will be collected for backup purpuse. Serial number of one radio module is mandatory argument for test.
    ...  In second step allowed and suppressed parameters will be removed from ALARMSUPP.
    ...  fault4592CancellationTimer is set to 1800. Site reset will be performed. After fault 4592 is expected, alarm presence is verified.
    ...  EAC_IN object is created with polarity Normally_closed and severity minor. Presence of minor fault 1400 is verified.
    ...  In third step fault 1400 is added to allowedFaultList with severity minor and warning. Presence of minor fault 1400 is verified.
    ...  In fourth step alarm 7220 is added to allowedAlarmList with severity minor and warning. Alarm 7220 presence will be verified.
    ...  Primary system module will be powered off/on and supression will be verified for minor fault 4592.
    ...  One radio module will be powered off/on and supression for warning fault 4589 verified.
    ...  In fifth step minor faults 4592 and 1400 are added to allowedFaultList. Warning alarm 7115 is added to allowedAlarmList.
    ...  Presence of minor fault 1400 is verified. Primary system module will be powered off/on and presence will be verified for minor fault 4592.
    ...  One radio module will be powered off/on and presence for warning fault 4589 verified (with alarm 7115).
    ...  In sixth step minor faults 4592 and 1400 are added to allowedFaultList. Minor alarm 7220 is added to allowedAlarmList.
    ...  Presence of minor fault 1400 is verified. Primary system module will be powered off/on and presence will be verified for minor fault 4592.
    ...  One radio module will be powered off/on and supression for warning fault 4589 verified. Presence of alarm id 7220 will be verified.
    ...  In seventh step minor faults 4592 and 1400 are added to allowedFaultList. AlarmId changed to ANY in allowedAlarmList severity minor warning.
    ...  Presence of minor fault 1400 is verified. Primary system module will be powered off/on and presence will be verified for minor fault 4592.
    ...  One radio module will be powered off/on and presence for warning fault 4589 verified (with alarm 7115).
    ...  In eighth step full recomisioning with backup SCF will be performed.
    ...  Throughout testcase steps alarms presence/supression will be verified in WebEM and NMS.
    ...  Throughout testcase steps RawSuppressedAlarmHistory.txt and RawAlarmHistory.txt files will be checked.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # Mandatory. Serial number of RMOD that support fault 4589.
${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.


*** Keywords ***
TC_FM__Suppress_alarms_based_on_both_fault_and_alarm_Id
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28939
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28939 - Initial TAT creation
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  *******************


    Set Tags  CA-FM  OWNER-corneliu.marcu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R2  FEATURE-CB010788


    Step 1: Test Case Specific Preconditions
    Step 2: Trigger Minor Faults 4592 And 1400
    Step 3: Add Fault 1400 To AllowedFaultList With Severity Minor And Warning
    Step 4: Add Alarm 7220 To AllowedAlarmList With Severity Minor And Warning
    Step 5: Add Minor Fault 4592 And 1400 To AllowedFaultList And Add Warning Alarm 7115 To AllowedAlarmList
    Step 6: Add Minor Fault 4592 And 1400 To AllowedFaultList And Add Minor Alarm 7220 To AllowedAlarmList
    Step 7: Add Minor Fault 4592 And 1400 To AllowedFaultList And Change AllowedAlarmList To ANY AlarmId With Severity Minor And Warning
    Step 8: Performed Commissioning With Backup SCF


Step 1: Test Case Specific Preconditions
    Log  \nStep 1: Test case specific preconditions.  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R2'  Fail  Software release is ${ENB_BRANCH}. Test is supported on software release equal to or higher than 25R2.
    Should Not Be Empty  ${RMOD_SN}  Serial number for radio module not provided. [NOK]
    ${rmods_list}  coam.Get Frm
    FOR  ${rmod}  IN  @{rmods_list}
      IF  '${rmod}[serialNumber]' == '${RMOD_SN}'
        Set Test Variable  ${RMOD}  ${rmod}
        BREAK
      END
    END
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


Step 2: Trigger Minor Faults 4592 And 1400
    Log  \nStep 2: Trigger minor faults 4592 and 1400.  console=true
    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${RAW_SUPPRESED_TIME}  ${date_time_raw_suppresed}
    Set Test Variable  ${RAW_TIME}  ${date_time_raw_history}
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration]/EAC_IN-1.  console=true
    Modify EAC_IN Object And Verify Fault 1400  operation=create  system_module=${SMOD}  status_fault_1400=active  severity_fault=Minor


Step 3: Add Fault 1400 To AllowedFaultList With Severity Minor And Warning
    Log  \nStep 3: Add fault 1400 to allowedFaultList with severity minor and warning.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  1400
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration]/EAC_IN-1.  console=true
    Verify Fault 1400 Presence  active  Minor  ${RAW_SUPPRESED_TIME}  ${RAW_TIME}
    ${allowed_faults}  Create List
    Append To List  ${allowed_faults}  ${FAULT_1400_MINOR}[fault_id]
    Check If Only Allowed Alarms And Faults Are Active  ${allowed_faults}  Minor_Warning  fault


Step 4: Add Alarm 7220 To AllowedAlarmList With Severity Minor And Warning
    Log  \nStep 4: Add alarmId 7220 to allowedAlarmList with severity minor and warning.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${allowed_alarm_list}  Create List
    ${allowed_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmId  7220
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_alarm_list}  ${allowed_alarm_dict_1}
    Add Given Alarm And Severity To AllowedAlarmList  ${allowed_alarm_list}

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4654}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4654} is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4654}
    Log  Fault ${FAULT_4654} is active in Netact. [OK]  console=true
    Verify Alarm In RawAlarmHistory File  4654  ${RAW_TIME}
    ${allowed_alarms}  Create List
    Append To List  ${allowed_alarms}  ${FAULT_4654}[alarm_id]
    Check If Only Allowed Alarms And Faults Are Active  ${allowed_alarms}  Minor_Warning  alarm

    Log  Alarm supression will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration]/EAC_IN-1.  console=true
    Verify Fault 1400 Presence  inactive  Minor  ${RAW_SUPPRESED_TIME}  ${RAW_TIME}
    Log  Alarm suppression will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Power Off/On System Module And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Log  Alarm suppression will be verified for fault with severity=WARNING on mocDN=${RMOD}[id][configuration].  console=true
    Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${RMOD}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=inactive


Step 5: Add Minor Fault 4592 And 1400 To AllowedFaultList And Add Warning Alarm 7115 To AllowedAlarmList
    Log  \nStep 5: Add minor fault 4592 and 1400 to allowedFaultList and add warning alarm 7115 to allowedAlarmList.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  4592,1400
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    ${allowed_alarm_list}  Create List
    ${allowed_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmId  7115
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmSeverity  WARNING
    Append To List  ${allowed_alarm_list}  ${allowed_alarm_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Add Given Alarm And Severity To AllowedAlarmList  ${allowed_alarm_list}
    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration]/EAC_IN-1.  console=true
    Verify Fault 1400 Presence  active  Minor  ${RAW_SUPPRESED_TIME}  ${RAW_TIME}
    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Power Off/On System Module And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    ${allowed_faults}  Create List
    Append To List  ${allowed_faults}  ${FAULT_4592_MINOR}[fault_id]  ${FAULT_1400_MINOR}[fault_id]
    Check If Only Allowed Alarms And Faults Are Active  ${allowed_faults}  Minor_Warning  fault
    Log  Alarm presence will be verified for alarm id 7115 (with fault 4589) with severity=WARNING on mocDN=${RMOD}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=active


Step 6: Add Minor Fault 4592 And 1400 To AllowedFaultList And Add Minor Alarm 7220 To AllowedAlarmList
    Log  \nStep 6: Add minor fault 4592 and 1400 to allowedFaultList and add minor alarm 7220 to allowedAlarmList.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  4592,1400
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    ${allowed_alarm_list}  Create List
    ${allowed_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmId  7220
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmSeverity  MINOR
    Append To List  ${allowed_alarm_list}  ${allowed_alarm_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Add Given Alarm And Severity To AllowedAlarmList  ${allowed_alarm_list}

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4654}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4654} is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4654}
    Log  Fault ${FAULT_4654} is active in Netact. [OK]  console=true
    Verify Alarm In RawAlarmHistory File  4654  ${RAW_TIME}
    ${allowed_alarms}  Create List
    Append To List  ${allowed_alarms}  ${FAULT_4654}[alarm_id]  ${FAULT_1400_Minor}[alarm_id]  ${FAULT_4592_MINOR}[alarm_id]
    Check If Only Allowed Alarms And Faults Are Active  ${allowed_alarms}  Minor_Warning  alarm

    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration]/EAC_IN-1.  console=true
    Verify Fault 1400 Presence  active  Minor  ${RAW_SUPPRESED_TIME}  ${RAW_TIME}
    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    Log  Alarm suppression will be verified for alarm id 7115 (with fault 4589) with severity=WARNING on mocDN=${RMOD}[id][configuration].
    ...  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=inactive


Step 7: Add Minor Fault 4592 And 1400 To AllowedFaultList And Change AllowedAlarmList To ANY AlarmId With Severity Minor And Warning
    Log  \nStep 7: Add minor fault 4592 and 1400 to allowedFaultList and change qllowedAlarmList to ANY alarmId With severity minor and warning.
    ...  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  4592,1400
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    ${allowed_alarm_list}  Create List
    ${allowed_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmId  ANY
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_alarm_list}  ${allowed_alarm_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Add Given Alarm And Severity To AllowedAlarmList  ${allowed_alarm_list}

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4654}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4654} is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4654}
    Log  Fault ${FAULT_4654} is active in Netact. [OK]  console=true
    Verify Alarm In RawAlarmHistory File  4654  ${RAW_TIME}

    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration]/EAC_IN-1.  console=true
    Verify Fault 1400 Presence  active  Minor  ${RAW_SUPPRESED_TIME}  ${RAW_TIME}
    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    Log  Alarm presence will be verified for alarm id 7115 (with fault 4589) with severity=WARNING on mocDN=${RMOD}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=active


Step 8: Performed Commissioning With Backup SCF
    Log  \nStep 8: Performed commissioning with backup SCF.  console=true
    Performing Commisioning With Backup SCF


TC Setup
    Common Test Setup  tc_name=FM__Suppress_alarms_based_on_both_fault_and_alarm_Id
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Run Keywords
    ...  Check If System Module Is Powered On  ${SMOD}
    ...  AND
    ...  Check If All RMODs Are Powered On
    ...  AND
    ...  Performing Commisioning With Backup SCF
    Teardown Netact
    Common Test Teardown