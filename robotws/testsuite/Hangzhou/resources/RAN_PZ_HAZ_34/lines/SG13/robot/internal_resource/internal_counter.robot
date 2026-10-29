*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_NSB_MN_RAN_RD_VRF_HAZ4_13@internal.nsn.com

*** Keywords ***
download PM counter file
    [Arguments]    ${log_dir}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remaining_time}     evaluate    ${remaining_time}+120
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    [Return]    ${PM_counter_file}
    
get tput from PM counter
    [Arguments]    ${log_dir}    ${counter_id}    ${cell}=1
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remaining_time}     evaluate    ${remaining_time}+180
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    ${PM_counter_DL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=${counter_id}
    ...   cell_id=${cell}
    ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
    [Return]    ${DL_throughput}
