*** Settings ***
Documentation    TC for CB012370-C
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/diagnostic_check_new.robot
Resource    ../resources/ping_utils.robot
Library     DateTime
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${STARTUP_TIMEOUT}  15  # Timeout value in minutes after startup for all modules to reach working state.
${cmd}    while true; do echo 50 >/dev/ddal/fan/0/pwm; echo 70 > /dev/ddal/fan/1/pwm; sleep 1; done &
${PROCES_ACTIVE}      ${False}

*** Keywords ***
TC__LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26791
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
    ...  This TC verifies Diagnostic Check with check point Id:37 System Module Fan Speed.
    ...  User triggers automatic Diagnostic Check (DC) on BTS, which met conditions for raising FID:4079 (Cooling fan speed decreased).
    ...  In this case result for check point 37 will be NOK and FID:4681 (Diagnostic Check Error) should be raised on BTS.

    ...  *******************

    ...  *******************


    Set Tags    CA-LOGS    OWNER-joanna.wolnicka@nokia.com    AUTHOR-iuliia.taupeka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com     PHASE-CRT    SW-SBTS24R2    FEATURE-CB012370239-C
    Step 0: Preconditions
    Step 1: Perform Site Reset And Trigger Conditions For Raising FID 4079
    Step 2: Check Fans Status
    Step 3: Check Automatic Diagnostic Check Results
    Step 4: Schedule Service Impacted Diagnostic Check
    Step 5: Check DC Results
    Step 6: Collect Snapshot And Verify DiagnosticReport

Step 0: Preconditions
    [Documentation]
    ...  In this step test saves SCF file to be restored after test.
    Log  \nStep 0: Preconditions.  console=${True}
    ${bts_id}   bts_states.Get BTS ID
    Set Test Variable   ${BTS_ID}   ${bts_id}
    Set Test Variable   ${TRBL_MNLENT_DISTNAME}   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    coam.Get Current SCF File
    ...    ${BTS Files}  SCF.xml  timeout=120   export_type=configuration  parameters_save_variant=actualValues
    Set Test Variable    ${SCF_CHANGED}  ${False}


Step 1: Perform Site Reset And Trigger Conditions For Raising FID 4079
    [Documentation]
    ...  In this step test performs Site Reset and Triggers FID 4079 just after BTS become pingable
    ...  (by sending command via SSH modifying FAN speed).
    ...  Test waits for auto DC start (after all cells are OnAir after reset).
    ...  Then Fid 4681 is checked if raised with severity Warning.
    ...  Fault 4079 is checked if present in RawAlarmHistory file in active alarms.

    Log  \nStep 1: Perform Site Reset And Trigger Conditions For Raising FID 4079.  console=${True}
    coam.Reset Site
    ping_utils.Wait For Target IP To Be Reachable    192.168.255.129    5
    Sleep    30s
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Write    ${cmd}

    ${cmd_output}  SSHLibrary.read until    root@
    ${split}  Split string From Right  ${cmd_output}
    Set Test Variable   ${proc_id}    ${split}[1]
    Log  Running Proces ID is: ${proc_id}      console=${True}
    Set Test Variable   ${PROCES_ACTIVE}   ${True}

    ute_syslog.Start Syslog   alias=monitoring_syslog   ip=192.168.255.126   log_dir=${BTS_Files}/monitoring_syslog   log_name=monitoring_syslog
    Wait For Scheduled DC Start    monitoring_syslog    ${STARTUP_TIMEOUT}m
    ${DC_run_date}   DateTime.Get Current Date   exclude_millis=True   result_format=%Y-%m-%d %H:%M:%S
    ${DC_run_date}   DateTime.Subtract Time From Date  ${DC_run_date}  6 seconds    result_format=%Y-%m-%d %H:%M:%S
    Log   Timestamp before DC Start: ${DC_run_date}.  console=${True}
    ${DC_run_date}   Replace String   ${DC_run_date}   ${SPACE}   T
    Set Test Variable   ${DC_run_date}

    Wait For Diagnostic Check Finish    monitoring_syslog

    Wait until keyword Succeeds  120s  5s    diagnostic_check_new.Check Alarm 4681   Active   Warning

    ${RawAlarms}=     coam.Get Raw Alarm History File
    ${RawAlamrsActive}=    Fetch From Left  ${RawAlarms}  Inactive faults
    Should contain    ${RawAlamrsActive}  (4079)
    Should contain    ${RawAlamrsActive}  EFaultId_CoolingFanSpeedDecreasedAl
    Log    Fault 4079 EFaultId_CoolingFanSpeedDecreasedAl is active in RawAlarmHistory.    console=${True}


