*** Settings ***
Resource    ../resources/diagnostic_check.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/ping_utils.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pdu.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.ul.verify_snapshot   WITH NAME  snapshot

*** Variables ***


*** Keywords ***
TC__LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26918
    ...  ******************
    ...  Author: Iuliia Taupeka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-01-19 - TC created. version 1.0
    ...  - 2024-02-19 - Full TC released
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies Diagnostic Check with check point Id:33 Secondary core connectivity.
    ...  BTS checks the connectivity with the secondary core and existing fault: 4352 No connection between primary and BTS extension system module.
    ...  After Diagnostic Check is triggered by user in WebEM, fault 4681 (Diagnostic Check Error) is raised on BTS due to CP33 NOK.
    ...  When connection between cores is restored and 4352 fault is cleared, second Diagnostic Check (automatic this time)
    ...  should clear 4681 fault on BTS.
    ...  Content of snapshot and DC report will be checked as well.
    ...  *******************


    Set Tags    CA-LOGS    OWNER-joanna.wolnicka@nokia.com    AUTHORS-iuliia.taupeka@nokia.com,    jakub.kokoszka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com     PHASE-CRT    SW-SBTS24R2    FEATURE-CB012370-B
    Step 0: Preconditions
    Step 1: Run Diagnostic Check And Check The Result
    Step 2: ESM OFF
    Step 3: Waiting for FID:4352
    Step 4: Run Diagnostic Check And Check CP 31 and 33 Results
    Step 5: ESM ON
    Step 6: Check if FID:4352 is inactive
    Step 7: Perform Site Reset And Wait For Auto DC Start
    Step 8: Collect Snapshot And Verify DiagnosticReport




Step 0: Preconditions
    [Documentation]
    ...  In this step test prepare variables for test

    Log    \nStep 0: Preconditions    console=${True}

    ${is_it_dualcore}    Run Keyword And Return Status  Variable Should Exist  ${SMOD2}
    Run Keyword If    ${is_it_dualcore}==${False}
    ...    verdicts.Set Test Failed  test requires dualcore  ${TRUE}
    ...    ELSE  Log    dual core: OK

    Set Test Variable    ${ESM_OFF}  ${False}
    ${bts_id}   bts_states.Get BTS ID
    Set Test Variable    ${bts_id}
    ${secondary_SMOD_IM_obj}    Query Infomodel    get object //SMOD_R-* is [activeRole="Secondary"]
    ${sec_core_SMOD_SN}    Set Variable   SMOD_${secondary_SMOD_IM_obj.serialNumber}
    Set Test Variable  ${SEC_CORE_SMOD_SN}  ${sec_core_SMOD_SN}

Step 1: Run Diagnostic Check And Check The Result
    [Documentation]
    ...  In this step test Runs Diagnostic Check, checks that fault 4681 is not reported, gets DC report and checks OK result for CP1.

    Log    \nStep 1: Run Diagnostic Check And Check The Result    console=${True}
    diagnostic_check.Perform Diagnostic Check
    coam.Assert Alarm Inactive  parameters=alarmId=7115, faultId=4681, faultName="Diagnostic Check Error"  timeout=120
    diagnostic_check.Get DC Report And Check CP Result   1   OK

Step 2: ESM OFF
    [Documentation]
    ...  In this step test sets ESM OFF
    Log    Step 2: ESM OFF    console=${True}
    pdu.Pdu BTS Interface Off    ${SEC_CORE_SMOD_SN}
    Log  power on ESM: ${SEC_CORE_SMOD_SN} was turned OFF  console=${True}
    Set Test Variable  ${ESM_OFF}  ${True}

Step 3: Waiting for FID:4352
    [Documentation]
    ...  In this step test Waiting for FID:4352
    Log    Step 3: Waiting for FID:4352    console=${True}
    ${fault_status}  Run Keyword And Return Status  Wait until keyword succeeds  360  10
    ...  coam.Assert Alarm Active
    ...  parameters=alarmId=7116, faultId=4352, faultName="No connection between primary and BTS extension system module", severity=Critical
    ...  timeout=120
    Run keyword if  ${fault_status}
    ...  Log  Fault 4352 "No connection between primary and BTS extension system module" - severity=Critical - appeared  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Fault 4352 "No connection between primary and BTS extension system modul" - did not not appear    ${True}

