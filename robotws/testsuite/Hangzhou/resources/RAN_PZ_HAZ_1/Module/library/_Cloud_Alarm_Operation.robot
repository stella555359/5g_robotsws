*** Settings ***
Documentation
...    Author: Xiang Liangliang
...    Contact: liang.xiang@nokia-sbell.com
...    Common KWs use to alarm related operation

Library           Collections
Library           re
Library           DateTime
Library           OperatingSystem
Library           Process
Library           Screenshot
Library           String
Library           yaml
Library           XML
Library           Telnet
Library           json
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.gnb.oam.coam.cu.interface.cu    WITH NAME    cu
Library           alarm_worker/alarm_ulti.py          WITH NAME    alarm_ulti
Library           taf.ul.alarms_watchdog    WITH NAME    watchalarm


*** Keywords ***
Cloud Alarm Operation
    [Arguments]    ${operation}    ${product_type}    ${bts_index}    ${cudu_index}
    ...            ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}

    ${out}    run keyword    _Cloud_Alarm_Operation.${product_type}_${operation}
    ...    ne_index=${cudu_index}
    ...    gnb_index=${bts_index}
    ...    timeout=${timeout}
    ...    operation=${operation}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}
    [Return]    ${out}

################################ VDU Alarm Operation Part #################################
_Cloud_Alarm_Operation.vdu_login
    [Arguments]    ${alias}=default    ${vdu_index}=${0}    ${gnb_index}=${0}
    vdu.connect to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    [Return]    ${alias}

_Cloud_Alarm_Operation.vdu_logout
    [Arguments]    ${alias}=default
    vdu.disconnect    ${alias}

_Cloud_Alarm_Operation.vdu_check_active_alarms
    [Arguments]  ${ne_index}    ${operation}     ${gnb_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}
    Log To Console    ${timeout}
    ${connection}    _Cloud_Alarm_Operation.vdu_login
    ...    vdu_index=${ne_index}
    ...    gnb_index=${gnb_index}
    ...    alias=${operation}
    ${alarm_info}     vdu.vdu_get_active_alarms      vdu_connection=${connection}
    ${flag_expect_alarm}  ${flag_critical_alarm}   alarm_ulti.check_active_alarms      expected_patterns=${expected_alarms}
    ...     add_ignored_alarm=${ignored_alarms}     critical_patterns=${critical_alarms}  alarm_info=${alarm_info}
    ${out}   Create Dictionary   flag_expect_alarm=${flag_expect_alarm}    flag_critical_alarm=${flag_critical_alarm}
    [Return]   ${out}
    [Teardown]    Run Keyword And Ignore Error    _Cloud_Alarm_Operation.vdu_logout    alias=${connection}

_Cloud_Alarm_Operation.vdu_get_active_alarms
    [Arguments]  ${ne_index}    ${operation}
    ...   ${gnb_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}

    Log To Console    ${timeout}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${connection}    _Cloud_Alarm_Operation.vdu_login
    ...    vdu_index=${ne_index}
    ...    gnb_index=${gnb_index}
    ...    alias=${operation}
    ${out}    vdu.vdu_get_active_alarms    vdu_connection=${connection}
    ${rtn}=    _Cloud_Alarm_Operation_Alarm_Parse
    ...    alarm_info=${out}
    ...    alarm_type=active_alarm
    ...    ne_type=vdu
    [Return]   ${rtn}
    [Teardown]    Run Keyword And Ignore Error    _Cloud_Alarm_Operation.vdu_logout    alias=${connection}

_Cloud_Alarm_Operation.vdu_get_historical_alarms
    [Arguments]  ${ne_index}    ${operation}
    ...   ${gnb_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}

    Log To Console    ${timeout}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${connection}    _Cloud_Alarm_Operation.vdu_login
    ...    vdu_index=${ne_index}
    ...    gnb_index=${gnb_index}
    ...    alias=${operation}
    ${out}    vdu.vdu_get_historical_alarms    paging=${False}    vdu_connection=${connection}
    ${rtn}=    _Cloud_Alarm_Operation_Alarm_Parse
    ...    alarm_info=${out}
    ...    alarm_type=historical_alarm
    ...    ne_type=vdu
    [Return]   ${rtn}
    [Teardown]    Run Keyword And Ignore Error    _Cloud_Alarm_Operation.vdu_logout    alias=${connection}

