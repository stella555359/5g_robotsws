*** Settings ***
Documentation   Tests for CB012370
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
Resource    ../resources/ssh_utils.robot
Resource    ../resources/ping_utils.robot
#Resource    ../resources/diagnostic_check.robot
Resource    ../resources/diagnostic_check_new.robot


*** Variables ***
${FID_6504_active}  ${False}
${ip_MSM}    192.168.255.129
${password_MSM}    oZPS0POrRieRtu
${user_name_MSM}    toor4nsn

${change_maxUsedSsdLogs_SysinfoQuota}    sed -i 's|<maxUsedSsdLogs>[^<]*</maxUsedSsdLogs>|<maxUsedSsdLogs>50</maxUsedSsdLogs>|' /tmp/SysinfoQuota.xml
${trigger_FID6504_ASOH_ASOG}    cd /ffs/run/logs/oam/asm/auditlog; fallocate -l 1.9G test1.txt # create file test1.txt
${check_trigger_FID6504_ASOGH}    ls -lah /ffs/run/logs/oam/asm/auditlog | grep test1.txt #check if trigger file is created
${decrease_size_file}    cd /ffs/run/logs/oam/asm/auditlog; chattr -i test1.txt && truncate -s 1800M test1.txt
${cancel_6504_ASOGH}    cd /ffs/run/logs/oam/asm/auditlog; chattr -i test.txt && rm test1.txt    #set variable for cancel FID 6504

${activate_new_quota}    cd /tmp; echo "sysinfo -x" | nc 0 15007
${trigger_FID6504_MSM}    cd /ffs/run/logs; fallocate -l 10000M test.txt     #set variable for trigger FID 6504
${check_trigger_FID6504}    ls -la /ffs/run/logs | grep test.txt    # variable check if trigger file is created successfully
${cancel_6504_MSM}    cd /ffs/run/logs; rm test.txt    #set variable for cancel FID 6504

${revert_maxUsedSsdLogs_SysinfoQuota}    sed -i 's|<maxUsedSsdLogs>[^<]*</maxUsedSsdLogs>|<maxUsedSsdLogs>95</maxUsedSsdLogs>|' /tmp/SysinfoQuota.xml
${REVERT_DELTA_CHANGES}  ${False}


*** Keywords ***
TC__LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27065
    ...  ******************
    ...  Author: Joanna Wolnicka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-03-04 - TAT- - TC created, version 1.0
    ...  - 2026-02-06  Dan Moldovan: Update/adjustment:decrease the size of file so that DC have space to be collected
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies Diagnostic Check from WebEM CLI with check point Id:13 Available disk space for runtime procedure.
    ...  In this case BTS checks if FID 6504 SSD almost full is available, after exceeding the quota under folder /ff/run/logs.
    ...  After DC is triggered by user in WebEM CLI, fault 4681 (EFaultId_SanityCheckErrAl) is raised on BTS. Fault is visible as transient (30 sec)
    ...  and then is cleared. Afterwards trigger for fault 6504 SSD almost full is cleared from BTS and second DC from WebEM CLI will clear
    ...  the NOK results in report for CP13. Content of snapshot and DC report will be checked.
    ...  *******************


    Set Tags    CA-LOGS    OWNER-joanna.wolnicka@nokia.com    AUTHOR-joanna.wolnicka@nokia.com
    ...    MAINTAINER-joanna.wolnicka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...    PHASE-CRT    SW-SBTS24R2    FEATURE-CB012370-A

      Step 0: Preconditions
      Step 1: Trigger FID:6504
      Step 2: Check FID:6504 in WebEm
      Step 3: Run Diagnostic Check with no service impact and verify results
      Step 4: Verify Diagnostic Check Result In Snapshot
      Step 5: Clear FID:6504 from BTS
      Step 6: Run Diagnostic Check with no service impact and verify results
      Step 7: Verify Checkpoint 13 Result In Snapshot


Step 0: Preconditions
    [Documentation]
    ...   All diagnostic checkpoints except point 13 are disabled for diagnostic check.

    Log    \nStep 0: disable all check points except of CP13    console=${True}
    ${bts_id}   bts_states.Get BTS ID
    Set Test Variable   ${BTS_ID}   ${bts_id}
    Set Test Variable   ${TRBL_MNLENT_DISTNAME}   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    diagnostic_check_new.Disable Diagnostic Checkpoints Except    13
    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${True}


