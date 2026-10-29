*** Settings ***
Documentation
...  author:        Bernd Hoffmann
...  contact:       Bernd.Hoffmann@nokia.com
...  Description:   Example how to use the syslog_parser in test environment

Library             OperatingSystem
Library             Process
Library             syslog_parser.py

*** Variables ***
${ts_log_dir}    /mnt/etfiles/users/li70968/tmp/syslog_parser

*** Test Cases ***
Verify SYSLOG Trace for CB008847-D
    ${syslog_dir}=  Set Variable  ${ts_log_dir}/TDD
    ${syslog_files}=  OperatingSystem.List Files In Directory  ${syslog_dir}  *.tgz
    ${num_of_files}=  Get Length  ${syslog_files}

    # IF   ${num_of_files}==1
    #    OperatingSystem.Run  tar zxvf ${syslog_dir}/${syslog_files}[0] -C ${syslog_dir}
    # ELSE
    #    Log to console  No syslog_files.tgz available
    # END
    # ${output}    OperatingSystem.Run  pwd
    # @{syslog_files_to_analyse}=  OperatingSystem.List Files In Directory  ${syslog_dir}  SYSLOG*.*
    # ${num_of_syslog_files}=  get length  ${syslog_files_to_analyse}

    ${EXCEPTIONFILE}=  Set Variable  testsuite/Ulm/ET/resources/syslog_parser/SYSLOG_EXCEPTION.TXT
    ${ERRORARRAYFILE}=  Set Variable  testsuite/Ulm/ET/resources/syslog_parser/SYSLOG_ARRAY.TXT
    ${REQUIREMENTFILE}=  Set Variable  testsuite/Ulm/ET/resources/syslog_parser/SYSLOG_REQUIREMENT.TXT

    IF   ${num_of_files}==1
        ${error_file}    Find Errors And Warnings In Logfile And Write Them Into Resultfile     ${syslog_dir}/${syslog_files}[0]
        ...    ignorefname=${EXCEPTIONFILE}     errordeffname=${ERRORARRAYFILE}     requirementfname=${REQUIREMENTFILE}
    ELSE
        Log To Console    No syslog_files.tgz available
    END
    OperatingSystem.File Should Be Empty  ${error_file}
