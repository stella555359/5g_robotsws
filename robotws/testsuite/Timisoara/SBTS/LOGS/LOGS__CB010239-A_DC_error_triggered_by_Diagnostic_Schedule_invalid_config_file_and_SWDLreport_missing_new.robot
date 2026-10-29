*** Settings ***
Documentation  Test for CB010239
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.transport.ssh  WITH NAME  ssh
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     ute_syslog
Library     DateTime
Resource    ../resources/unpacking.robot
Resource    ../resources/ssh_utils.robot
#Resource    ../resources/diagnostic_check.robot
Resource    ../resources/diagnostic_check_new.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${CONFIG_FILES_MODIFIED}   ${False}
${SCF_MODIFIED}            ${False}

*** Keywords ***
TC__LOGS__CB010239-A_DC_error_triggered_by_Diagnostic_Schedule_invalid_config_file_and_SWDLreport_missing_new
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-25767
    ...  *****************
    ...  Author: Damian Kotula
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies Diagnostic Check with disabling and then enabling particular check points.
    ...  In this case, firstly invalid file model_5.ims2 on active partition BTS will cause the alarm (scheduled DC with enabled only CP Id:7), then
    ...  additionally missing SWDLreport.txt on active partition will return NOK for manual Diagnostic check (with two enabled CP, Id:3 and Id:7).
    ...  Both NOK situation will be triggered at one time, but their detection will be depend on what CP is enabled/disabled in Diagnostic check.
    ...  After scheduled DC fault 4681 is visible with minor severity, after second - manual DC also minor severity fault 4681 is raised.
    ...  Content of snapshot and DC report will be checked.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-10-24 - TC created. TAT-25767
    ...  - 2024-03-20 - change coam.Run Diagnostic Check timeout in accordance to updated req OM_GEN_SFS_PERF_CAP.10677
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...  LOGS__CB010239-A_DC_error_triggered_by_Diagnostic_Schedule_invalid_config_file_and_SWDLreport_missing.png
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...   PHASE-CRT   PHASE-CRT SW-SBTS23R4

    Step 0: Preparation
    Step 1: Modify Configuration Files And Run Scheduled Diagnostic Check For CP 7
    Step 2: Run Diagnostic Check For CP 7 And 3
    Step 3: Restore Configuration Files And Run Diagnostic Check For CP 7 And 3


Step 0: Preparation
    [Documentation]
    ...   In this step diagnostic checkpoints except CP 7 are disabled.

    Log   \nStep 0: Preparation   console=${True}
    ${bts_id}   bts_states.Get BTS ID
    Set Test Variable   ${BTS_ID}   ${bts_id}
    Set Test Variable   ${TRBL_MNLENT_DISTNAME}   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    diagnostic_check_new.Disable Diagnostic Checkpoints Except   7
    Set Test Variable   ${SCF_MODIFIED}   ${True}

Step 1: Modify Configuration Files And Run Scheduled Diagnostic Check For CP 7
    [Documentation]
    ...   In this step two configuration files are modified on active partition of Primary SMOD - content of "model_5.ims2" is removed
    ...   and "SWDLreport.txt" is deleted. That should cause NOK results for CP 3 and 7. Scheduled diagnostic check is performed with only CP 7.
    ...   Result of DC is verified in diagnostic report and in snapshot. Only CP 7 shall be in DC report and result should be NOK.
    ...   Presence of Fault 4681 "Diagnostic Check Error" - severity Minor is checked.

    Log   \nStep 1: Modify Configuration Files And Run Scheduled Diagnostic Check For CP 7   console=${True}
    diagnostic_check_new.Schedule Diagnostic Check
    Backup And Modify Configuration Files From Active Partition
    Wait For Diagnostic Check Completion
    diagnostic_check_new.Get DC Report And Check CP Result   7   Check point failure
    diagnostic_check_new.Check Alarm 4681   Active   Minor
    Collect Snapshot
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snapshot}
    Verify Checkpoint 7 Result In Snapshot   ${diagnostic_report_from_snapshot}

Step 2: Run Diagnostic Check For CP 7 And 3
    [Documentation]
    ...   In this step diagnostic checkpoints except CP 3 and 7 are disabled. Diagnostic check is performed for those checkpoints.
    ...   Result of DC is verified - CP 3 and 7 shall be in DC report with status NOK.
    ...   Presence of Fault 4681 "Diagnostic Check Error" - severity Minor is checked.

    Log   \nStep 2: Run Diagnostic Check For CP 7 And 3   console=${True}
    diagnostic_check_new.Disable Diagnostic Checkpoints Except   7   3
    Backup And Modify Model_5.ims2
    diagnostic_check_new.Perform Diagnostic Check
    diagnostic_check_new.Get DC Report And Check CP Result   7   Check point failure
    diagnostic_check_new.Get DC Report And Check CP Result   3   Check point failure
    diagnostic_check_new.Check Alarm 4681   Active   Minor
    Collect Snapshot
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snapshot}
    Verify CP 7 And 3 Result In Snapshot   ${diagnostic_report_from_snapshot}