Step 1: Trigger FID:6504
    [Documentation]
    ...    connect via SSH to MSM and create file for exceed the quota on folder ffs/run/logs

    Log    \nStep 1: Trigger FID:6504  console=${True}
    SSHLibrary.Open Connection    ${ip_MSM}
    SSHLibrary.Login    ${user_name_MSM}    ${password_MSM}
    ${sm_variant}  Get SMOD Variant
    ${sm_variant}  Set Variable  ${sm_variant[0]}
    Run Keyword If  '${sm_variant}'=='ASOG' or '${sm_variant}'=='ASOH'  Run Keywords
    ...  SSHLibrary.Execute Command    ${change_maxUsedSsdLogs_SysinfoQuota}
    ...  AND  SSHLibrary.Execute Command    ${activate_new_quota}
    Run Keyword If  '${sm_variant}'=='ASOG' or '${sm_variant}'=='ASOH'
    ...  SSHLibrary.Execute Command    ${trigger_FID6504_ASOH_ASOG}
    ...  ELSE
    ...  SSHLibrary.Execute Command    ${trigger_FID6504_MSM}
    Run Keyword If  '${sm_variant}'=='ASOG' or '${sm_variant}'=='ASOH'
    ...  Set Test Variable  ${check_trigger}    ${check_trigger_FID6504_ASOGH}
    ...  ELSE
    ...  Set Test Variable  ${check_trigger}    ${check_trigger_FID6504}
    ${print_trigger_FID6504}    SSHLibrary.Execute Command    ${check_trigger}
    Set Test Variable  ${FID_6504_active}  ${True}
    ${isEmpty}  Get length  ${print_trigger_FID6504}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  File ${print_trigger_FID6504} not created.  ${TRUE}
    ...  ELSE  Log  File ${print_trigger_FID6504} was created successfully.    console=${True}


Step 2: Check FID:6504 in WebEm
    [Documentation]
    ...    Check if FID 6504 is available in WebEm

    Log    \Step 2: Check FID:6504 in WebEm    console=${True}
    Log  Wait up to 15 min in order to check if alarm 6504 raised.  console=${True}
    ${expected_fault}=  Create Dictionary  faultId=6504
    ${expected_fault}=  Create List  ${expected_fault}
    ${status}=  Run keyword and return status  Wait Until Keyword Succeeds  15 min  30 sec
    ...  bts_states.Check Active Alarms  print_alarms=${False}  expected_patterns=${expected_fault}
    Run keyword unless  ${status}  Fail  Fault 6504 was not received.
    Log  Fault 6504 is reported  console=${True}


Step 3: Run Diagnostic Check with no service impact and verify results
    [Documentation]
    ...   Diagnostic check is performed and result is verified.
    ...   Presence of Fault 4681 "Diagnostic Check Error" - severity Warning is checked.

    ${sm_variant}  Get SMOD Variant
    ${sm_variant}  Set Variable  ${sm_variant[0]}

    Log    \Step 3: Run Diagnostic Check with no service impact and verify results    console=${True}
    log to console     Decrease file so that DC can fit
    SSHLibrary.Open Connection    ${ip_MSM}
    SSHLibrary.Login    ${user_name_MSM}    ${password_MSM}
    SSHLibrary.Execute Command    ${decrease_size_file}
    diagnostic_check_new.Perform Diagnostic Check
    diagnostic_check_new.Check Alarm 4681   Active   Warning
    Run Keyword If  '${sm_variant}'=='ASOG' or '${sm_variant}'=='ASOH'
    ...  diagnostic_check_new.Get DC Report And Check CP Result   13   Check point failure

Step 4: Verify Diagnostic Check Result In Snapshot
    [Documentation]
    ...   In this step snapshot is downloaded, DiagnosticReport is extracted and verified (should be empty, because lack of SSD disc space).

    Log   \nStep 4: Verify Diagnostic Check Result In Snapshot   console=${True}
    ${sm_variant}  Get SMOD Variant
    ${sm_variant}  Set Variable  ${sm_variant[0]}
    Collect Snapshot
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snapshot}
    Run Keyword If  '${sm_variant}'=='ASOG' or '${sm_variant}'=='ASOH'
    ...  Verify Checkpoint 13 NOK In Snapshot   ${diagnostic_report_from_snapshot}
    ...  ELSE
    ...  Verify If Diagnostic Report Is Empty   ${diagnostic_report_from_snapshot}


Step 5: Clear FID:6504 from BTS
    [Documentation]
    ...    In this step delete file test.txt from /ffs/run/logs
    ...    Check if FID 6504 is canceled from WebEm

    ${sm_variant}  Get SMOD Variant
    ${sm_variant}  Set Variable  ${sm_variant[0]}

    Log   \nStep 5: Clear FID:6504 from BTS   console=${True}
    Run Keyword If  '${sm_variant}'=='ASOG' or '${sm_variant}'=='ASOH'
    ...  SSHLibrary.Execute Command    ${cancel_6504_ASOGH}
    ...  ELSE
    ...  SSHLibrary.Execute Command  ${cancel_6504_MSM}
