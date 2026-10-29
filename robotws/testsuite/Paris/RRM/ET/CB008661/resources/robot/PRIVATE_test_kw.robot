*** Settings ***
Documentation   :copyright: Nokia
...             :author/s: denis.taupin@nokia.com
...             :contact/s: denis.taupin@nokia.com
...             :description: private KW for DEBUG

Library           DateTime
Library           BuiltIn
Library           String
Library           Collections

*** Variables ***
${OUTPUT_DIR}           /home/ute/Downloads
${script_name}          example_script
#${pm_path}    PM.BTS-1.20250222.103600.ANY.xml
${pm_path_ini}    /home/ute/CrtRoot/logs/CrtTest_2025_02_21-22_37/CB009092_FR1_BKG/Logs
${pm_path_end}    /20250221_223823128102.CB009092_FR1_BKG/PM/pm_files/PM.BTS-1.20250222.000000.ANY.xml
${pm_path}        ${pm_path_ini}${pm_path_end}
${start_time}     2025-02-26 10:00:00
${stop_time}      2025-02-26 10:01:00
${time_until_next_5min}    2
${full_pm_left}            2

*** Test Cases ***
Calculate Duration In Seconds
    write_to_report    DTN: Start Calculate Duration In Seconds
    ${run_sce_duration}=    Subtract Date From Date    ${stop_time}   ${start_time}    exclude_millis=yes
    write_to_report    DTN: Duration in seconds: ${run_sce_duration}
    ${enough_time_to_run_before_next_pm}=    Evaluate    ${run_sce_duration} < ${time_until_next_5min} + ${full_pm_left} * 300
    write_to_report    DTN: enough_time_to_run_before_next_pm: ${enough_time_to_run_before_next_pm}
    ${full_pm_left}        set variable    0
    ${enough_time_to_run_before_next_pm}=    Evaluate    ${run_sce_duration} < ${time_until_next_5min} + ${full_pm_left} * 300
    write_to_report    DTN: enough_time_to_run_before_next_pm: ${enough_time_to_run_before_next_pm}

*** Keywords ***

