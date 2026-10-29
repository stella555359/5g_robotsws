*** Settings ***
Documentation  Test for CB010788-SR-A
Library     ../resources/extractor.py
Library     SSHLibrary
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     taf.transport.ssh  WITH NAME  ssh
Library     DateTime
Library     OperatingSystem
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/diagnostic_check_new.robot
Resource    ../resources/suppress.robot
Resource    ../resources/ecc_errors.robot

*** Variables ***
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${FID_248_active}  ${False}
#${FID_250_active}  ${False}
${REVERT_ALLOW_DELTA_CHANGES}  ${False}
${REVERT_SUPPRESS_DELTA_CHANGES}  ${False}
#${REVERT_DC_DELTA_CHANGES}  ${False}
#${REVERT_NOTE_DELTA_CHANGES}  ${False}

*** Keywords ***
TC__LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    [Documentation]
    ...  ******************
    ...  Author: Andrei Maria
    ...  ******************
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-03-13 - TC created, version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  In these case, BTS checks the runtime ECC Errors that appear on BBMOD with existing faults: 248 and 250 (EFaultId_UncorrectableMemoryEccErrAl
    ...  and EFaultId_MemoryECCErrOccurredAl). When 248 and 250 faults ((EFaultId_UncorrectableMemoryEccErrAl and EFaultId_MemoryECCErrOccurredAl)
    ...  are active in WebEM, alarm suppression framework introduced by CB010788 will suppress these faults. When 248 and 250 faults
    ...  ((EFaultId_UncorrectableMemoryEccErrAl and EFaultId_MemoryECCErrOccurredAl) are listed in Suppressed Alarms list, alarm suppression
    ...  framework display back these faults. Information about ECC memory error is checked in logs. Content of snapshot will be checked as well.
    ...  *******************

    [Arguments]    ${FSP_ID}    ${board_pos}    ${SMOD_side}

    Set Tags    CA-LOGS    OWNER-andrei.maria@nokia.com    AUTHOR-andrei.maria@nokia.com
    ...    MAINTAINER-andrei.maria@nokia.com    GROUP_IN_CHARGE-TSR1_7_Vrf
    ...    PHASE-CRT    SW-SBTS25R2    FEATURE-CB010788-SR-A

      Set Test Variable    ${FSP_ID_test}    ${FSP_ID}
      Set Test Variable    ${board_pos_test}    ${board_pos}
      Set Test Variable    ${SMOD_side_test}    ${SMOD_side}
      Step 0: Preconditions
      Step 1: Trigger FID:248
      Step 2: Check FID:248 in WebEm
      Step 3: Check if ECC UE counter is incremented as expected
      Step 4: Configure ALARMSUPP to Suppress FID:248
      Step 5: Get Suppressed Alarms list
#      Step 6: Run Diagnostic Check with no service impact and verify results
      Step 7: Collect Snapshot
#      Step 8: Verify Checkpoint 34 Result In Snapshot
      Step 9: Extract blackbox ECC UE file from Snapshot
      Step 10: Check If blackbox ECC UE file Content from Snapshot is correct
      Step 11: Extract RawSuppressedAlarmHistory file from Snapshot
      Step 12: Check If RawSuppressedAlarmHistory file Content from Snapshot is correct
      Step 13: Configure ALARMSUPP to Allow FID:248
      Step 14: Check FID:248 in WebEm
      Step 15: Get Suppressed Alarms list
#      Step 16: Run Diagnostic Check with no service impact and verify results
      Step 17: Collect Snapshot
#      Step 18: Verify Checkpoint 34 Result In Snapshot
      Step 19: Extract RawSuppressedAlarmHistory file from Snapshot
      Step 20: Check If RawSuppressedAlarmHistory file Content from Snapshot is correct
      Step 21: Clear FID:248 from BTS
#      Step 22: Run Diagnostic Check with no service impact and verify results

Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    Step 0: Preconditions    console=${True}

    Check Unexpected Alarms  skip_fault=61524,61649,4654,4655,61652
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable    ${BTS_ID}    ${btsid}
    Set Test Variable   ${TRBL_MNLENT_DISTNAME}   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
#    diagnostic_check_new.Disable Diagnostic Checkpoints Except    34
#    Set Test Variable    ${REVERT_DC_DELTA_CHANGES}  ${True}
#    Configure NOTE to unhide suppressed faults    P5N3
#    Set Test Variable    ${REVERT_NOTE_DELTA_CHANGES}  ${True}
    Get ECC UE file from BBMOD    FSP_ID=${FSP_ID_test}
    Analyze Initial blackbox ECC UE file

Step 1: Trigger FID:248
    Trigger FID:248 on BBMOD    FSP_ID=${FSP_ID_test}

Step 2: Check FID:248 in WebEm
    Check FID in WebEm    fid=248
#    Check FID in WebEm    fid=250

Step 3: Check if ECC UE counter is incremented as expected
    Get ECC UE file from BBMOD    FSP_ID=${FSP_ID_test}
    Analyze blackbox ECC UE file after FID:248 triggering

Step 4: Configure ALARMSUPP to Suppress FID:248
    Configure ALARMSUPP to Suppress FID:248
    Set Test Variable    ${REVERT_SUPPRESS_DELTA_CHANGES}  ${True}
    Check Unexpected Alarms  skip_fault=61524,61649,4654,4655,61652

Step 5: Get Suppressed Alarms list
    Wait Until Keyword Succeeds    1min    10s    Check If FID:248 from BBMOD is Suppressed in RawSuppressedAlarmHistory file

Step 6: Run Diagnostic Check with no service impact and verify results
    [Documentation]
    ...   Diagnostic check is performed and result is verified to see if CP 34 status is Check point failure.
    ...   Presence of Fault 4681 "Diagnostic Check Error" - severity Minor is checked.

    Log    \nRun Diagnostic Check with no service impact and verify results    console=${True}
    diagnostic_check_new.Perform Diagnostic Check
    diagnostic_check_new.Get DC Report And Check CP Result   34   Check point failure
    diagnostic_check_new.Check Alarm 4681   Active   Minor

Step 7: Collect Snapshot
    Snapshot Collection

Step 8: Verify Checkpoint 34 Result In Snapshot
    [Documentation]
    ...   In this step snapshot is downloaded, DiagnosticReport is extracted and result of checkpoint 34 is verified.

    Log    \nVerify Checkpoint 34 Result In Snapshot   console=${True}
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snap_1}
    Verify Checkpoint Result In Snapshot   ${diagnostic_report_from_snapshot}

Step 9: Extract blackbox ECC UE file from Snapshot
    Extract blackbox ECC file from Snapshot    board_pos=${board_pos_test}    ecc_type=ue

Step 10: Check If blackbox ECC UE file Content from Snapshot is correct
    Check If blackbox ECC file Content from Snapshot is correct    ecc_type=ue

Step 11: Extract RawSuppressedAlarmHistory file from Snapshot
    Extract RawSuppressedAlarmHistory file from Snapshot

Step 12: Check If RawSuppressedAlarmHistory file Content from Snapshot is correct
    ${filename}=    OperatingSystem.Run    ls ${path_to_SuppAlarm_file_from_Snapshot}/
    ${filepath}=    Set Variable    ${path_to_SuppAlarm_file_from_Snapshot}/${filename.strip()}
    Wait Until Keyword Succeeds    1min    10s    Check if BBMOD Fault is Suppressed
    ...    RawSuppressedAlarmsFile=${filepath}    fid=248    BBMOD_pos=${board_pos_test}
#    Wait Until Keyword Succeeds    1min    10s    Check if BBMOD Fault is Suppressed
#    ...    RawSuppressedAlarmsFile=${filepath}    fid=250    BBMOD_pos=${board_pos_test}

Step 13: Configure ALARMSUPP to Allow FID:248
    Configure ALARMSUPP to Allow FID:248
    Set Test Variable    ${REVERT_ALLOW_DELTA_CHANGES}  ${True}

Step 14: Check FID:248 in WebEm
    Check FID in WebEm    fid=248
#    Check FID in WebEm    fid=250

Step 15: Get Suppressed Alarms list
    Wait Until Keyword Succeeds    1min    10s    Check If FID:248 from BBMOD is NOT Suppressed in RawSuppressedAlarmHistory file

Step 16: Run Diagnostic Check with no service impact and verify results
    [Documentation]
    ...   Diagnostic check is performed and result is verified to see if CP 34 status is Check point failure.
    ...   Presence of Fault 4681 "Diagnostic Check Error" - severity Minor is checked.

    Log    \nRun Diagnostic Check with no service impact and verify results    console=${True}
    diagnostic_check_new.Perform Diagnostic Check
    diagnostic_check_new.Get DC Report And Check CP Result   34   Check point failure
    diagnostic_check_new.Check Alarm 4681   Active   Minor

Step 17: Collect Snapshot
    Snapshot Collection

Step 18: Verify Checkpoint 34 Result In Snapshot
    [Documentation]
    ...   In this step snapshot is downloaded, DiagnosticReport is extracted and result of checkpoint 34 is verified.

    Log    \nVerify Checkpoint 34 Result In Snapshot   console=${True}
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snap_1}
    Verify Checkpoint Result In Snapshot   ${diagnostic_report_from_snapshot}

