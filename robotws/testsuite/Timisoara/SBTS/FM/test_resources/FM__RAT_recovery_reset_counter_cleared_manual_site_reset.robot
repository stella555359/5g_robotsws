*** Settings ***
Documentation
    ...  This test case was created to verify counter reset for RAT recovery reset scenario. Rioboot command will be used
    ...  with write option. Before crash file data.dat with value "OxFFFF" is created in /tmp. To perform DSP crash value 0x128FFFFF
    ...  needs to be put into created file inline with nodeID in hex format. Example rioboot -c write -a 0x128FFFFF -f /tmp/data.dat 0x1335.
    ...  Fault 6707/6708/6709 appearance and WCDMA cells reset are being checked in two seperate threads.
    ...  In meantime also Recovery Reset Indication appearance
    ...  is checked under FRI. 4th crash of DSP results in exceeding recovery reset counter.
    ...  Insted of WCDMA RAT reset alarm 7116 will be displayed and recovery action will be blocked.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # Timeout for SBTS after site reset
${RECOVERY_TIMEOUT}  360  # Timeout for SBTS after recovery action
${ALARM_TIMEOUT}  660  # Timeout for alarm reporting in WebEM
${NETACT_TIMEOUT}  120  # Timeout for alarm reporting in Netact


*** Keywords ***
TC__FM__RAT_recovery_reset_counter_cleared_manual_site_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10456
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.10.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20316 - Timeout at Check All Cells after site reset to clear all recovery counters
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25140 - Test fail since test does not wait enough for fault to occur
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  - 16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28442 - Verification of fault signature scope field for FM test cases
    ...  - 19.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29411 - Delete verification in background for alarm.
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20A

    Step1: TC Preconditions
    Step2: Trigger 1st WCDMA DSP Crash
    Step3: Site Reset To Clear Counters
    FOR  ${loop}  IN RANGE  0  3
        Step4: Trigged WCDMA DSP Crash
        IF  ${loop} == 2  Check Alarm 7116
        Step5: Verify Success Of Recovery Action
    END


Step1: TC Preconditions
    [Documentation]  In this step system module release will be check and required file will be created.

    Log  \nStep1: TC preconditions.  console=true
    ${act_force_auto_reset_ini}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Set Test Variable  ${ACT_FORCE_AUTO_RESET_INI}
    Log  Value of actForceAutoReset is ${ACT_FORCE_AUTO_RESET_INI}.  console=true
    ${status_act}  Run Keyword And Return Status  Should Contain  ${ACT_FORCE_AUTO_RESET_INI}  true
    IF  ${status_act} == ${FALSE}  Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    ${act_force_auto_reset_changed}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    IF  ${status_act} == ${FALSE}  Log  Value of actForceAutoReset after change is ${act_force_auto_reset_changed}.  console=true
    Perform Site Reset
    Check Commissioned Technologies  WCDMA
    Check If 2RAT
    Choose DSP For Crash  WCDMA
    Set Fault Signature Variables For WCDMA DSP Crash
    Checking RNCid And WBTSid From IM
    ${fault_rat_auto_reset}  Copy Dictionary  ${FAULT_6707_RAT_AUTO_RST}
    Set To Dictionary  ${fault_rat_auto_reset}  fault_id=regex"6707|6708|6709"
    ${fault_rat_auto_reset_params}  Get String With Alarm Parameters  ${fault_rat_auto_reset}
    Set Test Variable  ${FAULT_PARAMETERS}  ${fault_rat_auto_reset_params}


Step2: Trigger 1st WCDMA DSP Crash
    [Documentation]  In this step WCDMA DSP crash for the 1st time will be performed.

    Log  \nStep2: Trigger 1st WCDMA DSP crash.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}
    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Check Links Status  Available
    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded
    Verify SMOD Type And Trigger DSP Crash
    Assert Alarm Active  parameters=${FAULT_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    Log  Alarm 7101 "${FAULT_6707_RAT_AUTO_RST}[fault_name]" is visible after 1st DSP crash.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30   Check All Cells
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6707_RAT_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_6707_RAT_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_6707_RAT_AUTO_RST} found in Netact.  console=true

    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  extra_info=${EXTRA_INFO}  info=${INFO}
    ...  load_name=${SW_VERSION}  minor=${MINOR}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