until_next_pm_start
    [Arguments]               ${reportingIntervalPm}     ${script_name}=wait    ${until_new_pm_only}=yes
    Set Suite Variable        ${offset_pm}               5
    Set Suite Variable        ${count_pm_period}         0
    Set Suite Variable        ${intervals}               2
    Set Suite Variable        ${time_until_next_5min}   -1
    Set Suite Variable        ${run_sce_duration}       -1
    Set Suite Variable        ${full_pm_left}            -1
    Set Suite Variable        ${current_interval}        -1
    Set Suite Variable        ${log_interval}            60
    Set Suite Variable        ${iteration_count}         -1
    write_to_report           INF: reportingIntervalPm=${reportingIntervalPm}
    write_to_report           INF: until_new_pm_only=${until_new_pm_only}
    write_to_report           INF: script_name=${script_name}
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    @{pm_interval_start}    0  1  2  3  4  5  6  7  8  9  10  11
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    @{pm_interval_start}    0  3  6  9
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    @{pm_interval_start}    0
    ...    ELSE    write_to_report     ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    ${intervals}    2
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    ${intervals}    4
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    ${intervals}    13
    ...    ELSE   write_to_report        ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    ${pm_duration}    300
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    ${pm_duration}    900
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    ${pm_duration}    3600
    ...    ELSE   write_to_report        ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    Run Keyword If    '${until_new_pm_only}' == 'yes'     Set Suite Variable    ${intervals}    2
    write_to_report           INF: pm_interval_start=${pm_interval_start}
    write_to_report           INF: intervals to count=${intervals}
    ${condition_met}=   Evaluate    True
    WHILE    ${condition_met}
        ${current_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        Run Keyword If    ${iteration_count} % ${log_interval} == 0    write_to_report
        ...               :::::::::: ${current_time} count_pm_period=${count_pm_period} - current_interval=${current_interval}
        ${iteration_count}=    Evaluate    ${iteration_count} + 1
        Run Keyword If    '${script_name}' == 'wait'    Sleep    1s
        Run Keyword If    '${script_name}' != 'wait'    write_to_report     :::::::::: run_sce_by_telnet_once with ${script_name}
        Run Keyword If    '${script_name}' != 'wait'    ${run_sce_duration}=     run_sce_by_telnet_once     ${script_name}      ${OUTPUT_DIR}
        check_current_pm
        Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    ${full_pm_left}    Evaluate    (1 - ${current_interval}) % 1
        ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    ${full_pm_left}    Evaluate    (2 - ${current_interval}) % 3
        ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    ${full_pm_left}    Evaluate    (11 - ${current_interval}) % 12
        ...    ELSE   write_to_report        ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
        ${is_not_in_start_interval}=             Check Value In List   ${current_interval}    @{pm_interval_start}
        ${less_than_reportingInterval}=          Evaluate    ${count_pm_period} < ${intervals}
        ${enough_time_to_run_before_next_pm}=    Evaluate    ${run_sce_duration} < ${time_until_next_5min} + ${full_pm_left} * 300
        write_to_report           DTN250225: run_sce_duration = ${run_sce_duration}
        write_to_report           DTN250225: time_until_next_5min = ${time_until_next_5min}
        write_to_report           DTN250225: full_pm_left = ${full_pm_left}
        ${condition_met}=                        Evaluate    ${less_than_reportingInterval} or ${is_not_in_start_interval}
        ${condition_met}=                        Evaluate    ${condition_met} and ${enough_time_to_run_before_next_pm}
    END
    ${current_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    write_to_report    :::::::::: ${current_time} count_pm_period=${count_pm_period} - current_interval=${current_interval}
    # write_to_report    :::::::::: is_not_in_start_interval=${is_not_in_start_interval} - less_than_reportingInterval=${less_than_reportingInterval}
    # write_to_report    :::::::::: End of until_next_pm_start

get_last_pm
    [Arguments]        ${reportingIntervalPm}=5min
    ${is_the_last_pm_file}     Set Variable   False
    write_to_report       DBG: DTN250207: is_the_last_pm_file INI=${is_the_last_pm_file}
    WHILE    not ${is_the_last_pm_file}
        # ${pm_path}                   Counters.Collect PM files from BTS    ${LOG_PATH}/PM
        ${is_the_last_pm_file}=      Check Minutes    ${pm_path}    ${reportingIntervalPm}
        write_to_report       INF: is_the_last_pm_file condition = ${is_the_last_pm_file}
        Run Keyword If    not ${is_the_last_pm_file}      Sleep          5s
    END
    write_to_report       INF: get_last_pm is pm_path=${pm_path}
    [return]                  ${pm_path}

Check Minutes
    [Arguments]     ${pm_path}    ${reportingIntervalPm}
    ${max_delta}    Set Variable    4
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    ${max_delta}    4
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    ${max_delta}    14
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    ${max_delta}    59
    ...    ELSE        write_to_report     ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    write_to_report    DBG: DTN250207: reportingIntervalPm=${reportingIntervalPm}
    write_to_report    DBG: DTN250207: max_delta=${max_delta}
    write_to_report    DBG: DTN250207: pm_path=${pm_path}
    ${matches}=    Get Regexp Matches    ${pm_path}    .+\\d{8}.\\d{2}\(\\d{2}\)\\d{2}.ANY.xml    1
    ${minutes}=    Get From List    ${matches}    0
    ${current_minute}=    Get Current Date    result_format=%M
    ${current_minute_str}=    Evaluate    str("${current_minute}")
    ${minutes_str}=           Evaluate    str("${minutes}")
    write_to_report       INF: minutes from current date, MM = ${current_minute_str}
    write_to_report       INF: minutes from pm file, MM = ${minutes_str}
    ${current_minute}=    Evaluate    "${current_minute_str}".lstrip("0") if "${current_minute_str}" != "00" else 0
    ${minutes}=           Evaluate    "${minutes_str}".lstrip("0") if "${minutes_str}" != "00" else 0
    write_to_report       INF: minutes from current date, MM = ${current_minute}
    write_to_report       INF: minutes from pm file, MM = ${minutes}
    ${delta}=    Evaluate    int(${current_minute}) - int(${minutes})
    write_to_report       INF: delta between minutes = ${delta}
    ${result}=     Evaluate     ${minutes} <= ${current_minute} and ${delta} < ${max_delta}
    [return]     ${result}

run_sce_by_telnet_during_pm
    # [Arguments]               ${script_name}
    Set Suite Variable        ${count_pm_period}     0
    Set Suite Variable        ${intervals}           3
    Set Suite Variable        ${current_interval}    0
    WHILE    ${count_pm_period} < ${intervals}
        ${start_time}=       Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        log      :::::::::: sleep 5 ::::::::::
        Sleep    1s
        ${stop_time}=        Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        check_current_pm
    END

check_current_pm
    ${current_time}     Get Current Date    result_format=%H:%M:%S
    ${minutes_str}=     Evaluate            str("${current_time}"[3:5])
    ${seconds_str}=     Evaluate            str("${current_time}"[6:8])
    ${minutes}=         Evaluate            "${minutes_str}".lstrip("0") if "${minutes_str}" != "00" else 0
    ${seconds}=         Evaluate            "${seconds_str}".lstrip("0") if "${seconds_str}" != "00" else 0
    ${total_seconds}    Evaluate            int(${minutes}) * 60 + int(${seconds})
    ${interval}         Evaluate            ${total_seconds} // 300
    ${time_until_next_5min}    Evaluate    300 - (${total_seconds} % 300)
    # write_to_report        Current PM interval is : ${interval}
    ${start_time_minutes}     Evaluate           (${interval} * 5) // 60
    ${start_time_seconds}     Evaluate           (${interval} * 5) % 60
    ${end_time_minutes}       Evaluate           (${interval} * 5 + 5) // 60
    ${end_time_seconds}       Evaluate           (${interval} * 5 + 5) % 60
    ${start_time}             Evaluate           "{:02d}:{:02d}:00".format(${start_time_minutes}, ${start_time_seconds})
    ${end_time}               Evaluate           "{:02d}:{:02d}:00".format(${end_time_minutes}, ${end_time_seconds})
    write_to_report           DTN250225: Current time is within the interval ${interval} : ${start_time} - ${end_time}
    Run Keyword If            '${interval}' != '${current_interval}'         Increment Count
    Set Suite Variable        ${current_interval}             ${interval}
    Set Suite Variable        ${time_until_next_5min}     ${time_until_next_5min}
    write_to_report           DTN250225: time_until_next_5min = ${time_until_next_5min}

Increment Count
    ${count_pm_period}    Evaluate    ${count_pm_period} + 1
    Set Suite Variable    ${count_pm_period}    ${count_pm_period}
    log          Count of PM is now ${count_pm_period}


wait_next_pm_start
    [Arguments]               ${reportingIntervalPm}     ${wait_for_new_pm_only}=no
    Set Suite Variable        ${count_pm_period}         0
    Set Suite Variable        ${intervals}               2
    Set Suite Variable        ${current_interval}        -1
    Set Suite Variable        ${log_interval}            10
    Set Suite Variable        ${iteration_count}         0
    Log Both           :::::::::: reportingIntervalPm=${reportingIntervalPm}
    Log Both           :::::::::: wait_for_new_pm_only=${wait_for_new_pm_only}
    Log Both           :::::::::: intervals to count=${intervals}
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    @{pm_interval_start}    0  1  2  3  4  5  6  7  8  9  10  11
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    @{pm_interval_start}    0  3  6  9
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    @{pm_interval_start}    0
    ...    ELSE    write_to_report     ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    ${intervals}    2
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    ${intervals}    4
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    ${intervals}    13
    ...    ELSE   Log Both        ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    Run Keyword If    '${wait_for_new_pm_only}' == 'yes'     Set Suite Variable    ${intervals}    2
    Log Both           :::::::::: pm_interval_start=${pm_interval_start}
    Log Both           :::::::::: intervals to count=${intervals}
    ${condition_met}=   Evaluate    True
    WHILE    ${condition_met}
        check_current_pm
        ${is_not_in_start_interval}=    Check Value In List   ${current_interval}    @{pm_interval_start}
        ${less_than_reportingInterval}=     Evaluate    ${count_pm_period} < ${intervals}
        ${condition_met}=      Evaluate    ${less_than_reportingInterval} or ${is_not_in_start_interval}
        Log Both    :::::::::: count_pm_period=${count_pm_period} - current_interval=${current_interval}
        Log Both    :::::::::: is_not_in_start_interval=${is_not_in_start_interval}
        Log Both    :::::::::: less_than_reportingInterval=${less_than_reportingInterval}
        Log Both    :::::::::: condition_met=${condition_met}
        Run Keyword If    ${iteration_count} % ${log_interval} == 0    Log Both
        ...               :::::::::: count_pm_period=${count_pm_period} - current_interval=${current_interval}
        Run Keyword If    ${iteration_count} % ${log_interval} == 0    Log Both
        ...               :::::::::: condition_met=${condition_met}
        ${iteration_count}=    Evaluate    ${iteration_count} + 1
        Sleep    1s
    END
    Log Both    :::::::::: count_pm_period=${count_pm_period} - current_interval=${current_interval} - condition_met=${condition_met}
    Log Both    :::::::::: count_pm_period=${count_pm_period} - current_interval=${current_interval}
    Log Both    :::::::::: is_not_in_start_interval=${is_not_in_start_interval}
    Log Both    :::::::::: less_than_reportingInterval=${less_than_reportingInterval}

Check Value In List
    [Arguments]    ${value}    @{input_list}
    ${found}=    Set Variable    False
    ${value}=    Evaluate    int(${value})
    FOR    ${item}    IN    @{input_list}
        ${item}=     Evaluate    int(${item})
        ${found}=    Evaluate    ${item} == ${value}
        Log Both    :::::::::: Check Value In List: value=${value} - item=${item} - found=${found}
        Run Keyword If    ${found}    Exit For Loop
    END
    ${found}=    Evaluate    not ${found}
    [Return]    ${found}

Log Both
    [Arguments]    ${message}    ${level}=INFO
    ${current_time}=    Get Time    format=%H:%M:%S
    Log    ${current_time} ${message}    ${level}
    Log To Console    ${current_time} ${message}

write_to_report
    [Arguments]    ${message}    ${level}=INFO
    ${current_time}=    Get Time    format=%H:%M:%S
    Log    ${current_time} ${message}    ${level}
    Log To Console    ${current_time} ${message}