Step 4: Run Diagnostic Check And Check CP 31 and 33 Results
    [Documentation]
    ...  In this step test runs Diagnostic Check and checks CP31 and CP 33 results (NOK expected).
    ...  It is also verified that all CPs for Secondary Core have Not Executed status
    Log    Step 4: Run Diagnostic Check And Check CP 31 and 33 Results    console=${True}
    diagnostic_check.Perform Diagnostic Check
    diagnostic_check.Check Alarm 4681   Active   Minor
    diagnostic_check.Get DC Report And Check CP Result   31   NOK
    diagnostic_check.Get DC Report And Check CP Result   33   NOK
    Verify NotExecuted CPs For Secondary Core

Step 5: ESM ON
    [Documentation]
    ...  In this step test turns ESM ON

    Log    \nStep 5: ESM ON    console=${True}

    pdu.Pdu BTS Interface On    ${SEC_CORE_SMOD_SN}

    Log  power on ESM: ${SEC_CORE_SMOD_SN} was turned ON  console=${True}
    Set Test Variable  ${ESM_OFF}  ${False}
    Log  Waiting up to 20min for BTS to become on air after power on ESM was turned ON  console=${True}
    Sleep    180s
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

Step 6: Check if FID:4352 is inactive
    [Documentation]
    ...  In this step test Check if FID:4352 disappear
    Log    \nStep 6: Check if FID:4352 is inactive    console=${True}
    ${fault_status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   120   10
    ...   coam.Assert Alarm Inactive
    ...   parameters=alarmId=7116, faultId=4352, faultName="No connection between primary and BTS extension system module", severity=Critical
    ...  timeout=120
    Run Keyword If   ${fault_status}
    ...   Log    Fault 4352 "No connection between primary and BTS extension system module" is Inactive.    console=${True}
    ...   ELSE   verdicts.Set Test Failed   WebEM: Fault 4352 "No connection between primary and BTS extension system module" not Inactive.

Step 7: Perform Site Reset And Wait For Auto DC Start
    [Documentation]
    ...  In this step test performs site reset and waits for auto DC start

    Log    \nStep 7: Perform Site Reset And Wait For Auto DC Start    console=${True}
    coam.Reset Site
    ping_utils.Wait For Target IP To Be Reachable    192.168.255.129
    Sleep    30s
    Wait For Automatic DC Start
    ${DC_run_date}   DateTime.Get Current Date   exclude_millis=True   result_format=%Y-%m-%d %H:%M:%S
    ${DC_run_date}   DateTime.Subtract Time From Date  ${DC_run_date}  6 seconds    result_format=%Y-%m-%d %H:%M:%S
    Log   Timestamp before DC Start: ${DC_run_date}.  console=${True}
    ${DC_run_date}   Replace String   ${DC_run_date}   ${SPACE}   T
    Set Test Variable   ${DC_run_date}

    Wait For Diagnostic Check Finish
    diagnostic_check.Get DC Report And Check CP Result   31   OK
    diagnostic_check.Get DC Report And Check CP Result   33   OK

Step 8: Collect Snapshot And Verify DiagnosticReport
    [Documentation]
    ...  In this step Snapshot is collected. After extraction of DiagnosticReport File CP1 and CP2 status is verified in this file (NOK expected).
    Log    \nStep 8: Collect Snapshot And Verify DiagnosticReport    console=${True}
    Collect Snapshot
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snapshot}

    ${dc_report_content}   OperatingSystem.Get File   ${diagnostic_report_from_snapshot}   encoding_errors=ignore
    ${dc_report_lines}   String.Split To Lines   ${dc_report_content}   start=1
    Verify CP33 Result In Snapshot    ${diagnostic_report_from_snapshot}
    Verify Secondary Core CP Result Change In Snapshot    ${diagnostic_report_from_snapshot}

Verify CP33 Result In Snapshot
    [Documentation]
    ...  Keyword used to check if checkpoint 33 of diagnostic report has status 'OK' in snapshot.
    [Arguments]   ${extracted_file_path}

    Log   Checking result of checkpoint 33 in snapshot    console=${True}
    ${CP_33_line}   OperatingSystem.Grep File   ${extracted_file_path}   Secondary core connectivity
    ${CP_33_status}   String.Fetch From Right   ${CP_33_line}   ,
    Should Be Equal As Strings   ${CP_33_status}   OK
    Log   Checkpoint 33 has status "${CP_33_status}" in snapshot (expected status: "OK")   console=${True}

