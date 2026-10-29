*** Settings ***
Documentation  Test for CB010239 DC verification
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Library     DateTime
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_EXTRACTED}  ${FALSE}

*** Keywords ***
TC__LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25772
    ...  ******************
    ...  Author: Iuliia Taupeka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-08-07 - TC created. version 1.0
    ...  - 2023-10-31 - TC released.
    ...  - 2024-03-20 - change coam.Run Diagnostic Check timeout in accordance to updated req OM_GEN_SFS_PERF_CAP.10677
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies the content of diagnostic report (inside the snapshot), after full Diagnostic Check execution via WebEM.
    ...  It checks correctnes of CP headers in DiagnosticReport csv file.
    ...  Two reports (from CLI response and from DiagnosticReport csv file from Snapshot are compared:
    ...  values like CP ID, timestamps, results, Distnames should be equal in both reports.
    ...  *******************


    Set Tags    CA-LOGS    OWNER-joanna.wolnicka@nokia.com    AUTHOR-iuliia.taupeka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com     PHASE-CRT    SW-SBTS23R4    FEATURE-CB010239-C

    Step 0: Precondition
    Step 1: Run DC And Get Diagnostic Report
    Step 2: Collect Snapshot And Save DiagnosticReport File
    Step 3: Verify DiagnosticReport File

Step 0: Precondition
    Log  \nStep 0: Precondition  console=${True}
    log to console    sw is:${active SW version}
    ${sw_build}  Fetch From Left  ${active SW version}    _
    Set Test Variable    ${software_version}  ${sw_build}

Step 1: Run DC And Get Diagnostic Report
    [Documentation]
    ...  In this step test:
    ...  - runs Diagnostic Check and gets Diagnostic Report.
    Log  \nStep 1: Run DC And Get Diagnostic Report.  console=${True}
    ${DC1_run_date}  DateTime.Get Current Date  exclude_millis=True  result_format=%Y-%m-%d %H:%M:%S
    Log    Timestamp before DC Start: ${DC1_run_date}. Sleep for 10s and run Diagnostic Check.    console=${True}
    ${DC1_run_date}  Replace String  ${DC1_run_date}  ${SPACE}  T
    Set Test Variable    ${DC1_run_date}
    Sleep    10s
    ${DC1_result}=    coam.Run Diagnostic Check    allow_service_impact=True    timeout=1830
    Log    First Diagnostic Check finished. [OK]    console=${True}
    Wait Until Keyword Succeeds   20m   30s   pm_logs_general.Check All Modules And All Cells Working States
    ${report_status}  coam.Get Diagnostic Report
    Set Test Variable    ${WebEM_report_result}    ${report_status}

Step 2: Collect Snapshot And Save DiagnosticReport File
    [Documentation]
    ...  In this step Snapshot is collected, DiagnosticReport file is found and extracted for analysis.
    Log  \nStep 2: Collect Snapshot And Save DiagnosticReport File.  console=${True}
    ${timestamp}  Get time
    ${timestamp}  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    Set Test Variable  ${timestamp}
    ${log_status}    Run Keyword And Ignore Error  coam.Collect snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=1800
    Run Keyword If  '${log_status[0]}'=='FAIL'
    ...    Fail  Collecting snapshot failed
    ...    ELSE
    ...    Log  Full snapshot is successfully collected  console=${True}
    Set Test Variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip
	${Diag_report}  Find And Extract DiagnosticReport File    ${path_to_snapshot}
    Set Test Variable    ${Diag_report}

Step 3: Verify DiagnosticReport File
    [Documentation]
    ...  In this step test compares 2 diagnostic reports (from CLI collected in step 1 and from DiagnosticReport.csv file in Snapshot)
    Log  \nStep 3: Verify DiagnosticReport File.  console=${True}
    Log  Verify correctness of CP attributes in csv file.  console=${True}
    ${diag_report_from_snap}    Convert CSV File    ${Diag_report}
    Should Be True    '${headers[0]}' == 'Check status'    CP parameter name incorrect: ${headers[0]}
    Should Be True    '${headers[1]}' == 'Check point'    CP parameter name incorrect: ${headers[1]}
    Should Be True    '${headers[2]}' == 'Check point name'    CP parameter name incorrect: ${headers[2]}
    Should Be True    '${headers[3]}' == 'Target distinguished name'    CP parameter name incorrect: ${headers[3]}
    Should Be True    '${headers[4]}' == 'Product name'    CP parameter name incorrect: ${headers[4]}
    Should Be True    '${headers[5]}' == 'Product code'    CP parameter name incorrect: ${headers[5]}
    Should Be True    '${headers[6]}' == 'Serial number'    CP parameter name incorrect: ${headers[6]}
    ###update PR04441331
    Should Be True    '${headers[7]}' == 'Check point details'    CP parameter name incorrect: ${headers[7]}
    Should Be True    '${headers[8]}' == 'Execution time'    CP parameter name incorrect: ${headers[8]}
    Should Be True    '${headers[9]}' == 'Trigger type'    CP parameter name incorrect: ${headers[9]}
    Should Be True    '${headers[10]}' == 'Last definitive check status'    CP parameter name incorrect: ${headers[10]}
    Should Be True    '${headers[11]}' == 'Execution time of last definitive status'    CP parameter name incorrect: ${headers[11]}
    Compare Diagostic Reports    ${WebEM_report_result}

Step 3: Verify DiagnosticReport Fileold
    [Documentation]
    ...  In this step test compares 2 diagnostic reports (from CLI collected in step 1 and from DiagnosticReport.csv file in Snapshot)
    Log  \nStep 3: Verify DiagnosticReport File.  console=${True}
    Log  Verify correctness of CP attributes in csv file.  console=${True}
    ${diag_report_from_snap}    Convert CSV File    ${Diag_report}
    Should Be True    '${headers[0]}' == 'Check point Id'    CP parameter name incorrect: ${headers[0]}
    Should Be True    '${headers[1]}' == 'Check point name'    CP parameter name incorrect: ${headers[1]}
    Should Be True    '${headers[2]}' == 'Distname'    CP parameter name incorrect: ${headers[2]}
    Should Be True    '${headers[3]}' == 'last definitive result timestamp'    CP parameter name incorrect: ${headers[3]}
    Should Be True    '${headers[4]}' == 'last definitive result'    CP parameter name incorrect: ${headers[4]}
    Should Be True    '${headers[5]}' == 'trigger type'    CP parameter name incorrect: ${headers[5]}
    Should Be True    '${headers[6]}' == 'timestamp'    CP parameter name incorrect: ${headers[6]}
    Should Be True    '${headers[7]}' == 'last result'    CP parameter name incorrect: ${headers[7]}
    Compare Diagostic Reports    ${WebEM_report_result}


Compare Diagostic Reports
    [Documentation]
    ...  This KW compares 2 diagnostic reports:
    ...  - one get from CLI response;
    ...  - second one - extracted Diagnostic Report csv file from Snapshot.
    ...  For compare purposes CPs headers are modified: spaces are removed and titles changed to lower case.
    ...  Values in both reports should be equal (timestamps, CP results, CP name, distname..).
    [Arguments]    ${WebEM_report}
    ${diag_report_from_csv_len}    Get Length    ${lines_from_diag_report}
    ${WebEM_report_len}    Get Length    ${WebEM_report}
    Run Keyword If    '${diag_report_from_csv_len}' == '${WebEM_report_len}'    Log    Reports length are equal(total num of CPs)    console=${True}
    Log    Values from 2 reports (from CLI and from Snapshot csv file) will be compared.    console=${True}
    FOR  ${i}  IN RANGE  0  ${diag_report_from_csv_len}
        ${csv_cp}=    Set Variable    ${lines_from_diag_report[${i}]}
        ${csv_cp}    Remove Spaces And Convert To LowerCase    ${csv_cp}
        ${csv_cp}    Set Variable    ${csv_cp.replace(",,", ",")}
        ${csv_cp}    Set Variable    ${csv_cp.rstrip(",")}
        ${CLI_CP}=    Get Dictionary Values   ${WebEM_report[${i}]}    sort_keys=False
        ${CLI_CP}    Convert To String    ${CLI_CP}
        ${CLI_CP}    Remove Spaces And Convert To LowerCase    ${CLI_CP}
        ${CLI_CP}    Set Variable    ${CLI_CP.replace("'", "")}
        ${CLI_CP}    Remove String    ${CLI_CP}    [    ]
        ${CLI_CP}    Set Variable    ${CLI_CP.replace(",,", ",")}
        ${CLI_CP}    Set Variable    ${CLI_CP.rstrip(",")}
        ${status}    Run Keyword And Return Status    Should Be Equal   ${csv_cp}  ${CLI_CP}
        Run Keyword If    ${status}
        ...    Log    CP ${lines_from_diag_report[${i}]} equal in both reports.    console=${True}
        ...    ELSE   verdicts.Set Test Failed  CP ${lines_from_diag_report[${i}]} results from Snapshot are different.  ${False}
    END

Remove Spaces And Convert To LowerCase
    [Documentation]
    ...  This KW prepares CP keys for comparison: spaces are removed, CP titles are changed to lower case, None values changed to epmty.
    [Arguments]    ${string}
    ${modified_string}    Set Variable    ${string.replace(" ", "")}
    ${modified_string}    Convert To Lower Case    ${modified_string}
    ${modified_string}    Set Variable    ${modified_string.replace("none", "")}
    [Return]    ${modified_string}


Find And Extract DiagnosticReport File
    [Documentation]
    ...  This KW searches for DiagnosticReport File in Snapshot and extracts it for further verification.
    ...  |  Parameters     | Man. |  Description         |
    ...  |  snapshot_path  | Yes  |  path to Snapshot    |
    ...
    ...  *RETURN*
    ...  |  Parameters      |  Description           |
    ...  |  extracted_file  |  Path to extracted DiagnosticReport File |
    [Arguments]    ${snapshot_path}
    Log  Find And Extract DiagnosticReport File  console=${True}
    ${snapshot_dict}    snapshot.Get Data From Snapshot    ${snapshot_path}
    FOR  ${key}  IN  @{snapshot_dict.keys()}
        ${MATCHES}  get regexp matches  ${snapshot_dict["${key}"][0]}  .*011_DiagnosticReport.csv.xz
        run keyword if  ${MATCHES}  run keywords
        ...  Log  DiagnosticReport file: ${MATCHES[0]} found  console=${True}
        ...  AND  Set Test Variable  ${MATCHES}    ${MATCHES}
        ...  AND  Exit For Loop
    END
    ${extracted_file}    Extract log file    ${snapshot_path}    ${MATCHES[0]}
    Log To Console    Extracted file: ${extracted_file}
    #run keyword unless  ${MATCHES}  Fail  DiagnosticReport file not found
    run keyword if  not ${MATCHES}  Fail  DiagnosticReport file not found
    [Return]    ${extracted_file}

Extract log file
    [Documentation]
    ...  Keyword used to extract DiagnosticReport file from snapshot.
    ...  |  Parameters               | Man. |  Description         |
    ...  |  snapshot_path            | Yes  |  path to Snapshot    |
    ...  |  path_to_extracting_file  | Yes  |  path to Snapshot    |
    ...  *RETURN*
    ...  |  Parameters           |  Description           |
    ...  |  extracted_file_path  |  Path to extracted DiagnosticReport File |
    [Arguments]    ${snapshot_path}    ${path_to_extracting_file}
    Log   Start extracting DiagnosticReport file for further analysis    console=${True}

    run keyword if  not ${SNAPSHOT_EXTRACTED}
    ...  unpacking.Unpack Archive Content To Directory  ${snapshot_path}  ${BTS_Files}/snapshot_${timestamp}
    set test variable  ${SNAPSHOT_EXTRACTED}  ${TRUE}
    ${zip_from_extract}  get regexp matches  ${path_to_extracting_file}  [\\w.]+
    ${log_to_extract}  replace string using regexp  ${zip_from_extract[0]}  (.zip)  ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}  ${BTS_Files}/DiagnosticReport

    ${unzipped_log_name}  replace string using regexp  ${zip_from_extract[1]}  (.xz)  ${EMPTY}
    ${extracted_file_path}    Set Variable    ${BTS_Files}/DiagnosticReport/${unzipped_log_name}
    [Return]  ${extracted_file_path}

