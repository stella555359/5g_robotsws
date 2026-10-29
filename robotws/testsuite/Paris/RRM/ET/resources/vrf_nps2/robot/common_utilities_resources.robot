*** Settings ***
Documentation     Usefull Keywords
...               author: Abderrahmane NEZROUk
...               date: 01/07/2025

Library    OperatingSystem
Library    String
Library    Collections

Library    ../python/pm_utilities.py



*** Keywords ***
Suite Dir Preparation
  [Documentation]    Generic keyword for all test suite.
  ...    This keyword prepares the directory structure for a Robot Framework test suite. It creates necessary
  ...    subdirectories and files based on the provided test.
  ${timestamp}=       Get Current Date    result_format=%Y%m%d_%H%M%S
  ${suite_dir}        replace string      ${SUITE NAME}_${timestamp}    ${SPACE}    _
  ${suite_dir}        joinpath            ${OUTPUTDIR}/Logs/${ENB_BRANCH}     ${suite_dir}
  Create Directory    ${suite_dir}
  Set Suite variable   ${PATH_Storage}     ${suite_dir}

Test Case Dir Preparation
  [Documentation]    This keyword prepares the directory structure for a specific Robot Framework test case
  ...    within a test suite. It creates necessary subdirectories and files based on the provided test case.
  ${directory}        replace string      ${TEST NAME}    ${SPACE}    _
  ${LOG_PATH}         joinpath        ${PATH_Storage}     ${directory}
  Create Directory    ${LOG_PATH}
  Set Suite Variable   ${LOG_PATH}

Save PI Data To JSON File
    [Arguments]    ${pi_list}    ${pi_dir}    ${mos_list}=${None}    ${pi_file_pattern}=PM.*
    ...     ${m_period}=${5}    ${intervals}=${None}    ${before}=${False}
    ...     ${out_dir}=${None}    ${filename_prefix}=results
    [Documentation]    Saves PI (Performance Indicator) data to JSON file
    ...                Arguments:
    ...                - pi_list: List of PI identifiers to process
    ...                - pi_dir: Directory containing PI files
    ...                - mos_list: Optional list of Managed Objects (default: None)
    ...                - pi_file_pattern: File pattern to match PI files (default: *.PM.*)
    ...                - m_period: Measurement period in minutes (default: 5)
    ...                - intervals: Optional intervals specification (default: None)
    ...                - before: Boolean flag for before/after comparison (default: False)
    ...                - out_dir: Output directory for JSON file (default: None)
    ...                - filename: Output filename without extension (default: results)

    ${json_path}=    pm_utilities.save_pi_to_json
    ...    pi_list=${pi_list}
    ...    pi_dir=${pi_dir}
    ...    mos_list=${mos_list}
    ...    pi_file_pattern=${pi_file_pattern}
    ...    m_period=${m_period}
    ...    intervals=${intervals}
    ...    before=${before}
    ...    out_dir=${out_dir}
    ...    filename_prefix=${filename_prefix}
    [Return]    ${json_path}

Validate Counters Values From Json File
    [Arguments]    @{counter_args}    ${pm_json_file}    ${mo}    ${timestamp}    ${before}    ${m_period}
    [Documentation]    Calls the validate_counters Python function with positional and keyword arguments
    ...                Arguments:
    ...                - pm_json_file: Path to PM JSON file
    ...                - mo: Managed Object identifier
    ...                - timestamp: Timestamp string
    ...                - before: Boolean flag indicating before/after validation
    ...                - counter_args: Variable number of counter arguments
    ${false_items}=    Create List

    ${results}=    pm_utilities.validate_counters
    ...    @{counter_args}    pm_json_file=${pm_json_file}    mo=${mo}
    ...    timestamp=${timestamp}    before=${before}    m_period=${m_period}
    log     ${results}    console=${True}
    FOR    ${item}    IN    @{results}
        FOR    ${key}    IN    @{item.keys()}
            IF    ${item}[${key}] == ${False}
                Append To List    ${false_items}    ${key}
            END
        END
    END
    IF    ${false_items}
        ${error_msg}=    Set Variable    Comparison failures found: ${false_items}
        Fail    ${error_msg}
    END