Verify Secondary Core CP Result Change In Snapshot
    [Documentation]
    ...  Keyword used to check if checkpoint 33 of diagnostic report has status 'OK' in snapshot.
    [Arguments]   ${extracted_file_path}
    ${CP_11_line}   OperatingSystem.Grep File   ${extracted_file_path}   11,System Module RAM usage,${smod_distname_for_snap}
    ${CP_11_status}   String.Fetch From Right   ${CP_11_line}   ,
    Should Be Equal As Strings   ${CP_11_status}   OK
    Log   Checkpoint 11 has status "${CP_11_status}" in snapshot (expected status: "OK")   console=${True}

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
          ${MATCHES}   Get Regexp Matches   ${snapshot_dict["${key}"][0]}   .*1011_DiagnosticReport.csv.xz
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
    [Return]   ${extracted_file_path}

Wait For Automatic DC Start
    ute_syslog.Start Syslog   alias=monitoring_syslog   ip=192.168.255.126   log_dir=${BTS_Files}/monitoring_syslog   log_name=monitoring_syslog
    Log   Waiting for diagnostic check to start   console=${True}
    Wait Until Keyword Succeeds  6m  5s  Check Expected Print In Syslog  All cells reached OnAirDone status, clear timer and run Diagnostic Check
    Log   Scheduled diagnostic check started!   console=${True}

Wait For Diagnostic Check Finish
    Log   Waiting for diagnostic check to finish   console=${True}
    Wait Until Keyword Succeeds   930s   10s   Check Expected Print In Syslog   change report status and reset runningOperation
    Log   Diagnostic check finished!   console=${True}
    ute_syslog.Stop Syslog   alias=monitoring_syslog

Check Expected Print In Syslog
    [Documentation]
    ...   This keyword checks if expected print is present in syslog.
    [Arguments]   ${expected_print}
    ${msg}   ute_syslog.Message Should Exist In Syslog File   regexp=${expected_print}   alias=monitoring_syslog
    [Return]   ${msg}

Verify NotExecuted CPs For Secondary Core
    [Documentation]
    ...   This keyword checks all CPs for secondary core - results should be 'Not Executed'
    ${is_it_singlecore}   Run Keyword And Return Status   Variable Should Not Exist   ${SMOD2}
    ${smod_obj}   Query Infomodel   get object //SMOD_R-* is [activeRole=Secondary]
    ${smod_distname}   Fetch From Right   ${smod_obj.dist_name}   /
    ${smod_distname_for_snap}    Fetch From Right   ${smod_obj.dist_name}    MRBTS_R-1/
    Set Test Variable    ${smod_distname_for_snap}    MRBTS-${bts_id}/${smod_distname_for_snap}

    Log   \nVerifying if all CPs from Secondary Core has expected status NotExecuted in DC Report.   console=${True}
    ${dc_report_connection}   coam.Connect To   name=dc_report_connection
    ${diagnostic_report}   coam.Get Diagnostic Report   connection=${dc_report_connection}

    @{found_checkpoints}   Create List
    FOR   ${CP}   IN   @{diagnostic_report}
        ${checkpoint_id}   Get From Dictionary   ${CP}   checkpointId
        ${cp_distname}   Get From Dictionary   ${CP}   distName
        ${cp_distname}   Fetch From Right   ${cp_distname}   /
        Run Keyword If   '${cp_distname}' == '${smod_distname}'    run keywords
        ...    Log To Console   Checkpoint ${checkpoint_id} found for distname: ${cp_distname}
        ...    AND    diagnostic_check.Verify Checkpoints Timestamp    ${CP}    ${DC_run_date}
        ...    AND    diagnostic_check.Verify CP Status   ${CP}   NotExecuted
        ...    AND    Append To List   ${found_checkpoints}    ${CP}
    END
    coam.Teardown   connection=${dc_report_connection}

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

Custom Test Teardown
    [Documentation]
    ...  This keyword powers ESM on if in the test it wasn't powered on.
    Log  \nCustom Test Teardown  console=${True}
    Run Keyword If    ${ESM_OFF}    Run Keywords
    ...    pdu.Pdu BTS Interface On    ${SEC_CORE_SMOD_SN}
    ...    AND  Log  power on ESM: ${SEC_CORE_SMOD_SN} was turned ON  console=${True}
    ...    AND  Log  Waiting up to 20min for BTS to become on air after power on ESM was turned ON  console=${True}
    ...    AND  Sleep    180s
    ...    AND  Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown


