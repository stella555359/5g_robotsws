*** Settings ***
Documentation
    ...  TC__LOGS__CB010699_Not_possible_to_collect_SCREL_when_snapshot_is_ongoing
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     DateTime
Library     OperatingSystem
Library     String
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${EXPECTED_ERROR}    *Request rejected as another snapshot collection is ongoing*
${SNAPSHOT_TIMEOUT}    1800

*** Keywords ***
TC__LOGS__CB010699_Not_possible_to_collect_SCREL_when_snapshot_is_ongoing
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27531
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case verifies the functionality of rejecting SCREL when snapshot collection is ongoing.
    ...  SCREL history file is checked to ensure it contains an entry about rejected SCREL from Step 1.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 20.05.2024 - Initial creation
    ...
    Set Tags   CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R3    FEATURE-CB010699


    Step 1: Trigger Snapshot And SCREL While Snapshot Is Ongoing
    Step 2: Collect And Check SCREL History File


Step 1: Trigger Snapshot And SCREL While Snapshot Is Ongoing
    [Documentation]
    ...  In this step local Snapshot is triggered and while it's collecting SCREL is triggered.
    ...  The expected behavior is that the SCREL request should be rejected because a Snapshot collection is already in progress.
    Log  \nStep 1: Trigger Snapshot And SCREL While Snapshot Is Ongoing  console=${True}

    ${BTS_ID}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}
    Set Parameter actSysCriticalEventLogs  ${True}
    ${second_connection}  coam.Connect To  name=second_connection
    ${timestamp}  Get time
    ${timestamp}  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    coam.Run_Keyword_In_Background  Collect snapshot  ${BTS_Files}/snapshot_${timestamp}.zip
    ...  timeout=${SNAPSHOT_TIMEOUT}  connection=second_connection
    ${snapshot_status}  Query Infomodel    check //TECHREP_L-*/SNAPSHOT-* is [originator=ADMIN,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_status}  Log  Local Snapshot was triggered.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered.  ${TRUE}
    ${timestamp_screl}  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M
    Set Test Variable  ${timestamp_screl}
    Run Keyword And Expect Error  ${EXPECTED_ERROR}  coam.Collect Local SCREL  include_pmfm_data=${True}
    ...  target_file_name=${bts_files}/SCREL_${timestamp}.zip
    Log  SCREL is rejected while snapshot collection is ongoing [OK].  console=${True}

    Log  Wait max ${SNAPSHOT_TIMEOUT} seconds for local snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=ADMIN,stateInfo.usageState=Active]
    ...  timeout=${SNAPSHOT_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Local snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Local snapshot collection not finished in ${SNAPSHOT_TIMEOUT} seconds.  ${TRUE}
    OperatingSystem.File Should Exist  ${BTS_Files}/snapshot_${timestamp}.zip


Step 2: Collect And Check SCREL History File
    [Documentation]
    ...  In this step the SCREL history file is checked if it contains the entry about rejected SCREL from Step 1.

    Log  \nStep 2: Collect And Check SCREL History File  console=${True}
    coam.Get SCREL history  ${bts_files}/SCREL_history.txt
    ${screl_history}  OperatingSystem.Get File  ${bts_files}/SCREL_history.txt
    @{screl_history_lines}  Split To Lines  ${screl_history}
    ${last_entry}  Set Variable  ${screl_history_lines}[-1]
    Should Contain  ${last_entry}  "start_time":"${timestamp_screl}    msg=start time in SCREL history is not correct!
    Should Contain  ${last_entry}  "trigger_type":"ON DEMAND"    msg=trigger type in SCREL history is not correct!
    Should Contain  ${last_entry}  "trigger_originator":"ADMIN"    msg=trigger originator in SCREL history is not correct!
    Should Contain  ${last_entry}  "coverage_level":"Screl"    msg=coverage level in SCREL history is not correct!
    Should Contain  ${last_entry}  "snapshot_result":"fail"   msg=result in SCREL history is not correct!
    Should Contain  ${last_entry}  "failed_reason":"Rejected because TECHREP_L is not Idle."   msg=failed reason is not correct!
    Log  SCREL history file contains correct entry about rejected SCREL from Step 1.  console=${True}


Set Parameter actSysCriticalEventLogs
    [Documentation]
    ...  This keyword sets the parameter actSysCriticalEventLogs in FEATCADM to value passed as KW argument.
    [Arguments]  ${required_value}
    ${featcadm}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${feature_flag_status}  Query Infomodel  check //MNL_A-*/MNLENT_A-*/FEATCADM_A-* is [actSysCriticalEventLogs=${required_value}]
    ...  timeout=60  allow_negative_result=${True}
    Run Keyword If    ${feature_flag_status} != ${True}
    ...  Run Keywords  coam.Perform Parameter Recommissioning  dist_name=${featcadm}  parameter=actSysCriticalEventLogs
    ...  operation=update  value=${required_value}  skip_parameter_relation_errors=${True}
    ...  AND  Log  Parameter actSysCriticalEventLogs changed to ${required_value}  console=${True}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND  Setup Scout And Send Configuration
    ...    AND  Common Test Teardown
