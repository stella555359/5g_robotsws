*** Settings ***
Documentation
    ...  This test was designed to test feature CB010788 Enabling/Disabling minor/warning alarms.
    ...  CB010788 introduces control over alarm notifications on the BTS level to prevent alarm flooding and provide flexibility in alarm management.
    ...  It allows operator to suppress undesired minor/warning alarms based on alarm ID, fault ID, severity level, hardware Managed Object Class(MOC)
    ...  or on MOC Distinguished Name (DN), while still allowing desired alarms to be reported to network management system and Web Element Manager.

    ...  In first step current SCF will be collected for backup purpuse. Allowed and suppressed parameters will be removed from ALARMSUPP.
    ...  In second step a fault with severity minor will be triggered. Alarm presence will be verified in WebEM and NMS.
    ...  In third step fault will be added to suppressedFaultList with severity minor and warning. actAlarmsSuppression parameter set suppressAlarms.
    ...  Alarm absence will be verified in WebEM and NMS.
    ...  In fourth step fault will be added to suppressedFaultList with severity minor. Alarm absence will be verified in WebEM and NMS.
    ...  In fifth step fault will be added to suppressedFaultList with severity warning. Alarm presence will be verified in WebEM and NMS.
    ...  In sixth step fault will be added to allowedFaultList with severity minor and warning. Alarm presence will be verified in WebEM and NMS.
    ...  In seventh step fault will be added to allowedFaultList with severity minor. Alarm presence will be verified in WebEM and NMS.
    ...  In eighth step fault will be added to allowedFaultList with severity warning. Alarm absence will be verified in WebEM and NMS.
    ...  In ninth step in allowedFaultList fault ID will be set to ANY with severity minor and warning.
    ...  Alarm presence will be verified in WebEM and NMS.
    ...  In tenth step actAlarmsSuppression will be set to suppressAlarms. MOC will be added to suppressAlarmsByMOCList with severity warning.
    ...  Another fault under MOC will be triggered with severity warning. Fault should be absent in WebEM and NMS.
    ...  In eleventh step combination MOC and product code will be added to suppressAlarmsByMOCList with severity warning.
    ...  Fault will be trigger under MOC with severity warning, however product code differs than product code set in suppressAlarmsByMOCList.
    ...  Fault should be present in WebEM and NMS.
    ...  In twelfth step actAlarmsSuppression parameter will be set to disabled. Previosly suppressed alarms are displayed in WebEM and NMS.
    ...  In thirteenth step full recomisioning with backup SCF will be performed.
    ...  Throughout testcase steps RawSuppressedAlarmHistory.txt and RawAlarmHistory.txt files will be checked.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.
