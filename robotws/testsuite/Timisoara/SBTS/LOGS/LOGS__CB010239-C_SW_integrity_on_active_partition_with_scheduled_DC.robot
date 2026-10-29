*** Settings ***
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.transport.ssh  WITH NAME  ssh
Library     ute_syslog
Library     DateTime
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/diagnostic_check.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${HASH_FILE_CHANGED}    ${False}
${SECOND_DC_EXPECTED_ERROR}    *Operation failed. ErrorCode: 69*

*** Keywords ***
TC__LOGS__CB010239-C_SW_integrity_on_active_partition_with_scheduled_DC
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-25771
    ...  *****************
    ...  Author: Damian Kotula
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies CP16: SW integrity on active partition. It should return NOK result if at least one hash signature for any file
    ...  from the active partition does not match the one from the Hash Container, or at least one checksum of any file from the active partition
    ...  does not match the one from the TargetBD, or at least one p7 signature file is missing for any file (except the hash container files)
    ...  from the active partition. Additionally, fault 4681 (Diagnostic Check Error) should be raised.
    ...  Fault will be visible as transient (30 sec) and then will be cleared.
    ...  Test also checks functionality that only one Diagnostic Check can run at the same time
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-09-06 - TC created. TAT-25771
    ...  - 2023-09-21 - Moved KWs to resource diagnostic_check: Schedule Diagnostic Check, Get Checkpoint Result For SMOD; minor impovements
    ...  - 2024-03-20 - change coam.Run Diagnostic Check timeout in accordance to updated req OM_GEN_SFS_PERF_CAP.10677
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...  LOGS__CB010239-C_SW_integrity_on_active_partition_with_scheduled_DC.png
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...   PHASE-CRT   PHASE-CRT SW-SBTS24R1

    Step 0: Preparation
    Step 1: Change Hash File And Run Scheduled Diagnostic Check
    Step 2: Restore Hash File And Run Scheduled Diagnostic Check


Step 0: Preparation
    [Documentation]
    ...   In this step necessary test variables are set. All diagnostic checkpoints except point 16 are disabled for diagnostic check.
    Log   \nStep 0: Preparation   console=${True}

    ${bts_id}   bts_states.Get BTS ID
    Set Test Variable   ${BTS_ID}   ${bts_id}
    Set Test Variable   ${TRBL_MNLENT_DISTNAME}   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    diagnostic_check.Disable Diagnostic Checkpoints Except   16

Step 1: Change Hash File And Run Scheduled Diagnostic Check
    [Documentation]
    ...   In this step file "HashContainerSignature_*.sig" on active partition of SMOD1 is modified.
    ...   Diagnostic check is scheduled and verified if finished. Diagnostic check report is checked to see if CP 16 status is NOK.
    ...   Presence of Fault 4681 "Diagnostic Check Error" - severity Warning is checked.

    Log   \nStep 1: Change Hash File And Run Scheduled Diagnostic Check   console=${True}
    Change Hash File On BTS
    diagnostic_check.Schedule Diagnostic Check
    Wait For Diagnostic Check Completion
    Get DC Report And Check CP Result   16   NOK   ${connection}
    Check If Alarm 4681 Is Present

Step 2: Restore Hash File And Run Scheduled Diagnostic Check
    [Documentation]
    ...   In this step original "HashContainerSignature_*.sig" file is restored to active partition of SMOD1.
    ...   Diagnostic check is scheduled and verified if finished. Diagnostic check report is checked to see if CP 16 status is OK.

    Log   \nStep 2: Restore Hash File And Run Scheduled Diagnostic Check   console=${True}
    Restore Hash File
    diagnostic_check.Schedule Diagnostic Check
    Wait For Diagnostic Check Completion
    ${second_connection}   coam.Connect To   name=dc_second_connection
    Get DC Report And Check CP Result   16   OK   ${second_connection}
    coam.teardown   connection=${second_connection}

Wait For Diagnostic Check Completion
    [Documentation]
    ...   This keyword is used to monitor diagnostic check start and completion by checking if specific messages appeared in syslog.
    ...   When scheduled DC is ongoing, second DC is triggered to check if it will be rejected.

    ute_syslog.Start Syslog   alias=monitoring_syslog   ip=192.168.255.126   log_dir=${BTS_Files}/monitoring_syslog   log_name=monitoring_syslog
    Log   Waiting for diagnostic check to start   console=${True}
    Wait Until Keyword Succeeds   5m   10s   Check Expected Print In Syslog   Start runDiagnosticCheck request
    Log   Scheduled diagnostic check started!   console=${True}
    Log   \nChecking functionality that only one Diagnostic Check can run at the same time.   console=${True}
    Run Keyword And Expect Error   ${SECOND_DC_EXPECTED_ERROR}   coam.Run Diagnostic Check  timeout=930
    Log   Second DC was rejected as expected.   console=${True}
    Log   Waiting for diagnostic check to finish   console=${True}
    Wait Until Keyword Succeeds   860s   10s   Check Expected Print In Syslog   change report status and reset runningOperation
    Log   Diagnostic check finished!   console=${True}
    ute_syslog.Stop Syslog   alias=monitoring_syslog

