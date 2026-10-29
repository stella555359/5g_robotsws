*** Settings ***
Documentation
    ...    This test case is used to verify KPI Duration of PM Collection on vCU
    ...    History of changes:     21.11.2025 - Initial creation
    ...    Author:         jakub.kokoszka@nokia.com

*** Variables ***
${PmReportingFormat_changes}        ${False}    #Used to track if PmReportingFormat was changed during test
${IntervalPm_changes}               ${False}    #Used to track if IntervalPm was change during test

*** Keywords ***
OAMKPI PM Collection vCU
    [Documentation]
    ...    This test case is used to verify the correct generation and naming convention of PM files
    ...    (both OMeS and 3GPP formats) on a vCU. It configures the PM collection parameters,
    ...    waits for PM reports, retrieves the generated files, and validates their names against expected patterns.
    ...    The test runs for a specified number of iterations and ensures proper cleanup of configuration changes.
    [Timeout]    12h
    [Arguments]    ${test_iterations}


    ${mrbts_id}    ${nrbts_id}    Get MRBTS and NRBTS IDs    vCU
    Set Test Variable    ${PMCADM_DN}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
    Change Parameters activeBulkPmReportingFormat and reportingIntervalPm

    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}    Evaluate    ${i} + 1
        Log To Console    \n--- Execution loop: ${index} ---\n
        ${files_from_iteration}=    Set Variable  ${SUITE_LOGS_DIR_PATH}/PM_files_from_${index}_iteration
        OperatingSystem.Create Directory    ${files_from_iteration}
        Log to console    Waiting for next interval PM report...
        Sleep Until Next PM File Appears
        ${today}=    Get Current Date    result_format=%Y%m%d
        Log to console    Downloading OmeS and 3GPP PM files list...
        ${output_OmeS}    ${output_3GPP}     Get PM Files From oampm pod
        ${output_OmeS_str}=    Convert To String    ${output_OmeS}
        ${output_3GPP_str}=    Convert To String    ${output_3GPP}
        Create File    ${files_from_iteration}/PM_OmeS_files_${index}_iteration.txt    ${output_OmeS_str}
        Create File    ${files_from_iteration}/PM_3GPP_files_${index}_iteration.txt    ${output_3GPP_str}
        ${last_record_OmeS}    Get Last Record From Output    ${output_OmeS}
        ${last_record_3GPP}    Get Last Record From Output    ${output_3GPP}
        ${OmeS_record}    Extract CleanFile FromLine    ${last_record_OmeS}
        ${3GPP_record}    Extract CleanFile FromLine    ${last_record_3GPP}
        Log To Console    Last OmeS record: ${OmeS_record}
        Log To Console    Last 3GPP record: ${3GPP_record}
        Log To Console    Checking OmeS and 3GPP PM files pattern...
        Run Keyword And Continue On Failure    Validate PM File Names
        ...    ${OmeS_record}    ${3GPP_record}    ${mrbts_id}    ${today}
    END
    [Teardown]    OAMKPI_PM_Collection_vCU.Custom Test Teardown

Validate PM File Names
    [Documentation]
    ...    Validates the naming convention of OMeS and 3GPP PM files against predefined regular expressions.
    ...    Expected OMeS pattern:
    ...    <File_Type><Measurement_Start_Date>.<Measurement_Start_Time>-<Measurement_End_Date>.<Measurement_End_Time>_<BTS_Id>.xml.gz
    ...    Expected 3GPP pattern:
    ...    <Type><YYYY><MM><DD>.<HH><MM><s><hh><mm>-<YYYY><MM><DD>.<HH><MM><s><hh><mm>_ManagedElement=MRBTS-<MRBTS.mrbtsid>.xml.gz
    [Arguments]    ${OmeS_record}    ${3GPP_record}    ${mrbts_id}    ${today}

    # Regex dla OmeS
    ${regex_omes}=    Set Variable    [A-Z]${today}\\.\\d{4,6}[+-]\\d{4}-${today}\\.\\d{4,6}[+-]\\d{4}_MRBTS-${mrbts_id}_\\d+\\.xml\\.gz
    Should Match Regexp    ${OmeS_record}    ${regex_omes}    OmeS record does not match expected pattern!
    Log To Console    OmeS record "${OmeS_record}" matches expected pattern.
    #OmeS patters:
    #<File_Type><Measurement_Start_Date>.<Measurement_Start_Time>-<Measurement_End_Date>.<Measurement_End_Time>_<BTS_Id>.xml.gz

    # Regex dla 3GPP
    ${regex_3gpp}=    Set Variable    [A-Z]${today}\\.\\d{4,6}[+-]\\d{4}-${today}\\.\\d{4,6}[+-]\\d{4}_ManagedElement=MRBTS-${mrbts_id}\\.xml(\\.gz)?
    Should Match Regexp    ${3GPP_record}    ${regex_3gpp}    3GPP record does not match expected pattern!
    Log To Console    3GPP record "${3GPP_record}" matches expected pattern.
    #<Type><YYYY><MM><DD>.<HH><MM><s><hh><mm>-<YYYY><MM><DD>.<HH><MM><s><hh><mm>_ManagedElement=MRBTS-<MRBTS.mrbtsid>.xml.gz