${RECOVERY_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after test scenario.


*** Keywords ***
TC__FM__Alarm_suppression_based_on_faultID
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28938
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28938 - Initial TAT creation
    ...  - 14.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28935 - Change keyword implementation
    ...  - 29.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28937 - Move keywords to resource file
    ...  *******************

    Set Tags  CA-FM  OWNER-corneliu.marcu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R2  FEATURE-CB010788


     Step 0: Test Case Specific Preconditions
     Step 1: Remove Allowed And Suppressed Parameters From ALARMSUPP
     Step 2: Trigger Fault 4592 With Minor Severity
     Step 3: Add Fault 4592 To SuppressedFaultList With Severity Minor And Warning
     Step 4: Add Fault 4592 To SuppressedFaultList With Severity Minor
     Step 5: Add Fault 4592 To SuppressedFaultList With Severity Warning
     Step 6: Add Fault 4592 To AllowedFaultList With Severity Minor And Warning
     Step 7: Add Fault 4592 To AllowedFaultList With Severity Minor
     Step 8: Add Fault 4592 To AllowedFaultList With Severity Warning
     Step 9: Set Fault Id To Any In AllowedFaultList
     Step 10: Add EQM/APEQM/CABINET/BBMOD MOC To SuppressAlarmsByMOCList With Severity Warning And Trigger Fault 2078
     Step 11: Add EQM/APEQM/CABINET/BBMOD MOC And Product Code To SuppressAlarmsByMOCList With Severity Warning And Trigger Fault 2078
     Step 12: Set ActAlarmsSuppression To Disabled
     Step 13: Performed Commissioning With Backup SCF


Step 0: Test Case Specific Preconditions
    Log  \nStep 0: Test case specific preconditions.  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R2'  Fail  Software release is ${ENB_BRANCH}. Test is supported on software release equal to or higher than 25R2.
    Log  Collect current SCF for backup purpose.  console=true
    Get Current Scf File  local_dir_path=${BTS_FILES}  file_name=backup_scf.xml  timeout=60  export_type=configurationAndRuntimeObjects
    ...  parameters_save_variant=actualValues
    ${allowed_faults}  Create List
    Append To List  ${allowed_faults}  ${FAULT_4592_MINOR}[fault_id]
    Set Test Variable  ${ALLOWED_FAULTS}
    ${current_date_time_raw}  Get BTS time in UTC format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${CURRENT_DATE_TIME_RAW}
    ${bbmods_list}  Get Parameters For All  BBMOD
    ${bbmods_for_test}  Create List
    ${type}  Create List
    Append To List  ${type}  NRCELL  LNCEL
    FOR  ${object}  IN  @{bbmods_list}
        ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${object}[id]
        ${empty_status}  Run Keyword And Return Status  Should Not Be Empty  ${cells_on_bbmod}
        Continue For Loop If  not(${empty_status})
        ${cells_match}  Check Cells Type  ${cells_on_bbmod}  ${type}
        IF  ${cells_match}  Append To List  ${bbmods_for_test}  ${object}
    END
    ${bbmod_chosen}  Evaluate  random.choice(${bbmods_for_test})  random
    ${bbmod_horizontal_position}  Get Module Horizontal Position  ${bbmod_chosen}[id]
    ${receiver}  Set Variable If  '${bbmod_horizontal_position}' == '1'  269554178  537989634
    ${bbmod_l}  Query Infomodel  get object //BBMOD_L-* is [serialNumber=${bbmod_chosen}[serialNumber]]
    ${bbu_exist}  Run Keyword And Return Status  Query Infomodel  check ${bbmod_l.dist_name}/BBU_L-1
    ${bbu_string}  Set Variable If  ${bbu_exist}  ${bbmod_l.dist_name}/BBU_L-1  ${bbmod_l.dist_name}/BOARD_L-1
    ${cpu_l}  Query Infomodel  get object ${bbu_string}/POWER_GROUP_L-1/SOC_L-1/CPU_L-1
    ${cpu_node_id}  Convert To Hex  ${cpu_l}[nodeId]
    ${sender}  Convert To Integer  0X${cpu_node_id}04B5
    ${bbu_l}  Query Infomodel  get object ${bbu_string}
    ${node_id}   Set Variable  ${bbu_l}[nodeId]
    ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${bbmod_chosen}[id]
    Set Test Variable  ${BBMOD_CHOSEN}
    Set Test Variable  ${RECEIVER}
    Set Test Variable  ${SENDER}
    Set Test Variable  ${NODE_ID}
    Set Test Variable  ${CELLS_ON_BBMOD}


Step 1: Remove Allowed And Suppressed Parameters From ALARMSUPP
    Log  \nStep 1: Remove allowed and suppressed parameters from ALARMSUPP.  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP


Step 2: Trigger Fault 4592 With Minor Severity
    Log  \nStep 2: Trigger fault 4592 with minor severity.  console=true
    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${RAW_SUPPRESED_1}  ${date_time_raw_suppresed}
    Set Test Variable  ${RAW_HISTORY_1}  ${date_time_raw_history}
    Change FMCADM Parameter  fault4592CancellationTimer  1800
    Log  Site reset will be performed.  console=true
    coam.Reset Site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  1min  Check Modules And Cells
    Log  Check fault presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_fault_webem}  Fault ${FAULT_4592_MINOR} is not active in WebEM.
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true
    Log  Check fault presence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}
    Should Be True  ${check_fault_netact}  Fault ${FAULT_4592_MINOR} is not active in Netact.
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Verify Alarm In RawAlarmHistory File  4592  ${RAW_HISTORY_1}