Step 19: Extract RawSuppressedAlarmHistory file from Snapshot
    Extract RawSuppressedAlarmHistory file from Snapshot

Step 20: Check If RawSuppressedAlarmHistory file Content from Snapshot is correct
    ${filename}=    OperatingSystem.Run    ls ${path_to_SuppAlarm_file_from_Snapshot}/
    ${filepath}=    Set Variable    ${path_to_SuppAlarm_file_from_Snapshot}/${filename.strip()}
    Wait Until Keyword Succeeds    1min    10s    Check if BBMOD Fault is NOT Suppressed
    ...    RawSuppressedAlarmsFile=${filepath}    fid=248    BBMOD_pos=${board_pos_test}
#    Wait Until Keyword Succeeds    1min    10s    Check if BBMOD Fault is NOT Suppressed
#    ...    RawSuppressedAlarmsFile=${filepath}    fid=250    BBMOD_pos=${board_pos_test}

Step 21: Clear FID:248 from BTS
    Clear FID from BTS    fid=248    board_pos=${board_pos_test}    SMOD_side=${SMOD_side_test}
#    Clear FID from BTS    fid=250    board_pos=${board_pos_test}    SMOD_side=${SMOD_side_test}

Step 22: Run Diagnostic Check with no service impact and verify results
    [Documentation]
    ...   Diagnostic check is performed and result is verified to see if CP 34 status is Check point successful.
    ...   Presence of Fault 4681 "Diagnostic Check Error" is checked - should not be visible.

    Log    \nRun Diagnostic Check with no service impact and verify results    console=${True}
    diagnostic_check_new.Perform Diagnostic Check
    diagnostic_check_new.Get DC Report And Check CP Result   34   Check point successful
    diagnostic_check_new.Check Alarm 4681   Inactive   Minor

