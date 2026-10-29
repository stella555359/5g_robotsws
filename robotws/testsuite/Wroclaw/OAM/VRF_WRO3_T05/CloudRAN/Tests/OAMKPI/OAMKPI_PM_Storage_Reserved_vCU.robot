*** Settings ***
Documentation
    ...    This test case checks the OAMKPI PM Storage Reserved on vCU.
    ...    It verifies that the storage space available for PM files is sufficient
    ...    and ensures that the parameters 'activeBulkPmReportingFormat' and 'reportingIntervalPm'
    ...    are set correctly. Additionally, it validates the uptime of the vCU before starting the test.
    ...    History of changes: 21.11.2025 - Initial creation
    ...    Author: jakub.kokoszka@nokia.com

*** Variables ***
${PmReportingFormat_changes}        ${False}    # Used to track if PmReportingFormat was changed during test
${IntervalPm_changes}               ${False}    # Used to track if IntervalPm was changed during test
${dummy_file_created}               ${False}    # Used to track if dummy file was created
${REQUIRED_MB}                      1000        # Minimum required space in MB for PM files
${REQUIRED_GB}                      1.0         # Minimum required space in GB for PM files
${DUMMY_PM_FILE_NAME}               test_KPI.xml.gz    #PM dummy file name

*** Keywords ***
OAMKPI PM Storage Reserved vCU
    [Documentation]
    ...    This test case checks the OAMKPI PM Storage Reserved on vCU.
    ...    It ensures that the available storage space for PM files is sufficient
    ...    and validates the uptime of the vCU before starting the test.


    Log to console    Starting test case: OAMKPI PM Storage Reserved vCU
    ${mrbts_id}    ${nrbts_id}    Get MRBTS and NRBTS IDs    vCU
    Set Test Variable    ${PMCADM_DN}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
    Log to console    Change Parameters activeBulkPmReportingFormat and reportingIntervalPm
    Change Parameters activeBulkPmReportingFormat and reportingIntervalPm

    ${uptime}    Get vCU Uptime
    Run Keyword If    int(${uptime}) > 86400
    ...    Log    Uptime of vCU is more than 24h. Starting test.  console=${True}
    ...    ELSE    Run Keywords
    ...    Log    Uptime of vCU ${uptime}s is less than 24hs.    console=${True}
    ...    AND    Wait For vCU 24h Uptime    ${uptime}

    common_vcu.Connect To vCU K8s Master Node With Tenant

    ${output_space}    Check storage space for PM files
    ${used_space}=    Get Disk Space Value    ${output_space}
    ${used_space_num}=    Replace String    ${used_space}    M    ${EMPTY}
    ${used_space_num}=    Convert To Integer    ${used_space_num}
    ${min_free_space}=    Evaluate    1000 - ${used_space_num}
    Log to console    Used PM Space before test: ${used_space}

    Log to console    Create And Copy Dummy PM File And Verify Reserved Storage
    issh.Execute
    ...    dd if=/dev/zero of=${DUMMY_PM_FILE_NAME} bs=1M count=${min_free_space}
    issh.Execute
    ...    kubectl cp ${DUMMY_PM_FILE_NAME} ${CRAN_VCU}/po-oampm-0:/mnt/services/SS_OAM/PMSTAT/pm_result_files/
    Set Test Variable    ${dummy_file_created}    ${True}
    ${output_space}    Check storage space for PM files
    ${used_space}=    Get Disk Space Value    ${output_space}
    Log to console    Used Space After Dummy File Copy: ${used_space}

    ${check_if_space_ok}    Check Used Space   ${used_space}

    Run Keyword And Ignore Error    Disconnect Interactive Connection

    [Teardown]    OAMKPI_PM_Storage_Reserved_vCU.Custom Test Teardown

