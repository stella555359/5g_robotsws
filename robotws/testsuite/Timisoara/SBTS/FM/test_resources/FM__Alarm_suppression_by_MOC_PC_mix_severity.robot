*** Settings ***
Documentation
    ...  This test was designed to test feature CB010788 Enabling/Disabling minor/warning alarms.
    ...  CB010788 introduces control over alarm notifications on the BTS level to prevent alarm flooding and provide flexibility in alarm management.
    ...  It allows operator to suppress undesired minor/warning alarms based on alarm ID, fault ID, severity level, hardware Managed Object Class(MOC)
    ...  or on MOC Distinguished Name (DN), while still allowing desired alarms to be reported to network management system and Web Element Manager.

    ...  In first step current SCF will be collected for backup purpuse. Serial numbers of two radio modules are mandatory arguments for test.
    ...  In second step allowed and suppressed parameters will be removed from ALARMSUPP. One radio module will be powered off from PDU and presence
    ...  of critical fault 10 will be verified. After radio module is powered on, warning fault 4589 presence will be verified.
    ...  In third step partial RMOD DN will be added to suppressAlarmsByMOCList with severity warning and supression for warning fault 4589 will be
    ...  verified by powering off/on one radio module.
    ...  In fourth step default values will be configured under ALARMSUPP. Primary system module will be powered off/on and fault presence will
    ...  be verified for minor fault 4592.
    ...  In fifth step partial SMOD DN will be added to suppressAlarmsByMOCList with severity minor. Primary system module will be powered off/on and
    ...  fault supression will be verified for minor fault 4592. One radio module will be powered off and presence of critical fault 10 is verified.
    ...  After radio module is powered on, warning fault 4589 presence will be verified.
    ...  In sixth step partial RMOD DN and product code of one radio module will be added to suppressAlarmsByMOCList with severity warning.
    ...  All radio modules will be powered off/on individually. Fault presence of critical fault 10 and warning fault 4589 for all radio modules.
    ...  For radio module with product code configured in suppressAlarmsByMOCList, supression for warning fault 4589 will be verified for this RMOD.
    ...  In seventh step partial RMOD DN and product code of two radio modules will be added to suppressAlarmsByMOCList with severity critical.
    ...  All radio modules will be powered off/on individually. Fault presence of critical fault 10 and warning fault 4589 for all radio modules.
    ...  For radio modules with product code configured in suppressAlarmsByMOCList, supression of critical fault10 and warning fault 4589 is verified.
    ...  In eighth step full RMOD DN will be added to suppressAlarmsByMOCList with severity warning. One radio module will be powered off and presence
    ...  of fault 10 critical will be verified. After radio module is powered on, supression for warning fault 4589 presence will be verified.
    ...  In ninth step multiple mocDN (partially SMOD DN and full RMOD DN) will be added in suppressAlarmsByMOCList with various severities.
    ...  Site reset will be performed and fault supression will be verified for minor fault 4592. Next primary system module will be powered off/on
    ...  and supression will be verified for minor fault 4592. One radio module will be powered off/on and supression for warning fault 4589 verified.
    ...  In tenth step EAC_IN object is created with polarity Normally_closed and severity major. Presence of major fault 1400 is verified.
    ...  In eleventh step full SMOD DN will be added to suppressAlarmsByMOCList with severity critical. Supression of major fault 1400 is verified.
    ...  In twelfth step actAlarmsSuppression will be set to disabled. Original faults are verified:
    ...  - presence of major fault 1400 is verified.
    ...  - site reset will be performed and fault presence will be verified for minor fault 4592.
    ...  - primary system module will be powered off/on and presence will be verified for minor fault 4592.
    ...  - one radio module will be powered off/on and presence of critical fault 10 and warning fault 4589 is verified.
    ...  In thirteenth step full recomisioning with backup SCF will be performed.
    ...  Throughout testcase steps alarms presence/supression will be verified in WebEM and NMS.
    ...  Throughout testcase steps RawSuppressedAlarmHistory.txt and RawAlarmHistory.txt files will be checked.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_1_SN}  ${EMPTY}  # Mandatory. Serial number of RMOD that support fault 4589.