Extract CleanFile FromLine
    [Documentation]
    ...    Extracts and cleans a PM file name from a given line of text, typically from an 'ls -l' command output.
    ...    It expects the file name to start with an uppercase letter followed by '20' (e.g., part of a date).
    [Arguments]    ${line}

    ${matches}=    Get Regexp Matches    ${line}    '?[A-Z]20.*
    Should Not Be Empty    ${matches}
    ${file}=    Get From List    ${matches}    0
    ${file}=    Replace String    ${file}    '    ${EMPTY}
    [Return]    ${file}

Get Last Record From Output
    [Documentation]
    ...    Parses the output of a directory listing command (e.g., 'ls -l') and returns the last
    ...    (most recent) line that contains a PM file name (ending with ".xml.gz").
    [Arguments]    ${output}

    ${lines}=    Split To Lines    ${output}
    @{files}=    Create List
    FOR    ${line}    IN    @{lines}
        ${line}=    Strip String    ${line}
        IF    ".xml.gz" in "${line}"
            Append To List    ${files}    ${line}
        END
    END
    ${last_file}=    Get From List    ${files}    -1
    [Return]    ${last_file}

Get PM Files From oampm pod
    [Documentation]
    ...    Connects to the vCU K8s master node and retrieves the list of OMeS and 3GPP PM files
    ...    from their respective directories on the 'po-oampm-0' pod using 'kubectl exec ls -l'.

    ${cmd_OmeS}=    Catenate    SEPARATOR=
    ...  date; kubectl exec -it -n ${CRAN_VCU} po-oampm-0 -c ctr-oampm${SPACE}
    ...  -- ls -l /mnt/services/SS_OAM/PMSTAT/pm_result_files --time-style="+%Y%m%d.%H%M%S"; date
    ${cmd_3GPP}=    Catenate    SEPARATOR=
    ...  date; kubectl exec -it -n ${CRAN_VCU} po-oampm-0 -c ctr-oampm${SPACE}
    ...  -- ls -l /mnt/services/SS_OAM/PMSTAT/pm_result_files_3GPP --time-style="+%Y%m%d.%H%M%S"; date
    common_vcu.Connect To vCU K8s Master Node With Tenant
    ${output_OmeS}=    issh.Execute        ${cmd_OmeS}
    ${output_3GPP}=    issh.Execute        ${cmd_3GPP}
    Run Keyword And Ignore Error    Disconnect Interactive Connection
    [Return]    ${output_OmeS}    ${output_3GPP}

Sleep Until Next PM File Appears
    [Documentation]
    ...    Calculates and performs a sleep to synchronize test execution with the next 5-minute
    ...    PM reporting interval, ensuring new PM files are generated. It adds a buffer to account for processing time.
    [Arguments]    ${buffer_sec}=120

    ${cmd}=    Catenate    SEPARATOR=
    ...    ((5 - __import__('datetime').datetime.now().minute % 5)*60${SPACE}
    ...    - __import__('datetime').datetime.now().second + ${buffer_sec})
    ${total_seconds}=    Evaluate    ${cmd}
    Log to console    Sleeping for ${total_seconds} seconds until next reportingIntervalPm apperes.
    Sleep    ${total_seconds}s

Custom Test Teardown
    [Documentation]
    ...    A custom teardown keyword that reverts any configuration changes made during the test execution.
    ...    It checks the internal flags (${PmReportingFormat_changes}, ${IntervalPm_changes})
    ...    to determine if 'activeBulkPmReportingFormat' or 'reportingIntervalPm' were modified,
    ...    and if so, calls the appropriate keywords to restore their original values.

    Run Keyword If    ${PmReportingFormat_changes}
    ...    Run Keywords    Remove activeBulkPmReportingFormat    AND
    ...    Set Test Variable    ${PmReportingFormat_changes}        ${False}
    Run Keyword If    ${IntervalPm_changes}
    ...    Run Keywords    Change reportingIntervalPm    AND
    ...    Set Test Variable    ${IntervalPm_changes}        ${False}