Step 3: Add Fault 4592 To SuppressedFaultList With Severity Minor And Warning
    Log  \nStep 3: Add fault 4592 to suppressedFaultList with severity minor and warning.  console=true
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_fault_dict_1}  faultId  4592
    Set To Dictionary  ${suppress_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict_1}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}
    Log  Check fault absence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_fault_webem}  Fault ${FAULT_4592_MINOR} is still active in WebEM.
    Log  Fault ${FAULT_4592_MINOR} is inactive in WebEM.  console=true
    Log  Check fault absence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4592_MINOR}  time_from=${time_from}
    Should Be True  ${check_fault_netact}  Fault ${FAULT_4592_MINOR} is still active in Netact.
    Log  Fault ${FAULT_4592_MINOR} is not active in Netact.  console=true
    Verify Alarm In RawAlarmHistory File  4592  ${RAW_HISTORY_1}
    Verify Alarm In RawSuppressedAlarmHistory File  fault_number=4592  current_date_time=${RAW_SUPPRESED_1}


Step 4: Add Fault 4592 To SuppressedFaultList With Severity Minor
    Log  \nStep 4: Add fault 4592 to suppressedFaultList with severity minor.  console=true
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_fault_dict_1}  faultId  4592
    Set To Dictionary  ${suppress_fault_dict_1}  alarmSeverity  MINOR
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict_1}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}
    Log  Check fault absence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_fault_webem}  Fault ${FAULT_4592_MINOR} is still active in WebEM.
    Log  Fault ${FAULT_4592_MINOR} is inactive in WebEM.  console=true
    Log  Check fault absence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}
    Should Not Be True  ${check_fault_netact}  Fault ${FAULT_4592_MINOR} is still active in Netact.
    Log  Fault ${FAULT_4592_MINOR} is not active in Netact.  console=true
    Verify Alarm In RawAlarmHistory File  4592  ${RAW_HISTORY_1}
    Verify Alarm In RawSuppressedAlarmHistory File  fault_number=4592  current_date_time=${RAW_SUPPRESED_1}


Step 5: Add Fault 4592 To SuppressedFaultList With Severity Warning
    Log  \nStep 5: Add fault 4592 to suppressedFaultList with severity warning.  console=true
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${suppress_fault_dict_1}  faultId  4592
    Set To Dictionary  ${suppress_fault_dict_1}  alarmSeverity  WARNING
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict_1}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}
    Log  Check fault presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_fault_webem}  Fault ${FAULT_4592_MINOR} is not active in WebEM.
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true
    Log  Check fault presence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}
    Should Be True  ${check_fault_netact}  Fault ${FAULT_4592_MINOR} is not active in Netact.
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Verify Alarm In RawAlarmHistory File  4592  ${RAW_HISTORY_1}


Step 6: Add Fault 4592 To AllowedFaultList With Severity Minor And Warning
    Log  \nStep 6: Add fault 4592 to allowedFaultList with severity minor and warning.  console=true
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  4592
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Log  Check fault presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_fault_webem}  Fault ${FAULT_4592_MINOR} is not active in WebEM.
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true
    Log  Check fault presence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}
    Should Be True  ${check_fault_netact}  Fault ${FAULT_4592_MINOR} is not active in Netact.
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Check If Only Allowed Alarms And Faults Are Active  ${ALLOWED_FAULTS}  Minor_Warning  fault
    Verify Alarm In RawAlarmHistory File  4592  ${RAW_HISTORY_1}


Step 7: Add Fault 4592 To AllowedFaultList With Severity Minor
    Log  \nStep 7: Add fault 4592 to allowedFaultList with severity minor.  console=true
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  4592
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Log  Check fault presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_fault_webem}  Fault ${FAULT_4592_MINOR} is not active in WebEM.
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true
    Log  Check fault presence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}
    Should Be True  ${check_fault_netact}  Fault ${FAULT_4592_MINOR} is not active in Netact.
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Check If Only Allowed Alarms And Faults Are Active  ${ALLOWED_FAULTS}  Minor  fault
    Verify Alarm In RawAlarmHistory File  4592  ${RAW_HISTORY_1}


