*** Keywords ***
Wait '${time}' for stable running
    sleep    ${time}

Convert BIP To CSV
    [Arguments]    ${convert_from}    ${convert_to}    ${FILTER}    ${titles}
    Convert BIP To CSV    ${convert_from}    ${convert_to}    ${FILTER}    ${titles}

Start Collecting GNB Syslog in '${file_name}' File
    [Documentation]    This keyword is to start GNB and AP Syslog
    ...    Examples:
    ...    | Start Collect GNB and AP Syslog in 'syslog' File|
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb

Stop Collecting GNB Syslog in '${file_name}' File
    [Documentation]    This keyword is to stop GNB and AP Syslog
    ...    Examples:
    ...    | Stop Collect GNB and AP Syslog in 'syslog' File |
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}${file_name}_gnb.tar.gz

