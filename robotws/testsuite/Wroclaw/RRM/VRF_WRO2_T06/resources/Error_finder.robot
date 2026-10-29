*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Library     OperatingSystem
Library     Collections
Library     String
Library     testsuite/Wroclaw/RRM/resources/syslog_checker.py

*** Variables ***
${LOGS_PATH}                ${OUTPUT DIR}/Logs
${LOGS_PATH_REMOTE_HOST}    ${OUTPUT DIR}

*** Keywords ***
Find Errors in gNB Syslog
    [Documentation]    For list of accepted ERRORS in syslog please visit https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1637010227
    [Arguments]    ${base_dir}=${OUTPUT DIR}    ${output_dir}=${OUTPUT DIR}    ${output_file}=errors_prints_in_gNB_syslog.txt
    ${full_output_path}=    Set Variable    ${output_dir}/${output_file}
    ${command_syslog_file_with_name_syslog_gnb}=    Set Variable
    ...    find "${base_dir}" -type f -name "*syslog*_gnb*.log" -exec grep -H "ERR/" {} \\; | tee -a "${full_output_path}"
    Run    ${command_syslog_file_with_name_syslog_gnb}
    ${command_syslog_file_with_name_gnb_syslog}=    Set Variable
    ...    find "${base_dir}" -type f -name "*gnb*_syslog*.log" -exec grep -H "ERR/" {} \\; | tee -a "${full_output_path}"
    Run    ${command_syslog_file_with_name_gnb_syslog}
    Log    Error lines have been written to ${full_output_path} and printed to the console.

Find Errors in Iphy Syslog
    [Arguments]    ${base_dir}=${OUTPUT DIR}    ${output_dir}=${OUTPUT DIR}    ${output_file}=errors_prints_in_iphy_syslog.txt
    ${full_output_path}=    Set Variable    ${output_dir}/${output_file}
    ${command}=    Set Variable
    ...    find "${base_dir}" -type f -name "iphy*_syslog*.log" -exec grep -H "ERR/" {} \\; | tee -a "${full_output_path}"
    Run    ${command}
    Log    Error lines have been written to ${full_output_path} and printed to the console.

Find Errors in Egate console log
    [Arguments]    ${base_dir}=${OUTPUT DIR}    ${output_dir}=${OUTPUT DIR}    ${output_file}=errors_prints_in_egate.txt
    ${input_path}=    Set Variable    /opt/iphy/latest/egate_console.log
    ${output_path}=    Set Variable    ${output_dir}/${output_file}
    ${command_egate_file_in_latest_dir}=    Set Variable
    ...    grep -HiE "mERR|mACR|Crash|Segmentation fault" /opt/iphy/latest/egate_console.log | tee -a "${output_path}"
    Run    ${command_egate_file_in_latest_dir}
    ${command_egate_file_copied_to_output_dir}=    Set Variable
    ...    find "${base_dir}" -type f -name "egate_console.log" -exec grep -HiE "mERR|mACR|Crash|Segmentation fault" {} \\; | tee -a "${output_path}"
    Run    ${command_egate_file_copied_to_output_dir}
    Log    Error lines have been written to ${output_path} and printed to the console.

Find Errors Old
    [Arguments]    ${base_dir}=${OUTPUT DIR}    ${output_dir}=${OUTPUT DIR}
    Find Errors in Egate console log    ${base_dir}    ${output_dir}
    Find Errors in gNB Syslog    ${base_dir}    ${output_dir}
    Find Errors in Iphy Syslog    ${base_dir}    ${output_dir}

Find Errors
    [Arguments]    ${remote_host}=False    ${base_dir}=${OUTPUT DIR}    ${output_dir}=${OUTPUT DIR}
    ${suite_file}=    Set Variable    ${SUITE_SOURCE}
    ${original_suite_name}=    Evaluate    os.path.splitext(os.path.basename(r"""${suite_file}"""))[0]    modules=os
    ${syslog_path_WRO6}=    Run Keyword If    '${remote_host}'=='True'    Set Variable    ${LOGS_PATH_REMOTE_HOST}/${TEST_NAME}
    ...    ELSE    Set Variable    ${LOGS_PATH}/${original_suite_name}/${TEST_NAME}
    Run Keyword And Ignore Error    Find Suspicious Logs
    Run Keyword And Ignore Error    Execute Syslog Error Filtering    ${syslog_path_WRO6}
    Run Keyword And Ignore Error    Find Errors in Egate console log    ${base_dir}    ${output_dir}

Execute Syslog Error Filtering
    [Arguments]    ${syslog_path}
    [Documentation]    Executes a bash command to find and filter 'syslog_report.txt' files for errors.
    ...    The command searches for 'syslog_report.txt' files under the given path,
    ...    filters out specific log messages, and saves the remaining lines to a new file
    ...    named '{original_filename}_errors.txt' in the same directory.

    # Defensive check: Ensure syslog_path is a string.
    # If it somehow became a list (e.g., ['/path/to/logs']), extract the first element.
    ${path_to_use}=    Set Variable    ${syslog_path}
    IF    "${syslog_path.__class__.__name__}" == "list"
        ${path_to_use}=    Set Variable    ${syslog_path}[0]
        Log To Console    DEBUG: Corrected syslog_path from list to string: ${path_to_use}
    END

    ${bash_command}=    Catenate    SEPARATOR=
    ...    find "${path_to_use}" -type f -name "syslog_report.txt" -exec bash -c '
    ...    grep -v "192.168.200.1" {} |
    ...    grep -v "Log expected on simulator environment" |
    ...    grep -v "Log may be expected in some simulator environment. Issue may be located in L1/RF" |
    ...    grep -v "WRN/" > {}_errors.txt
    ...    ' \\;

    Log To Console    Executing command: ${bash_command}
    ${output}=    Run    ${bash_command}
    # Call the keyword to find and log error file contents, and capture its return value
    ${file_content}=    OperatingSystem.get file    ${path_to_use}/syslog_report.txt_errors.txt
    Log    ${file_content}