Check Expected Print In Syslog
    [Documentation]
    ...   This keyword checks if expected print is present in syslog.
    [Arguments]   ${expected_print}
    ${msg}   ute_syslog.Message Should Exist In Syslog File   regexp=${expected_print}   alias=monitoring_syslog
    [Return]   ${msg}

Change Hash File On BTS
    [Documentation]
    ...   This keyword downloads "HashContainerSignature_*.sig" file from active partition of SMOD1 to BTS_Files as backup
    ...   and modifies that file on BTS by appending new line to end of the file.

    ssh_utils.Setup SMOD Connection
    ${hash_signature_file}   ssh.Execute   ls /ffs/run/ |grep 'HashContainerSignature.*\.sig$'
    ${hash_signature_file}   Strip String   ${hash_signature_file}
    Set Test Variable   ${HASH_SIGNATURE_FILE}   ${hash_signature_file}
    ssh.Download File   /ffs/run/${hash_signature_file}   ${BTS_Files}/${hash_signature_file}
    Log   Modifying content of Hash Signature File on BTS. Original file is copied to BTS_files.   console=${True}
    ssh.Execute   echo ">>>THIS LINE BREAKS HASH<<<" >> /ffs/run/${hash_signature_file}
    Set Test Variable   ${HASH_FILE_CHANGED}   ${True}
    ssh.Disconnect

Restore Hash File
    [Documentation]
    ...   This keyword uploads original "HashContainerSignature_*.sig" file from BTS_Files to active partition of SMOD1

    ssh_utils.Setup SMOD Connection
    Log   Initial Hash Signature File will be restored on BTS   console=${True}
    ssh.Upload File   ${BTS_Files}/${hash_signature_file}   /ffs/run/${hash_signature_file}
    Set Test Variable   ${HASH_FILE_CHANGED}   ${False}
    ssh.Disconnect

Get DC Report And Check CP Result
    [Documentation]
    ...   This keyword verifies if checkpoint has expected status in latest diagnostic check report.
    [Arguments]   ${checkpoint}   ${expected_status}   ${connection}

    Log   \nVerifying if CP '${checkpoint}' has expected status '${expected_status}' in DC Report.   console=${True}
    ${diagnostic_report}   coam.Get Diagnostic Report   connection=${connection}
    ${found_checkpoint}   diagnostic_check.Get Checkpoint Result For SMOD   Primary   ${diagnostic_report}   ${checkpoint}
    diagnostic_check.Verify Checkpoints Timestamp   ${found_checkpoint}   ${DC_run_date}
    diagnostic_check.Verify CP Status   ${found_checkpoint}   ${expected_status}

Check If Alarm 4681 Is Present
    [Documentation]
    ...   This keyword verifies that fault 4681 (severity: Warning) is raised on BTS.

    Log   \nCheck If Alarm 4681 Is Present (severity: Warning).   console=${True}
    ${fault_status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   120   10
    ...   coam.Assert Alarm Active   parameters=alarmId=7115, faultId=4681, faultName="Diagnostic Check Error", severity=Warning   timeout=120
    Run Keyword If   ${fault_status}
    ...   Log   WebEM: Fault 4681 "Diagnostic Check Error" is active on BTS. [OK]   console=${True}
    ...   ELSE   Set Test Failed   WebEM: Fault 4681 "Diagnostic Check Error" is not active on BTS. [NOK]

Revert Delta Changes
    [Documentation]
    ...   This keyword prepares and recommissions delta that removes scheduled diagnostic check and excluded diagnostic checkpoints.

    Log   \nRemoving diagnostic check schedule and excluded diagnostic checkpoints from configuration   console=${True}
    ${delta_id}   Set Variable   remove_delta_changes
    coam.Create Delta   ${delta_id}
    coam.Append Parameter Delete To Delta   ${TRBL_MNLENT_DISTNAME}   diagnosticCheckSchedule   ${delta_id}
    coam.Append Parameter Delete To Delta   ${TRBL_MNLENT_DISTNAME}   excludedDiagnosticCheckPoints   ${delta_id}
    coam.Get Delta   ${delta_id}
    coam.Save Delta   ${BTS Files}/remove_delta_changes.json   ${delta_id}
    coam.Perform Delta Recommissioning   ${BTS Files}/remove_delta_changes.json   skip_parameter_relation_errors=${True}


Custom Test Teardown
    Revert Delta Changes
    Run Keyword If   ${HASH_FILE_CHANGED}
    ...  Restore Hash File

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND   Setup Scout And Send Configuration
    ...  AND   Custom Test Teardown
    ...  AND   Common Test Teardown
