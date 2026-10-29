*** Settings ***
Library     ../resources/extractor.py
Library     SSHLibrary
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     taf.transport.ssh  WITH NAME  ssh
Library     DateTime
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/diagnostic_check.robot



*** Variables ***
${SENDER}    1
${RECEIVER}    269554178
${SIC_MESSAGE_ID}    9236
${FID_248_active}  ${False}
${REVERT_DELTA_CHANGES}  ${False}

*** Keywords ***
TC__LOGS__CNI-96681-F_01_Full_DC_for_CP34_Uncorrectable_ECC_errors_on_SMOD
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27356
    ...  ******************
    ...  Author: Joanna Wolnicka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-04-15 - TAT-27356 - TC created, version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies Diagnostic Check with check point Id:34 Uncorrectable ECC errors.
    ...  In this case, BTS checks the runtime ECC Errors that appear on SMOD with existing fault: 248 (EFaultId_UncorrectableMemoryEccErrAl).
    ...  After Diagnostic Check is triggered by user in WebEM, fault 4681 (EFaultId_SanityCheckErrAl) is raised on BTS due to CP34 NOK.
    ...  When 248 fault ((EFaultId_UncorrectableMemoryEccErrAl) is cleared (after removing fault trigger), second Diagnostic Check should clear 4681
    ...  fault on BTS.
    ...  Content of snapshot and DC report will be checked as well.
    ...  *******************



    Set Tags    CA-LOGS    OWNER-joanna.wolnicka@nokia.com    AUTHOR-joanna.wolnicka@nokia.com
    ...    MAINTAINER-joanna.wolnicka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...    PHASE-CRT    SW-SBTS24R2    FEATURE-CNI-96681

      Step 0: Preconditions
      Step 1: Trigger FID:248
      Step 2: Check FID:248 in WebEm
      Step 3: Run Diagnostic Check with no service impact and verify results
      Step 4: Verify Checkpoint 34 Result In Snapshot
      Step 5: Clear FID:248 from BTS
      Step 6: Run Diagnostic Check with no service impact and verify results


Step 0: Preconditions
    [Documentation]
    ...   All diagnostic checkpoints except point 34 are disabled for diagnostic check.

    Log    \nStep 0: Disable all check points except of CP34    console=${True}
    ${bts_id}   bts_states.Get BTS ID
    Set Test Variable   ${BTS_ID}   ${bts_id}
    Set Test Variable   ${TRBL_MNLENT_DISTNAME}   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    diagnostic_check.Disable Diagnostic Checkpoints Except    34
    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${True}


Step 1: Trigger FID:248
    [Documentation]
    ...    This step provides to trigger fault 248

    Log    \nStep 1: Send fault 248Trigger FID:248  console=${True}
    ${faultParams}=  Create List  0  4113  2  0  0  0  0  0  0  0  0  0  0  0  0  0
    ${send_fault}=  Run keyword and return status  send_fault_ind_msg  ${SENDER}  ${RECEIVER}  248  1  fault_params=@{faultParams}
    ...  sic_message_id=${SIC_MESSAGE_ID}
    Set Test Variable  ${FID_248_active}  ${True}
    Run keyword if  ${send_fault}
    ...  Log  Fault 248 was sent. [OK]  console=${True}
    ...  ELSE
    ...  Fail  msg=Fault 248 was not sent. [NOK]


Step 2: Check FID:248 in WebEm
    [Documentation]
    ...    Check if fault 248 is available in WebEm

    Log    \nStep 2: Check FID:248 in WebEm    console=${True}
    Log  Wait up to 1 min in order to check if alarm 248 raised.  console=${True}
    ${expected_fault}=  Create Dictionary  faultId=248
    ${expected_fault}=  Create List  ${expected_fault}
    ${status}=  Run keyword and return status  Wait Until Keyword Succeeds  1 min  10 sec
    ...  bts_states.Check Active Alarms  print_alarms=${False}  expected_patterns=${expected_fault}
    Run keyword unless  ${status}  Fail  Fault 248 was not received.
    Log  Fault 248 is reported  console=${True}


Step 3: Run Diagnostic Check with no service impact and verify results
    [Documentation]
    ...   Diagnostic check is performed and result is verified to see if CP 34 status is NOK.
    ...   Presence of Fault 4681 "Diagnostic Check Error" - severity Minor is checked.

    Log    \nStep 3: Run Diagnostic Check with no service impact and verify results    console=${True}
    diagnostic_check.Perform Diagnostic Check
    diagnostic_check.Get DC Report And Check CP Result   34   NOK
    diagnostic_check.Check Alarm 4681   Active   Minor


Step 4: Verify Checkpoint 34 Result In Snapshot
    [Documentation]
    ...   In this step snapshot is downloaded, DiagnosticReport is extracted and result of checkpoint 34 is verified.

    Log    \nStep 4: Verify Checkpoint 34 Result In Snapshot   console=${True}
    Collect Snapshot
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snapshot}
    Verify Checkpoint Result In Snapshot   ${diagnostic_report_from_snapshot}


