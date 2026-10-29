*** Settings ***
Documentation
...  Description:   Example how to use the syslog_parser in test environment

Library             OperatingSystem
Library             Process
Library             syslog_parser.py

*** Variables ***
${ts_log_dir}    /home/ute/csamson/7-20-UTE5GCLASSTL113/tools_for-vm-ute/TLConfig/CrtResults_20250622_052734/CB013715_C_template_test_NSA_F

*** Test Cases ***
Verify SYSLOG Trace
    ${syslog_dir}=  Set Variable  ${ts_log_dir}/btslog
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

    ${absolut_path_to_NPS}=    evaluate    str(Path(__file__).parents[3])
    BuiltIn.log    absolut_path_to_NPS=${absolut_path_to_NPS}    console=True
    ${EXCEPTIONFILE}    catenate    ${absolut_path_to_NPS} "/syslog_parser/SYSLOG_ERROR_EXCEPTION.TXT"
    ${REQUIREMENTFILE}    catenate    ${absolut_path_to_NPS}  "/syslog_parser/SYSLOG_ERROR_REQUIREMENT.TXT"
    BuiltIn.log    EXCEPTIONFILE=${EXCEPTIONFILE}    console=True
    BuiltIn.log    REQUIREMENTFILE=${REQUIREMENTFILE}    console=True

    IF   ${num_of_files}==1
        ${error_file}    Find Errors And Warnings In Logfile And Write Them Into Resultfile     ${syslog_dir}/${syslog_files}[0]
        ...    ignorefname=${EXCEPTIONFILE}     errordeffname=${ERRORARRAYFILE}     requirementfname=${REQUIREMENTFILE}
    ELSE
        Log To Console    No syslog_files.tgz available
    END
    OperatingSystem.File Should Be Empty  ${error_file}
