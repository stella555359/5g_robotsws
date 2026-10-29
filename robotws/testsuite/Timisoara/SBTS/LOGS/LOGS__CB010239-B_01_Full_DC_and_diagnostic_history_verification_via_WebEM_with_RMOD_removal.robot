*** Settings ***
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Library     DateTime
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_EXTRACTED}  ${FALSE}
${RMOD_SERIAL_NUMB}    L1170711405

*** Keywords ***
TC__LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25769
    ...  ******************
    ...  Author: Iuliia Taupeka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-08-07 - TC created. version 1.0
    ...  - 2024-03-20 - change coam.Run Diagnostic Check timeout in accordance to updated req OM_GEN_SFS_PERF_CAP.10677
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies the content of diagnostic history (inside the snapshot), after full Diagnostic Check execution via WebEM.
    ...  It checks also if only one Diagnostic Check can be running at the same time.
    ...  Test checks removing RMOD in runtime - after it items from diagnostic history will also be verified - all items for deleted HW should be
    ...  cleared from diagnostic history (in Snapshot).
    ...  *******************
    ...  Test case flowchart: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...  LOGS__CB010239-B_Full_DC_from_WebEM_and_diagnostic_history_verification_after_RMOD_removal.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-joanna.wolnicka@nokia.com    AUTHOR-iuliia.taupeka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com     PHASE-CRT    SW-SBTS23R4    FEATURE-CB010239-B

    Step 0: Preconditions
    Step 1: Run DC And Verify That DC Cannot Be Run When Another DC Is Running
    Step 2: Collect Snapshot
    Step 3: Find DC results For Tested RMOD in DiagnosticHistoryHistogram File
    Step 4: Remove RMOD From Configuration And Run Diagnostic Check
    Step 5: Collect Snapshot
    Step 6: Verify That RMOD Is Deleted From DC History

Step 0: Preconditions
    [Documentation]
    ...  In this step test saves SCF file and gets distname of RMOD under test (Serial Number is given as input test variable).
    ...
    Log  \nStep 0: Preconditions.  console=${True}
    coam.Get Current Scf File  ${BTS_Files}  SCF.xml  export_type=configuration
    ${SCF}  Parse Xml  ${BTS_Files}/SCF.xml
    Set Test Variable  ${SCF}
    Log  SCF file collected.    console=${True}
    ${checked_RMOD_DN}    Infomodel Get RMOD distName By Serial Number    ${RMOD_SERIAL_NUMB}
    Log    Tested RMOD Distname:\n ${checked_RMOD_DN}  console=${True}
    Set Test Variable    ${checked_RMOD_DN}
    Set Test Variable    ${RMOD_REMOVED}  ${False}


Step 1: Run DC And Verify That DC Cannot Be Run When Another DC Is Running
    [Documentation]
    ...  In this step test:
    ...  - runs Diagnostic Check and waits for completion;
    ...  - in the meantime checks that second Diagnostic Check will not run when another DC is ongoing.
    Log  \nStep 1: Run DC And Verify That DC Cannot Be Run When Another DC Is Running.  console=${True}
    ${DC1_run_date}  DateTime.Get Current Date  exclude_millis=True  result_format=%Y-%m-%d %H:%M:%S
    Log    Timestamp before DC Start: ${DC1_run_date}. Sleep for 10s and run Diagnostic Check.    console=${True}
    ${DC1_run_date}  Replace String  ${DC1_run_date}  ${SPACE}  T
    Set Test Variable    ${DC1_run_date}
    Sleep    10s
    Log    Run Diagnostic Check in background.    console=${True}
    ${DC1_result}=    coam.Run Keyword In Background    Run Diagnostic Check  timeout=930
    Log    Run second Diagnostic Check.    console=${True}
    ${second_connection}  coam.Connect To  name=dc_connection
    ${report2_status}  Run Keyword and Return Status    coam.Run Diagnostic Check    connection=dc_connection  timeout=930
    Run Keyword If    ${report2_status}==${True}
    ...    verdicts.Set Test Failed  Second diagnostic succeeded, but should be not executed when another DC is ongoing.  ${TRUE}
    ...    ELSE  Log  Status of second DC ${report2_status}. [OK]    console=${True}
    Sleep    500s
    Log    First Diagnostic Check finished. [OK]    console=${True}

