*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
*** Variables ***



*** Keywords ***
Manual_SiSo_TEST_Black_Box
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]to check if the content of the snapshot contains the BBOX5 file in case the
        ...    radio is operational from System Module perspective to retrieve blackbox data after the radio
        ...    shipped back to repair center. Repair engineer might cannot get blackbox data by snapshot,
        ...    so we can collect them directly from Radio Unit
        ...    Note: different RU, BBOX5 content is different. this script according to AQQL
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 7.4.2022 - - Created
        ...    *******************
        ...    yue.2.liu@nokia-sbell.com

    Check BBOX5 content on snapshot
    Check BBOX5 content on ru
    [Teardown]   Selenium Logout And Close Browser

Check BBOX5 content on snapshot
    [Arguments]    ${ru_index}=1
    ${BBOX5_content}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${cpu_load_list}    Get Regexp Matches     ${BBOX5_content}    cpu_load
    ${cpu_load_num}    get length  ${cpu_load_list}
    Should be true    ${cpu_load_num}==${17}
    log to console    \n cpu load item num:${cpu_load_num}
    ${memory_load_list}    Get Regexp Matches     ${BBOX5_content}    memory_load
    ${memory_load_num}    get length  ${memory_load_list}
    Should be true    ${memory_load_num}==${17}
    log to console    \n memory load item num:${memory_load_num}
    ${pattern_signal}   Set Variable    <([^<]*)2<
    ${signal_ranges_list}    Get Regexp Matches     ${BBOX5_content}    ${pattern_signal}    1
    ${ranges_list}    Get Regexp Matches     ${signal_ranges_list}[0]    -2
    Should be true    ${ranges_list}[0]==${-2}
    log to console    \n signal Ranges:[${ranges_list}[0]dB - 2dB]
    ${pattern_temperature}   Set Variable    <([^<]*)130<
    ${temperature_ranges_list}    Get Regexp Matches     ${BBOX5_content}    ${pattern_temperature}    1
    ${temperature_list}    Get Regexp Matches     ${temperature_ranges_list}[0]    -30
    Should be true    ${temperature_list}[0]==${-30}
    log to console    \n temperature Ranges:[${temperature_list}[0] - 130]
    ${pattern_voltage}   Set Variable    <([^<]*)60<
    ${voltage_ranges_list}    Get Regexp Matches     ${BBOX5_content}    ${pattern_voltage}    1
    ${voltage_list}    Get Regexp Matches     ${voltage_ranges_list}[0]    24
    Should be true    ${voltage_list}[0]==${24}
    log to console    \n voltage Ranges:[${voltage_list}[0]V - 60V]
    ${pattern_cpu_load}   Set Variable    <([^<]*)100<
    ${cpu_load_ranges_list}    Get Regexp Matches     ${BBOX5_content}    ${pattern_cpu_load}    1
    ${cpu_load_list}    Get Regexp Matches     ${cpu_load_ranges_list}[5]    \\d+
    Should be true    ${cpu_load_list}[0]==${0}
    log to console    \n cpu_load Ranges [%]:[${cpu_load_list}[0] - 100%]
    ${pattern_memory_load}   Set Variable    <([^<]*)100<
    ${memory_load_ranges_list}    Get Regexp Matches     ${BBOX5_content}    ${pattern_memory_load}    1
    ${memory_load_list}    Get Regexp Matches     ${memory_load_ranges_list}[0]    \\d+
    Should be true    ${memory_load_list}[0]==${0}
    log to console    \n memory_load Ranges [%]:[${memory_load_list}[0] - 100%]
    ${Isti_pattern}   Set Variable    Isti(\n)Last(.+)(\n)Value: (.+)
    ${Isti_value}    Get Regexp Matches     ${BBOX5_content}    ${Isti_pattern}    4
    Should Not Be Empty    ${Isti_value}[0]
    ${Reset_counter_pattern}   Set Variable    Reset Counter: (.+)
    ${Reset_counter_value}    Get Regexp Matches     ${BBOX5_content}    ${Reset_counter_pattern}    1
    Should Not Be Empty    ${Reset_counter_value}[0]
    ${Active_SW_pattern}   Set Variable    File(.*)1(.*)version: (.*)
    ${Active_SW}    Get Regexp Matches     ${BBOX5_content}    ${Active_SW_pattern}    3
    ${Passive_SW_pattern}   Set Variable    File(.*)0(.*)version: (.*)
    ${Passive_SW}    Get Regexp Matches     ${BBOX5_content}    ${Passive_SW_pattern}    3
    ${RF_SW_Version}    get RFSW active and passive version from radio module
    Should be equal    ${Active_SW}    ${RF_SW_Version}[0]
    Should be equal    ${Passive_SW}    ${RF_SW_Version}[1]