Check Used Space
    [Documentation]    Validates if the available space meets the required threshold.
    ...                 Arguments:
    ...                 - ${used_space}: The available space as a string (e.g., '500M', '2.5G').
    ...                 The keyword extracts the numeric value and unit from ${used_space},
    ...                 compares it against predefined thresholds (${REQUIRED_MB} for MB and ${REQUIRED_GB} for GB),
    ...                 and logs the result or fails if insufficient.
    [Arguments]    ${used_space}

    ${value}=    Evaluate    float(''.join([c for c in '${used_space}' if c.isdigit() or c=='.']))
    ${units}=    Evaluate    ''.join([c for c in '${used_space}' if not c.isdigit() and c != '.']).strip()

    IF    '${units}'.upper() == 'M'
        IF    ${value} >= ${REQUIRED_MB}
            Log to console    Value in MB is sufficient: ${value} MB
        ELSE
            Fail    Not enough space in MB! Current: ${value} MB, required: ${REQUIRED_MB} MB
        END
    ELSE IF    '${units}'.upper() == 'G'
        IF    ${value} >= ${REQUIRED_GB}
            Log to console    Value in GB is sufficient: ${value} GB
        ELSE
            Fail    Not enough space in GB! Current: ${value} GB, required: ${REQUIRED_GB} GB
        END
    ELSE
        Fail    Unknown unit: ${units}. Unable to verify free space.
    END

Get Disk Space Value
    [Documentation]
    ...    Extracts the disk space value from the given output.
    [Arguments]    ${output}
    ${lines}=    Split String    ${output}    \n
    ${value}=    Set Variable    ${EMPTY}

    FOR    ${line}    IN    @{lines}
        ${line}=    Strip String    ${line}
        ${line}=    Replace String    ${line}    \r    ${EMPTY}
        ${is_number}=    Run Keyword And Return Status    Should Match Regexp    ${line}    ^[0-9]

        IF    ${is_number}
            ${parts}=    Split String    ${line}
            ${value}=    Set Variable    ${parts}[0]
            Exit For Loop
        END
    END

    Should Not Be Empty    ${value}    No disk space value found
    Log to console    Extracted disk space value: ${value}
    [Return]    ${value}

Check storage space for PM files
    [Documentation]
    ...    Checks the storage space used for PM files on the vCU.
    ${cmd}=    Catenate    SEPARATOR=
    ...    date; kubectl exec -it -n ${CRAN_VCU} po-oampm-0 -c ctr-oampm -- du -sh${SPACE}
    ...    /mnt/services/SS_OAM/PMSTAT
    Log    Executing command: ${cmd}
    ${output_space}=    issh.Execute    ${cmd}
    [Return]    ${output_space}

Wait For vCU 24h Uptime
    [Documentation]
    ...    Waits until the vCU uptime reaches 24 hours.
    [Arguments]    ${uptime}
    ${remaining_time}=    Evaluate    86400 - int(${uptime})
    Log to console    Waiting ${remaining_time} seconds for vCU to reach 24 hours uptime.
    Sleep    ${remaining_time}s

Custom Test Teardown
    [Documentation]
    ...    A custom teardown keyword that reverts any configuration changes made during the test execution.
    ...    It checks the internal flags (${PmReportingFormat_changes}, ${IntervalPm_changes})
    ...    to determine if 'activeBulkPmReportingFormat' or 'reportingIntervalPm' were modified,
    ...    and if so, calls the appropriate keywords to restore their original values.
    ...    Additionally, it removes the dummy PM file if it was created during the test.

    Run Keyword If    ${PmReportingFormat_changes}
    ...    Run Keywords    Remove activeBulkPmReportingFormat    AND
    ...    Set Test Variable    ${PmReportingFormat_changes}    ${False}
    Run Keyword If    ${IntervalPm_changes}
    ...    Run Keywords    Change reportingIntervalPm    AND
    ...    Set Test Variable    ${IntervalPm_changes}    ${False}

    Run Keyword If    ${dummy_file_created}
    ...    Run Keywords    Run Keyword And Ignore Error    Disconnect Interactive Connection    AND
    ...    common_vcu.Connect To vCU K8s Master Node With Tenant    AND
    ...    issh.Execute
    ...    kubectl exec -it -n ${CRAN_VCU} po-oampm-0 -c ctr-oampm -- rm /mnt/services/SS_OAM/PMSTAT/pm_result_files/${DUMMY_PM_FILE_NAME}    AND
    ...    issh.Execute    rm ${DUMMY_PM_FILE_NAME}    AND
    ...    Run Keyword And Ignore Error    Disconnect Interactive Connection    AND
    ...    Set Test Variable    ${dummy_file_created}    ${False}
