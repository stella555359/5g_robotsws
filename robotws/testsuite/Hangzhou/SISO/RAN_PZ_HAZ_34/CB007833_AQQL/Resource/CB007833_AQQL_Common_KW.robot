*** Settings ***
Documentation     author: Liu Yue
...               Group: HGZ_SG5
...               contact: yue.2.liu@nokia-sbell.com
    
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot


*** Keywords ***
General_SiSo_RU_installation_time_optical_signal_level_in_BBOX5_AQQL
    [Arguments]    ${ru_index}=1
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${pattern_signal}   Set Variable    <([^<]*)2<
    ${signal_ranges_list}    Get Regexp Matches     ${log_on_snapshot_full}    ${pattern_signal}    1
    ${ranges_list}    Get Regexp Matches     ${signal_ranges_list}[0]    -2
    Should be true    ${ranges_list}[0]==${-2}
    log to console    \n signal Ranges:[${ranges_list}[0]dB - 2dB]
General_SiSo_RU_Minimum_information_in_Black_Box_AQQL
    [Arguments]    ${ru_index}=1
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${cpu_load_list}    Get Regexp Matches     ${log_on_snapshot_full}    cpu_load
    ${cpu_load_num}    get length  ${cpu_load_list}
    Should be true    ${cpu_load_num}==${17}
    log to console    \n cpu load item num:${cpu_load_num}
    ${memory_load_list}    Get Regexp Matches     ${log_on_snapshot_full}    memory_load
    ${memory_load_num}    get length  ${memory_load_list}
    Should be true    ${memory_load_num}==${17}
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
General_SiSo_RU_Black_Box_faulty_in_history_of_a_presumably
    [Arguments]  ${ru_index}=1
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${faulty_history}=    Get Lines Containing String     ${log_on_snapshot_full}    List of events
	${fault_list}    Get Regexp Matches     ${faulty_history}    1...
	should not be empty    ${fault_list}
General_SiSo_RU_record_the_voltage_related_data_in_case_of_a_failure
    [Arguments]    ${ru_index}=1
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
	${pattern_voltage}   Set Variable    <([^<]*)60<
    ${voltage_ranges_list}    Get Regexp Matches     ${log_on_snapshot_full}    ${pattern_voltage}    1
    ${voltage_list}    Get Regexp Matches     ${voltage_ranges_list}[0]    24
    Should be true    ${voltage_list}[0]==${24}
    log to console    \n voltage Ranges:[${voltage_list}[0]V - 60V]
General_SiSo_RU_record_the_health_related_data_during_start-up_and_reset
    [Arguments]    ${ru_index}=1
    Wait until keyword succeeds    10 min    5sec    COAM Check GNB RU status
	${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
	Selenium Login And Disable Screen Lock
	Perform RU Lock And Unlock
	Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
	Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}
	sleep    2m
	Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    ${log_on_snapshot_full_after}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
	Should Be Equal As Strings    ${log_on_snapshot_full}    ${log_on_snapshot_full_after}

General_SiSo_RU_record_ISTI_in_Service_Time_Indicator
    [Arguments]    ${ru_index}=1
    Wait until keyword succeeds    10 min    5sec    COAM Check GNB RU status
	${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${Isti_pattern}   Set Variable    Isti(\n)Last(.+)(\n)Value: (.+)
    ${Isti_value}    Get Regexp Matches     ${log_on_snapshot_full}    ${Isti_pattern}    4
    Should Not Be Empty    ${Isti_value}[0]
General_SiSo_RU_parameter_CPU_load_in_BBOX5
    [Arguments]    ${ru_index}=1
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${cpu_load_list}    Get Regexp Matches     ${log_on_snapshot_full}    cpu_load
    ${cpu_load_num}    get length  ${cpu_load_list}
    Should be true    ${cpu_load_num}==${17}
    log to console    \n cpu load item num:${cpu_load_num}
General_SiSo_RU_parameter_memory_load_in_BBOX5
    [Arguments]    ${ru_index}=1
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${memory_load_list}    Get Regexp Matches     ${log_on_snapshot_full}    memory_load
    ${memory_load_num}    get length  ${memory_load_list}
    Should be true    ${memory_load_num}==${17}
    log to console    \n memory load item num:${memory_load_num}
General_SiSo_RU_record_the_number_of_occurrences_for_every_trigger
    [Arguments]    ${ru_index}=1
	Wait until keyword succeeds    10 min    5sec    COAM Check GNB RU status
    ${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${Reset_counter_pattern}   Set Variable    Reset Counter: (.+)
    ${Reset_counter_value}    Get Regexp Matches     ${log_on_snapshot_full}    ${Reset_counter_pattern}    1
    Should Not Be Empty    ${Reset_counter_value}[0]
	
	
General_SiSo_RU_parameter_SW-version_information_in_BBOX5
    [Arguments]    ${ru_index}=1
	Wait until keyword succeeds    10 min    5sec    COAM Check GNB RU status
	${log_on_snapshot_full}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
	#${Active_SW_pattern}   Set Variable    File \[1] version: (.*)
	${Active_SW_pattern}   Set Variable    File(.*)1(.*)version: (.*)
    ${Active_SW}    Get Regexp Matches     ${log_on_snapshot_full}    ${Active_SW_pattern}    3
	${Passive_SW_pattern}   Set Variable    File(.*)0(.*)version: (.*)
    ${Passive_SW}    Get Regexp Matches     ${log_on_snapshot_full}    ${Passive_SW_pattern}    3
	${RF_SW_Version}    get RFSW active and passive version from radio module
	Should be equal    ${Active_SW}    ${RF_SW_Version}[0]
	Should be equal    ${Passive_SW}    ${RF_SW_Version}[1]
	
	
get RFSW active and passive version from radio module
    [Arguments]   ${ru_index}=1
    connect to common unit master
    sleep   1s
    Connect to RU With Allocated IP    ru_index=${ru_index}
    sleep   1s
    set test variable    ${cmd_ruSW}    sudo SWmanShellCommand -i
    ${output_cmd_ruSW}    csn.execute    command=${cmd_ruSW}    connection=RU    timeout=60s
    ${Active_pattern}   Set Variable    File(.*)1(.*)(\n)(.+)(\n)version: (.+)(\r)
    ${Active_version_RF}    Get Regexp Matches     ${output_cmd_ruSW}    ${Active_pattern}    6
    ${Passive_pattern}   Set Variable    File(.*)0(.*)(\n)(.+)(\n)version: (.+)(\r)
    ${Passive_version_RF}    Get Regexp Matches     ${output_cmd_ruSW}    ${Passive_pattern}    6
	@{RF_SW_Version}=    Create List    ${Active_version_RF}    ${Passive_version_RF}
    run keyword and ignore error    csn.disconnect    connection=RU
    run keyword and ignore error    csn.disconnect    connection=ASIK Master
    [Return]    @{RF_SW_Version}