Check If FID:248 from BBMOD is Suppressed in RawSuppressedAlarmHistory file
    Get RawSuppressedAlarmHistory file
    Check if BBMOD Fault is Suppressed    fid=248    BBMOD_pos=${board_pos_test}
#    Check if BBMOD Fault is Suppressed    fid=250    BBMOD_pos=${board_pos_test}

Check If FID:248 from BBMOD is NOT Suppressed in RawSuppressedAlarmHistory file
    Get RawSuppressedAlarmHistory file
    Check if BBMOD Fault is NOT Suppressed    fid=248    BBMOD_pos=${board_pos_test}
#    Check if BBMOD Fault is NOT Suppressed    fid=250    BBMOD_pos=${board_pos_test}

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
    ...  Keyword used to check if checkpoint 34 of diagnostic report has status 'Check point failure' in snapshot.
    [Arguments]   ${extracted_file_path}

    Log   Checking result of checkpoint 34 in snapshot    console=${True}
    ${CP_34_line}   OperatingSystem.Grep File   ${extracted_file_path}   Uncorrectable ECC errors
    ${CP_34_status}   String.Fetch From Left   ${CP_34_line}   ,
    Should Be Equal As Strings   ${CP_34_status}   Check point failure
    Log   Checkpoint 34 has status "${CP_34_status}" in snapshot (expected status: "Check point failure")   console=${True}