Step3: Site Reset To Clear Counters
    Log  \nStep3: Site reset to clear counters.  console=true
    Perform Site Reset
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}


Step4: Trigged WCDMA DSP Crash
    [Documentation]  In this step WCDMA DSP crash will be performed.

    Log  \nStep4: Trigger WCDMA DSP crash.  console=true
    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Check Links Status  Available
    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=cellsCheck
    ${cells_status}  Run Keyword In Background  Assert Every  class_name=WNCEL  parameters=operationalState=${DISABLED}  timeout=660
    ...  alias=cellsCheck

    Verify SMOD Type And Trigger DSP Crash
    Assert Alarm Active  parameters=${FAULT_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    Log  Fault 6707/6708/6709 "${FAULT_6707_RAT_AUTO_RST}[fault_name]" occured. [OK]  console=true
    ${recovery_reset}  Run Keyword And Return Status  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=240
    ${status_cells}  Run Keyword And Return Status  Collect Keyword Result  ${cells_status}  timeout=660
    Run Keyword And Continue On Failure  Teardown Admin  alias=cellsCheck
    IF  ${status_cells}
      Log  WCDMA cells were failed while fault 6707/6708/6790 occured. [OK]  console=true
    ELSE
      Set Test Restriction  WCDMA cells were not failed while fault 6707/6708/6790 occured. [NOK]
    END
    IF  ${recovery_reset}
      Log  Recovery Reset Indication was visible under FRI. [OK]  console=true
    ELSE
      Set Test Restriction  Recovery Reset Indication was not visible under FRI. [NOK]
    END


Step5: Verify Success Of Recovery Action
    [Documentation]  In this step verification of recovery action will be checked.

    Log  \nStep5: Verify success of recovery action after WCDMA DSP crash.  console=true
    Assert Alarm Inactive  parameters=${FAULT_PARAMETERS}
    Log  Fault "${FAULT_6707_RAT_AUTO_RST}[fault_name]" is not visible after recovery action.  console=true
    Log  Checking Historical Alarms for presence of 7101 Autonomous Rat Reset notification  console=true
    ${historical_alarms}  Get Historic Alarms  severity=warning
    FOR  ${element}  IN  @{historical_alarms}
        ${status7101}  Run Keyword And Return Status  Should Be Equal As Integers  ${element}[alarmId]  7101
        Exit For Loop If  ${status7101}
    END
    Should Be True  ${status7101}  Fault "${FAULT_6707_RAT_AUTO_RST}[fault_name]" is not visible in historical alarms.
    Log  Fault "${FAULT_6707_RAT_AUTO_RST}[fault_name]" is visible in historical alarms.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30   Check All Cells
    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded
    Check Links Status  Available
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6707_RAT_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_6707_RAT_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_6707_RAT_AUTO_RST} found in Netact.  console=true
    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  extra_info=${EXTRA_INFO}  info=${INFO}
    ...  load_name=${SW_VERSION}  minor=${MINOR}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


Restore Prameter And Reset
    Log  Parameter actForce(Unit)AutoReset will be changed to false.  console=true
    Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    Perform Site Reset


Check Alarm 7116
    ${fault_status_with_alaram7116}  Run Keyword And Return Status
    ...  Assert Alarm Active  alarmId=7116, faultId=regex"6707|6708|6709", alarmName="BASE STATION SERVICE PROBLEM"  timeout=300
    Should Not Be True  ${fault_status_with_alaram7116}  Alarm 7116 "BASE STATION SERVICE PROBLEM" is visible after 4th DSP crash.
    Log  Alarm 7116 "BASE STATION SERVICE PROBLEM" is NOT visible after 4th DSP crash.  console=true


TC Setup
    Common Test Setup  tc_name=FM__RAT_recovery_reset_counter_cleared_manual_site_reset
    Setup NetAct


TC Teardown
    Restore Prameter And Reset
    Teardown NetAct
    Common Test Teardown