Step 3: Restore Configuration Files And Run Diagnostic Check For CP 7 And 3
    [Documentation]
    ...   In this step original configuration files - "model_5.ims2" and "SWDLreport.txt" are restored to active partition of Primary SMOD.
    ...   Diagnostic check is performed for CP 3 and 7. Both checkpoints should have OK results. Fault 4681 "Diagnostic Check Error" shall be cleared.

    Log   \nStep 3: Restore Configuration Files And Run Diagnostic Check For CP 7 And 3   console=${True}
    Restore Configuration Files On Active Partition
    diagnostic_check_new.Perform Diagnostic Check
    diagnostic_check_new.Get DC Report And Check CP Result   7   Check point successful
    diagnostic_check_new.Get DC Report And Check CP Result   3   Check point successful
    diagnostic_check_new.Check Alarm 4681   Inactive   Minor


Backup And Modify Configuration Files From Active Partition
    [Documentation]
    ...   This keyword downloads files: "model_5.ims2" and "SWDLreport.txt" from active partition of Primary SMOD to BTS_Files as backup.
    ...   Content of model_5.ims2 is then modified and SWDLreport.txt is deleted from active partition.

    ssh_utils.Setup SMOD Connection
    ssh.Download File   /ffs/run/config/model_5.ims2   ${BTS_Files}/model_5.ims2
    ssh.Download File   /ffs/run/config/SWDLreport.txt   ${BTS_Files}/SWDLreport.txt
    OperatingSystem.File Should Exist   ${BTS_Files}/model_5.ims2
    OperatingSystem.File Should Exist   ${BTS_Files}/SWDLreport.txt
    Log   Modifying content of model_5.ims2 and deleting SWDLreport.txt from /ffs/run/config/ on Primary SMOD.   console=${True}
    Log   Original files are copied to BTS_files.   console=${True}
    ssh.Execute   echo "" > /ffs/run/config/model_5.ims2
    ssh.Execute   rm /ffs/run/config/SWDLreport.txt
    Set Test Variable   ${CONFIG_FILES_MODIFIED}   ${True}
    ssh.Disconnect

Backup And Modify Model_5.ims2
    [Documentation]
    ...   This keyword downloads file: "model_5.ims2" from active partition of Primary SMOD to BTS_Files as backup.
    ...   Content of model_5.ims2 is then modified on active partition.

    ssh_utils.Setup SMOD Connection
    ssh.Download File   /ffs/run/config/model_5.ims2   ${BTS_Files}/model_5.ims2
    OperatingSystem.File Should Exist   ${BTS_Files}/model_5.ims2
    Log   Modifying content of model_5.ims2 on Primary SMOD. Original file is copied to BTS_files.  console=${True}
    ssh.Execute   echo "" > /ffs/run/config/model_5.ims2
    Set Test Variable   ${CONFIG_FILES_MODIFIED}   ${True}
    ssh.Disconnect

Restore Configuration Files On Active Partition
    [Documentation]
    ...   This keyword uploads original files "model_5.ims2" and "SWDLreport.txt" from BTS_Files to active partition of Primary SMOD.

    ssh_utils.Setup SMOD Connection
    Log   Files: "model_5.ims2" and "SWDLreport.txt" will be restored on BTS   console=${True}
    ssh.Upload File   ${BTS_Files}/model_5.ims2   /ffs/run/config/model_5.ims2
    ssh.Upload File   ${BTS_Files}/SWDLreport.txt   /ffs/run/config/SWDLreport.txt
    ssh.Execute   chown btssw.btssw /ffs/run/config/model_5.ims2
    ssh.Execute   chmod 640 /ffs/run/config/model_5.ims2
    Set Test Variable   ${CONFIG_FILES_MODIFIED}   ${False}
    ssh.Disconnect

Wait For Diagnostic Check Completion
    [Documentation]
    ...   This keyword is used to monitor diagnostic check start and completion by checking if specific messages appeared in syslog.
    ...   When scheduled DC is ongoing, second DC is triggered to check if it will be rejected.

    ute_syslog.Start Syslog   alias=monitoring_syslog   ip=192.168.255.126   log_dir=${BTS_Files}/monitoring_syslog   log_name=monitoring_syslog
    Log   Waiting for diagnostic check to start   console=${True}
    Wait Until Keyword Succeeds   5m   10s   Check Expected Print In Syslog   Start runDiagnosticCheck request
    Log   Scheduled diagnostic check started!   console=${True}
    Log   Waiting for diagnostic check to finish   console=${True}
    Wait Until Keyword Succeeds   8m   10s   Check Expected Print In Syslog   change report status and reset runningOperation
    Log   Diagnostic check finished!   console=${True}
    ute_syslog.Stop Syslog   alias=monitoring_syslog