Convert CSV File
    [Documentation]
    ...  Keyword used to convert Diagnostic Report from csv file to list of dictionaries.
    [Arguments]    ${path_to_csv}
    ${diag_report_csv}  OperatingSystem.Get File  ${path_to_csv}  encoding_errors=ignore
    Set Test Variable  ${diag_report_csv}
    @{lines_from_diag_report}  Split To Lines  ${diag_report_csv}
    ${headers}=    Set Variable    ${lines_from_diag_report[0]}
    @{headers}  Split String  ${headers}  ,
    Set Test Variable    @{headers}
    Remove From List  ${lines_from_diag_report}  0
    Set Test Variable    ${lines_from_diag_report}
    ${diagnostic_report_list}=    Create List
    FOR  ${line}  IN  @{lines_from_diag_report}
        @{values}  Split String  ${line}  ,
        ${CP_dictionary}  Create DiagReport Dictionary  ${headers}  @{values}
        ${CP_dictionary_lenght}  Get Length  ${CP_dictionary}
        Run Keyword if  not ${CP_dictionary_lenght}==0    Append To List    ${diagnostic_report_list}    ${CP_dictionary}
    END
    [Return]    ${diagnostic_report_list}

Create DiagReport Dictionary
    [Documentation]
    ...  This keyword assigns from CP line in csv each parameter to appropriate key - separate dictionary for CP.
    [Arguments]  ${headers}    @{values}
    ${values_length}  Get Length  ${values}
    ${checkpoint_dictionary}  Create Dictionary
    Run Keyword If  ${values_length}==8  Run Keywords
    ...  Set To Dictionary  ${checkpoint_dictionary}  ${headers[0]}  ${values[0]}
    ...  AND  Set To Dictionary  ${checkpoint_dictionary}  ${headers[1]}  ${values[1]}
    ...  AND  Set To Dictionary  ${checkpoint_dictionary}  ${headers[2]}  ${values[2]}
    ...  AND  Set To Dictionary  ${checkpoint_dictionary}  ${headers[3]}  ${values[3]}
    ...  AND  Set To Dictionary  ${checkpoint_dictionary}  ${headers[4]}  ${values[4]}
    ...  AND  Set To Dictionary  ${checkpoint_dictionary}  ${headers[5]}  ${values[5]}
    ...  AND  Set To Dictionary  ${checkpoint_dictionary}  ${headers[6]}  ${values[6]}
    ...  AND  Set To Dictionary  ${checkpoint_dictionary}  ${headers[7]}  ${values[7]}
    ...  ELSE  Log  Incorrect line in diag report file: ${values}  WARN  console=yes
    [return]  ${checkpoint_dictionary}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
