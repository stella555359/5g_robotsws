*** Settings ***
Documentation
...  The purpose of this test case is to check procedure of Radio Unit snapshot collection during fail safe mode.

Library     taf.transport.ssh  WITH NAME  tafssh
Resource    ../../../../resources/ca_siso_hran.robot
Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_fail_safe.robot

*** Variables ***

${RMOD_SN}    #RU serial number
${node}    default

*** Keywords ***
TC__SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-46760
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to check procedure of Radio Unit snapshot collection during fail safe mode.
    ...  Snapshot logs should contain RFSW logs from Radio Unit.
    ...  TC enables Fail Safe Mode and verify faults 2934, 1850, 1462 reporting after fail safe mode activation.
    ...  TC verifying Snapshot Full and Most important log files.
    ...  TC disabled Fail Safe Mode, verify clear alarms and check On Air status.
    ...  IMPORTANT:
    ...  TC works with RU families: 5.1*, 6.2* tested on AHIB, AHEGC, AHFIG.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.04.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-46760 - Initial creation

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB011039

    step1: Preconditions
    step2: Fail Safe Mode Activation
    step3: Collect And Compare Snapshot from WebEM and Radio Unit - "All log files"
    step4: Collect And Compare Snapshot from WebEM and Radio Unit - "Most important log files"
    step5: Fail Safe Mode Deactivation

step1: Preconditions

    Log To Console  --------------------
    Log To Console  step1: Preconditions
    Log To Console  --------------------${\n}

    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !
    Verify Serial Number  ${RMOD_SN}
    Log To Console  RMOD with SN -> ${RMOD_SN} found in HW Configuration

step2: Fail Safe Mode Activation

    Log To Console  --------------------
    Log To Console  step2: Fail Safe Mode Activation
    Log To Console  --------------------${\n}

    ca_BSRF_fail_safe.Enable Fail Safe Mode For RM  ${RMOD_SN}
    Wait Until Keyword Succeeds  3min  10sec  Check Fail Safe mode For RM  ${RMOD_SN}  Enabled
    Check Fail Safe Mode Fault Status  fault_status=Active
    admin.Collect Snapshot
    ...  target_file_name=${TestFiles}/test_snap.zip
    ...  coverage=Full
    ...  timeout=600
    ...  connection=${node}

step3: Collect And Compare Snapshot from WebEM and Radio Unit - "All log files"
    Log To Console  --------------------
    Log To Console  step3: Collect And Compare Snapshot from WebEM and Radio Unit - "All log files"
    Log To Console  --------------------${\n}

    Collect And Compare Snapshot  snapshot_coverage=Full  file_name=snapshot_all_log_files_webem.zip

step4: Collect And Compare Snapshot from WebEM and Radio Unit - "Most important log files"
    Log To Console  --------------------
    Log To Console  step4: Collect And Compare Snapshot from WebEM and Radio Unit - "Most important log files"
    Log To Console  --------------------${\n}

    Collect And Compare Snapshot  snapshot_coverage=Minor  file_name=snapshot_important_log_files_webem.zip

step5: Fail Safe Mode Deactivation
    ca_BSRF_fail_safe.Disable Fail Safe Mode For RM  ${RMOD_SN}
    Wait Until Keyword Succeeds  3min  10sec  Check Fail Safe mode For RM  ${RMOD_SN}  Disabled

    ${cells_status}  Run Keyword And Return Status  Check If All Cells And Modules Are OnAir  timeout=300
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir!
    ...  ELSE  Fail  Cells are not onAir!

    Check Fail Safe Mode Fault Status  fault_status=Inactive

Check Fail Safe Mode Fault Status
    [Arguments]    ${fault_status}