_Cloud_Alarm_Operation.vdu_get_alarms
    [Arguments]  ${ne_index}    ${operation}
    ...   ${gnb_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}
    ${active_alarms}=    _Cloud_Alarm_Operation.vdu_get_active_alarms
    ...    ne_index=${ne_index}
    ...    operation=${operation}
    ...    gnb_index=${gnb_index}
    ...    timeout=${timeout}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}

    ${historical_alarms}=    _Cloud_Alarm_Operation.vdu_get_historical_alarms
    ...    ne_index=${ne_index}
    ...    operation=${operation}
    ...    gnb_index=${gnb_index}
    ...    timeout=${timeout}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}

    [Return]    ${active_alarms}    ${historical_alarms}

_Cloud_Alarm_Operation.vdu_analyze_active_alarms
    [Arguments]    ${ne_index}    ${gnb_index}    ${operation}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${gnb_index}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${active_alarms}        _Cloud_Alarm_Operation.vdu_get_active_alarms
    ...    ne_index=${ne_index}
    ...    operation=${operation}
    ...    timeout=${timeout}
    ${rtn}    alarm_ulti.analyze_active_alarms    active_alarms=${active_alarms}    expected_alarms=${expected_alarms}
    [Return]    ${rtn}

_Cloud_Alarm_Operation.vdu_start_watch_alarms
    [Arguments]    ${ne_index}    ${gnb_index}    ${operation}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${gnb_index}
    Log To Console    ${operation}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    Log To Console    ${timeout}
    watchalarm.watch_alarms    bts_config=${tl.gnbs[0]}    du_id=${ne_index}

_Cloud_Alarm_Operation.vdu_stop_watch_alarms
    [Arguments]    ${ne_index}    ${gnb_index}    ${operation}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${ne_index}
    Log To Console    ${gnb_index}
    Log To Console    ${operation}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    Log To Console    ${timeout}
    Run keyword and ignore error    Stop Watching Alarms

_Cloud_Alarm_Operation.vdu_get_detected_alarms
    [Arguments]    ${ne_index}    ${gnb_index}    ${operation}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${ne_index}
    Log To Console    ${gnb_index}
    Log To Console    ${operation}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    Log To Console    ${timeout}
    ${res}    ${unexpected_alarms}    Run keyword and ignore error    watchalarm.get_detected_alarms
    ${empty_list}=   Create List
    ${watch_alarm_not_started}=     Run keyword And Return Status
    ...     Should Contain  ${unexpected_alarms}    WatchdogNotStarted
    ${unexpected_alarms}=   Set Variable If     ${watch_alarm_not_started}==${TRUE}
    ...     ${empty_list}   ${unexpected_alarms}

    [Return]    ${unexpected_alarms}

################################ VCU Alarm Operation Part #################################
_Cloud_Alarm_Operation.vcu_login
    [Arguments]    ${alias}=default    ${gnb_index}=${0}
    cu.connect to    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

_Cloud_Alarm_Operation.vcu_logout
    [Arguments]    ${alias}=default
    cu.disconnect    ${alias}

_Cloud_Alarm_Operation.vcu_check_active_alarms
    [Arguments]  ${ne_index}    ${operation}
    ...   ${gnb_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}
    Log To Console    ${ne_index}
    Log To Console    ${timeout}
    ${connection}  _Cloud_Alarm_Operation.vcu_login
    ...    gnb_index=${gnb_index}
    ...    alias=${operation}
    ${alarm_info}    cu.get_active_alarms   connection=${connection}
    ${flag_expect_alarm}  ${flag_critical_alarm}   alarm_ulti.check_active_alarms      expected_patterns=${expected_alarms}
    ...     add_ignored_alarm=${ignored_alarms}     critical_patterns=${critical_alarms}   alarm_info=${alarm_info}
    ${out}   Create Dictionary   flag_expect_alarm=${flag_expect_alarm}    flag_critical_alarm=${flag_critical_alarm}
    [Return]   ${out}
    [Teardown]    Run Keyword And Ignore Error    _Cloud_Alarm_Operation.vcu_logout    alias=${connection}