Step 5: Clear FID:248 from BTS
    [Documentation]
    ...    This step provides to clear fault 248 from BTS

    Log    \nStep 5: Clear FID:248 from BTS  console=${True}
    ${clear_faultParams}=  Create List  0  4113  2  0  0  0  0  0  0  0  0  0  0  0  0  0
    ${clear_fault}=  Run keyword and return status  send_fault_ind_msg  ${SENDER}  ${RECEIVER}  248  0  fault_params=@{clear_faultParams}
    ...  sic_message_id=${SIC_MESSAGE_ID}
    Set Test Variable  ${FID_248_active}  ${False}
    Run keyword if  ${clear_fault}
    ...  Log  Fault 248 is cleared. [OK]  console=${True}
    ...  ELSE
    ...  Fail  msg=Fault 248 is not cleared. [NOK]


Step 6: Run Diagnostic Check with no service impact and verify results
    [Documentation]
    ...   Diagnostic check is performed and result is verified to see if CP 34 status is OK.
    ...   Presence of Fault 4681 "Diagnostic Check Error" is checked - should not be visible.

    Log    \nStep 6: Run Diagnostic Check with no service impact and verify results    console=${True}
    diagnostic_check.Perform Diagnostic Check
    diagnostic_check.Get DC Report And Check CP Result   34   OK
    diagnostic_check.Check Alarm 4681   Inactive   Minor


Collect Snapshot
    [Documentation]
    ...  This keyword collects snapshot (full coverage), monitors collection status and sets path to snapshot as variable.
    Log   Collecting Snapshot   console=${True}
    ${timestamp}   Get time
    ${timestamp}   Replace String Using Regexp   ${timestamp}   (${SPACE}|:|-)  _
    Set Test Variable   ${timestamp}
    ${log_status}   Run Keyword And Ignore Error   coam.Collect snapshot   ${BTS_Files}/snapshot_${timestamp}.zip   timeout=1800
    Run Keyword If   '${log_status[0]}'=='FAIL'
    ...    Fail   Collecting snapshot failed
    ...    ELSE
    ...    Log   Full snapshot is successfully collected   console=${True}
    Set Test Variable   ${path_to_snapshot}   ${BTS_Files}/snapshot_${timestamp}.zip

Find And Extract DiagnosticReport File
    [Documentation]
    ...  This KW searches for DiagnosticReport File in Snapshot and extracts it for further verification.
    ...  |  Parameters     | Man. |  Description         |
    ...  |  snapshot_path  | Yes  |  path to Snapshot    |
    ...
    ...  *RETURN*
    ...  |  Parameters      |  Description           |
    ...  |  extracted_file  |  Path to extracted DiagnosticReport File |

    [Arguments]   ${snapshot_path}
    Log   Find and extract DiagnosticReport file   console=${True}
    ${snapshot_dict}   snapshot.Get Data From Snapshot   ${snapshot_path}
    FOR   ${key}   IN   @{snapshot_dict.keys()}
          ${MATCHES}   Get Regexp Matches   ${snapshot_dict["${key}"][0]}   .*BTS${BTS_ID}_.011_DiagnosticReport.csv.xz
          Run Keyword If   ${MATCHES}   Run Keywords
          ...   Log   DiagnosticReport file: ${MATCHES[0]} found   console=${True}
          ...   AND   Set Test Variable   ${MATCHES}   ${MATCHES}
          ...   AND   Exit For Loop
    END
    ${extracted_file}   Extract Log File   ${snapshot_path}   ${MATCHES[0]}
    Run Keyword Unless   ${MATCHES}   Fail   DiagnosticReport file not found
    [Return]   ${extracted_file}