Step 8: Add Fault 4592 To AllowedFaultList With Severity Warning
    Log  \nStep 8: Add fault 4592 to allowedFaultList with severity warning.  console=true
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  4592
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  WARNING
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Log  Check fault absence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_fault_webem}  Fault ${FAULT_4592_MINOR} is still active in WebEM.
    Log  Fault ${FAULT_4592_MINOR} is inactive in WebEM.  console=true
    Log  Check fault absence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4592_MINOR}  time_from=${time_from}
    Should Be True  ${check_fault_netact}  Fault ${FAULT_4592_MINOR} is still active in Netact.
    Log  Fault ${FAULT_4592_MINOR} is not active in Netact.  console=true
    Verify Alarm In RawAlarmHistory File  4592  ${RAW_HISTORY_1}
    Verify Alarm In RawSuppressedAlarmHistory File  fault_number=4592  current_date_time=${RAW_SUPPRESED_1}


Step 9: Set Fault Id To Any In AllowedFaultList
    Log  \nStep 9: Set fault id to ANY in allowedFaultList.  console=true
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict_1}  Create Dictionary
    Set To Dictionary  ${allowed_fault_dict_1}  faultId  ANY
    Set To Dictionary  ${allowed_fault_dict_1}  alarmSeverity  MINOR_AND_WARNING
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict_1}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}
    Log  Site reset will be performed.  console=true
    coam.Reset Site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  1min  Check Modules And Cells
    ${active_alarms}  Assert Alarm Active
    ${number_of_alarms}  Get Length  ${active_alarms}
    Should Not Be Empty  ${active_alarms}
    Should Not Be Equal  ${number_of_alarms}  0
    Log  Check fault presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_fault_webem}  Fault ${FAULT_4592_MINOR} is not active in WebEM.
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true
    Log  Check fault presence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}
    Should Be True  ${check_fault_netact}  Fault ${FAULT_4592_MINOR} is not active in Netact.
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Verify Alarm In RawAlarmHistory File  4592  ${RAW_HISTORY_1}


Step 10: Add EQM/APEQM/CABINET/BBMOD MOC To SuppressAlarmsByMOCList With Severity Warning And Trigger Fault 2078
    Log  \nStep 10: Add EQM/APEQM/CABINET/BBMOD MOC to suppressAlarmsByMOCList with severity warning and trigger fault 2078.  console=true
    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    ${suppress_moc_list}  Create List
    ${suppress_moc_bbmod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_bbmod_dict}  moc  EQM/APEQM/CABINET/BBMOD
    Set To Dictionary  ${suppress_moc_bbmod_dict}  alarmSeverity  WARNING
    Append To List  ${suppress_moc_list}  ${suppress_moc_bbmod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Fault 2078 will be triggered on baseband:\n ${BBMOD_CHOSEN}.  console=true
    Log  Cells mapped on FSP:\n ${CELLS_ON_BBMOD}.  console=true
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=first_warm_reset  admin_api_log_dir=${BTS_FILES}
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2078_BB_AUTO_RST}
    ${alarm_webem}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=first_warm_reset
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  ${FAULT_2078_BB_AUTO_RST}[fault_id]  ${NODE_ID}  2
    Wait Until Keyword Succeeds  120  10  Checking Cells On The Given FSP  ${cells_on_bbmod}  ${FAILED}  ${DISABLED}
    Log  Check fault absence in WebEM.  console=true
    ${check_alarm_webem}  Run Keyword And Return Status  Collect Keyword Result  ${alarm_webem}  timeout=${ALARM_TIMEOUT}
    Should Not Be True  ${check_alarm_webem}  Fault ${FAULT_2078_BB_AUTO_RST} was active in WebEm.
    Log  Fault ${FAULT_2078_BB_AUTO_RST} was not active in WebEm.  console=true
    Log  Check fault absence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2078_BB_AUTO_RST}  time_from=${time_from}
    ...  additional_fault_id=${FAULT_2078_BB_AUTO_RST}[fault_id]
    Should Not Be True  ${check_fault_netact}  Fault ${FAULT_2078_BB_AUTO_RST} was reported in Netact.
    Log  Fault ${FAULT_2078_BB_AUTO_RST} was not reported in Netact.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  1min  Check All Cells
    Verify Alarm In RawAlarmHistory File  2078  ${date_time_raw_history}  ${None}  inactive
    Verify Alarm In RawSuppressedAlarmHistory File  fault_number=2078  current_date_time=${date_time_raw_suppresed}  alarm_status=inactive

    [Teardown]  Teardown Admin  first_warm_reset


