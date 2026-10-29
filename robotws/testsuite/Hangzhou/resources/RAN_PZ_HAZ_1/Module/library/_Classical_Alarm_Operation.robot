*** Settings ***
Documentation
...    Author: Amaand li
...    Contact: amaand.li@nokia-sbell.com
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
Library           taf.sbts.oam.coam.admin     WITH NAME    coam
Library           alarm_worker/alarm_ulti.py          WITH NAME    alarm_ulti
Resource          _Cloud_Alarm_Operation.robot
Library           taf.ul.alarms_watchdog    WITH NAME    watchalarm
*** Variables ***
&{SIMPLIFIED_ALARM}     severity=${NONE}  faultId=${NONE}  faultName=${NONE}  notifier=${NONE}  number=${NONE}
*** Keywords ***
Classical Alarm Operation
    [Arguments]    ${operation}    ${product_type}    ${bts_index}
    ...            ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}

    Log To Console    ${product_type}
    ${out}    run keyword    _Classical_Alarm_Operation.${operation}
    ...    bts_index=${bts_index}
    ...    timeout=${timeout}
    ...    operation=${operation}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}
    [Return]    ${out}
############################################  Connection Part #############################################
_Classical_Alarm_Operation.Import_InitFile
    ${host_name}    alarm_ulti.get_hostname
    ${host_name}    set variable    ${host_name.replace('-','_')}
    ${host_name}    remove_suffix     ${host_name}
    set test variable    ${TESTLINE_NAME}    ${host_name}
    ${import_res}   run keyword and return status    BuiltIn.import Variables
    ...     /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    run keyword unless    ${import_res}    Fail    import init file failed.
    [Return]    ${import_res}
_Classical_Alarm_Operation.StartAdmin
    [Arguments]    ${connection}=${None}    ${product_type}=gnb    ${alias}=default    ${gnb_index}=${0}
    ...    ${oam_ip}=${None}
    _Classical_Alarm_Operation.Import_InitFile
    Return From Keyword If    '${connection}'!='${None}'    ${connection}
    ${enb_length}    Run Keyword If    '${tl.enbs}'!='${None}'    Get Length    ${tl.enbs}
    ...    ELSE    Set Variable    ${0}
    ${gnb_length}    Run Keyword If    '${tl.gnbs}'!='${None}'    Get Length    ${tl.gnbs}
    ...    ELSE    Set Variable    ${0}
    ${site_obj}    Run Keyword If    ${gnb_length}==${0} and '${product_type}'=='gnb'
    ...    Set Variable    ${tl.enbs[${gnb_index}]}
    ...    ELSE IF    ${enb_length}==${0} and '${product_type}'=='enb'
    ...    Set Variable     ${tl.gnbs[${gnb_index}]}
    ...    ELSE IF    '${product_type}'=='enb'
    ...    Set Variable    ${tl.enbs[${gnb_index}]}
    ...    ELSE
    ...    Set Variable    ${tl.gnbs[${gnb_index}]}
    ${admin_addr}    _Classical_Alarm_Operation.get_oam_addr    ${site_obj}    ${oam_ip}
    Run Keyword If    '${site_obj.__class__.__name__}'=='ClassicalBts'
    ...    coam.connect_to    bts_host=${admin_addr}
    ...    username=${site_obj.cu.oam_http_connection_details.username}
    ...    password=${site_obj.cu.oam_http_connection_details.password}
    ...    admin_api_log_dir=${OUTPUT_DIR}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=${alias}
    ...    ELSE IF    '${site_obj.__class__.__name__}'=='RealEnb'
    ...    coam.connect_to    bts_host=${admin_addr}
    ...    admin_api_log_dir=${OUTPUT_DIR}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=${alias}
    [Return]    ${alias}
_Classical_Alarm_Operation.get_oam_addr
    [Arguments]    ${site_obj}    ${oam_ip}=${None}
    Return From Keyword If    '${oam_ip}'!='${None}'    ${oam_ip}
    ${airscale_existed}    _Classical_Alarm_Operation.attribute available    ${site_obj}    airscale
    ${oam_ip_existed}    _Classical_Alarm_Operation.attribute available    ${site_obj}    oam_ip
    Run Keyword If    '${site_obj.__class__.__name__}'=='ClassicalBts'
    ...    Return From Keyword    ${site_obj.cu.oam_http_connection_details.addr}
    ...    ELSE IF    '${site_obj.__class__.__name__}'=='RealEnb' and '${airscale_existed}'=='${True}'
    ...    Return From Keyword    ${site_obj.airscale.common_units[0].lmp_connection.addr}
    ...    ELSE IF    '${site_obj.__class__.__name__}'=='RealEnb' and '${oam_ip_existed}'=='${True}'
    ...    Return From Keyword    ${site_obj.oam_ip.v4}
