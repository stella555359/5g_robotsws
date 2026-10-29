*** Settings ***
Documentation    Test keyword resource file for CB008409-B

Library    OperatingSystem
Library    Process
Library    ../../../../resources/Common/syslog_parser/syslog_parser.py



*** Keywords ***
Verify Errors and Warnings in SYSLOG Trace
    [Arguments]    ${EXCEPTIONFILE}=SYSLOG_EXCEPTION.txt
    ${syslog_files}=  OperatingSystem.List Files In Directory  ${syslog_dir}  *.tgz
    ${num_of_files}=  get length  ${syslog_files}

    ${EXCEPTIONFILE}=  Set Variable    ${CURDIR}/${EXCEPTIONFILE}
    ${error_file}=  IF  ${num_of_files}==1
    ...    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...    ${syslog_dir}/${syslog_files}[0]
    ...    ignorefname=${EXCEPTIONFILE}
    ...    ELSE  Log to console    No syslog_files.tgz available

    OperatingSystem.File Should Be Empty  ${error_file}
