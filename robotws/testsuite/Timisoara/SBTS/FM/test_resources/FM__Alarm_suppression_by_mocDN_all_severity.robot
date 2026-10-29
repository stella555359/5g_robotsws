*** Settings ***
Documentation
    ...  This test was designed to test feature CB010788 Enabling/Disabling minor/warning alarms.
    ...  CB010788 introduces control over alarm notifications on the BTS level to prevent alarm flooding and provide flexibility in alarm management.
    ...  It allows operator to suppress undesired minor/warning alarms based on alarm ID, fault ID, severity level, hardware Managed Object Class(MOC)
    ...  or on MOC Distinguished Name (DN), while still allowing desired alarms to be reported to network management system and Web Element Manager.

    ...  In first step current SCF will be collected for backup purpuse. Allowed and suppressed parameters will be removed from ALARMSUPP.
    ...  In second step two RMODs will be powered off from PDU and fault 10 is raised. After RMOD is power on, fault 4589 is raised.
    ...  In third step full mocDN of first RMOD will be added to suppressAlarmsByMOCList with severity warning. Both RMODs will be powered off/on.
    ...  For first RMOD, fault 10 appers active and fault 4589 is suppressed. For second RMOD, both faults 10 and 4589 are raised.
    ...  In fourth step full mocDN of first RMOD will be added to suppressAlarmsByMOCList with severity critical. Both RMODs will be powered off/on.
    ...  For first RMOD, both faults 10 and 4589 are suppressed. For second RMOD, both faults 10 and 4589 are raised.
    ...  In fifth step full SMOD mocDN will be added to suppressAlarmsByMOCList with severity major. fault4592CancellationTimer is set to 1800.
    ...  Site reset will be performed. After fault 4592 is expected, however fault will be suppressed as severity is minor.
    ...  In sixth step full SMOD mocDN will be added to suppressAlarmsByMOCList with severity warning. fault4592CancellationTimer is set to 1800.
    ...  Site reset will be performed. After fault 4592 is expected and appears active as severity is minor.
    ...  In seventh step full APEQM mocDN will be added to suppressAlarmsByMOCList with severity critical.
    ...  First RMOD is powered off/on with both faults 10 and 4589 expected to be suppressed.
    ...  In eighth step partially APEQM mocDN will be added to suppressAlarmsByMOCList with severity critical.
    ...  Second RMOD is powered off/on with both faults 10 and 4589 expected to be suppressed.
    ...  In ninth step multiple mocDN (partially or full DN) will be added in suppressAlarmsByMOCList with various severities.
    ...  Site reset and SBTS power off/on will be performed. Alarms presence/suppression will be verified.
    ...  In tenth step actAlarmsSuppression will be set to disabled. EAC_IN object is created with polarity Normally_closed and severity critical.
    ...  Fault 1400 is raised with severity critical.
    ...  In eleventh step full EAC mocDN will be added to suppressAlarmsByMOCList with severity critical. Fault 1400 is suppressed.
    ...  In twelfth step actAlarmsSuppression will be set to disabled. EAC_IN object is created with polarity Normally_closed and severity major.
    ...  Fault 1400 is raised with severity major.
    ...  In thirteenth step full EAC mocDN will be added to suppressAlarmsByMOCList with severity major. Fault 1400 is suppressed.
    ...  In fourteenth step actAlarmsSuppression will be set to disabled. EAC_IN object is created with polarity Normally_closed and severity minor.
    ...  Fault 1400 is raised with severity minor.
    ...  In fifteenth step full EAC mocDN will be added to suppressAlarmsByMOCList with severity minor. Fault 1400 is suppressed.
    ...  In sixteenth step test will try to set actAlarmsSuppression to allowAlarms while allowedfaultlist not configured.
    ...  Recommissioning should fail with pdl and feedback errors.
    ...  In seventeenth step actAlarmsSuppression is set to disabled. Site reset and SBTS power off/on are performed. Alarms presence is verified.
    ...  In eighteenth step full recomisioning with backup SCF will be performed.
    ...  Throughout testcase steps alarms presence/supression will be verified in WebEM and NMS.
    ...  Throughout testcase steps RawSuppressedAlarmHistory.txt and RawAlarmHistory.txt files will be checked.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_1_SN}  ${EMPTY}  # Mandatory. Serial number of RMOD that support fault 4589.