#    Run Keyword If  '${sm_variant}'=='ASOG' or '${sm_variant}'=='ASOH'  Run Keywords
#    ...  SSHLibrary.Execute Command    ${revert_maxUsedSsdLogs_SysinfoQuota}
#    ...  AND  SSHLibrary.Execute Command    ${activate_new_quota}
    SSHLibrary.Close Connection
    Log  Wait up to 15 min in order to check if alarm 6504 is canceled.  console=${True}
    Wait Until Keyword Succeeds    15min    10s    coam.Assert alarm inactive    faultId=6504, severity=Minor
    Log  Fault 6504 is cleared in WebEm  console=${True}
    Set Test Variable  ${FID_6504_active}  ${False}


Step 6: Run Diagnostic Check with no service impact and verify results
    [Documentation]
    ...   Diagnostic check is performed and result is verified to see if CP 13 status is OK.
    ...   Presence of Fault 4681 "Diagnostic Check Error" is checked - should not be visible.

    Log    \Step 6: Run Diagnostic Check with no service impact and verify results    console=${True}
    diagnostic_check_new.Perform Diagnostic Check
    diagnostic_check_new.Get DC Report And Check CP Result   13   Check point successful
    diagnostic_check_new.Check Alarm 4681   Inactive   Warning


Step 7: Verify Checkpoint 13 Result In Snapshot
    [Documentation]
    ...   In this step snapshot is downloaded, DiagnosticReport is extracted and result of checkpoint 13 is verified.

    Log   \nStep 7: Verify Checkpoint 13 Result In Snapshot   console=${True}
    Collect Snapshot
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snapshot}
    Verify Checkpoint Result In Snapshot   ${diagnostic_report_from_snapshot}


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

Verify If Diagnostic Report Is Empty
    [Documentation]
    ...  Keyword used to check if diagnostic report is empty (because of no available disk space on BTS).
    [Arguments]   ${extracted_file_path}

    Log   Checking if report is empty    console=${True}
    OperatingSystem.File Should Be Empty   ${extracted_file_path}   DC report is not empty
    Log   Diagnostic check report file is empty in snapshot   console=${True}

Verify Checkpoint Result In Snapshot
    [Documentation]
    ...  Keyword used to check if checkpoint 13 of diagnostic report has status 'Check point successful' in snapshot.
    [Arguments]   ${extracted_file_path}

    Log   Checking result of checkpoint 13 in snapshot    console=${True}
    ${CP_13_line}   OperatingSystem.Grep File   ${extracted_file_path}   Available disk space for runtime procedure
    ${CP_13_status}   String.Fetch From Left   ${CP_13_line}   ,
    Should Be Equal As Strings   ${CP_13_status}   Check point successful
    Log   Checkpoint 13 has status "${CP_13_status}" in snapshot (expected status: "Check point successful")   console=${True}

Verify Checkpoint 13 NOK In Snapshot
    [Documentation]
    ...  Keyword used to check if checkpoint 13 of diagnostic report has status 'Check point successful' in snapshot.
    [Arguments]   ${extracted_file_path}

    Log   Checking result of checkpoint 13 in snapshot    console=${True}
    ${CP_13_line}   OperatingSystem.Grep File   ${extracted_file_path}   Available disk space for runtime procedure
    ${CP_13_status}   String.Fetch From Left   ${CP_13_line}   ,
    Should Be Equal As Strings   ${CP_13_status}   Check point failure
    Log   Checkpoint 13 has status "${CP_13_status}" in snapshot (expected status: "Check point failure")   console=${True}

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
    ...    delete file test.txt from /ffs/run/logs
    ...    Check if FID 6504 is canceled from WebEm

    Run Keyword If    ${FID_6504_active}    Run Keywords
    ...  Log    Cancel FID 6504    console=${True}
    ...  AND  Log  Delete file test.txt from /ffs/run/logs.  console=${True}
    ...  AND  Cancel FID 6504
#    ...  AND  SSHLibrary.Execute Command  ${revert_maxUsedSsdLogs_SysinfoQuota}
#    ...  AND  SSHLibrary.Execute Command    ${activate_new_quota}
    ...  AND  SSHLibrary.Close Connection
    ...  AND  Log  Wait up to 15 min in order to check if alarm 6504 is canceled.  console=${True}
    ...  AND  Wait Until Keyword Succeeds    15min    10s    coam.Assert alarm inactive    faultId=6504, severity=Minor
    ...  AND  Log  Fault 6504 is cleared in WebEm  console=${True}
    ...  AND  Set Test Variable  ${FID_6504_active}  ${False}
    Run Keyword If  ${REVERT_DELTA_CHANGES}  Run Keywords
    ...    Revert Delta Changes
    ...    AND    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${False}

Cancel FID 6504
    ${sm_variant}  Get SMOD Variant
    ${sm_variant}  Set Variable  ${sm_variant[0]}
    Run Keyword If  '${sm_variant}'=='ASOG' or '${sm_variant}'=='ASOH'
    ...  SSHLibrary.Execute Command    ${cancel_6504_ASOGH}
    ...  ELSE
    ...  SSHLibrary.Execute Command  ${cancel_6504_MSM}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Custom Test Teardown
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