_Cloud_Alarm_Operation.vcu_get_active_alarms
    [Arguments]  ${ne_index}    ${operation}
    ...   ${gnb_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}

    Log To Console    ${ne_index}
    Log To Console    ${timeout}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${connection}  _Cloud_Alarm_Operation.vcu_login
    ...    gnb_index=${gnb_index}
    ...    alias=${operation}
    ${out}=    cu.get_active_alarms   connection=${connection}
    ${rtn}=    _Cloud_Alarm_Operation_Alarm_Parse
    ...    alarm_info=${out}
    ...    alarm_type=active_alarm
    ...    ne_type=vcu
    [Return]   ${rtn}
    [Teardown]    Run Keyword And Ignore Error    _Cloud_Alarm_Operation.vcu_logout    alias=${connection}

_Cloud_Alarm_Operation.vcu_get_historical_alarms
    [Arguments]  ${ne_index}    ${operation}
    ...   ${gnb_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}

    Log To Console    ${ne_index}
    Log To Console    ${timeout}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${connection}  _Cloud_Alarm_Operation.vcu_login
    ...    gnb_index=${gnb_index}
    ...    alias=${operation}
    ${out}    cu.get_historical_alarms  paging=${False}    connection=${connection}
    ${rtn}=    _Cloud_Alarm_Operation_Alarm_Parse
    ...    alarm_info=${out}
    ...    alarm_type=historical_alarm
    ...    ne_type=vcu
    [Return]   ${rtn}
    [Teardown]    Run Keyword And Ignore Error    _Cloud_Alarm_Operation.vcu_logout    alias=${connection}

_Cloud_Alarm_Operation.vcu_get_alarms
    [Arguments]  ${ne_index}    ${operation}
    ...   ${gnb_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}
    ${active_alarms}=    _Cloud_Alarm_Operation.vcu_get_active_alarms
    ...    ne_index=${ne_index}
    ...    operation=${operation}
    ...    gnb_index=${gnb_index}
    ...    timeout=${timeout}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}

    ${historical_alarms}=    _Cloud_Alarm_Operation.vcu_get_historical_alarms
    ...    ne_index=${ne_index}
    ...    operation=${operation}
    ...    gnb_index=${gnb_index}
    ...    timeout=${timeout}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}

    [Return]    ${active_alarms}    ${historical_alarms}

_Cloud_Alarm_Operation.vcu_analyze_active_alarms
    [Arguments]    ${ne_index}    ${gnb_index}    ${operation}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${gnb_index}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${active_alarms}        _Cloud_Alarm_Operation.vcu_get_active_alarms
    ...    ne_index=${ne_index}
    ...    operation=${operation}
    ...    timeout=${timeout}
    ${rtn}    alarm_ulti.analyze_active_alarms    active_alarms=${active_alarms}    expected_alarms=${expected_alarms}
    [Return]    ${rtn}

_Cloud_Alarm_Operation.vcu_start_watch_alarms
    [Arguments]    ${ne_index}    ${gnb_index}    ${operation}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${gnb_index}
    Log To Console    ${operation}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    Log To Console    ${timeout}
    watchalarm.watch_alarms    bts_config=${tl.gnbs[0]}    cu_id=${ne_index}

_Cloud_Alarm_Operation.vcu_stop_watch_alarms
    [Arguments]    ${ne_index}    ${gnb_index}    ${operation}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${ne_index}
    Log To Console    ${gnb_index}
    Log To Console    ${operation}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    Log To Console    ${timeout}
    Run keyword and ignore error    Stop Watching Alarms