_Classical_Alarm_Operation.attribute available
    [Arguments]    ${obj}    ${attr}
    ${is_existed}    Run Keyword And Return Status  Set Variable    ${obj.${attr}}
    ${validate}    Run Keyword If    ${is_existed}
    ...    Run Keyword And Return Status    Should Be True    ${obj.${attr} is not ${None}}
    ...    ELSE    Set Variable    ${False}
    [Return]    ${validate}
_Classical_Alarm_Operation.StopAdmin
    [Arguments]    ${connection}=${None}
    coam.teardown    connection=${connection}
    [Return]    ${connection}

################################################## Alarm Operation Part ###############################################
_Classical_Alarm_Operation.get_active_alarms
    [Arguments]       ${operation}
    ...   ${bts_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}
    ...    ${product_type}=gnb
    Log To Console    ${timeout}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${connection}    _Classical_Alarm_Operation.StartAdmin
    ...    product_type=${product_type}
    ...    gnb_index=${bts_index}
    ...    alias=${operation}
    ${out}=    coam.get_active_alarms    connection=${connection}
    ${rtn}=     _Classical_Alarm_Operation_Alarm_Parse
    ...    alarm_info=${out}
    ...    alarm_type=active_alarm
    ...    ne_type=bts
    [Return]      ${rtn}
    [Teardown]    Run Keyword And Ignore Error    _Classical_Alarm_Operation.StopAdmin    connection=${connection}

_Classical_Alarm_Operation.check_active_alarms
    [Arguments]    ${operation}     ${bts_index}=0    ${product_type}=enb    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}
    Log To Console    ${timeout}
    ${connection}    _Classical_Alarm_Operation.StartAdmin
    ...    product_type=${product_type}
    ...    gnb_index=${bts_index}
    ...    alias=${operation}
    ${alarm_info}     coam.get_active_alarms    connection=${connection}
    ${flag_expect_alarm}  ${flag_critical_alarm}   alarm_ulti.check_active_alarms
    ...      expected_patterns=${expected_alarms}
    ...      add_ignored_alarm=${ignored_alarms}     critical_patterns=${critical_alarms}  alarm_info=${alarm_info}
    ...      product_type=enb

    ${out}   Create Dictionary   flag_expect_alarm=${flag_expect_alarm}    flag_critical_alarm=${flag_critical_alarm}
    [Return]   ${out}
    [Teardown]    Run Keyword And Ignore Error    _Classical_Alarm_Operation.StopAdmin    alias=${connection}

_Classical_Alarm_Operation.get_historical_alarms
    [Arguments]       ${operation}
    ...   ${bts_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}
    ...    ${product_type}=enb
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${connection}=    _Classical_Alarm_Operation.StartAdmin
    ...    product_type=${product_type}
    ...    gnb_index=${bts_index}
    ...    alias=${operation}
    ${out}    coam.get_historic_alarms    timeout=${timeout}    load_history=True    connection=${connection}
    ${rtn}=     _Classical_Alarm_Operation_Alarm_Parse
    ...    alarm_info=${out}
    ...    alarm_type=historical_alarm
    ...    ne_type=bts
    [Return]   ${rtn}
    [Teardown]    Run Keyword And Ignore Error    _Classical_Alarm_Operation.StopAdmin    connection=${connection}

_Classical_Alarm_Operation.get_alarms
    [Arguments]       ${operation}
    ...   ${bts_index}=0    ${timeout}=100s
    ...    ${expected_alarms}=${None}    ${ignored_alarms}=${None}    ${critical_alarms}=${None}
    ${active_alarms}=    _Classical_Alarm_Operation.get_active_alarms
    ...    operation=${operation}
    ...    bts_index=${bts_index}
    ...    timeout=${timeout}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}

    ${historical_alarms}=    _Classical_Alarm_Operation.get_historical_alarms
    ...    operation=${operation}
    ...    bts_index=${bts_index}
    ...    timeout=${timeout}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}

    [Return]    ${active_alarms}    ${historical_alarms}

_Classical_Alarm_Operation.analyze_active_alarms
    [Arguments]         ${bts_index}    ${operation}
    ...    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${bts_index}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    ${active_alarms}        _Classical_Alarm_Operation.get_active_alarms
    ...    operation=${operation}
    ...    timeout=${timeout}
    ${rtn}    alarm_ulti.analyze_active_alarms    active_alarms=${active_alarms}    expected_alarms=${expected_alarms}
    [Return]    ${rtn}

_Classical_Alarm_Operation.start_watch_alarms
    [Arguments]         ${bts_index}    ${operation}
    ...    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${operation}
    Log To Console    ${expected_alarms}
    Log To Console    ${critical_alarms}
    Log To Console    ${timeout}
    _Classical_Alarm_Operation.Import_InitFile
    ${log_dir}     alarm_ulti.create_watchdog_logdir     ${OUTPUT_DIR}/WatchAlarmLog
    Run keyword if     ${tl.enbs}
    ...    watchalarm.watch_alarms    allowed_alarms=${ignored_alarms}    bts_config=${tl.enbs[${bts_index}]}
    ...    log_dir=${log_dir}    reconnect=True
    ...    ELSE    run keyword
    ...    watchalarm.watch_alarms    allowed_alarms=${ignored_alarms}     bts_config=${tl.gnbs[${bts_index}]}
    ...    log_dir=${log_dir}    reconnect=True
_Classical_Alarm_Operation.stop_watch_alarms
    [Arguments]         ${bts_index}    ${operation}
    ...    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${bts_index}
    Log To Console    ${operation}
    Log To Console    ${expected_alarms}
    Log To Console    ${ignored_alarms}
    Log To Console    ${critical_alarms}
    Log To Console    ${timeout}
    Run keyword and ignore error    watchalarm.Stop Watching Alarms

_Classical_Alarm_Operation.get_detected_alarms
    [Arguments]         ${bts_index}    ${operation}    ${expected_alarms}
    ...    ${ignored_alarms}    ${critical_alarms}    ${timeout}
    Log To Console    ${bts_index}
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

_Classical_Alarm_Operation_Alarm_Parse
    [Arguments]   ${alarm_info}   ${alarm_type}    ${ne_type}
    &{rtn}    Create Dictionary
    ${alarm_length}   get length    ${alarm_info}
    ${alarmlist}    Create List
    FOR    ${i}    IN RANGE    0     ${alarm_length}
        ${tmp_dict}   Copy Dictionary   ${alarm_info[${i}]}
        ${reg_dict}   create dictionary
        Set To Dictionary    ${reg_dict}    additional_info   ${tmp_dict['alarmText']['alarmAdditionalInfo']}
        Set To Dictionary    ${reg_dict}    alarm_id      ${tmp_dict['alarmId']}
        Set To Dictionary    ${reg_dict}    alarm_name    ${tmp_dict['alarmName']}
        Set To Dictionary    ${reg_dict}    alarming_object   ${tmp_dict['alarmingObjectIds']}
        Set To Dictionary    ${reg_dict}    appear_time      ${tmp_dict['btsObservationTime']}
        Set To Dictionary    ${reg_dict}    event_type_name    ${tmp_dict['eventType']}
        Set To Dictionary    ${reg_dict}    fault_id      ${tmp_dict['faultId']}
        Set To Dictionary    ${reg_dict}    fault_name    ${tmp_dict['faultName']}
        Set To Dictionary    ${reg_dict}    last_updated_time    ${tmp_dict['btsLastUpdateTime']}
        Set To Dictionary    ${reg_dict}    probable_cause_name    ${tmp_dict['configObjectName']}
        Set To Dictionary    ${reg_dict}    severity    ${tmp_dict['faultSeverity']}
        Set To Dictionary    ${reg_dict}    clear    ${tmp_dict['faultSeverity']}
        ${i}  convert to string  ${i}
        Set To Dictionary  ${rtn}   ${i}   ${reg_dict}
    END
    ${timestamp}   _Classical_Alarm_Operation.Get TimeStamp
    ${file_name}    Set Variable    ${ne_type}_${alarm_type}_${timestamp}.csv
    ${file}    alarm_ulti.create_alarm_file    log_path=${OUTPUT_DIR}/alarm_operation_module    file_name=${file_name}
    Run Keyword And Ignore Error    alarm_ulti.save_alarms_to_csvfile    alarm_data=${alarm_info}    file_name=${file}
    [Return]    ${rtn}

_Classical_Alarm_Operation.Get TimeStamp
    [Arguments]    ${format}=%Y%m%d%H%M%S
    ${timestamp}    DateTime.Get Current Date    result_format=${format}
    [Return]    ${timestamp}
