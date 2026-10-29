*** Settings ***
Documentation
    ...  This test was designed to test feature CB010788 Enabling/Disabling minor/warning alarms.
    ...  CB010788 introduces control over alarm notifications on the BTS level to prevent alarm flooding and provide flexibility in alarm management.
    ...  It allows operator to suppress undesired minor/warning alarms based on alarm ID, fault ID, severity level, hardware Managed Object Class(MOC)
    ...  or on MOC Distinguished Name (DN), while still allowing desired alarms to be reported to network management system and Web Element Manager.

    ...  In first step current SCF will be collected for backup purpuse. Allowed and suppressed parameters will be removed from ALARMSUPP.
    ...  In second step minor alarm 7115 with fault 4592 will be triggered by setting fault4592CancellationTimer to 1800 and resetting SBTS.
    ...  Warning alarm 7115 with fault 4589 will be triggered by power off/on of a radio module.
    ...  In third step actAlarmsSuppression is set to suppressAlarms. AlarmId 7115 with severity MINOR_AND_WARNING added to suppressedAlarmList.
    ...  In fourth step actAlarmsSuppression changed to allowAlarms. AlarmId 7115 with severity MINOR_AND_WARNING added to allowedAlarmList.
    ...  In fifth step actAlarmsSuppression is set to suppressAlarms. FaultId 4589, 4592 with severity MINOR_AND_WARNING added to suppressedFaultList.
    ...  In sixth step actAlarmsSuppression changed to allowAlarms. FaultId 4589, 4592 with severity MINOR_AND_WARNING added to allowedFaultList.
    ...  In seventh step actAlarmsSuppression is set to suppressAlarms. FaultId ANY with severity MINOR_AND_WARNING changed in suppressedFaultList.
    ...  In eighth step actAlarmsSuppression changed to allowAlarms. FaultId ANY with severity MINOR_AND_WARNING changed in allowedFaultList.
    ...  In ninth step actAlarmsSuppression is set to suppressAlar. Alarm Id ANY with severity MINOR_AND_WARNING changed in suppressedAlarmList.
    ...  In tenth step actAlarmsSuppression changed to allowAlarms. Alarm Id ANY with severity MINOR_AND_WARNING changed in allowedAlarmList.
    ...  In eleventh step actAlarmsSuppression is set to suppressAlarms. Both suppressedAlarmList and suppressedFaultList are configured.
    ...  In twelfth step actAlarmsSuppression changed to allowAlarms. Both allowedAlarmList and allowedFaultList are configured.
    ...  In thirteenth step actAlarmsSuppression is set to disabled.
    ...  In eighteenth step full recomisioning with backup SCF will be performed.
    ...  Throughout testcase steps alarms presence/supression will be verified in WebEM and NMS.
    ...  Throughout testcase steps RawSuppressedAlarmHistory.txt and RawAlarmHistory.txt files will be checked.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # Mandatory. Serial number of RMOD that support fault 4589.