Step 3: Find DC results For Tested RMOD in DiagnosticHistoryHistogram File
    [Documentation]
    ...  In this step below actions are performed:
    ...  - find DiagnosticHistoryHistogram File in Snapshot and extract it.
    ...  - search for checkpoints for tested RMOD in DiagnosticHistoryHistogram File (number should be greated than 0).
    Log  \nStep 3: Find DC results For Tested RMOD in DiagnosticHistoryHistogram File  console=${True}
    ${Histogram_before_rmod_deletion}  Find And Extract DiagnosticHistoryHistogram File    ${path_to_snapshot_2}
    ${num_of_rmod_cps}    Get Number Of Found RMOD CPs  ${checked_RMOD_DN}  ${Histogram_before_rmod_deletion}
    Run Keyword If    '${num_of_rmod_cps}' == '0'
    ...    verdicts.Set Test Failed    No checkpoints found in report for tested RMOD. [NOK]    ${TRUE}
    ...    ELSE  Log  Number of executed checkpoints for tested RMOD= ${num_of_rmod_cps}

Step 4: Remove RMOD From Configuration And Run Diagnostic Check
    [Documentation]
    ...  In this step test removes tested RMOD from configuration (in runtime)
    ...  and runs diagnostic check.

    Log  \nStep 4: Remove RMOD From Configuration And Run Diagnostic Check   console=${True}
    ${list_of_modules}    coam.Get Parameters For All    RMOD
    ${delta_id}  Set Variable  remove_rmod
    coam.Create Delta  ${delta_id}
    coam.Append Managed Object To Delta  MRBTS-10826/EQM-1/APEQM-1/RMOD-4  delete  ${delta_id}
    coam.Append Managed Object To Delta  MRBTS-10826/LNBTS-10826/LNCEL-48262  delete  ${delta_id}
    coam.Append Managed Object To Delta  MRBTS-10826/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2  delete  ${delta_id}
    coam.Append Managed Object To Delta  MRBTS-10826/EQM-1/HWTOP-1/CABLINK-14  delete  ${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    coam.Perform delta recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
    Log    RMOD-4, LNCEL-2, LCELL-2 and CABLINK-14 MOs deleted from config.    console=${True}
    Set Test Variable    ${RMOD_REMOVED}  ${True}
    Log    Running Diagnostic Check.    console=${True}
    ${DC2_result} =    coam.Run Diagnostic Check  timeout=930
    Log    Diagnostic Check finished. [OK]    console=${True}


Step ${n}: Collect Snapshot
    [Documentation]
    ...  In this step Snapshot (full) is collected.
    Log  \nStep ${n}: Trigger Snapshot  console=${True}
    ${timestamp}  Get time
    ${timestamp}  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    Set Test Variable  ${timestamp}
    ${log_status}    Run Keyword And Ignore Error  coam.Collect snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=1800
    Run Keyword If  '${log_status[0]}'=='FAIL'
    ...    Fail  Collecting snapshot failed
    ...    ELSE
    ...    Log  Full snapshot is successfully collected  console=${True}
    Set Test Variable  ${path_to_snapshot_${n}}  ${BTS_Files}/snapshot_${timestamp}.zip


Step 6: Verify That RMOD Is Deleted From DC History
    [Documentation]
    ...  In this step below actions are performed:
    ...  - find DiagnosticHistoryHistogram File in second Snapshot(collected after RMOD removal) and extract it.
    ...  - search for checkpoints for tested RMOD in DiagnosticHistoryHistogram File
    ...  Number of found checkpoints for tested RMOD should be = 0 - this means that all entries for removed HW are cleared properly from
    ...  History histogram.
    Log  \nStep 6: Verify That RMOD Is Deleted From DC History  console=${True}
    Set Test Variable    ${SNAPSHOT_EXTRACTED}    ${False}
    ${Histogram_after_rmod_deletion}  Find And Extract DiagnosticHistoryHistogram File    ${path_to_snapshot_5}
    ${num_of_rmod_cps}    Get Number Of Found RMOD CPs  ${checked_RMOD_DN}  ${Histogram_after_rmod_deletion}
    Run Keyword If    '${num_of_rmod_cps}' != '0'    verdicts.Set Test Failed  Items not removed from History Histogram after RMOD deletion.  ${TRUE}
    ...  ELSE  Log  History Histogram cleared properly entries for removed RMOD.  console=${True}


Infomodel Get RMOD distName By Serial Number
    [Documentation]
    ...  Returns distname of RMOD with specified serial number for diagnostic check .
    ...  |  Parameters     | Man. |  Description         |
    ...  |  serial_number  | Yes  |  RMOD serial number  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description           |
    ...  |  rmod_DN_DC        |  RMOD distName prepared for Diagnostic Check Report verification  |
    ...
    ...  *EXAMPLE*
    ...  | ${rmod_dn} =  | Infomodel Get RMOD distName By Serial Number  |  FGYU12345  |
    [Arguments]  ${serial_number}
    ${rmod_r} =          Get Infomodel Object  //RMOD_R-* is [serialNumber=${serial_number}]
    ${rmod_distname}=    Get From Dictionary   ${rmod_r}    dist_name
    ${rmod_DN_DC}        Fetch From Right      ${rmod_distname}    MRBTS_R-1/
    ${bts_id}            bts_states.Get BTS ID
    ${rmod_DN_DC}        Catenate  SEPARATOR=  ${bts_id}/  ${rmod_DN_DC}
    [Return]  ${rmod_DN_DC}

Find And Extract DiagnosticHistoryHistogram File
    [Documentation]
    ...  This KW searches for DiagnosticHistoryHistogram File in Snapshot and extracts it for further verification.
    ...  |  Parameters     | Man. |  Description         |
    ...  |  snapshot_path  | Yes  |  path to Snapshot    |
    ...
    ...  *RETURN*
    ...  |  Parameters      |  Description           |
    ...  |  extracted_file  |  Path to extracted DiagnosticHistoryHistogram File |
    ...
    ...  *EXAMPLE*
    ...  | ${extracted_file}  |    Find And Extract DiagnosticHistoryHistogram File   | ${path_to_snapshot}
    [Arguments]    ${snapshot_path}
    Log  Find and extract DiagnosticHistoryHistogram file  console=${True}
    ${snapshot_dict}    snapshot.Get Data From Snapshot    ${snapshot_path}
    FOR  ${key}  IN  @{snapshot_dict.keys()}
        ${MATCHES}  get regexp matches  ${snapshot_dict["${key}"][0]}  .*011_DiagnosticHistoryHistogram.csv.xz
        run keyword if  ${MATCHES}  run keywords
        ...  Log  DiagnosticHistoryHistogram file: ${MATCHES[0]} found  console=${True}
        ...  AND  Set Test Variable  ${MATCHES}    ${MATCHES}
        ...  AND  Exit For Loop
    END
    ${extracted_file}    Extract log file    ${snapshot_path}    ${MATCHES[0]}
    run keyword unless  ${MATCHES}  Fail  DiagnosticHistoryHistogram file not found
    [Return]    ${extracted_file}

Extract log file
    [Documentation]
    ...  Keyword used to extract specified file from snapshot.
    ...  |  Parameters               | Man. |  Description         |
    ...  |  snapshot_path            | Yes  |  path to Snapshot    |
    ...  |  path_to_extracting_file  | Yes  |  path to Snapshot    |
    ...  *RETURN*
    ...  |  Parameters           |  Description           |
    ...  |  extracted_file_path  |  Path to extracted DiagnosticHistoryHistogram File |
    [Arguments]    ${snapshot_path}    ${path_to_extracting_file}
    Log   Start extracting DiagnosticHistoryHistogram file for further analysis    console=${True}
    run keyword unless  ${SNAPSHOT_EXTRACTED}
    ...  unpacking.Unpack Archive Content To Directory  ${snapshot_path}  ${BTS_Files}/snapshot_${timestamp}
    set test variable  ${SNAPSHOT_EXTRACTED}  ${TRUE}
    ${zip_from_extract}  get regexp matches  ${path_to_extracting_file}  [\\w.]+
    ${log_to_extract}  replace string using regexp  ${zip_from_extract[0]}  (.zip)  ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}  ${BTS_Files}/HistoryHistogram
    ${unzipped_log_name}  replace string using regexp  ${zip_from_extract[1]}  (.xz)  ${EMPTY}
    ${extracted_file_path}    Set Variable    ${BTS_Files}/HistoryHistogram/${unzipped_log_name}
    [Return]  ${extracted_file_path}

Get Number Of Found RMOD CPs
    [Documentation]
    ...  Keyword returns number of found in diagnostic history historgam file checkpoints for tested RMOD.
    [Arguments]    ${rmod_dn}    ${histogram_file_path}
    ${history_histogram}  OperatingSystem.Get File  ${histogram_file_path}  encoding_errors=ignore
    @{lines_from_history_histogram}  Split To Lines  ${history_histogram}
    ${found_CP_numb}=  Get Match Count  ${lines_from_history_histogram}  *${rmod_dn}*
    Log     Number of found checkpoints for ${rmod_dn} is= ${found_CP_numb}.    console=${True}
    [Return]    ${found_CP_numb}


Custom Test Teardown
    Run Keyword If  ${RMOD_REMOVED}  Run Keywords
    ...    Log    \n----- Teardown: Commission BTS From Backup File-----    console=${True}
    ...    AND    coam.Perform Commissioning   scf_file=${BTS Files}/SCF.xml    skip_parameter_relation_errors=True    timeout=900
    ...    AND    Wait Until Keyword Succeeds  15m  20s  pm_logs_general.Check All Modules And All Cells Working States
    ...    AND    Log    All modules reached working state.  console=${True}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