Check BBOX5 content on ru
    [Arguments]    ${ru_index}=1    ${connection}=RU_${ru_index}    ${download_dir}=${TS_CASE_LOG_PATH}    ${asik_alias}=ASIK Master
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=GNB_OAM
    ${ru_serial_number}    Set variable    ${ru_info['serialNumber']}
    ${rfsw_log_path_on_ru}    Set Variable    /mnt/runtime/BBOX5
    ${ru_file_name}    Set Variable    BBOX5
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=${asik_alias}
    Connect to RU With Allocated IP LTE   ru_index=${ru_index}    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
    Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
    ...                                          remote_path=${rfsw_log_path_on_ru}
    ...                                          local_path=${download_dir}/${ru_file_name}
    ...                                          connection=${connection}
    ${rfsw_bbox5_path_on_testPC}   Join Path    ${download_dir}    ${ru_file_name}
    ${bbox5_ru}    OperatingSystem.get file    ${rfsw_bbox5_path_on_testPC}
    ${cpu_load_list}    Get Regexp Matches     ${bbox5_ru}    cpu_load
    ${cpu_load_num}    get length    ${cpu_load_list}
    Should be true    ${cpu_load_num}==${17}
    log to console    \n cpu load item num:${cpu_load_num}
    ${memory_load_list}    Get Regexp Matches     ${bbox5_ru}    memory_load
    ${memory_load_num}    get length  ${memory_load_list}
    Should be true    ${memory_load_num}==${17}
    log to console    \n memory load item num:${memory_load_num}
    ${pattern_signal}   Set Variable    <([^<]*)2<
    ${signal_ranges_list}    Get Regexp Matches     ${bbox5_ru}    ${pattern_signal}    1
    ${ranges_list}    Get Regexp Matches     ${signal_ranges_list}[0]    -2
    Should be true    ${ranges_list}[0]==${-2}
    log to console    \n signal Ranges:[${ranges_list}[0]dB - 2dB]
    ${pattern_temperature}   Set Variable    <([^<]*)130<
    ${temperature_ranges_list}    Get Regexp Matches     ${bbox5_ru}    ${pattern_temperature}    1
    ${temperature_list}    Get Regexp Matches     ${temperature_ranges_list}[0]    -30
    Should be true    ${temperature_list}[0]==${-30}
    log to console    \n temperature Ranges:[${temperature_list}[0] - 130]
    ${pattern_voltage}   Set Variable    <([^<]*)60<
    ${voltage_ranges_list}    Get Regexp Matches     ${bbox5_ru}    ${pattern_voltage}    1
    ${voltage_list}    Get Regexp Matches     ${voltage_ranges_list}[0]    24
    Should be true    ${voltage_list}[0]==${24}
    log to console    \n voltage Ranges:[${voltage_list}[0]V - 60V]
    ${pattern_cpu_load}   Set Variable    <([^<]*)100<
    ${cpu_load_ranges_list}    Get Regexp Matches     ${bbox5_ru}    ${pattern_cpu_load}    1
    ${cpu_load_list}    Get Regexp Matches     ${cpu_load_ranges_list}[5]    \\d+
    Should be true    ${cpu_load_list}[0]==${0}
    log to console    \n cpu_load Ranges [%]:[${cpu_load_list}[0] - 100%]
    ${pattern_memory_load}   Set Variable    <([^<]*)100<
    ${memory_load_ranges_list}    Get Regexp Matches     ${bbox5_ru}    ${pattern_memory_load}    1
    ${memory_load_list}    Get Regexp Matches     ${memory_load_ranges_list}[0]    \\d+
    Should be true    ${memory_load_list}[0]==${0}
    log to console    \n memory_load Ranges [%]:[${memory_load_list}[0] - 100%]
    ${Isti_pattern}   Set Variable    Isti(\n)Last(.+)(\n)Value: (.+)
    ${Isti_value}    Get Regexp Matches     ${bbox5_ru}    ${Isti_pattern}    4
    Should Not Be Empty    ${Isti_value}[0]
    ${Reset_counter_pattern}   Set Variable    Reset Counter: (.+)
    ${Reset_counter_value}    Get Regexp Matches     ${bbox5_ru}    ${Reset_counter_pattern}    1
    Should Not Be Empty    ${Reset_counter_value}[0]
    ${Active_SW_pattern}   Set Variable    File(.*)1(.*)version: (.*)
    ${Active_SW}    Get Regexp Matches     ${bbox5_ru}    ${Active_SW_pattern}    3
    ${Passive_SW_pattern}   Set Variable    File(.*)0(.*)version: (.*)
    ${Passive_SW}    Get Regexp Matches     ${bbox5_ru}    ${Passive_SW_pattern}    3
    ${RF_SW_Version}    get RFSW active and passive version from radio module
    Should be equal    ${Active_SW}    ${RF_SW_Version}[0]
    Should be equal    ${Passive_SW}    ${RF_SW_Version}[1]
get RFSW active and passive version from radio module
    [Arguments]   ${ru_index}=1    ${connection}=RU_${ru_index}     ${asik_alias}=ASIK Master
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=${asik_alias}
    Connect to RU With Allocated IP LTE   ru_index=${ru_index}    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
    sleep   1s
    set test variable    ${cmd_ruSW}    sudo SWmanShellCommand -i
    ${output_cmd_ruSW}    csn.execute    command=${cmd_ruSW}    connection=${connection}    timeout=60s
    ${Active_pattern}   Set Variable    File(.*)1(.*)(\n)(.+)(\n)version: (.+)(\r)
    ${Active_version_RF}    Get Regexp Matches     ${output_cmd_ruSW}    ${Active_pattern}    6
    ${Passive_pattern}   Set Variable    File(.*)0(.*)(\n)(.+)(\n)version: (.+)(\r)
    ${Passive_version_RF}    Get Regexp Matches     ${output_cmd_ruSW}    ${Passive_pattern}    6
    @{RF_SW_Version}=    Create List    ${Active_version_RF}    ${Passive_version_RF}
    run keyword and ignore error    csn.disconnect    connection=${connection}
    run keyword and ignore error    csn.disconnect    connection=${asik_alias}
    [Return]    @{RF_SW_Version}
