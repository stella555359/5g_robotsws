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
Resource    ../resources/diagnostic_check.robot
Resource    ../resources/suppress.robot
Resource    ../resources/ecc_errors.robot

*** Variables ***
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${FID_247_active}  ${False}
${REVERT_ALLOW_DELTA_CHANGES}  ${False}
${REVERT_SUPPRESS_DELTA_CHANGES}  ${False}
${REVERT_NOTE_DELTA_CHANGES}  ${False}

*** Keywords ***
TC__LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD
    [Documentation]
    ...  ******************
    ...  Author: Andrei Maria
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-03-13 - TC created, version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  In this case, BTS checks the runtime ECC Errors that appear on BBMOD with existing fault: 247 (EFaultId_CorrectableMemoryEccErrAl).
    ...  When 247 fault ((EFaultId_CorrectableMemoryEccErrAl) is active in WebEM, alarm suppression framework introduced by CB010788 will
    ...  suppress this fault. When 247 fault ((EFaultId_CorrectableMemoryEccErrAl) is listed in Suppressed Alarms list, alarm suppression framework
    ...  display back this fault.
    ...  Information about ECC memory error is checked in logs. Content of snapshot will be checked as well.
    ...  *******************

    [Arguments]   ${FSP_ID}    ${board_pos}    ${SMOD_side}

    Set Tags    CA-LOGS    OWNER-andrei.maria@nokia.com    AUTHOR-andrei.maria@nokia.com
    ...    MAINTAINER-andrei.maria@nokia.com    GROUP_IN_CHARGE-TSR1_7_Vrf
    ...    PHASE-CRT    SW-SBTS25R2    FEATURE-CB010788-SR-A

      Set Test Variable    ${FSP_ID_test}    ${FSP_ID}
      Set Test Variable    ${board_pos_test}    ${board_pos}
      Set Test Variable    ${SMOD_side_test}    ${SMOD_side}
      Step 0: Preconditions
      Step 1: Trigger FID:247
      Step 2: Check FID:247 in WebEm
      Step 3: Check if ECC CE counter is incremented as expected
      Step 4: Configure ALARMSUPP to Suppress FID:247
      Step 5: Get Suppressed Alarms list
      Step 6: Collect Snapshot
      Step 7: Extract blackbox ECC CE file from Snapshot
      Step 8: Check If blackbox ECC CE file Content from Snapshot is correct
      Step 9: Extract RawSuppressedAlarmHistory file from Snapshot
      Step 10: Check If RawSuppressedAlarmHistory file Content from Snapshot is correct
      Step 11: Configure ALARMSUPP to Allow FID:247
      Step 12: Check FID:247 in WebEm
      Step 13: Get Suppressed Alarms list
      Step 14: Collect Snapshot
      Step 15: Extract RawSuppressedAlarmHistory file from Snapshot
      Step 16: Check If RawSuppressedAlarmHistory file Content from Snapshot is correct
      Step 17: Clear FID:247 from BTS

Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    Step 0: Preconditions    console=${True}

    Check Unexpected Alarms  skip_fault=61524,61649,4654,4655,61652
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable    ${BTS_ID}    ${btsid}
    Configure NOTE to unhide suppressed faults    P1I8
    Set Test Variable    ${REVERT_NOTE_DELTA_CHANGES}  ${True}
    Prepare TL for FID:247 alarm triggering
    Get ECC CE file from BBMOD    FSP_ID=${FSP_ID_test}
    Analyze Initial blackbox ECC CE file

Step 1: Trigger FID:247
    Trigger FID:247 on BBMOD    FSP_ID=${FSP_ID_test}

Step 2: Check FID:247 in WebEm
    Check FID in WebEm    fid=247

Step 3: Check if ECC CE counter is incremented as expected
    Get ECC CE file from BBMOD    FSP_ID=${FSP_ID_test}
    Analyze blackbox ECC CE file after FID:247 triggering

Step 4: Configure ALARMSUPP to Suppress FID:247
    Configure ALARMSUPP to Suppress FID:247
    Set Test Variable    ${REVERT_SUPPRESS_DELTA_CHANGES}  ${True}
    Check Unexpected Alarms  skip_fault=61524,61649,4654,4655,61652

Step 5: Get Suppressed Alarms list
    Wait Until Keyword Succeeds    1min    10s    Check If FID:247 from BBMOD is Suppressed in RawSuppressedAlarmHistory file

Step 6: Collect Snapshot
    Snapshot Collection

Step 7: Extract blackbox ECC CE file from Snapshot
    Extract blackbox ECC file from Snapshot    board_pos=${board_pos_test}    ecc_type=ce

Step 8: Check If blackbox ECC CE file Content from Snapshot is correct
    Check If blackbox ECC file Content from Snapshot is correct    ecc_type=ce

Step 9: Extract RawSuppressedAlarmHistory file from Snapshot
    Extract RawSuppressedAlarmHistory file from Snapshot

Step 10: Check If RawSuppressedAlarmHistory file Content from Snapshot is correct
    ${filename}=    OperatingSystem.Run    ls ${path_to_SuppAlarm_file_from_Snapshot}/
    ${filepath}=    Set Variable    ${path_to_SuppAlarm_file_from_Snapshot}/${filename.strip()}
    Wait Until Keyword Succeeds    1min    10s    Check if BBMOD Fault is Suppressed
    ...    RawSuppressedAlarmsFile=${filepath}    fid=247    BBMOD_pos=${board_pos_test}

Step 11: Configure ALARMSUPP to Allow FID:247
    Configure ALARMSUPP to Allow FID:247
    Set Test Variable    ${REVERT_ALLOW_DELTA_CHANGES}  ${True}

Step 12: Check FID:247 in WebEm
    Check FID in WebEm    fid=247

Step 13: Get Suppressed Alarms list
    Wait Until Keyword Succeeds    1min    10s    Check If FID:247 from BBMOD is NOT Suppressed in RawSuppressedAlarmHistory file

Step 14: Collect Snapshot
    Snapshot Collection

Step 15: Extract RawSuppressedAlarmHistory file from Snapshot
    Extract RawSuppressedAlarmHistory file from Snapshot

Step 16: Check If RawSuppressedAlarmHistory file Content from Snapshot is correct
    ${filename}=    OperatingSystem.Run    ls ${path_to_SuppAlarm_file_from_Snapshot}/
    ${filepath}=    Set Variable    ${path_to_SuppAlarm_file_from_Snapshot}/${filename.strip()}
    Wait Until Keyword Succeeds    1min    10s    Check if BBMOD Fault is NOT Suppressed
    ...    RawSuppressedAlarmsFile=${filepath}    fid=247    BBMOD_pos=${board_pos_test}

Step 17: Clear FID:247 from BTS
    Clear FID from BTS    fid=247    board_pos=${board_pos_test}    SMOD_side=${SMOD_side_test}

Check If FID:247 from BBMOD is Suppressed in RawSuppressedAlarmHistory file
    Get RawSuppressedAlarmHistory file
    Check if BBMOD Fault is Suppressed    fid=247    BBMOD_pos=${board_pos_test}

Check If FID:247 from BBMOD is NOT Suppressed in RawSuppressedAlarmHistory file
    Get RawSuppressedAlarmHistory file
    Check if BBMOD Fault is NOT Suppressed    fid=247    BBMOD_pos=${board_pos_test}

TC Setup
    Common Test Setup

Custom TC Teardown
    [Documentation]
    ...    Send proper value to clear FID:247 from BTS
    ...    Check if FID 247 is canceled from WebEm

    Run Keyword If    ${FID_247_active}    Run Keywords
    ...  Log    Cancel FID 247    console=${True}
    ...  AND  Log  Proper Payload to clear fault 247 is sent  console=${True}
    ...  AND  Clear FID from BTS    fid=247    board_pos=${board_pos_test}    SMOD_side=${SMOD_side_test}
    ...  AND  Log  Wait up to 1 min in order to check if alarm 247 is canceled.  console=${True}
    ...  AND  Wait Until Keyword Succeeds    1min    10s    coam.Assert alarm inactive    faultId=247, severity=Minor
    ...  AND  Log  Fault 247 is cleared in WebEm  console=${True}
    ...  AND  Set Test Variable  ${FID_247_active}  ${False}
    Run Keyword If  ${REVERT_NOTE_DELTA_CHANGES}  Run Keywords
    ...    Revert Note Delta Changes
    ...    AND    Set Test Variable    ${REVERT_NOTE_DELTA_CHANGES}  ${False}
    Run Keyword If  ${REVERT_ALLOW_DELTA_CHANGES}  Run Keywords
    ...    Revert Allow Delta Changes for FID:247
    ...    AND    Set Test Variable    ${REVERT_ALLOW_DELTA_CHANGES}  ${False}
    Run Keyword If  ${REVERT_SUPPRESS_DELTA_CHANGES}  Run Keywords
    ...    Revert Suppress Delta Changes for FID:247
    ...    AND    Set Test Variable    ${REVERT_SUPPRESS_DELTA_CHANGES}  ${False}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Custom TC Teardown
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
