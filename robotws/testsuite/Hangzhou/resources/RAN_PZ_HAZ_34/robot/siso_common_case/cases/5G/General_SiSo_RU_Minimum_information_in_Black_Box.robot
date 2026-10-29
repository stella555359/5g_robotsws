*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot


*** Keywords ***
General_SiSo_RU_Minimum_information_in_Black_Box
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] to Check black box support in 5.1 Radio unit.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.09.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=3
    ${log_on_snapshot}   Get BBOX5 file On Snapshot  ru_index=${ru_index}
    ${today}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d
    ${yesterday}    robot.libraries.DateTime.Subtract Time From Date     ${today}    1 day   result_format=%Y-%m-%d
    ${pattern}   Set Variable    Last save: ([^T]*)T
    ${save_time_list}    Get Regexp Matches     ${log_on_snapshot}    ${pattern}    1
    Should Contain Any    ${save_time_list}[0]    ${today}    ${yesterday}
    ${pattern_sw}   Set Variable    SW_version([^T]*)T
    ${sw_time_list_temp}    Get Regexp Matches     ${log_on_snapshot}    ${pattern_sw}    1
    ${sw_time_list}    Get Regexp Matches     ${sw_time_list_temp}[0]    Last write: (.*)    1
    # LEOPARD-2375: use 'blackbox_reset' file to read reset history instead of 'blackbox' file
    # ${pattern_reset}   Set Variable    resets([^T]*)T
    # ${reset_time_list_temp}    Get Regexp Matches     ${log_on_snapshot}    ${pattern_reset}    1
    # ${reset_time_list}    Get Regexp Matches     ${reset_time_list_temp}[0]    Reset.*0.* Write: (.*)    1
    ${pattern_port}   Set Variable    SFP_2([^<]*)<
    ${pattern_last_write}   Set Variable    Last write: (\\d{4}-\\d{2}-\\d{2})T
    ${unuse_port_list_temp}    Get Regexp Matches     ${log_on_snapshot}    ${pattern_port}    1
    ${Len}    Get Length    ${unuse_port_list_temp}
    ${unuse_port_list}    run keyword if  '${len}'!='0'    Get Regexp Matches     ${unuse_port_list_temp}[0]
    ...    ${pattern_last_write}    1
    ...    ELSE   create list    ${today}
    ${unuse_RXTX_list_temp}    Get Regexp Matches     ${log_on_snapshot}    RX:1([^<]*)<    1
    ${unuse_RXTX_list}    Get Regexp Matches     ${unuse_RXTX_list_temp}[0]    ${pattern_last_write}    1
    # LEOPARD-2396: ignore the time of the last write in the blackbox file
    ${last_write_list}    Get Regexp Matches     ${log_on_snapshot}    ${pattern_last_write}    1
    ${stream}    get stream from version    version=${Active_SW_version}    convert_to_trunk=${False}
    IF    '${stream}' >= 'SBTS25R2'
        ${last_write_list}   Ignore_Diagnostic_Data    blackbox_data=${log_on_snapshot}    last_write_list=${last_write_list}
    END
    FOR  ${last_write}  IN  @{last_write_list}
        Should Contain Any    ${last_write}    ${today}    ${yesterday}    ${sw_time_list}[0]
        ...    ${unuse_port_list}[0]    ${unuse_RXTX_list}[0]    1970-01-01
    END

Ignore_Diagnostic_Data
    [Arguments]  ${blackbox_data}    ${last_write_list}
    ${diagnostic_time_list}    Create List
    ${diagnostic_id_list}    Create List    SW_PACKAGE_AND_NVM_INTEGRITY_CHECKS    MEMORY_USAGE_UTILIZATION    TEMPERATURE_SENSOR    DDR_POST
    FOR    ${diagnostic_id}    IN    @{diagnostic_id_list}
        ${pattern_diagnostic}    Set Variable    ${diagnostic_id}([^T]*)T
        ${diagnostic_time_list_temp}    Get Regexp Matches     ${blackbox_data}    ${pattern_diagnostic}    1
        ${diagnostic_id_time}    Get Regexp Matches     ${diagnostic_time_list_temp}[0]    Last write: (.*)    1
        Append To List    ${diagnostic_time_list}    ${diagnostic_id_time}[0]
    END
    Log    \nLast write time for diagnostic_test: ${diagnostic_time_list}
    ${diagnostic_sw_flag}  ${diagnostic_memory_flag}  ${diagnostic_temperature_flag}  ${diagnostic_ddr_flag} =    Set Variable
    ...    ${True}    ${True}    ${True}    ${True}
    ${new_write_list}    Create List
    FOR  ${last_write}  IN  @{last_write_list}
        IF  ${diagnostic_sw_flag} and '${last_write}' == '${diagnostic_time_list}[0]'
            ${diagnostic_sw_flag}  Set Variable  ${False}
            CONTINUE
        ELSE IF  ${diagnostic_memory_flag} and '${last_write}' == '${diagnostic_time_list}[1]'
            ${diagnostic_memory_flag}  Set Variable  ${False}
            CONTINUE
        ELSE IF  ${diagnostic_temperature_flag} and '${last_write}' == '${diagnostic_time_list}[2]'
            ${diagnostic_temperature_flag}  Set Variable  ${False}
            CONTINUE
        ELSE IF  ${diagnostic_ddr_flag} and '${last_write}' == '${diagnostic_time_list}[3]'
            ${diagnostic_ddr_flag}  Set Variable  ${False}
            CONTINUE
        END
        Append To List    ${new_write_list}    ${last_write}
    END
    [Return]    ${new_write_list}