Check Expected Print In Syslog
    [Documentation]
    ...   This keyword checks if expected print is present in syslog.
    [Arguments]   ${expected_print}
    ${msg}   ute_syslog.Message Should Exist In Syslog File   regexp=${expected_print}   alias=monitoring_syslog
    [Return]   ${msg}

Collect Snapshot
    [Documentation]
    ...  This keyword collects snapshot (full coverage), monitors collection status and sets path to snapshot as variable.
    Log   \nCollecting Snapshot   console=${True}
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
    ...   ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}   ${BTS_Files}/DiagnosticReport_${timestamp}
    ${unzipped_log_name}   Replace String Using Regexp   ${zip_from_extract[1]}   (.xz)   ${EMPTY}
    ${extracted_file_path}   Set Variable   ${BTS_Files}/DiagnosticReport_${timestamp}/${unzipped_log_name}
    Run   rm ${snapshot_path}
    Run   rm -r ${BTS_Files}/snapshot_${timestamp}
    [Return]   ${extracted_file_path}

Verify Checkpoint 7 Result In Snapshot
    [Documentation]
    ...  Keyword used to check if CP 7 is the only CP in diagnostic report in snapshot and has 'NOK' status.
    [Arguments]   ${diagnostic_report_from_snapshot}

    Log   Checking result of checkpoint 7 in snapshot    console=${True}
    ${dc_report_content}   OperatingSystem.Get File   ${diagnostic_report_from_snapshot}   encoding_errors=ignore
    ${dc_report_lines}   String.Split To Lines   ${dc_report_content}   start=1
    ${checkpoints_count}   Get Length   ${dc_report_lines}
    Should Be Equal As Integers   ${checkpoints_count}   1

    ${CP_7_line}   Get Lines Containing String   ${dc_report_content}   Configuration file validity on the active partition
    ${CP_7_line}   Convert To String   ${CP_7_line}
    ${CP_7_status}   String.Fetch From Left   ${CP_7_line}   ,
    Log   Checkpoint 7 has status "${CP_7_status}" in snapshot (expected status: "NOK")   console=${True}
    Should Be Equal As Strings   ${CP_7_status}   Check point failure

Verify CP 7 And 3 Result In Snapshot
    [Documentation]
    ...  Keyword used to check if CPs 7 and 3 are the only CPs in diagnostic report in snapshot and have 'NOK' status.
    [Arguments]   ${diagnostic_report_from_snapshot}

    Log   Checking result of checkpoint 7 and 3 in snapshot    console=${True}
    ${dc_report_content}   OperatingSystem.Get File   ${diagnostic_report_from_snapshot}   encoding_errors=ignore
    ${dc_report_lines}   String.Split To Lines   ${dc_report_content}   start=1
    ${checkpoints_count}   Get Length   ${dc_report_lines}
    Should Be Equal As Integers   ${checkpoints_count}   2

    ${CP_7_line}   Get Lines Containing String   ${dc_report_content}   Configuration file validity on the active partition
    ${CP_7_line}   Convert To String   ${CP_7_line}
    ${CP_7_status}   String.Fetch From Left   ${CP_7_line}   ,
    ${CP_3_line}   Get Lines Containing String   ${dc_report_content}   Software download report presence
    ${CP_3_line}   Convert To String   ${CP_3_line}
    ${CP_3_status}   String.Fetch From Left   ${CP_3_line}   ,
    Log   Checkpoint 7 has status "${CP_7_status}" in snapshot (expected status: "NOK")   console=${True}
    Log   Checkpoint 3 has status "${CP_3_status}" in snapshot (expected status: "NOK")   console=${True}
    Should Be Equal As Strings   ${CP_7_status}   Check point failure
    Should Be Equal As Strings   ${CP_3_status}   Check point failure

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
    Set Test Variable   ${SCF_MODIFIED}   ${False}

Custom Test Teardown
    Run Keyword If   ${CONFIG_FILES_MODIFIED}   Run Keywords
    ...   Restore Configuration Files On Active Partition
    ...   AND   Revert Delta Changes
    ...   AND   coam.Run Diagnostic Check   timeout=930
    ...   AND   Check Alarm 4681   Inactive   Minor
    Run Keyword If   ${SCF_MODIFIED}
    ...   Revert Delta Changes

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...   interface.Common step trigger
    ...   AND   Setup Scout And Send Configuration
    ...   AND   Custom Test Teardown
    ...   AND   Common Test Teardown