Step 2: Check Fans Status
    [Documentation]
    ...  In this step test verifies that one of FANs is in degraded availability status and removes FAN speed faault conditions (by killing process).
    Log  \nStep 2: Check Fans Status.    console=${True}

    ${num_of_FANs_degraded}=  Query Infomodel  get count //BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/FAN_L-* is [stateInfo.availabilityStatus=Degraded]
    Run Keyword If    ${num_of_FANs_degraded}>=1
        ...   Log    ${num_of_FANs_degraded} FANs are in Degraded state. [OK]    console=${TRUE}
    Run Keyword If    ${num_of_FANs_degraded}==0  Fail  There is no FAN in Degraded availabilityStatus. [NOK]

    SSHLibrary.Write  kill ${proc_id}
    Log    Proces ID: ${proc_id} killed.    console=${True}
    Set Test Variable   ${PROCES_ACTIVE}   ${False}
    SSHLibrary.Close Connection


Step 3: Check Automatic Diagnostic Check Results
    [Documentation]
    ...  In this step test gets Diagnostic Check report. From report is returned checkpoint 1 (Configuration file presence on the active partition)
    ...  and under CP 1 checked:
    ...  - timestamp - should be correct;
    ...  - lastResult - should be NOK.

    Log  \nStep 3: Check Automatic Diagnostic Check Results.   console=${True}
    Log    Sleeping 100s to wait for FANs availability.    console=${True}
    Sleep    100s
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    diagnostic_check_new.Get DC Report And Check CP Result   37   Check point failure
    Verify FANs Are Available

Step 4: Schedule Service Impacted Diagnostic Check
    Log  \nStep 4: Schedule Service Impacted Diagnostic Check.   console=${True}
    ute_syslog.Start Syslog   alias=ServImp_syslog   ip=192.168.255.126   log_dir=${BTS_Files}/ServImp_syslog   log_name=ServImp_syslog
    Log    Syslog started to monitor service impacted DC.   console=${True}
    diagnostic_check_new.Schedule Service Impacted Diagnostic Check
    Set Test Variable    ${SCF_CHANGED}  ${True}

    Wait For Scheduled ServImp DC Start    ServImp_syslog
    Log    Waiting for no ping (BTS resetting).    console=${True}
    Wait Until Keyword Succeeds    3m   5s    ping_utils.Check If Host Is Not Pingable    192.168.255.129
    ping_utils.Wait For Target IP To Be Reachable   192.168.255.129   10
    Log    Waiting for setting reset timer for DC    console=${True}
    Wait Until Keyword Succeeds   6m   10s
    ...   Check Expected Print In Syslog   Set the radio reset timer for diagnostic check to    ServImp_syslog
    Wait For Diagnostic Check Finish    ServImp_syslog    900s

Step 5: Check DC Results
    Log  \nStep 5: Check DC Results.   console=${True}
    diagnostic_check_new.Get DC Report And Check CP Result   37   Check point successful
    diagnostic_check_new.Get DC Report And Check CP Result   35   Check point successful
    diagnostic_check_new.Check Alarm 4681   Inactive   Minor
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

Step 6: Collect Snapshot And Verify DiagnosticReport
    [Documentation]
    ...  In this step Snapshot is collected. After extraction of DiagnosticReport File CP1 and CP2 status is verified in this file (NOK expected).
    Log    \nStep 6: Collect Snapshot And Verify DiagnosticReport    console=${True}
    Collect Snapshot
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snapshot}

    ${dc_report_content}   OperatingSystem.Get File   ${diagnostic_report_from_snapshot}   encoding_errors=ignore
    ${dc_report_lines}   String.Split To Lines   ${dc_report_content}   start=1
    ${CP_35_lines}   Get Lines Containing String   ${dc_report_content}   Power-on Self Test
    ${CP_35_lines}   Convert To String   ${CP_35_lines}
    @{CP_35_results}=    Split String  ${CP_35_lines}  \n
    FOR    ${line}    IN    @{CP_35_results}
      Log    CP ${line}    console=${True}
      ${CP_35_status}=   String.Fetch From Left   ${line}   ,
      Should Be Equal As Strings   ${CP_35_status}   Check point successful
      Log    CP status ${CP_35_status} is correct.    console=${True}
    END

    ${CP_37_lines}   Get Lines Containing String   ${dc_report_content}   System Module FAN speed
    ${CP_37_lines}   Convert To String   ${CP_37_lines}
    @{CP_37_results}=    Split String  ${CP_37_lines}  \n
    FOR    ${line}    IN    @{CP_37_results}
      Log    CP ${line}    console=${True}
      ${CP_37_status}=   String.Fetch From Left   ${line}   ,
      Should Be Equal As Strings   ${CP_37_status}   Check point successful
      Log    CP ${CP_37_status} status is correct    console=${True}
    END


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