${RMOD_2_SN}  ${EMPTY}  # Mandatory. Serial number of RMOD that support fault 4589.
${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.
${RECOVERY_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after test scenario.


*** Keywords ***
TC_FM__Alarm_suppression_by_MOC_PC_mix_severity
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28936
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28936 - Initial TAT creation
    ...  - 02.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29308 - Test fails at checking the number of RMODS
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  *******************


    Set Tags  CA-FM  OWNER-corneliu.marcu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R2  FEATURE-CB010788

     Step 1: Test Case Specific Preconditions
     Step 2: Configure Default Values Under ALARMSUPP And Power Off/On One Radio Module To Verify Fault 4589
     Step 3: Add RMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Verify Supression For Fault 4589
     Step 4: Configure Default Values Under ALARMSUPP And Power Off/On System Module To Verify Fault 4592
     Step 5: Add SMOD MOC DN To SuppressAlarmsByMOCList, Verify Supression For Fault 4592 On System Module And Verify Fault 4589 On Radio Module
     Step 6: Add RMOD MOC DN And ProductCode To SuppressAlarmsByMOCList With Severity Warning And Power Off/On All Radio Modules
     Step 7: Add Two RMOD MOC DN And ProductCode To SuppressAlarmsByMOCList With Severity Critical And Power Off/On All Radio Modules
     Step 8: Add RMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Verify Supression For Fault 4589
     Step 9: Add SMOD And RMOD DN To SuppressAlarmsByMOCList, Supression For Fault 4592 On System Module And Supression Fault 4589 On Radio Module
     Step 10: Configure EAC And Trigger EAC Fault 1400 With Severity Major
     Step 11: Add SMOD MOC DN To SuppressAlarmsByMOCList With Severity Critical And Verify Supression For EAC Fault 1400 Major
     Step 12: Set ActAlarmsSuppression To Disabled And Verify Original Faults
     Step 13: Performed Commissioning With Backup SCF


Step 1: Test Case Specific Preconditions
    Log  \nStep 1: Test case specific preconditions.  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R2'  Fail  Software release is ${ENB_BRANCH}. Test is supported on software release equal to or higher than 25R2.
    Should Not Be Empty  ${RMOD_1_SN}  Serial numbers for radio modules not provided. [NOK]
    Should Not Be Empty  ${RMOD_2_SN}  Serial numbers for radio modules not provided. [NOK]
    ${rmods_list}  coam.Get Frm
    ${lenght}  Get Length  ${rmods_list}
    IF  ${lenght} < 3  Fail  At least 3 radio modules should be configured on platform for testcase scenario. [NOK]
    FOR  ${rmod}  IN  @{rmods_list}
      IF  '${rmod}[serialNumber]' == '${RMOD_1_SN}'  Set Test Variable  ${RMOD_1}  ${rmod}
      IF  '${rmod}[serialNumber]' == '${RMOD_2_SN}'  Set Test Variable  ${RMOD_2}  ${rmod}
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


Step 2: Configure Default Values Under ALARMSUPP And Power Off/On One Radio Module To Verify Fault 4589
    Log  \nStep 2: Configure default values under ALARMSUPP and power off/on one radio module to verify fault 4589.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    Log  Set ActAlarmsSuppression to suppressAlarms and configure default values to suppressedFaultList.  console=true
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_fault_dict_1}  faultId  4527,4079,4080
    Set To Dictionary  ${suppress_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict_1}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_1}  status_fault_10=active  status_fault_4589=active


Step 3: Add RMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Verify Supression For Fault 4589
    Log  \nStep 3: Add RMOD MOC DN to suppressAlarmsByMOCList with severity warning and verify supression for fault 4589.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_moc_list}  Create List
    ${suppress_moc_rmod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_rmod_dict}  moc  EQM/APEQM/RMOD
    Set To Dictionary  ${suppress_moc_rmod_dict}  alarmSeverity  WARNING
    Append To List  ${suppress_moc_list}  ${suppress_moc_rmod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault with severity=WARNING on mocDN=${RMOD_1}[id][configuration].  console=true
    Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${RMOD_1}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_1}  status_fault_10=active  status_fault_4589=inactive


Step 4: Configure Default Values Under ALARMSUPP And Power Off/On System Module To Verify Fault 4592
    Log  \nStep 4: Configure default values under ALARMSUPP and power off/on system module to verify fault 4592.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    Log  Set ActAlarmsSuppression to suppressAlarms and configure default values to suppressedFaultList.  console=true
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_fault_dict_1}  faultId  4527,4079,4080
    Set To Dictionary  ${suppress_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict_1}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}
    Log  Alarm presence will be verified for fault 4592 under ${SMOD}[id][configuration].  console=true
    Power Off/On System Module And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    Log  Waiting for fault to cancel.  console=true
    ${fault_parameters_4592}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${alarm_parameters}  Catenate  ${fault_parameters_4592},  alarmingResource=${SMOD}[id][runtime]
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=1800
    Log  Fault ${FAULT_4592_MINOR} is inactive in WebEM. [OK]  console=true


Step 5: Add SMOD MOC DN To SuppressAlarmsByMOCList, Verify Supression For Fault 4592 On System Module And Verify Fault 4589 On Radio Module
    Log  \nStep 5:Add SMOD MOC DN to suppressAlarmsByMOCList, verify supression for fault 4592 on system module and verify fault 4589 on radio module.
    ...  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_moc_list}  Create List
    ${suppress_moc_smod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_smod_dict}  moc  MRBTS/EQM/APEQM/CABINET/SMOD
    Set To Dictionary  ${suppress_moc_smod_dict}  alarmSeverity  MINOR
    Append To List  ${suppress_moc_list}  ${suppress_moc_smod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Power Off/On System Module And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Log  Alarm presence will be verified for fault with severity=WARNING on mocDN=${RMOD_2}[id][configuration].  console=true
    Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${RMOD_2}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_2}  status_fault_10=active  status_fault_4589=active


Step 6: Add RMOD MOC DN And ProductCode To SuppressAlarmsByMOCList With Severity Warning And Power Off/On All Radio Modules
    Log  \nStep 6: Add RMOD MOC DN and productCode To SuppressAlarmsByMOCList with severity warning and power off/on all radio modules.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_moc_list}  Create List
    ${suppress_moc_rmod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_rmod_dict}  moc  EQM/APEQM/RMOD
    Set To Dictionary  ${suppress_moc_rmod_dict}  productCode  ${RMOD_2}[productCode]
    Set To Dictionary  ${suppress_moc_rmod_dict}  alarmSeverity  WARNING
    Append To List  ${suppress_moc_list}  ${suppress_moc_rmod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    ${rmods_list}  coam.Get Frm
    FOR  ${rmod}  IN  @{rmods_list}
      IF  '${rmod}[productCode]' == '${RMOD_2}[productCode]'
        Log  Alarm suppression will be verified for fault with severity=WARNING on mocDN=${RMOD_2}[id][configuration].  console=true
        Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${RMOD_2}[id][configuration].  console=true
        Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_2}  status_fault_10=active  status_fault_4589=inactive
      ELSE
        Log  Alarm presence will be verified for fault with severity=WARNING on mocDN=${rmod}[id][configuration].  console=true
        Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${rmod}[id][configuration].  console=true
        Power Off/On Radio Module And Verify Faults  radio_module=${rmod}  status_fault_10=active  status_fault_4589=active
      END
    END


Step 7: Add Two RMOD MOC DN And ProductCode To SuppressAlarmsByMOCList With Severity Critical And Power Off/On All Radio Modules
    Log  \nStep 7: Add two RMOD MOC DN and productCode to SuppressAlarmsByMOCList with severity critical and power off/on all radio modules.
    ...  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_moc_list}  Create List
    ${suppress_moc_rmod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_rmod_dict}  moc  RMOD
    Set To Dictionary  ${suppress_moc_rmod_dict}  productCode  ${RMOD_1}[productCode],${RMOD_2}[productCode]
    Set To Dictionary  ${suppress_moc_rmod_dict}  alarmSeverity  CRITICAL
    Append To List  ${suppress_moc_list}  ${suppress_moc_rmod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    ${rmods_list}  coam.Get Frm
    FOR  ${rmod}  IN  @{rmods_list}
      IF  '${rmod}[productCode]' == '${RMOD_1}[productCode]'
        Log  Alarm suppression will be verified for fault with severity=WARNING on mocDN=${RMOD_1}[id][configuration].  console=true
        Log  Alarm suppression will be verified for fault with severity=CRITICAL on mocDN=${RMOD_1}[id][configuration].  console=true
        Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_1}  status_fault_10=inactive  status_fault_4589=inactive
      ELSE IF  '${rmod}[productCode]' == '${RMOD_2}[productCode]'
        Log  Alarm suppression will be verified for fault with severity=WARNING on mocDN=${RMOD_2}[id][configuration].  console=true
        Log  Alarm suppression will be verified for fault with severity=CRITICAL on mocDN=${RMOD_2}[id][configuration].  console=true
        Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_2}  status_fault_10=inactive  status_fault_4589=inactive
      ELSE
        Log  Alarm presence will be verified for fault with severity=WARNING on mocDN=${rmod}[id][configuration].  console=true
        Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${rmod}[id][configuration].  console=true
        Power Off/On Radio Module And Verify Faults  radio_module=${rmod}  status_fault_10=active  status_fault_4589=active
      END
    END


Step 8: Add RMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Verify Supression For Fault 4589
    Log  \nStep 8: Add RMOD MOC DN To SuppressAlarmsByMOCList With Severity Warning And Verify Supression For Fault 4589.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_moc_list}  Create List
    ${suppress_moc_rmod_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_moc_rmod_dict_1}  moc  EQM/APEQM/RMOD
    Set To Dictionary  ${suppress_moc_rmod_dict_1}  alarmSeverity  WARNING
    ${suppress_moc_rmod_dict_2}  Create Dictionary
    Set To Dictionary  ${suppress_moc_rmod_dict_2}  mocDN  ${RMOD_1}[id][configuration]
    Set To Dictionary  ${suppress_moc_rmod_dict_2}  alarmSeverity  WARNING
    Append To List  ${suppress_moc_list}  ${suppress_moc_rmod_dict_1}  ${suppress_moc_rmod_dict_2}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault with severity=WARNING on mocDN=${RMOD_1}[id][configuration].  console=true
    Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${RMOD_1}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_1}  status_fault_10=active  status_fault_4589=inactive


