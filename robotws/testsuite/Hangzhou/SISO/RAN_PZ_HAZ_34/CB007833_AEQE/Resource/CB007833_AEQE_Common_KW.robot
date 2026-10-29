*** Settings ***
Documentation     author: Liu Yue
...               Group: HGZ_SG5
...               contact: yue.2.liu@nokia-sbell.com
    
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot


*** Keywords ***
General_SiSo_RU_Minimum_information_in_Black_Box_AEQE
    [Arguments]    ${ru_index}=1
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${cpu_load_list}    Get Regexp Matches     ${log_on_snapshot_full}    cpu_load
    ${cpu_load_num}    get length  ${cpu_load_list}
    Should be true    ${cpu_load_num}==${9}
    log to console    \n cpu load item num:${cpu_load_num}
    ${memory_load_list}    Get Regexp Matches     ${log_on_snapshot_full}    memory_load
    ${memory_load_num}    get length  ${memory_load_list}
    Should be true    ${memory_load_num}==${9}
    log to console    \n memory load item num:${memory_load_num}
    ${pattern_signal}   Set Variable    <([^<]*)2<
    ${signal_ranges_list}    Get Regexp Matches     ${log_on_snapshot_full}    ${pattern_signal}    1
    ${ranges_list}    Get Regexp Matches     ${signal_ranges_list}[0]    -2
    Should be true    ${ranges_list}[0]==${-2}
    log to console    \n signal Ranges:[${ranges_list}[0]dB - 2dB]
    ${pattern_temperature}   Set Variable    <([^<]*)130<
    ${temperature_ranges_list}    Get Regexp Matches     ${log_on_snapshot_full}    ${pattern_temperature}    1
    ${temperature_list}    Get Regexp Matches     ${temperature_ranges_list}[0]    -30
    Should be true    ${temperature_list}[0]==${-30}
    log to console    \n temperature Ranges:[${temperature_list}[0] - 130]
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
General_SiSo_RU_online_access_to_Black_Box_contents
    [Arguments]    ${ru_index}=1
    Wait until keyword succeeds    10 min    5sec    COAM Check GNB RU status
	Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
    ${output}    csn.execute    cat /mnt/runtime/BBOX5    connection=RU_${ru_index}
    should not be empty    ${output}
General_SiSo_RU_Definition_of_Black_Box_Contents_Format
    [Arguments]    ${ru_index}=1
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    should not be empty   ${log_on_snapshot_full} 
