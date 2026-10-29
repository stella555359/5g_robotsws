*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
*** Variables ***

*** Keywords ***
General_SiSo_RU_installation_time_optical_signal_level_in_BBOX5
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] to Check black box support in 5.1 Radio unit.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.09.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=1
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${cpu_load_list}    Get Regexp Matches     ${log_on_snapshot_full}    cpu_load
    ${cpu_load_num}    get length  ${cpu_load_list}
    Should be true    ${cpu_load_num}==${5}
    log to console    \n cpu load item num:${cpu_load_num}
    ${memory_load_list}    Get Regexp Matches     ${log_on_snapshot_full}    memory_load
    ${memory_load_num}    get length  ${memory_load_list}
    Should be true    ${memory_load_num}==${5}
    log to console    \n memory load item num:${memory_load_num}
    ${pattern_signal}   Set Variable    <([^<]*)2<
    ${signal_ranges_list}    Get Regexp Matches     ${log_on_snapshot_full}    ${pattern_signal}    1
    ${ranges_list}    Get Regexp Matches     ${signal_ranges_list}[0]    -2
    Should be true    ${ranges_list}[0]==${-2}
    log to console    \n signal Ranges:[${ranges_list}[0]dB - 2dB]
    ${pattern_temperature}   Set Variable    <([^<]*)170<
    ${temperature_ranges_list}    Get Regexp Matches     ${log_on_snapshot_full}    ${pattern_temperature}    1
    ${temperature_list}    Get Regexp Matches     ${temperature_ranges_list}[0]    -40
    Should be true    ${temperature_list}[0]==${-40}
    log to console    \n temperature Ranges:[${temperature_list}[0] - 170]
    ${pattern_voltage}   Set Variable    <([^<]*)60<
    ${voltage_ranges_list}    Get Regexp Matches     ${log_on_snapshot_full}    ${pattern_voltage}    1
    ${voltage_list}    Get Regexp Matches     ${voltage_ranges_list}[0]    24
    Should be true    ${voltage_list}[0]==${24}
    log to console    \n voltage Ranges:[${voltage_list}[0]V - 60V]
    ${pattern_cpu_load}   Set Variable    <([^<]*)100<
    ${cpu_load_ranges_list}    Get Regexp Matches     ${log_on_snapshot_full}    ${pattern_cpu_load}    1
    ${cpu_load_list}    Get Regexp Matches     ${cpu_load_ranges_list}[5]    \\d+
    Should be true    ${cpu_load_list}[0]==${0}
    log to console    \n cpu_load Ranges [%]:[${cpu_load_list}[0] - 100%]
    ${pattern_memory_load}   Set Variable    <([^<]*)100<
    ${memory_load_ranges_list}    Get Regexp Matches     ${log_on_snapshot_full}    ${pattern_memory_load}    1
    ${memory_load_list}    Get Regexp Matches     ${memory_load_ranges_list}[0]    \\d+
    Should be true    ${memory_load_list}[0]==${0}
    log to console    \n memory_load Ranges [%]:[${memory_load_list}[0] - 100%]