Wait For Scheduled DC Start
    [Documentation]
    ...  This keyword is waiting for scheduled DC start (expecting special print to appear in syslog)
    [Arguments]    ${syslog_alias}    ${timeout}=6m
    Log   Waiting for diagnostic check to start   console=${True}
    Wait Until Keyword Succeeds  ${timeout}  5s
    ...  Check Expected Print In Syslog  All cells reached OnAirDone status, clear timer and run Diagnostic Check    ${syslog_alias}
    Log   Scheduled diagnostic check started!   console=${True}

Wait For Diagnostic Check Finish
    [Documentation]
    ...  This keyword is waiting for DC finish (expecting special print to appear in syslog)
    [Arguments]    ${syslog_alias}    ${timeout}=930s
    Log   Waiting for diagnostic check to finish   console=${True}
    Wait Until Keyword Succeeds   ${timeout}   10s
    ...   Check Expected Print In Syslog   change report status and reset runningOperation    ${syslog_alias}
    Log   Diagnostic check finished!   console=${True}
    ute_syslog.Stop Syslog   alias=${syslog_alias}

Wait For Scheduled ServImp DC Start
    [Documentation]
    ...  This keyword is waiting for service impacted scheduled DC start (expecting special print to appear in syslog)
    [Arguments]    ${syslog_alias}
    Log  Waiting for scheduled service impacted diagnostic check to start   console=${True}
    Wait Until Keyword Succeeds  8m  5s
    ...    Check Expected Print In Syslog  Start runDiagnosticCheck request    ${syslog_alias}
    Log   Scheduled diagnostic check started!   console=${True}

Check Expected Print In Syslog
    [Documentation]
    ...   This keyword checks if expected print is present in syslog.
    [Arguments]   ${expected_print}    ${syslog_alias}
    ${msg}   ute_syslog.Message Should Exist In Syslog File   regexp=${expected_print}   alias=${syslog_alias}
    [Return]   ${msg}

Verify FANs Are Available
    [Documentation]
    ...   This keyword checks availabilityStatus and verifies that FANs are not degraded.
    ${num_of_FANs_degraded}=  Query Infomodel  get count //BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/FAN_L-* is [stateInfo.availabilityStatus=Degraded]
    Run Keyword If    ${num_of_FANs_degraded}==0
        ...   Log    All FANs are working. [OK]    console=${TRUE}
    Run Keyword If    ${num_of_FANs_degraded}>0  Fail  There are ${num_of_FANs_degraded} FANs in Degraded availabilityStatus. [NOK]

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



Custom Test Teardown
    [Documentation]
    ...   In custom test teaedown process is killed if still running and Commissioning is perfordem to revert all changes.
    Log    \nCustom Test Teardown    console=${True}
    Run Keyword If    ${PROCES_ACTIVE}    Run Keywords
    ...  SSHLibrary.Write  kill ${proc_id}
    ...  AND    Log    Proces ID: ${proc_id} killed.    console=${True}
    ...  AND    Set Test Variable   ${PROCES_ACTIVE}   ${False}
    ...  AND    SSHLibrary.Close Connection
    Run Keyword If  ${SCF_CHANGED}  Run Keywords
    ...  Log    Perform Commissioning To Restore Configuration Before TC start.  console=${True}
    ...  AND    coam.Perform Commissioning   scf_file=${BTS Files}/SCF.xml    skip_parameter_relation_errors=True    timeout=900
    ...  AND    Wait Until Keyword Succeeds  15m  20s  pm_logs_general.Check All Modules And All Cells Working States
    ...  AND    Log  All modules reached working state  console=${TRUE}
    ...  ELSE   Log  No changes in SCF, skipping Custom Test Teardown  console=${TRUE}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