Step 9: Add SMOD And RMOD DN To SuppressAlarmsByMOCList, Supression For Fault 4592 On System Module And Supression Fault 4589 On Radio Module
    Log  \nStep 9:Add SMOD And RMOD DN To SuppressAlarmsByMOCList, Supression Fault 4592 On System Module And Supression Fault 4589 On Radio Module.
    ...  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_moc_list}  Create List
    ${suppress_moc_smod_dict}  Create Dictionary
    ${suppress_moc_rmod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_smod_dict}  moc  MRBTS/EQM/APEQM/CABINET/SMOD
    Set To Dictionary  ${suppress_moc_smod_dict}  alarmSeverity  MINOR
    Set To Dictionary  ${suppress_moc_rmod_dict}  mocDN  ${RMOD_1}[id][configuration]
    Set To Dictionary  ${suppress_moc_rmod_dict}  alarmSeverity  WARNING
    Append To List  ${suppress_moc_list}  ${suppress_moc_smod_dict}  ${suppress_moc_rmod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Log  Alarm suppression will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Power Off/On System Module And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=inactive
    Log  Alarm suppression will be verified for fault with severity=WARNING on mocDN=${RMOD_1}[id][configuration].  console=true
    Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${RMOD_1}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_1}  status_fault_10=active  status_fault_4589=inactive


Step 10: Configure EAC And Trigger EAC Fault 1400 With Severity Major
    Log  \nStep 10: Configure EAC and trigger EAC fault 1400 with severity major.  console=true
    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${RAW_SUPPRESED_TIME}  ${date_time_raw_suppresed}
    Set Test Variable  ${RAW_TIME}  ${date_time_raw_history}
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    Log  Alarm presence will be verified for fault with severity=MAJOR on mocDN=${SMOD}[id][configuration]/EAC_IN-1.  console=true
    Modify EAC_IN Object And Verify Fault 1400  operation=create  system_module=${SMOD}  status_fault_1400=active  severity_fault=Major


Step 11: Add SMOD MOC DN To SuppressAlarmsByMOCList With Severity Critical And Verify Supression For EAC Fault 1400 Major
    Log  \nStep 11: Add SMOD MOC DN to suppressAlarmsByMOCList with severity critical and verify supression for EAC fault 1400 major.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_moc_list}  Create List
    ${suppress_moc_eac_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_eac_dict}  mocDN  ${SMOD}[id][configuration]
    Set To Dictionary  ${suppress_moc_eac_dict}  alarmSeverity  CRITICAL
    Append To List  ${suppress_moc_list}  ${suppress_moc_eac_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Alarm suppression will be verified for fault with severity=MAJOR on mocDN=${SMOD}[id][configuration].  console=true
    Verify Fault 1400 Presence  inactive  Major  ${RAW_SUPPRESED_TIME}  ${RAW_TIME}


Step 12: Set ActAlarmsSuppression To Disabled And Verify Original Faults
    Log  \nStep 12: Set actAlarmsSuppression to disabled and verify original faults.  console=true
    Set ActAlarmsSuppression To Disabled
    Log  Alarm presence will be verified for fault with severity=MAJOR on mocDN=${SMOD}[id][configuration]/EAC_IN-1.  console=true
    Verify Fault 1400 Presence  active  Major  ${RAW_SUPPRESED_TIME}  ${RAW_TIME}
    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Perform Site Reset And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    Log  Alarm presence will be verified for fault with severity=MINOR on mocDN=${SMOD}[id][configuration].  console=true
    Power Off/On System Module And Verify Fault 4592  system_module=${SMOD}  status_fault_4592=active
    Log  Alarm presence will be verified for fault with severity=WARNING on mocDN=${RMOD_2}[id][configuration].  console=true
    Log  Alarm presence will be verified for fault with severity=CRITICAL on mocDN=${RMOD_2}[id][configuration].  console=true
    Power Off/On Radio Module And Verify Faults  radio_module=${RMOD_2}  status_fault_10=active  status_fault_4589=active


Step 13: Performed Commissioning With Backup SCF
    Log  \nStep 13: Performed commissioning with backup SCF.  console=true
    Performing Commisioning With Backup SCF


TC Setup
    Set Log Level  INFO
    Common Test Setup  tc_name=FM__Alarm_suppression_by_MOC_PC_mix_severity
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
    Set Log Level  TRACE