${RMOD_2_SN}  ${EMPTY}  # Mandatory. Serial number of RMOD that support fault 4589.
${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.

*** Keywords ***
TC__FM__Alarm_suppression_by_mocDN_all_severity
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28935
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28935 - Initial TAT creation
    ...  - 29.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28937 - Move keywords to resource file
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  *******************


    Set Tags  CA-FM  OWNER-corneliu.marcu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R2  FEATURE-CB010788


     Step 0: Test Case Specific Preconditions
     Step 1: Remove Allowed And Suppressed Parameters From ALARMSUPP
     Step 2: Performing Power Off/On On Two Radio Modules And Verify Fault 4589 Presence
     Step 3: Add Full RMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Trigger Fault 4589
     Step 4: Add Full RMOD MOC DN To SuppressAlarmsByMOCList With Severity Critical And Trigger Fault 4589
     Step 5: Add Full SMOD MOC DN To SuppressAlarmsByMOCList With Severity Major And Trigger Fault 4592
     Step 6: Add Full SMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Trigger Fault 4592
     Step 7: Add Full APEQM MOC DN To SuppressAlarmsByMOCList With Severity Critical And Trigger Fault 4589
     Step 8: Add Partially APEQM MOC DN To SuppressAlarmsByMOCList With Severity Critical And Trigger Fault 4589
     Step 9: Add Multiple MOC DN In SuppressAlarmsByMOCList With Various Severities
     Step 10: Set ActAlarmsSuppression To Disabled And Triger EAC Critical Fault
     Step 11: Add Full EAC MOC DN To SuppressAlarmsByMOCList With Severity Critical And Triger EAC Fault
     Step 12: Set ActAlarmsSuppression To Disabled And Triger EAC Major Fault
     Step 13: Add Full EAC MOC DN To SuppressAlarmsByMOCList With Severity Major And Triger EAC Fault
     Step 14: Set ActAlarmsSuppression To Disabled And Triger EAC Minor Fault
     Step 15: Add Full EAC MOC DN To SuppressAlarmsByMOCList With Severity Minor And Triger EAC Fault
     Step 16: Set ActAlarmsSuppression To AllowAlarms While Allowedfaultlist Not Configured
     Step 17: Set ActAlarmsSuppression To Disabled And Verify Original Faults
     Step 18: Performed Commissioning With Backup SCF


Step 0: Test Case Specific Preconditions
    Log  \nStep 0: Test case specific preconditions.  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R2'  Fail  Software release is ${ENB_BRANCH}. Test is supported on software release equal to or higher than 25R2.
    ${current_date_time_raw}  Get BTS time in UTC format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${CURRENT_DATE_TIME_RAW}
    ${status_1}  Run Keyword And Return Status  Should Not Be Empty  ${RMOD_1_SN}
    ${status_2}  Run Keyword And Return Status  Should Not Be Empty  ${RMOD_2_SN}
    IF  ${status_1} and ${status_2}  Log  Serial number provided. Test will continue.  console=true  ELSE  Fail  Serial number not provided.
    ${rmods_list}  coam.Get Frm
    FOR  ${rmod}  IN  @{rmods_list}
      IF  '${rmod}[serialNumber]' == '${RMOD_1_SN}'
        Set Test Variable  ${RMOD_1}  ${rmod}
        BREAK
      END
    END
    FOR  ${rmod}  IN  @{rmods_list}
      IF  '${rmod}[serialNumber]' == '${RMOD_2_SN}'
        Set Test Variable  ${RMOD_2}  ${rmod}
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


Step 2: Performing Power Off/On On Two Radio Modules And Verify Fault 4589 Presence
    Log  \nStep 2: Performing power off/on on two radio modules and verify fault 4589 presence.  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_1}  status_fault_10=active  status_fault_4589=active
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_2}  status_fault_10=active  status_fault_4589=active


Step 3: Add Full RMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Trigger Fault 4589
    Log  \nStep 3: Add full RMOD MOC DN to suppressAlarmsByMOCList with severity warning and trigger fault 4589.  console=true
    ${suppress_moc_list}  Create List
    ${suppress_moc_rmod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_rmod_dict}  mocDN  ${RMOD_1}[id][configuration]
    Set To Dictionary  ${suppress_moc_rmod_dict}  alarmSeverity  WARNING
    Append To List  ${suppress_moc_list}  ${suppress_moc_rmod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault with severity=WARNING on mocDN=${RMOD_1}[id][configuration].  console=true
    Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${RMOD_1}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_1}  status_fault_10=active  status_fault_4589=inactive
    Log  Alarm presence for fault with severity severity=WARNING will be verified for mocDN=${RMOD_2}[id][configuration].  console=true
    Log  Alarm presence for fault with severity severity=CRITICAL will be verified for mocDN=${RMOD_2}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_2}  status_fault_10=active  status_fault_4589=active


Step 4: Add Full RMOD MOC DN To SuppressAlarmsByMOCList With Severity Critical And Trigger Fault 4589
    Log  \nStep 4: Add full RMOD MOC DN to suppressAlarmsByMOCList with severity critical and trigger fault 4589.  console=true
    ${suppress_moc_list}  Create List
    ${suppress_moc_rmod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_rmod_dict}  mocDN  ${RMOD_1}[id][configuration]
    Set To Dictionary  ${suppress_moc_rmod_dict}  alarmSeverity  CRITICAL
    Append To List  ${suppress_moc_list}  ${suppress_moc_rmod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault with severity=WARNING on mocDN=${RMOD_1}[id][configuration].  console=true
    Log  Alarm suppression will be verified for fault with severity=CRITICAL on mocDN=${RMOD_1}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_1}  status_fault_10=inactive  status_fault_4589=inactive
    Log  Alarm presence for fault with severity severity=WARNING will be verified for mocDN=${RMOD_2}[id][configuration].  console=true
    Log  Alarm presence for fault with severity severity=CRITICAL will be verified for mocDN=${RMOD_2}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_2}  status_fault_10=active  status_fault_4589=active


Step 5: Add Full SMOD MOC DN To SuppressAlarmsByMOCList With Severity Major And Trigger Fault 4592
    Log  \nStep 5: Add full SMOD MOC DN to suppressAlarmsByMOCList with severity major and trigger fault 4592.  console=true
    ${suppress_moc_list}  Create List
    ${suppress_moc_smod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_smod_dict}  mocDN  ${SMOD}[id][configuration]
    Set To Dictionary  ${suppress_moc_smod_dict}  alarmSeverity  MAJOR
    Append To List  ${suppress_moc_list}  ${suppress_moc_smod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault.  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive


Step 6: Add Full SMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Trigger Fault 4592
    Log  \nStep 6: Add full SMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Trigger Fault 4592.  console=true
    ${suppress_moc_list}  Create List
    ${suppress_moc_smod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_smod_dict}  mocDN  ${SMOD}[id][configuration]
    Set To Dictionary  ${suppress_moc_smod_dict}  alarmSeverity  WARNING
    Append To List  ${suppress_moc_list}  ${suppress_moc_smod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm presence will be verified for fault.  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active


Step 7: Add Full APEQM MOC DN To SuppressAlarmsByMOCList With Severity Critical And Trigger Fault 4589
    Log  \nStep 7: Add full APEQM MOC DN to suppressAlarmsByMOCList with severity critical and trigger fault 4589.  console=true
    ${full_dn}  Fetch From Left  ${SMOD}[id][configuration]  /CABINET
    ${suppress_moc_list}  Create List
    ${suppress_moc_apeqm_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_apeqm_dict}  mocDN  ${full_dn}
    Set To Dictionary  ${suppress_moc_apeqm_dict}  alarmSeverity  CRITICAL
    Append To List  ${suppress_moc_list}  ${suppress_moc_apeqm_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault with severity=CRITICAL on mocDN=${full_dn}.  console=true.
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_1}  status_fault_10=inactive  status_fault_4589=inactive


Step 8: Add Partially APEQM MOC DN To SuppressAlarmsByMOCList With Severity Critical And Trigger Fault 4589
    Log  \nStep 8: Add partially APEQM MOC DN to suppressAlarmsByMOCList with severity critical and trigger fault 4589.  console=true
    ${full_dn}  Fetch From Left  ${SMOD}[id][configuration]  /CABINET
    ${partially_dn}  Fetch From Right  ${full_dn}  MRBTS-${BTS_ID}/
    ${suppress_moc_list}  Create List
    ${suppress_moc_apeqm_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_apeqm_dict}  mocDN  ${partially_dn}
    Set To Dictionary  ${suppress_moc_apeqm_dict}  alarmSeverity  CRITICAL
    Append To List  ${suppress_moc_list}  ${suppress_moc_apeqm_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault with severity=CRITICAL on mocDN=${partially_dn}.  console=true.
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_2}  status_fault_10=inactive  status_fault_4589=inactive


Step 9: Add Multiple MOC DN In SuppressAlarmsByMOCList With Various Severities
    Log  \nStep 9: Add multiple MOC DN in suppressAlarmsByMOCList with various severities.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    ${suppress_alarms_by_moc_list}  Create List
    ${suppress_alarm_by_moc_1}  Create Dictionary
    Set To Dictionary  ${suppress_alarm_by_moc_1}  mocDN  ${SMOD}[id][configuration]
    Set To Dictionary  ${suppress_alarm_by_moc_1}  alarmSeverity  MINOR
    ${suppress_alarm_by_moc_2}  Create Dictionary
    ${string}  Fetch From Right  ${SMOD}[id][configuration]  /CABINET
    ${smod_id}  Fetch From Right  ${string}  /
    Set To Dictionary  ${suppress_alarm_by_moc_2}  mocDN  ${smod_id}
    Set To Dictionary  ${suppress_alarm_by_moc_2}  alarmSeverity  WARNING
    ${suppress_alarm_by_moc_3}  Create Dictionary
    ${string}  Fetch From Right  ${RMOD_1}[id][configuration]  /APEQM
    ${rmod_1_id}  Fetch From Right  ${string}  /
    Set To Dictionary  ${suppress_alarm_by_moc_3}  mocDN  ${rmod_1_id}
    Set To Dictionary  ${suppress_alarm_by_moc_3}  alarmSeverity  MAJOR
    ${suppress_alarm_by_moc_4}  Create Dictionary
    Set To Dictionary  ${suppress_alarm_by_moc_4}  mocDN  ${RMOD_2}[id][configuration]
    Set To Dictionary  ${suppress_alarm_by_moc_4}  alarmSeverity  CRITICAL
    Append To List  ${suppress_alarms_by_moc_list}  ${suppress_alarm_by_moc_1}  ${suppress_alarm_by_moc_2}  ${suppress_alarm_by_moc_3}
    ...  ${suppress_alarm_by_moc_4}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_alarms_by_moc_list}
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Power Off/On SBTS And Keep 2 RMODs Powered Off
    Verify Fault 10 Presence  ${RMOD_1}  active  ${date_time_raw_suppresed}  ${date_time_raw_history}  1800
    Verify Fault 10 Presence  ${RMOD_2}  inactive  ${date_time_raw_suppresed}  ${date_time_raw_history}  1800
    Pdu Bts Interface On  RMOD_${RMOD_1}[serialNumber]
    Verify Fault 4589 Presence  ${RMOD_1}  inactive  ${date_time_raw_suppresed}  ${date_time_raw_history}
    Pdu Bts Interface On  RMOD_${RMOD_2}[serialNumber]
    Verify Fault 4589 Presence  ${RMOD_2}  inactive  ${date_time_raw_suppresed}  ${date_time_raw_history}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  1min  Check Modules And Cells


Step ${index}: Set ActAlarmsSuppression To Disabled And Triger EAC ${step_severity} Fault
    Log  \nStep ${index}: Set actAlarmsSuppression to disabled and triger EAC ${step_severity} fault.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    Sleep  30s  Waiting for alarm update.
    ${active_alarms}  Assert Alarm Active
    ${number_of_alarms}  Get Length  ${active_alarms}
    Should Not Be Empty  ${active_alarms}
    Should Not Be Equal  ${number_of_alarms}  0
    Run Keyword And Ignore Error  Delete EAC_IN Object  managment_object_dn=${SMOD}[id][configuration]
    Modify EAC_IN Object And Verify Fault 1400  operation=create  system_module=${SMOD}  status_fault_1400=active  severity_fault=${step_severity}


Step ${index}: Add Full EAC MOC DN To SuppressAlarmsByMOCList With Severity ${step_severity} And Triger EAC Fault
    Log  \nStep ${index}: Add Full EAC MOC DN To SuppressAlarmsByMOCList With Severity ${step_severity} And Triger EAC Fault.  console=true
    ${severity_upper_case}  Convert To Upper Case  ${step_severity}
    ${suppress_moc_list}  Create List
    ${suppress_moc_eac_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_eac_dict}  mocDN  ${SMOD}[id][configuration]/EAC_IN-1
    Set To Dictionary  ${suppress_moc_eac_dict}  alarmSeverity  ${severity_upper_case}
    Append To List  ${suppress_moc_list}  ${suppress_moc_eac_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault.  console=true
    Modify EAC_IN Object And Verify Fault 1400  operation=update  system_module=${SMOD}  status_fault_1400=inactive  severity_fault=${step_severity}


Step 16: Set ActAlarmsSuppression To AllowAlarms While Allowedfaultlist Not Configured
    Log  \nStep 16: Set actAlarmsSuppression to allowAlarms while allowedfaultlist not configured.  console=true
    ${pdl_error}  Catenate  SEPARATOR=${SPACE}
    ...  'pdl':
    ...  "Assertion not met: ALARMSUPP(actAlarmsSuppression = 'allowAlarms') have allowedFaultList defined or allowedAlarmList defined"
    ${feedback_error}  Catenate  SEPARATOR=${SPACE}
    ...  'feedback':
    ...  'If \${ALARMSUPP-1.actAlarmsSuppression} (value: allowAlarms) is set to allowAlarms then at least one instance of
    ...   \${ALARMSUPP-1.allowedFaultList} (list of 0 items) or \${ALARMSUPP-1.allowedAlarmList} (list of 0 items) shall be configured.'
    Log  Attempting to set parameter.  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  allowAlarms  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_not_configured.json  delta_id=${delta_id}
    ${recommissioning_errors}  Run Keyword And Expect Error  *  Perform Delta Recommissioning  ${BTS_FILES}/delta_not_configured.json
    ...  skip_parameter_relation_errors=False  should_activate=True  timeout=120
    Should Contain  ${recommissioning_errors}  'status': 'FAIL'
    Should Contain  ${recommissioning_errors}  ${pdl_error}
    Should Contain  ${recommissioning_errors}  ${feedback_error}
    Log  Recommissioning failed with 'status': 'FAIL' because following errors:\n${pdl_error}\n${feedback_error}.  console=true


Step 17: Set ActAlarmsSuppression To Disabled And Verify Original Faults
    Log  \nStep 17: Set actAlarmsSuppression to disabled and verify original faults.  console=true
    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set ActAlarmsSuppression To Disabled
    Verify Fault 1400 Presence  active  Minor  ${date_time_raw_suppresed}  ${date_time_raw_history}
    Power Off/On SBTS And Keep 2 RMODs Powered Off
    Verify Fault 10 Presence  ${RMOD_1}  active  ${date_time_raw_suppresed}  ${date_time_raw_history}  1800
    Verify Fault 10 Presence  ${RMOD_2}  active  ${date_time_raw_suppresed}  ${date_time_raw_history}  1800
    Pdu Bts Interface On  RMOD_${RMOD_1}[serialNumber]
    Verify Fault 4589 Presence  ${RMOD_1}  active  ${date_time_raw_suppresed}  ${date_time_raw_history}
    Pdu Bts Interface On  RMOD_${RMOD_2}[serialNumber]
    Verify Fault 4589 Presence  ${RMOD_2}  active  ${date_time_raw_suppresed}  ${date_time_raw_history}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  1min  Check Modules And Cells


Step 18: Performed Commissioning With Backup SCF
    Log  \nStep 18: Performed commissioning with backup SCF.  console=true
    Performing Commisioning With Backup SCF


Power Off/On SBTS And Keep 2 RMODs Powered Off
    ${rmods_to_power_off_on}  Create List
    ${rmods_list}  coam.Get Frm
    FOR  ${rmod}  IN  @{rmods_list}
       Append To List  ${rmods_to_power_off_on}  ${rmod}[serialNumber]
    END
    ${smods_to_power_off_on}  Create List
    ${smods_list}  coam.Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
      Append To List  ${smods_to_power_off_on}  ${smod}[serialNumber]
    END
    FOR  ${serial_number}  IN  @{rmods_to_power_off_on}
      Log  Power off radio module with serial number: ${serial_number}.  console=true
      Pdu Bts Interface Off  RMOD_${serial_number}
    END
    FOR  ${serial_number}  IN  @{smods_to_power_off_on}
      Log  Power off system module with serial number: ${serial_number}.  console=true
      Pdu Bts Interface Off  SMOD_${serial_number}
    END
    Sleep  10s  Waiting for ping to be loss.
    Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=60
    FOR  ${serial_number}  IN  @{smods_to_power_off_on}
      Log  Power on system module with serial number: ${serial_number}.  console=true
      Pdu Bts Interface On  SMOD_${serial_number}
    END
    FOR  ${serial_number}  IN  @{rmods_to_power_off_on}
      IF  '${serial_number}'=='${RMOD_1}[serialNumber]' or '${serial_number}'=='${RMOD_2}[serialNumber]'  CONTINUE
      Log  Power on radio module with serial number: ${serial_number}.  console=true
      Pdu Bts Interface On  RMOD_${serial_number}
    END


TC Setup
    Set Log Level  INFO
    Common Test Setup  tc_name=FM__Alarm_suppression_by_mocDN_all_severity
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