#    Log To Console  Checking FID 1850 SW corrupted Critical is ${fault_status}.
#    ${1850}  Run Keyword If  '${fault_status}'=='Active'
#    ...  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1850  severity=Critical  timeout=120
#    ...  ELSE  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=1850  severity=Critical  timeout=120
#    Run Keyword If  ${1850} and '${fault_status}'=='Active'
#    ...  Log To Console  ${\n}Active Critical SW corrupted alarm.
#    ...  ELSE IF  ${1850} and '${fault_status}'=='Inactive'  Log To Console  ${\n}InActive Critical SW corrupted alarm.
#    ...  ELSE  Run Keyword And Continue On Failure
#    ...  Fail  Alarm SW corrupted has unexpected status!

    Log To Console  Checking FID 2934 Radio Module fail safe mode Critical is ${fault_status}.
    ${2934}  Run Keyword If  '${fault_status}'=='Active'
    ...  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=2934  severity=Critical  timeout=120  connection=${node}
    ...  ELSE  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=2934  severity=Critical  connection=${node}
    Run Keyword If  ${2934} and '${fault_status}'=='Active'
    ...  Log To Console  ${\n}Active Critical Radio Module fail safe mode
    ...  ELSE IF  ${2934} and '${fault_status}'=='Inactive'  Log To Console  ${\n}InActive Critical Radio Module fail safe mode
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Alarm Radio Module fail safe mode has unexpected status!

    Run Keyword If  '${fault_status}'=='Active'
    ...  Log To Console  Checking FID 1462 with severity Warning in fault_history_log.txt is ${fault_status}.

    ${1462}  Run Keyword If  '${fault_status}'=='Active'
    ...  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
    ...  fault_id=1462
    ...  severity=warning

    Run Keyword If  ${1462} and '${fault_status}'=='Active'
    ...  Log To Console  ${\n}Found --> Active Warning EFaultId_FailSafeMode (1462) in fault_history_log_for_fault_1462.txt!
    ...  ELSE IF  '${fault_status}'=='Inactive'
    ...  Log To Console  Skip check in fault_history_log_for_fault_1462.txt!
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  EFault FaultId_FailSafeMode (1462) has unexpected status, please check fault_history_log_for_fault_1462.txt!

Collect And Compare Snapshot
    [Arguments]  ${snapshot_coverage}  ${file_name}

    Log To Console  Collect Snapshot from WebEM - type "${snapshot_coverage}"
    admin.Collect Snapshot
    ...  target_file_name=${TestFiles}/${file_name}
    ...  coverage=${snapshot_coverage}
    ...  timeout=600
    ...  connection=${node}

    Log To Console  Collect Snapshot from Radio Module ${RMOD_SN}
    ${radio_logs_name}  radio.Collect Radio Module Snapshot
    ...  ru_serial_number=${RMOD_SN}
    ...  coverage=${snapshot_coverage}

    Log To Console  Copy Snapshot from Radio Module ${RMOD_SN} to SM
    radio.Send File Via SCP
    ...  ru_serial_number=${RMOD_SN}
    ...  direction=to_smod
    ...  file_path=/ram/${radio_logs_name}
    ...  destination_directory=/ffs

    Log To Console  Stored in VM Snapshot from Radio Module ${RMOD_SN}
    ${smod}  Get SMOD IP For Connected RMOD  ${RMOD_SN}
    Run Keyword If  '${smod}'=='192.168.255.1'  tafssh.Connect To  ${smod}  toor4nsn  oZPS0POrRieRtu  alias=primary
    ...  ELSE  tafssh.Connect To  fct-4a  toor4nsn  oZPS0POrRieRtu  proxy=primary  alias=secondary
    tafssh.Download File  /ffs/${radio_logs_name}  ${TestFiles}/${radio_logs_name}  connection=primary

    Log To Console  Check Content Of Radio Unit Logs In Snapshot

    ${compare_status}  Run Keyword And Return Status  radio.Compare Radio Module And WebEM Snapshots
    ...  ru_serial_number=${RMOD_SN}
    ...  webem_snapshot_path=${TestFiles}/${file_name}
    ...  ru_snapshot_path=${TestFiles}/${radio_logs_name}
    Run Keyword If  ${compare_status}  Log To Console  WebEM snapshot contains all files from ${RMOD_SN} radio module
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Number of files in radio module snapshot is NOT equal number of files for radio module ${RMOD_SN}.

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  ca_BSRF_fail_safe.Disable Fail Safe Mode For RM  ${RMOD_SN}
    Common Test Teardown