Extract Log File
    [Documentation]
    ...  Keyword used to extract specified file from snapshot.
    ...  |  Parameters               | Man. |  Description         |
    ...  |  snapshot_path            | Yes  |  path to Snapshot    |
    ...  |  path_to_extracting_file  | Yes  |  path to Snapshot    |
    ...  *RETURN*
    ...  |  Parameters           |  Description           |
    ...  |  extracted_file_path  |  Path to extracted DiagnosticReport File |

    [Arguments]   ${snapshot_path}   ${path_to_extracting_file}
    Log   Start extracting DiagnosticReport file for further analysis   console=${True}
    unpacking.Unpack Archive Content To Directory   ${snapshot_path}   ${BTS_Files}/snapshot_${timestamp}
    ${zip_from_extract}   Get Regexp Matches   ${path_to_extracting_file}   [\\w.]+
    ${log_to_extract}   Replace String Using Regexp   ${zip_from_extract[0]}   (.zip)   ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}   ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}   ${BTS_Files}/DiagnosticReport
    ${unzipped_log_name}   Replace String Using Regexp   ${zip_from_extract[1]}   (.xz)   ${EMPTY}
    ${extracted_file_path}   Set Variable   ${BTS_Files}/DiagnosticReport/${unzipped_log_name}
    [Return]   ${extracted_file_path}

Verify Checkpoint Result In Snapshot
    [Documentation]
    ...  Keyword used to check if checkpoint 34 of diagnostic report has status 'NOK' in snapshot.
    [Arguments]   ${extracted_file_path}

    Log   Checking result of checkpoint 34 in snapshot    console=${True}
    ${CP_34_line}   OperatingSystem.Grep File   ${extracted_file_path}   Uncorrectable ECC errors
    ${CP_34_status}   String.Fetch From Right   ${CP_34_line}   ,
    Should Be Equal As Strings   ${CP_34_status}   NOK
    Log   Checkpoint 34 has status "${CP_34_status}" in snapshot (expected status: "NOK")   console=${True}

Revert Delta Changes
    [Documentation]
    ...   This keyword prepares and recommissions delta that removes excluded diagnostic checkpoints.

    Log   \nRemoving excluded diagnostic checkpoints from configuration   console=${True}
    ${delta_id}   Set Variable   remove_delta_changes
    coam.Create Delta   ${delta_id}
    coam.Append Parameter Delete To Delta   ${TRBL_MNLENT_DISTNAME}   excludedDiagnosticCheckPoints   ${delta_id}
    coam.Get Delta   ${delta_id}
    coam.Save Delta   ${BTS Files}/remove_delta_changes.json   ${delta_id}
    coam.Perform Delta Recommissioning   ${BTS Files}/remove_delta_changes.json   skip_parameter_relation_errors=${True}

Custom Test Teardown
    [Documentation]
    ...    Send proper value to clear FID:248 from BTS
    ...    Check if FID 248 is canceled from WebEm

    Run Keyword If    ${FID_248_active}    Run Keywords
    ...  Log    Cancel FID 248    console=${True}
    ...  AND  Log  Proper Payload to clear fault 248 is sent  console=${True}
    ...  AND  Step 5: Clear FID:248 from BTS
    ...  AND  Log  Wait up to 1 min in order to check if alarm 248 is canceled.  console=${True}
    ...  AND  Wait Until Keyword Succeeds    1min    10s    coam.Assert alarm inactive    faultId=248, severity=Minor
    ...  AND  Log  Fault 248 is cleared in WebEm  console=${True}
    ...  AND  Set Test Variable  ${FID_248_active}  ${False}
    Run Keyword If  ${REVERT_DELTA_CHANGES}  Run Keywords
    ...    Revert Delta Changes
    ...    AND    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${False}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Custom Test Teardown
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
