*** Settings ***
Documentation
    ...  The purpose of this test case is verify category alarm - Cell Service Problem.
    ...  During System Verification testing customer relevant use cases will be tested in E2E environment.
    ...  Feature introduces support for the category alarms to reduce the number of BTS alarms reported.
    ...  Category alarms have alarm numbers within the range 7100-7198.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${NETACT_TIMEOUT}  120  # Timeout for fault reporting in Netact.
${ALARM_TIMEOUT}  1200  # Timeout for alarm reporting in WebEM.

*** Keywords ***
TC__FM__Improved_combined_FM_service_with_multiple_alarms
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21279
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21279 - Initial TAT creation
    ...  - 01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  - 29.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24118 - Test fail since it use predefined MRBTS id and not LNBTS id
    ...  - 12.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23761 - Fix for checking additional field
    ...  - 17.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24501 - Fix for checking additional field
    ...  - 15.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24686 - Remove actPoorSkyVisibilityAlarm parameter
    ...  - 27.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24823 - Testcase fails because fid 1898 is raised later
    ...  - 03.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24826 - Fix for checking additional field on different branches
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 23.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24998 - Testcase fails if GNSSE object already exists
    ...  - 20.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25174 - Test fails at recommissioning due to mandatory parameter on branch
    ...  - 25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25417 - Use Admin Get MRBTS ID and Admin Get LNBTS ID from sbts_admin
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26772 - Option to disable alarm check on MantaRay
    ...  - 30.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27859 - Test fails due to new parameter
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28425 - Test fails at recommissioning
    ...  - 19.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28756 - Add support for TOPP configuration
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21  FEATURE-LTE3342

    Step 0: Check Test Case Specific Preconditions
    Step 1: Trigger Fault Cell Service Problem And Check 6117 Fault With 7114 Alarm
    Step 2: Trigger Fault Base Station Information Problem And Check 4011 And 1898 Faults With 7115 Alarms
    Step 3: Trigger Fault Base Station Synchronization Problem And Check 4298 Fault With 7108 Alarm
    Step 4: Trigger Fault Cell Faulty And Check 49 Fault With 7102 Alarm
    Step 5: Performed Commissioning With Backup SCF


Step 0: Check Test Case Specific Preconditions
    Log  Step 0: Check test case specific preconditions.  console=true

    Log  Collect current SCF for backup purpose.  console=true
    coam.Get Current Scf File  local_dir_path=${BTS_FILES}  file_name=backup_scf.xml
    ${act_category_alarms}  Get Parameter Value From Infomodel  actCategoryAlarms
    Log  actCategoryAlarms value is ${act_category_alarms}.  console=true
    ${status}  Run Keyword And Return Status
    ...  Should Be Equal  ${act_category_alarms}  true
    IF  ${status} == ${FALSE}
      Change Paramter Value In Infomodel  actCategoryAlarms  true
    END
    Log  Check synchronitazion input type.  console=true
    Check If Synchronitazion Type Is TOPF Or TOPP
    Log  Select LNCEL to trigger fault and block.  console=true
    ${lncel_fdd_ids}  Query Infomodel  get list //LNCEL_L-*/LNCEL_FDD-*
    ${cells_number}  Get Length  ${lncel_fdd_ids}
    Select Random Cell  ${lncel_fdd_ids}  ${cells_number}
    Log  Collect MRBTS id and LNBTS id.  console=true
    ${mrbts}  Admin Get BTS ID
    ${lnbts}  Admin Get LNBTS ID
    Set Test Variable  ${MRBTS}
    Set Test Variable  ${LNBTS}
    Log  MRBTS ID is: ${MRBTS}; LNBTS ID is: ${LNBTS}  console=true


Step 1: Trigger Fault Cell Service Problem And Check 6117 Fault With 7114 Alarm
    Log  Step 1: Trigger fault Cell Service Problem and check 6117 fault with 7114 alarm.  console=true
    Create And Apply Provisioning Plan For RIP Alarm

    ${parameters_fault_6117}  Get String With Alarm Parameters  ${FAULT_6117}
    ${check_fault_6117_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${parameters_fault_6117}  timeout=${ALARM_TIMEOUT}
    IF  ${check_fault_6117_webem}
      Log  Fault ${FAULT_6117} is active in WebEM [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_6117} didn't appered in WebEM [NOK].
    END

    ${expected_alarm}  Create Dictionary  faultId=6117
    ${expected}  Create List  ${expected_alarm}
    ${status}  Run Keyword And Return Status
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}
    IF  '${status}' == 'FAIL'
      Log  Expected alarm missing or unexpected alarm is visible [NOK].  level=ERROR
    ELSE
      Log  Expected alarm is visible [OK].  console=TRUE
    END

    Log  Alarm presence will be checked in NA.  console=true
    ${check_fault_6117_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s  Check Additional Information For Given Alarm And Fault  &{FAULT_6117}
    ...  additional_fault_id=${FAULT_6117}[fault_id]
    IF  ${check_fault_6117_netact}
      Log  Fault ${FAULT_6117} ia active in Netact [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_6117} didn't appered in Netact [NOK].
    END

    Wait Until Keyword Succeeds  5x  1min
    ...  Check If Alarms From WebEM And NetAct Are The Same
    Wait Until Keyword Succeeds  3x  1min
    ...  Checking Additional Field  ${CELL_ID}


Step 2: Trigger Fault Base Station Information Problem And Check 4011 And 1898 Faults With 7115 Alarms
    Log  Step 2: Trigger fault Base Station Information Problem and check 4011 and 1898 faults with 7115 alarms.  console=true
    Create And Apply Provisioning Plan On GNSS

    ${parameters_fault_4011}  Get String With Alarm Parameters  ${FAULT_4011}
    ${check_fault_4011_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${parameters_fault_4011}  timeout=${ALARM_TIMEOUT}
    IF  ${check_fault_4011_webem}
      Log  Fault ${FAULT_4011} is active in WebEM [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_4011} didn't appered in WebEM [NOK].
    END

    ${parameters_fault_1898}  Get String With Alarm Parameters  ${FAULT_1898_MINOR_ALARM_7115}
    ${check_fault_1898_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${parameters_fault_1898}  timeout=${ALARM_TIMEOUT}
    IF  ${check_fault_1898_webem}
      Log  Fault ${FAULT_1898_MINOR_ALARM_7115} is active in WebEM [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_1898_MINOR_ALARM_7115} didn't appered in WebEM [NOK].
    END

    ${expected_alarm1}  Create Dictionary  faultId=4011
    ${expected_alarm2}  Create Dictionary  faultId=1898
    ${ignored_alarms}  Create Dictionary  faultId=6117
    ${expected}  Combine Lists  ${expected_alarm1}  ${expected_alarm2}
    ${ignored}  Create List  ${ignored_alarms}
    ${status}  Run Keyword And Return Status
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}  ignored_patterns=${ignored}
    IF  '${status}' == 'FAIL'
      Log  Expected alarm missing or unexpected alarm is visible [NOK].  level=ERROR
    ELSE
      Log  Expected alarm is visible [OK].  console=true
    END

    Log  Alarm presence will be checked in NA.  console=true
    ${check_fault_4011_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s  Check Additional Information For Given Alarm And Fault  &{FAULT_4011}
    ...  additional_fault_id=${FAULT_4011}[fault_id]
    IF  ${check_fault_4011_netact}
      Log  Fault ${FAULT_4011} is active in Netact [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_4011} didn't appered in Netact [NOK].
    END

    ${check_fault_1898_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s  Check Additional Information For Given Alarm And Fault  &{FAULT_1898_MINOR_ALARM_7115}
    ...  additional_fault_id=${FAULT_1898_MINOR_ALARM_7115}[fault_id]
    IF  ${check_fault_1898_netact}
      Log  Fault ${FAULT_1898_MINOR_ALARM_7115} is active in Netact [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_1898_MINOR_ALARM_7115} didn't appered in Netact [NOK].
    END
    Wait Until Keyword Succeeds  5x  1min
    ...  Check If Alarms From WebEM And NetAct Are The Same


Step 3: Trigger Fault Base Station Synchronization Problem And Check 4298 Fault With 7108 Alarm
    Log  Step 3: Trigger fault Base Station Synchronization Problem and check 4298 fault with 7108 alarm.  console=true
    IF  '${SYNC_TYPE}'=='TOPF'
      Create And Apply Provisioning Plan On TOPF
    ELSE
      Create And Apply Provisioning Plan On TOPP
    END
    ${parameters_fault_4298}  Get String With Alarm Parameters  ${FAULT_4298}
    ${check_fault_4298_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${parameters_fault_4298}  timeout=${ALARM_TIMEOUT}
    IF  ${check_fault_4298_webem}
      Log  Fault ${FAULT_4298} is active in WebEM [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_4298} didn't appered in WebEM [NOK].
    END

    ${parameters_fault_4452}  Get String With Alarm Parameters  ${FAULT_4452}
    ${parameters_fault_4530}  Get String With Alarm Parameters  ${FAULT_4530}

    IF  '${SYNC_TYPE}'=='TOPP'
      Assert Alarm Active  parameters=${parameters_fault_4452}  timeout=${ALARM_TIMEOUT}
      Log  Fault ${FAULT_4452} is active in WebEM [OK].  console=true
      Assert Alarm Active  parameters=${parameters_fault_4530}  timeout=${ALARM_TIMEOUT}
      Log  Fault ${FAULT_4530} is active in WebEM [OK].  console=true
      Check if fault 6280 is raised and see phase error
    END

    ${expected_alarm}  Create Dictionary  faultId=4298
    ${ignored_alarms1}  Create Dictionary  faultId=6117
    ${ignored_alarms2}  Create Dictionary  faultId=4011
    ${ignored_alarms3}  Create Dictionary  faultId=1898
    ${expected}  Create List  ${expected_alarm}
    ${ignored}  Combine Lists  ${ignored_alarms1}  ${ignored_alarms2}  ${ignored_alarms3}
    ${status}  Run Keyword And Return Status
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}  ignored_patterns=${ignored}
    IF  '${status}' == 'FAIL'
      Log  Expected alarm missing or unexpected alarm is visible [NOK].  level=Error
    ELSE
      Log  Expected alarm is visible [OK].  console=True
    END

    Log  Alarm presence will be checked in NA.  console=true
    ${check_fault_4298_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s  Check Additional Information For Given Alarm And Fault  &{FAULT_4298}
    ...  additional_fault_id=${FAULT_4298}[fault_id]
    IF  ${check_fault_4298_netact}
      Log  Fault ${FAULT_4298} is active in Netact [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_4298} didn't appered in Netact [NOK].
    END

    IF  '${SYNC_TYPE}'=='TOPP'
      Check Additional Information For Given Alarm And Fault  &{FAULT_4452}  additional_fault_id=${FAULT_4452}[fault_id]
      Log  Fault ${FAULT_4452} is active in Netact [OK].  console=true
      Check Additional Information For Given Alarm And Fault  &{FAULT_4530}  additional_fault_id=${FAULT_4530}[fault_id]
      Log  Fault ${FAULT_4530} is active in Netact [OK].  console=true
    END

    Wait Until Keyword Succeeds  5x  1min
    ...  Check If Alarms From WebEM And NetAct Are The Same


Step 4: Trigger Fault Cell Faulty And Check 49 Fault With 7102 Alarm
    Log  Step 4: Trigger fault Cell Faulty and check 49 fault with 7102 alarm.  console=true
    coam.Block Cell  dist_name=${CELL_DISTNAME}  timeout=60
    ${parameters_fault_49}  Get String With Alarm Parameters  ${FAULT_49}
    ${check_fault_49_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${parameters_fault_49}  timeout=${ALARM_TIMEOUT}
    IF  ${check_fault_49_webem}
      Log  Fault ${FAULT_49} is active in WebEM [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_49} didn't appered in WebEM [NOK].
    END

    ${expected_alarm}  Create Dictionary  faultId=49
    ${ignored_alarms1}  Create Dictionary  faultId=4011
    ${ignored_alarms2}  Create Dictionary  faultId=1898
    ${ignored_alarms3}  Create Dictionary  faultId=4298
    ${expected}  Create List  ${expected_alarm}
    ${ignored}  Combine Lists  ${ignored_alarms1}  ${ignored_alarms2}  ${ignored_alarms3}
    ${status}  Run Keyword And Return Status
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}  ignored_patterns=${ignored}
    IF  '${status}' == 'FAIL'
      Log  Expected alarm missing or unexpected alarm is visible [NOK].  level=ERROR
    ELSE
      Log  Expected alarm is visible [OK].  console=TRUE
    END

    Log  Alarm presence will be checked in NA.  console=true
    ${check_fault_4298_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s  Check Additional Information For Given Alarm And Fault  &{FAULT_4298}
    ...  additional_fault_id=${FAULT_4298}[fault_id]
    IF  ${check_fault_4298_netact}
      Log  Fault ${FAULT_4298} is active in Netact [OK].  console=true
    ELSE
      Fail  Fault ${FAULT_4298} didn't appered in Netact [NOK].
    END
    Wait Until Keyword Succeeds  5x  1min
    ...  Check If Alarms From WebEM And NetAct Are The Same


Step 5: Performed Commissioning With Backup SCF
    Log  Step 5: Performed commissioning with backup SCF.  console=true
    ${is_fault_49}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=alarmId=7102, faultId=49  timeout=30
    IF  ${is_fault_49}  coam.Unblock Cell  dist_name=${CELL_DISTNAME}  timeout=60
    coam.Perform Commissioning  bts_id=${MRBTS}  scf_file=${BTS_FILES}/backup_scf.xml  skip_parameter_relation_errors=true  timeout=300
    Wait Until Keyword Succeeds  600  10
    ...  Check All Cells
    Admin Check Active Alarms TAF


Get Parameter Value From Infomodel
    [Arguments]  ${im_parameter}

    ${parameter_name}  Convert To String  ${im_parameter}
    ${parameter_object}  Query Infomodel  get object /MRBTS-1/RAT-1//MNL_A-1/MNLENT_A-1/FMCADM_A-1
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parameter_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


Change Paramter Value In Infomodel
    [Arguments]  ${parameter_name}  ${value}

    ${im_bts_id}  Admin Get BTS ID
    ${dist_name_bts_id}  Set Variable  MRBTS-${im_bts_id}/MNL-1/MNLENT-1/FMCADM-1
    Log  ${parameter_name} will be changed to ${value}.  console=true
    ${status}  coam.Perform Parameter Recommissioning  ${dist_name_bts_id}  ${parameter_name}  update  ${value}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=300
    IF  ${status}
      Wait Until Keyword Succeeds  600  10  Check All Cells
    ELSE
      Fail  Recommissioning failed [NOK].
    END


Check If Synchronitazion Type Is TOPF Or TOPP
    ${im_bts_id}  Admin Get BTS ID
    ${smod_l}  Query Infomodel  get object //CLOCK_L-* is [syncHubRole="Master"]
    Log  On master syncHub selected synchronitazion source is ${smod_l}[selectedSource] and tuning mode is ${smod_l}[tuningMode].  console=true
    ${sync_status}  Run Keyword And Return Status  Query Infomodel  check //SYNC_A-* is [btsSyncMode=regex"FreqSync|PhaseSync"]
    ${clock_status}  Run Keyword And Return Status  Query Infomodel  check //CLOCK_A-* is [syncInputList[0].syncInputType[0]=regex"TOPF|TOPP"]
    IF  ${sync_status} and ${clock_status}
      Log  SYNC_A and CLOCK_A configured objects have: btsSyncMode "FreqSync" or "PhaseSync" and syncInputType TOPF or TOPP. [OK]  console=true
    ELSE
      Fail  SYNC_A and CLOCK_A configured objects does not have TOPF or TOPP synchronitazion. [NOK]
    END
    ${clock_a}  Query Infomodel  get object //CLOCK_A-* is [syncInputList[0].syncInputType[0]=regex"TOPF|TOPP"]
    ${sync_input}  Set Variable  ${clock_a}[syncInputList][0]
    Set Test Variable  ${SYNC_TYPE}  ${sync_input}[syncInputType]


Select Random Cell
    [Arguments]  ${lncel_fdd}  ${cells_number}

    ${ids}  Create List
    FOR  ${cell}  IN  @{lncel_fdd}
        ${string}  Fetch From Right  ${cell.dist_name}  LNCEL_FDD-
        Append To List  ${ids}  ${string}
    END
    ${index}  Evaluate  random.randint(0, ${cells_number}-1)  random
    Set Test Variable  ${CELL_ID}  ${ids}[${index}]
    ${cell_to_block}  Query Infomodel  get object //LNCEL_R-${CELL_ID}  timeout=30
    Set Test Variable  ${CELL_DISTNAME}  ${cell_to_block.dist_name}
    Log  LNCEL selected: ${CELL_DISTNAME}.  console=true


Create And Apply Provisioning Plan For RIP Alarm
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Log  Updating parameters on LNBTS and FDD LNCEL.  console=true
    Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}  update  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}  actCellTrace  true  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}  actMDTCellTrace  true  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}  actVendSpecCellTraceEnh  true  ${delta_id}
    ${rip_alarming_config_dict}  Create Dictionary
    Set To Dictionary  ${rip_alarming_config_dict}  actRIPAlarming  true
    Set To Dictionary  ${rip_alarming_config_dict}  alarmThresholdCrossingTime  1
    Set To Dictionary  ${rip_alarming_config_dict}  alarmThresholdULSF  -12600
    Append Complex Item To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNCEL-${CELL_ID}/LNCEL_FDD-0  list_name=ripAlarmingConfig
    ...  &{rip_alarming_config_dict}  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_1.json  delta_id=${delta_id}
    Log  Performing delta recommissioning.  console=true
    ${status}  Run Keyword And Return Status
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_1.json  skip_parameter_relation_errors=True
    IF  ${status}
      Log  Recommissioning was performed [OK].  console=true
    ELSE
      Fail  Recommissioning failed [NOK].
    END
    Remove Delta  ${delta_id}


Create And Apply Provisioning Plan On GNSS
    ${operation}  Check If GNSSE Object Exists
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Log  Updating parameters on GNSS.  console=true
    ${sync_input_list_dict}  Create Dictionary
    Set To Dictionary  ${sync_input_list_dict}  syncInputPrio  1
    Set To Dictionary  ${sync_input_list_dict}  syncInputType  1pps/ToD from external GNSS receiver
    Append Complex Item To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1  list_name=syncInputList  &{sync_input_list_dict}
    ...  delta_id=${delta_id}
    ${sync_input_list_dict2}  Create Dictionary
    Set To Dictionary  ${sync_input_list_dict2}  syncInputPrio  2
    Set To Dictionary  ${sync_input_list_dict2}  syncInputType  ${SYNC_TYPE}
    Append Complex Item To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1  list_name=syncInputList  &{sync_input_list_dict2}
    ...  delta_id=${delta_id}
    Append Managed Object To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  ${operation}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actGps  true  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actGps  true  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actBeidou  false  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actGalileo  false  ${delta_id}
    IF  '${ENB_BRANCH}'>'SBTS24R2' or '${ENB_BRANCH}'=='SBTS00'
      Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actGalileoOsnma  Disabled  ${delta_id}
    END
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actGlonass  false  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actGnssOutputLnaPowerSupply  true  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actNavic  false  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actQzss  false  ${delta_id}
    IF  '${ENB_BRANCH}'>'SBTS24R2' or '${ENB_BRANCH}'=='SBTS00'
      Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  galileoOsnmaExtTimeEnabled  false  ${delta_id}
    END
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  gnssReceiverHoldoverMode  false  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  intervalRepGnssAntPosiSpeed  1min  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  locationMode  automatic  ${delta_id}
    IF  '${ENB_BRANCH}' < 'SBTS23R2'
      Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1  actPoorSkyVisibilityAlarm  false  ${delta_id}
    END
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_2.json  delta_id=${delta_id}
    Log  Performing delta recommissioning.  console=true
    ${status}  Run Keyword And Return Status
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_2.json  skip_parameter_relation_errors=True
    IF  ${status}
      Log  Recommissioning was performed [OK].  console=true
    ELSE
      Fail  Recommissioning failed [NOK].
    END
    Remove Delta  ${delta_id}


Check If GNSSE Object Exists
    ${object}  coam.Get Gnsses Statuses
    ${status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${object}[GNSSE_R-1]
    ${gnsee_operation}  Set Variable If  ${status}  update  create

    [Return]  ${gnsee_operation}


Create And Apply Provisioning Plan On TOPF
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Log  Updating parameters on TOPF.  console=true
    Append Managed Object To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPF-1  update  ${delta_id}
    ${top_master_list_dict}  Create Dictionary
    Set To Dictionary  ${top_master_list_dict}  masterIpAddr  1.1.1.1
    Set To Dictionary  ${top_master_list_dict}  priority_1  0
    Set To Dictionary  ${top_master_list_dict}  priority_2  0
    Append Complex Item To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPF-1  list_name=topMasterList  &{top_master_list_dict}
    ...  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_3.json  delta_id=${delta_id}
    Log  Performing delta recommissioning.  console=true
    ${status}  Run Keyword And Return Status
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_3.json  skip_parameter_relation_errors=True
    IF  ${status}
      Log  Recommissioning was performed [OK].  console=true
    ELSE
      Fail  msg=Recommissioning failed [NOK].
    END
    Remove Delta  ${delta_id}


Create And Apply Provisioning Plan On TOPP
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Log  Updating parameters on TOPP.  console=true
    ${values_clock}  Create List  6
    Append Managed Object To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1  update  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1  acceptedClockClass  ${values_clock}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1  syncMessageRate  RATE_64  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1  topStandardProfile  Telecom2008  ${delta_id}
    Append Parameter Delete To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1  topEthMulticastAddress  ${delta_id}
    ${top_master_list_dict}  Create Dictionary
    Set To Dictionary  ${top_master_list_dict}  masterIpAddr  1.1.1.1
    Set To Dictionary  ${top_master_list_dict}  phaseErrorComp  0
    Set To Dictionary  ${top_master_list_dict}  maximumNetworkTimingError  0
    Set To Dictionary  ${top_master_list_dict}  localPriority  128
    Set To Dictionary  ${top_master_list_dict}  topMasterId  1
    Append Complex Item To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1  list_name=topMasterList  &{top_master_list_dict}
    ...  delta_id=${delta_id}
    Append Managed Object To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1  update  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1  sPlaneDscp  46  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1  sPlaneIpAddressDN
    ...  MRBTS-${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_4.json  delta_id=${delta_id}
    Log  Performing delta recommissioning.  console=true
    ${status}  Run Keyword And Return Status
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_4.json  skip_parameter_relation_errors=True
    IF  ${status}
      Log  Recommissioning was performed [OK].  console=true
    ELSE
      Fail  Recommissioning failed [NOK].
    END
    Remove Delta  ${delta_id}


Checking Additional Field
    [Arguments]  ${cell_id}

    IF  '${DISABLE_NETACT_CHECK}' == 'True'
      Log  Netact check is disabled, check will be skipped.  console=true
      Return From Keyword
    END
    ${lncel_list}  Get Ids For All  LNCEL
    ${lncel_qty}  Get Length  ${lncel_list}
    ${text_1}  Set Variable If  ${lncel_qty}==1  u'additionalText2': u'degraded_cells=LTE:all'  u'additionalText2': u'degraded_cells=LTE:${cell_id}'
    ${text_2}  Set Variable If  ${lncel_qty}==1  'additionalText2': 'degraded_cells=LTE:all'  'additionalText2': 'degraded_cells=LTE:${cell_id}'
    ${alarms}  netact.Get_alarms  dist_name=${MRBTS_DN}
    ${enb_alarms_str}  Convert To String  ${alarms}
    ${output}  Should Contain Any  ${enb_alarms_str}  ${text_1}  ${text_2}



Check if fault 6280 is raised and see phase error
    ${parameters_fault_6280}  Get String With Alarm Parameters  ${FAULT_6280}
    ${status_alarm}  Run Keyword And Return Status  Assert Alarm Active  parameters=${parameters_fault_6280}  timeout=${ALARM_TIMEOUT}
    IF  ${status_alarm}
      Log  Fault ${FAULT_6280} is active in WebEM [OK].  console=true
      Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s  Check Additional Information For Given Alarm And Fault  &{FAULT_6280}
      Log  Fault ${FAULT_6280} is active in Netact [OK].  console=true
    ELSE
      Check if phaseError not exceeds 5 us
    END


Check if phaseError not exceeds 5 us
    ${time_objects}  Query Infomodel  get list //TIME-*
    FOR  ${object}  IN  @{time_objects}
         ${operation}  Run keyword And Return Status  Evaluate  ${object}[phaseError] < -5000
         IF  ${operation}
           Log  phaseError under ${object}[dist_name] has value ${object}[phaseError] < -5000 [OK]  console=true
         ELSE
           Fail  phaseError exceeds 5 us [NOK]
         END
    END


TC Setup
    Common Test Setup  tc_name=FM__Improved_combined_FM_service_with_multiple_alarms
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Step 5: Performed Commissioning With Backup SCF
    Teardown NetAct
    Common Test Teardown
