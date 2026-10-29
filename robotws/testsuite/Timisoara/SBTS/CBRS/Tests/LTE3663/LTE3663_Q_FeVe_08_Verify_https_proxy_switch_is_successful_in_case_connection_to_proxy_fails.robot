*** Settings ***
Documentation
...    = Author =
...    jakub.klein@nokia.com
...    = Maintainer =
...    jakub.klein@nokia.com
...    = Reviewers =
...    albert.sakowicz@nokia.com
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_

*** Keywords ***
LTE3663_Q_FeVe_08_Verify_https_proxy_switch_is_successful_in_case_connection_to_proxy_fails
    ${enb_id}                     Set Variable    ${testlines.${testline_id}.enb_id}
    ${enb_ip}                     Set Variable    ${testlines.${testline_id}.mplane_ip_addr}
    ${vm_ip}                      Set Variable    ${testlines.${testline_id}.vm_ip}
    ${primary_sas_port}           Set Variable    4433
    ${secondary_sas_port}         Set Variable    1234
    ${primary_https_proxy_server_port}    Set Variable    4441    #4442
    ${secondary_https_proxy_server_port}  Set Variable    4443
    ${connect_to_sas_mode_after_test}     Set Variable    direct connect to SAS server
    ${connect_to_sas_mode}           Set Variable    connect through https proxy

    Log To Console    Disabling CBRS feature on eNB and kill all SAS processes
    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Log To Console    Setting Primary and Secondary HTTPS Proxy
    ${primary_sas_pid}    ${primary_sas_log}       Start SAS Process    alias=primary    port=${primary_sas_port}
    ${secondary_sas_pid}    ${secondary_sas_log}   Start SAS Process    alias=secondary    port=${secondary_sas_port}

    Sleep And Display Progress    10    sec    #allows SAS log file to be generated
    Log To Console    Stopping Secondary SAS Process
    Run    kill -9 ${secondary_sas_pid}

    Log To Console    Setting Primary and Secondary HTTPS Proxy in eNB configuration
    Replace Variables In File    file_path=${CURDIR}/Data/set_primary_and_secondary_HTTPS_proxy.json
    ...                          file_destination=${OUTPUT_DIR}/set_primary_and_secondary_HTTPS_proxy.json
    ...                          enb_id=${enb_id}
    ...                          primary_sas=${vm_ip}:${primary_sas_port}
    ...                          primaryHttpsProxyServer=${vm_ip}:${primary_https_proxy_server_port}
    ...                          secondaryHttpsProxyServer=${vm_ip}:${secondary_https_proxy_server_port}
    ...                          connectToSasMode=${connect_to_sas_mode}
    Replace Variables In File    file_path=${CURDIR}/Data/settings_after_test.json
    ...                          file_destination=${OUTPUT_DIR}/settings_after_test.json
    ...                          enb_id=${enb_id}
    ...                          connectToSasMode=${connect_to_sas_mode_after_test}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    1x    30s    Perform Delta Recommissioning
    ...                            ${OUTPUT_DIR}/set_primary_and_secondary_HTTPS_proxy.json    connection=RAT_1ST

    Log To Console    Start Primary HTTPS Proxy
    ${start_time}   Get Time
    ${primary_https_pid}    ${primary_https_log}   Start SAS HTTPS Proxy    alias=primary    port=${primary_https_proxy_server_port}

    Log To Console    Enable CBRS feature on eNB
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Sleep And Display Progress    90    s
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Start Watchdog Alarm Detection

    Log To Console    Checking HTTPS Proxy log
    ${stop_time}   Get Time
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${primary_https_log}    date_start=${start_time}    date_stop=${stop_time}
    ${warning_log}   Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=warning
    ${info_log}   Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=info
    Remove Values From List    ${warning_log}    fordwarding error :[Errno 9] Bad file descriptor
    Should Be Empty    ${warning_log}
    Should Contain Match    ${info_log}    regexp=start listening on port ${primary_https_proxy_server_port}
    Should Contain Match    ${info_log}    regexp=created a tunnel ${enb_ip}:.* <--> ${vm_ip}:${primary_sas_port}

    Log To Console    Start Secondary HTTPS Proxy and Stop Primary
    ${start_time_2}   Get Time
    ${secondary_https_pid}    ${secondary_https_log}   Start SAS HTTPS Proxy    alias=secondary    port=${secondary_https_proxy_server_port}
    Run    kill -9 ${primary_https_pid}

    Log To Console    Waiting for HTTPS Proxy switchover
    Sleep And Display Progress    90    s
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir

    Log To Console    Checking HTTPS Proxy log
    ${stop_time_2}   Get Time
    Run    kill -9 ${secondary_https_pid}
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${secondary_https_log}    date_start=${start_time_2}    date_stop=${stop_time_2}
    ${warning_log}   Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=warning
    ${info_log}   Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=info
    Remove Values From List    ${warning_log}    fordwarding error :[Errno 9] Bad file descriptor
    Should Be Empty    ${warning_log}
    Should Contain Match    ${info_log}    regexp=start listening on port ${secondary_https_proxy_server_port}
    Should Contain Match    ${info_log}    regexp=created a tunnel ${enb_ip}:.* <--> ${vm_ip}:${primary_sas_port}

    ${parsed_log_file}   Parse Sas Log File    log_file_name=${primary_sas_log}    date_start=${start_time}    date_stop=${stop_time_2}
    ${responsemessage_log}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                       parameter=responseMessage
    ...                                                       data_type=registrationResponse
    ${amount_of_approved_request}   Count Values In List    ${responsemessage_log}    CBSD request is approved by SAS
    Should Be Equal As Numbers    ${amount_of_approved_request}    1
    #"CBSD request is approved by SAS" message should be present in whole log only one time

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=primary    AND
    ...                           Get SAS Logs To Logs Dir    alias=secondary    AND
    ...                           Get SAS Proxy Logs To Logs Dir    alias=primary    AND
    ...                           Get SAS Proxy Logs To Logs Dir    alias=secondary    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Kill All SAS Processes    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Perform Delta Recommissioning    ${OUTPUT_DIR}/settings_after_test.json    alias=RAT_1ST
