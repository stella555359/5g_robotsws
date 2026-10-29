*** Settings ***
Documentation     Keywords for to BTSlog analysis
...               author: Abderrahmane NEZROUk
...               date: 30/09/2024

Library    OperatingSystem
Library    String

Library    ../python/utilities.py


*** Variables ***
# btslog_filters: key_filter, message_filter, outputfilename
@{btslog_filters}=     critical,,critical
...                    err\\/\\|error,,error
...                    wrn\\/\\|warning,,warning
...                    unknown,,unknown
# ...                    overload,,overload_messages



*** Keywords ***
Analys Btslogs
    [Documentation]
    ...         This keyword will apply a set of defined filters
    ...         to syslog
    [Arguments]    ${btslog_path}    ${btslog_filters}

    ${log_messages}    set variable    *** syslog analysis ***
    FOR    ${btslog_filter}    IN    @{btslog_filters}
        log    filtering syslog message using ${btslog_filter}
        @{filters}    Split String  ${btslog_filter}  ,
        ${filter_length}  Get length  ${filters}
        ${result_length}=    run keyword if  ${filter_length} > 2
        ...    Filter BTS Syslog Analysis    ${btslog_path}    ${filters[0]}
        ...                                  ${filters[2]}     filter_message=${filters[1]}
        ${log_messages}  catenate  SEPARATOR=\n  ${log_messages}
        ...    ${result_length} ${filters[2]} messages was found with cretiria "${filters[1]}"
    END
    ${log_messages}  catenate  SEPARATOR=\n  ${log_messages}    ********************************
    log     ${log_messages}    console=True


Filter BTS Syslog Analysis
    [Documentation]
    ...         This keyword help to extract data from syslog
    ...
    ...        :param  btslog_path    folder where btslogs are stored
    ...        :param  key_filter     filter string to find
    ...        :param  filter_name    output filter name
    ...        :param  result_file   output file, default filename: btslog_filtered.txt
    ...        :return:  result file path stored in btslogpath folder

    [Arguments]    ${btslog_file}    ${key_message}    ${filter_name}    ${filter_message}=${None}
    ${btslog_folder}=    utilities.get_folder_from_path  ${btslog_file}
    ${filtered_file}  join path  ${btslog_folder}  ${filter_name}_messages.txt
    ${result}    Run Keyword If    "${filter_message}" != "${Empty}"
    ...     run  zgrep -hai "${key_message}" ${btslog_file} | grep -v "${filter_message}"
    ...    ELSE
    ...     run  zgrep -hai "${key_message}" ${btslog_file}
    ${result_length}  String.Get Line Count  ${result}
    ${result}  run keyword if  ${result_length} > 0  catenate  SEPARATOR=\n  ***${key_message}:${filter_message}***  ${result}\n
    run keyword if  ${result_length} > 0  Append to file  ${filtered_file}  ${result}
    [Return]   ${result_length}