Step 11: Add EQM/APEQM/CABINET/BBMOD MOC And Product Code To SuppressAlarmsByMOCList With Severity Warning And Trigger Fault 2078
    Log  \nStep 11: Add EQM/APEQM/CABINET/BBMOD MOC and product code to suppressAlarmsByMOCList with severity warning and trigger fault 2078.
    ...  console=true
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    ${bbmods_list}  Get Parameters For All  BBMOD
    Remove Values From List  ${bbmods_list}  ${BBMOD_CHOSEN}
    ${random_bbmod}  Evaluate  random.choice(${bbmods_list})  random
    Log  Random BBMOD that will be added to suppressAlarmsByMOCList:\n ${random_bbmod}.  console=true
    ${suppress_moc_list}  Create List
    ${suppress_moc_bbmod_dict}  Create Dictionary
    Set To Dictionary  ${suppress_moc_bbmod_dict}  moc  EQM/APEQM/CABINET/BBMOD
    Set To Dictionary  ${suppress_moc_bbmod_dict}  alarmSeverity  WARNING
    Set To Dictionary  ${suppress_moc_bbmod_dict}  productCode  ${random_bbmod}[productCode]
    Append To List  ${suppress_moc_list}  ${suppress_moc_bbmod_dict}
    Add Given MOC And Severity To SuppressAlarmsByMOCList  ${suppress_moc_list}
    Log  Fault 2078 will be triggered on baseband:\n ${BBMOD_CHOSEN}.  console=true
    Log  Cells mapped on FSP:\n ${CELLS_ON_BBMOD}.  console=true
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=second_warm_reset  admin_api_log_dir=${BTS_FILES}
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2078_BB_AUTO_RST}
    ${alarm_webem}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=second_warm_reset
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  ${FAULT_2078_BB_AUTO_RST}[fault_id]  ${NODE_ID}  2
    Wait Until Keyword Succeeds  120  10  Checking Cells On The Given FSP  ${cells_on_bbmod}  ${FAILED}  ${DISABLED}
    Log  Check fault presence in WebEM.  console=true
    ${check_alarm_webem}  Run Keyword And Return Status  Collect Keyword Result  ${alarm_webem}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_alarm_webem}  Fault ${FAULT_2078_BB_AUTO_RST} was not active in WebEm.
    Log  Fault ${FAULT_2078_BB_AUTO_RST} was active in WebEm.  console=true
    Log  Check fault presence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2078_BB_AUTO_RST}  time_from=${time_from}
    Should Be True  ${check_fault_netact}  Fault ${FAULT_2078_BB_AUTO_RST} was not reported in Netact.
    Log  Fault ${FAULT_2078_BB_AUTO_RST} was reported and cleared from NetAct.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  1min  Check All Cells
    Verify Alarm In RawAlarmHistory File  2078  ${date_time_raw_history}  ${None}  inactive

    [Teardown]  Teardown Admin  second_warm_reset


Step 12: Set ActAlarmsSuppression To Disabled
    Log  \nStep 12: Set actAlarmsSuppression to disabled.  console=true
    Set ActAlarmsSuppression To Disabled
    Sleep  30s  Waiting for alarm update.
    ${active_alarms}  Assert Alarm Active
    ${number_of_alarms}  Get Length  ${active_alarms}
    Should Not Be Empty  ${active_alarms}
    Should Not Be Equal  ${number_of_alarms}  0
    Log  Check fault presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_fault_webem}  Fault ${FAULT_4592_MINOR} is not active in WebEM.
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true
    Log  Check fault presence in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}
    Should Be True  ${check_fault_netact}  Fault ${FAULT_4592_MINOR} is not active in Netact.
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Verify Alarm In RawAlarmHistory File  4592  ${RAW_HISTORY_1}


Step 13: Performed Commissioning With Backup SCF
    Log  \nStep 13: Performed commissioning with backup SCF.  console=true
    Performing Commisioning With Backup SCF


TC Setup
    Set Log Level  INFO
    Common Test Setup  tc_name=FM__Alarm_suppression_based_on_faultID
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Performing Commisioning With Backup SCF
    Teardown Netact
    Common Test Teardown
    Set Log Level  TRACE