${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.
${RECOVERY_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after test scenario.


*** Keywords ***
TC__FM__Update_alarm_fault_ID_online_suppressed_allowed_list
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28937
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28937 - Initial TAT creation
    ...  - 15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29230 - Mismatch of test case name in resource file
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  *******************


    Set Tags  CA-FM  OWNER-corneliu.marcu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R2  FEATURE-CB010788


     Step 0: Test Case Specific Preconditions
     Step 1: Remove Allowed And Suppressed Parameters From ALARMSUPP
     Step 2: Trigger A Persistent Minor Alarm And A Warning Alarm
     Step 3: Set ActAlarmsSuppression To SuppressAlarms And Add Alarm Id 7115 With Severity MINOR_AND_WARNING To SuppressedAlarmList
     Step 4: Set ActAlarmsSuppression To AllowAlarms And Add Alarm Id 7115 With Severity MINOR_AND_WARNING To AllowedAlarmList
     Step 5: Set ActAlarmsSuppression To SuppressAlarms And Add Faults Id 4589 And 4592 With Severity MINOR_AND_WARNING To SuppressedFaultList
     Step 6: Set ActAlarmsSuppression To AllowAlarms And Add Faults Id 4589 And 4592 With Severity MINOR_AND_WARNING To AllowedFaultList
     Step 7: Set ActAlarmsSuppression To SuppressAlarms And Add Fault Id ANY With Severity MINOR_AND_WARNING To SuppressedFaultList
     Step 8: Set ActAlarmsSuppression To AllowAlarms And Add Fault Id ANY With Severity MINOR_AND_WARNING To AllowedFaultList
     Step 9: Set ActAlarmsSuppression To SuppressAlarms And Add Alarm Id ANY With Severity MINOR_AND_WARNING To SuppressedAlarmList
     Step 10: Set ActAlarmsSuppression To AllowAlarms And Add Alarm Id ANY With Severity MINOR_AND_WARNING To AllowedAlarmList
     Step 11: Set ActAlarmsSuppression To SuppressAlarms And Configure Both SuppressedAlarmList And SuppressedFaultList
     Step 12: Set ActAlarmsSuppression To AllowAlarms And Configure Both AllowedAlarmList And AllowedFaultList
     Step 13: Set ActAlarmsSuppression To Disabled
     Step 14: Load And Activate Original SCF


Step 0: Test Case Specific Preconditions
    Log  \nStep 0: Test case specific preconditions.  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R2'  Fail  Software release is ${ENB_BRANCH}. Test is supported on software release equal to or higher than 25R2.
    IF  '${RMOD_SN}' == '${EMPTY}'  Fail  Serial number not provided.
    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${RAW_SUPPRESED_TIME}  ${date_time_raw_suppresed}
    Set Test Variable  ${RAW_HISTORY_TIME}  ${date_time_raw_history}
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


Step 1: Remove Allowed And Suppressed Parameters From ALARMSUPP
    Log  \nStep 1: Remove allowed and suppressed parameters from ALARMSUPP.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP


Step 2: Trigger A Persistent Minor Alarm And A Warning Alarm
    Log  \nStep 2: Trigger a persistent minor alarm and a warning alarm.  console=true
    Log  Alarm presence will be verified.  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=active


Step 3: Set ActAlarmsSuppression To SuppressAlarms And Add Alarm Id 7115 With Severity MINOR_AND_WARNING To SuppressedAlarmList
    Log  \nStep 3: Set actAlarmsSuppression to suppressAlarms and add alarm id 7115 with severity MINOR_AND_WARNING to suppressedAlarmList.
    ...  console=true
    ${suppress_alarm_list}  Create List
    ${suppress_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_alarm_dict_1}  alarmId  7115
    Set To Dictionary  ${suppress_alarm_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_alarm_list}  ${suppress_alarm_dict_1}
    Add Given Alarm And Severity To SuppressedAlarmList  ${suppress_alarm_list}
    Log  Alarm suppression will be verified.  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=inactive


Step 4: Set ActAlarmsSuppression To AllowAlarms And Add Alarm Id 7115 With Severity MINOR_AND_WARNING To AllowedAlarmList
    Log  \nStep 4: Set actAlarmsSuppression to allowAlarms and add alarm id 7115 with severity MINOR_AND_WARNING to allowedAlarmList.  console=true
    ${allowed_alarm_list}  Create List
    ${allowed_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmId  7115
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_alarm_list}  ${allowed_alarm_dict_1}
    Add Given Alarm And Severity To AllowedAlarmList  ${allowed_alarm_list}
    Log  Alarm presence will be verified.  console=true
    Verify Fault 4592 Presence  system_module=${SMOD}  status_fault_4592=active  time_raw_suppresed=${RAW_SUPPRESED_TIME}
    ...  time_raw_history=${RAW_HISTORY_TIME}
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=active


Step 5: Set ActAlarmsSuppression To SuppressAlarms And Add Faults Id 4589 And 4592 With Severity MINOR_AND_WARNING To SuppressedFaultList
    Log  \nStep 5: Set actAlarmsSuppression to suppressAlarms and add faults id 4589 and 4592 with severity MINOR_AND_WARNING to suppressedFaultList.
    ...  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_fault_dict_1}  faultId  4589,4592
    Set To Dictionary  ${suppress_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict_1}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}
    Log  Fault suppression will be verified.  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=inactive


Step 6: Set ActAlarmsSuppression To AllowAlarms And Add Faults Id 4589 And 4592 With Severity MINOR_AND_WARNING To AllowedFaultList
    Log  \nStep 6: Set actAlarmsSuppression to allowAlarms and add faults id 4589 and 4592 with severity MINOR_AND_WARNING to allowedFaultList.
    ...  console=true
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  4589,4592
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Log  Fault presence will be verified.  console=true
    Verify Fault 4592 Presence  system_module=${SMOD}  status_fault_4592=active  time_raw_suppresed=${RAW_SUPPRESED_TIME}
    ...  time_raw_history=${RAW_HISTORY_TIME}
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=active


Step 7: Set ActAlarmsSuppression To SuppressAlarms And Add Fault Id ANY With Severity MINOR_AND_WARNING To SuppressedFaultList
    Log  \nStep 7: Set actAlarmsSuppression to suppressAlarms and add fault id ANY with severity MINOR_AND_WARNING to suppressedFaultList.
    ...  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_fault_dict_1}  faultId  ANY
    Set To Dictionary  ${suppress_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict_1}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}
    Log  Fault suppression will be verified.  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=inactive


Step 8: Set ActAlarmsSuppression To AllowAlarms And Add Fault Id ANY With Severity MINOR_AND_WARNING To AllowedFaultList
    Log  \nStep 8: Set actAlarmsSuppression to allowAlarms and add fault id ANY with severity MINOR_AND_WARNING to allowedFaultList.  console=true
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  ANY
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Log  Fault presence will be verified.  console=true
    Verify Fault 4592 Presence  system_module=${SMOD}  status_fault_4592=active  time_raw_suppresed=${RAW_SUPPRESED_TIME}
    ...  time_raw_history=${RAW_HISTORY_TIME}
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=active