Revert CP:34 Delta Changes
    [Documentation]
    ...   This keyword prepares and recommissions delta that removes excluded diagnostic checkpoints.

    Log   \nRemoving excluded diagnostic checkpoints from configuration   console=${True}
    ${delta_id}   Set Variable   remove_delta_changes
    coam.Create Delta   ${delta_id}
    coam.Append Parameter Delete To Delta   ${TRBL_MNLENT_DISTNAME}   excludedDiagnosticCheckPoints   ${delta_id}
    coam.Get Delta   ${delta_id}
    coam.Save Delta   ${BTS Files}/remove_delta_changes.json   ${delta_id}
    coam.Perform Delta Recommissioning   ${BTS Files}/remove_delta_changes.json   skip_parameter_relation_errors=${True}

TC Setup
    Common Test Setup

Custom TC Teardown
    [Documentation]
    ...    Send proper value to clear FID:248 from BTS
    ...    Check if FID 248 is canceled from WebEm

    Run Keyword If    ${FID_248_active}    Run Keywords
    ...  Log    Cancel FID 248    console=${True}
    ...  AND  Log  Proper Payload to clear fault 248 is sent  console=${True}
    ...  AND  Clear FID from BTS    fid=248    board_pos=${board_pos_test}    SMOD_side=${SMOD_side_test}
    ...  AND  Log  Wait up to 1 min in order to check if alarm 248 is canceled.  console=${True}
    ...  AND  Wait Until Keyword Succeeds    1min    10s    coam.Assert alarm inactive    faultId=248, severity=Minor
    ...  AND  Log  Fault 248 is cleared in WebEm  console=${True}
    ...  AND  Set Suite Variable  ${FID_248_active}  ${False}
#    ...  AND  Delete ecc_ue file from BBMOD    FSP_ID=${FSP_ID_test}
#    ...  AND  Delete blackbox_ecc_ue file from BBMOD    FSP_ID=${FSP_ID_test}
#    ...  AND  Perform BBMOD reset    FSP_ID=${FSP_ID_test}
#    Run Keyword If    ${FID_250_active}    Run Keywords
#    ...  Log    Cancel FID 250    console=${True}
#    ...  AND  Log  Proper Payload to clear fault 250 is sent  console=${True}
#    ...  AND  Clear FID from BTS    fid=250    board_pos=${board_pos_test}    SMOD_side=${SMOD_side_test}
#    ...  AND  Log  Wait up to 1 min in order to check if alarm 250 is canceled.  console=${True}
#    ...  AND  Wait Until Keyword Succeeds    1min    10s    coam.Assert alarm inactive    faultId=250, severity=Minor
#    ...  AND  Log  Fault 250 is cleared in WebEm  console=${True}
#    ...  AND  Set Suite Variable  ${FID_250_active}  ${False}
#    Run Keyword If  ${REVERT_NOTE_DELTA_CHANGES}  Run Keywords
#    ...    Revert Note Delta Changes
#    ...    AND    Set Test Variable    ${REVERT_NOTE_DELTA_CHANGES}  ${False}
    Run Keyword If  ${REVERT_ALLOW_DELTA_CHANGES}  Run Keywords
    ...    Revert Allow Delta Changes for FID:248
    ...    AND    Set Test Variable    ${REVERT_ALLOW_DELTA_CHANGES}  ${False}
    Run Keyword If  ${REVERT_SUPPRESS_DELTA_CHANGES}  Run Keywords
    ...    Revert Suppress Delta Changes for FID:248
    ...    AND    Set Test Variable    ${REVERT_SUPPRESS_DELTA_CHANGES}  ${False}
    Clean up ECC UE files from BBMOD    FSP_ID=${FSP_ID_test}    BBMOD_pos=${board_pos_test}
#    Run Keyword If  ${REVERT_DC_DELTA_CHANGES}  Run Keywords
#    ...    Revert CP:34 Delta Changes
#    ...    AND    Set Test Variable    ${REVERT_DC_DELTA_CHANGES}  ${False}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Custom TC Teardown
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