_Cloud_Alarm_Operation.vcu_get_detected_alarms
    [Arguments]    ${ne_index}    ${gnb_index}    ${operation}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${ne_index}
    Log To Console    ${gnb_index}
    Log To Console    ${operation}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    Log To Console    ${timeout}
    ${res}    ${unexpected_alarms}    Run keyword and ignore error    watchalarm.get_detected_alarms
    ${empty_list}=   Create List
    ${watch_alarm_not_started}=     Run keyword And Return Status
    ...     Should Contain  ${unexpected_alarms}    WatchdogNotStarted
    ${unexpected_alarms}=   Set Variable If     ${watch_alarm_not_started}==${TRUE}
    ...     ${empty_list}   ${unexpected_alarms}
    [Return]    ${unexpected_alarms}
################################       Common Part      ###################################
_Cloud_Alarm_Operation_Alarm_Parse
    [Arguments]   ${alarm_info}   ${alarm_type}   ${ne_type}
    ${rtn}  Create Dictionary
    ${alarm_length}   Set Variable   ${alarm_info["total"]}
    ${detail_alarm_info}   Set Variable    ${alarm_info["alarms"]}
    FOR    ${i}    IN RANGE    0     ${alarm_length}
       ${tmp_dict}   Copy Dictionary   ${detail_alarm_info[${i}]}
        Set To Dictionary    ${tmp_dict}    additional_info   ${tmp_dict['additional_info']}
        Set To Dictionary    ${tmp_dict}    alarm_id      ${tmp_dict['alarm_id']}
        Set To Dictionary    ${tmp_dict}    alarm_name    ${tmp_dict['alarm_name']}
        Set To Dictionary    ${tmp_dict}    alarming_object   ${tmp_dict['alarming_object']}
        Set To Dictionary    ${tmp_dict}    appear_time      ${tmp_dict['appear_time']}
        Set To Dictionary    ${tmp_dict}    event_type_name    ${tmp_dict['event_type_name']}
        Set To Dictionary    ${tmp_dict}    fault_id      ${tmp_dict['fault_id']}
        Set To Dictionary    ${tmp_dict}    fault_name    ${tmp_dict['fault_name']}
        Set To Dictionary    ${tmp_dict}    last_updated_time    ${tmp_dict['last_updated_time']}
        Set To Dictionary    ${tmp_dict}    probable_cause_name    ${tmp_dict['probable_cause_name']}
        Set To Dictionary    ${tmp_dict}    severity    ${tmp_dict['severity']}
        ${i}  convert to string  ${i}
        Set To Dictionary  ${rtn}   ${i}   ${tmp_dict}
    END
    ${timestamp}   _Cloud_Alarm_Operation.Get TimeStamp
    ${file_name}    Set Variable    ${ne_type}_${alarm_type}_${timestamp}.csv
    ${file}    alarm_ulti.create_alarm_file    log_path=${OUTPUT_DIR}/alarm_operation_module    file_name=${file_name}
    Run Keyword And Ignore Error    alarm_ulti.save_alarms_to_csvfile    alarm_data=${alarm_info}    file_name=${file}
    [Return]    ${rtn}

_Cloud_Alarm_Operation.Get TimeStamp
    [Arguments]    ${format}=%Y%m%d%H%M%S
    ${timestamp}    DateTime.Get Current Date    result_format=${format}
    [Return]    ${timestamp}


_Cloud_Alarm_Operation.vdu.analyze_active_alarms
    [Arguments]    ${ne_index}    ${operation}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${active_alarms}        _Cloud_Alarm_Operation.vdu_get_active_alarms
    ...    ne_index=${ne_index}
    ...    operation=${operation}
    ...    timeout=${timeout}
    ${rtn}    alarm_ulti.analyze_active_alarms    active_alarms=${active_alarms}    expected_alarms=${expected_alarms}
    [Return]    ${rtn}