Step 9: Set ActAlarmsSuppression To SuppressAlarms And Add Alarm Id ANY With Severity MINOR_AND_WARNING To SuppressedAlarmList
    Log  \nStep 9: Set actAlarmsSuppression to suppressAlarms and add alarm id ANY with severity MINOR_AND_WARNING to suppressedAlarmList.
    ...  console=true
    ${suppress_alarm_list}  Create List
    ${suppress_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_alarm_dict_1}  alarmId  ANY
    Set To Dictionary  ${suppress_alarm_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_alarm_list}  ${suppress_alarm_dict_1}
    Add Given Alarm And Severity To SuppressedAlarmList  ${suppress_alarm_list}
    Log  Alarm suppression will be verified.  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=inactive


Step 10: Set ActAlarmsSuppression To AllowAlarms And Add Alarm Id ANY With Severity MINOR_AND_WARNING To AllowedAlarmList
    Log  \nStep 10: Set actAlarmsSuppression to allowAlarms and add alarm id ANY with severity MINOR_AND_WARNING to allowedAlarmList.  console=true
    ${allowed_alarm_list}  Create List
    ${allowed_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmId  ANY
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_alarm_list}  ${allowed_alarm_dict_1}
    Add Given Alarm And Severity To AllowedAlarmList  ${allowed_alarm_list}
    Log  Alarm presence will be verified.  console=true
    Verify Fault 4592 Presence  system_module=${SMOD}  status_fault_4592=active  time_raw_suppresed=${RAW_SUPPRESED_TIME}
    ...  time_raw_history=${RAW_HISTORY_TIME}
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD}  status_fault_10=active  status_fault_4589=active


Step 11: Set ActAlarmsSuppression To SuppressAlarms And Configure Both SuppressedAlarmList And SuppressedFaultList
    Log  \nStep 11: Set actAlarmsSuppression to suppressAlarms and configure both suppressedAlarmList and suppressedFaultList.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_alarm_list}  Create List
    ${suppress_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_alarm_dict_1}  alarmId  7103,7115
    Set To Dictionary  ${suppress_alarm_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_alarm_list}  ${suppress_alarm_dict_1}
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_fault_dict_1}  faultId  1400,4592
    Set To Dictionary  ${suppress_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict_1}
    Add Given Alarm And Severity To SuppressedAlarmList  ${suppress_alarm_list}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Run Keyword And Ignore Error  Delete EAC_IN Object  managment_object_dn=${SMOD}[id][configuration]
    Modify EAC_IN Object And Verify Fault 1400  operation=create  system_module=${SMOD}  status_fault_1400=inactive  severity_fault=Minor


Step 12: Set ActAlarmsSuppression To AllowAlarms And Configure Both AllowedAlarmList And AllowedFaultList
    Log  \nStep 12: Set actAlarmsSuppression to allowAlarms and configure both allowedAlarmList and allowedFaultList.  console=true
    ${allowed_alarm_list}  Create List
    ${allowed_alarm_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmId  7103,7115
    Set To Dictionary  ${allowed_alarm_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_alarm_list}  ${allowed_alarm_dict_1}
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  1400,4592
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    Add Given Alarm And Severity To AllowedAlarmList  ${allowed_alarm_list}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Sleep  30s  Waiting for alarm update.
    ${active_alarms}  Assert Alarm Active
    ${number_of_alarms}  Get Length  ${active_alarms}
    Should Not Be Empty  ${active_alarms}
    Should Not Be Equal  ${number_of_alarms}  0
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    Run Keyword And Ignore Error  Delete EAC_IN Object  managment_object_dn=${SMOD}[id][configuration]
    Modify EAC_IN Object And Verify Fault 1400  operation=create  system_module=${SMOD}  status_fault_1400=active  severity_fault=Minor


Step 13: Set ActAlarmsSuppression To Disabled
    Log  \nStep 13: Set actAlarmsSuppression to disabled.  console=true
    Set ActAlarmsSuppression To Disabled
    Sleep  30s  Waiting for alarm update.
    ${active_alarms}  Assert Alarm Active
    ${number_of_alarms}  Get Length  ${active_alarms}
    Should Not Be Empty  ${active_alarms}
    Should Not Be Equal  ${number_of_alarms}  0
    Verify Fault 4592 Presence  system_module=${SMOD}  status_fault_4592=active  time_raw_suppresed=${RAW_SUPPRESED_TIME}
    ...  time_raw_history=${RAW_HISTORY_TIME}
    Verify Fault 1400 Presence  status_fault_1400=active  severity_fault=Minor  time_raw_suppresed=${RAW_SUPPRESED_TIME}
    ...  time_raw_history=${RAW_HISTORY_TIME}


Step 14: Load And Activate Original SCF
    Log  \nStep 14: Load and activate original SCF.  console=true
    Performing Commisioning With Backup SCF


TC Setup
    Set Log Level  INFO
    Common Test Setup  tc_name=FM__Update_alarm_fault_ID_online_suppressed_allowed_list
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Run Keywords
    ...  Check If All RMODs Are Powered On
    ...  AND
    ...  Performing Commisioning With Backup SCF
    Teardown Netact
    Common Test Teardown
    Set Log Level  TRACE
