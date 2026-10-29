*** Keywords ***
Start Collecting Syslog
    [Arguments]    ${alias}=5g
    ${ran_str}    Generate random string    4    0123456789
    Start Syslog  log_dir=${LOG_PATH}/${test_name}/syslog/  log_name=syslog_${alias}_${ran_str}.log  ip=192.168.255.126
    ...    alias=${alias}
    Set Test Variable    ${current_syslog_path}   ${LOG_PATH}/${test_name}/syslog/syslog_${alias}_${ran_str}.log

Stop Collecting Syslog
    [Arguments]    ${alias}=5g
    Log To Console    \nCollecting syslog
    ${file_path}    Collect Syslog Results    alias=${alias}
    [Return]      ${file_path}

Verify Handover Succeeded
    Log To Console    \nChecking HO Success
    Confirm Handover Succeeded    syslog_path=${current_syslog_path}

Verify Handover Failed
    Log To Console    \nChecking HO Success
    Confirm Handover Failed    syslog_path=${current_syslog_path}
