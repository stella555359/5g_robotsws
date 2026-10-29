*** Settings ***
Documentation    Author: lily.l.xu@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library    BuiltIn
Library    ../python/tak_airphone/


*** Keywords ***
_wait_sim_state_until_active_and_setup_x2_connection
    [Arguments]    ${timeout}=180
    [Documentation]    This keyword is used to wait sim state active until timeout happened, then setup x2 connection
    ...    | Input Parameters | Man. | Description |
    ...    | ${timeout} | No | wait timeout, default is 180 |
    ...    Examples:
    ...    | Wait Sim State Until Active | 180 |
    Log To Console    ...wait sim state active and setup x2 connection...
    Wait Until Keyword Succeeds     ${timeout}     15     _sim_state_is_active
    Airphone Setup X2 Connection    timeout=${timeout}

_sim_state_is_active
    [Documentation]    This keyword is used to check if sim state is active
    ${sim_state}=    Airphone Get Sim State
    ${state}=    String.Convert To Lowercase    ${sim_state}
    Should Be Equal    ${state}    active

_wait_until_sib1_received_for_all_cells
    [Arguments]    ${timeout}=200
    [Documentation]    This keyword is used to wait sib1 message for all cells
    Log To Console    ...wait sib1 message for all cells...
    ${start_time_1}=    Get Time    epoch
    Wait Until Keyword Succeeds     ${timeout}     15     _sim_state_is_active
    ${end_time_1}=    Get Time    epoch
    ${used_time_1}=    Evaluate    ${end_time_1}-${start_time_1}
    ${timeout_1}=    Evaluate    ${timeout}-${used_time_1}
    Airphone Get Gnb Id
    ${cell_id_list}=    Airphone Get Cell Id List
    ${used_time_2}=    Set Variable    0
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${timeout_2}=    Evaluate    ${timeout_1}-${used_time_2}
        ${start_time_2}=    Get Time    epoch
        Airphone Wait Until Sib1 Received    cell_id=${cell_id}    timeout=${timeout_2}
        ${end_time_2}=    Get Time    epoch
        ${used_time_2}=    Evaluate    ${end_time_2}-${start_time_2}
    END

_wait_until_sib1_received_and_setup_x2_connection
    [Arguments]    ${timeout}=200
    [Documentation]    This keyword is used to wait sib1 message for all cells then setup x2 connection
    Log To Console    ...wait sib1 message for all cells then setup x2 connection...
    ${start_time}=    Get Time    epoch
    Airphone Get Enb Id
    _wait_until_sib1_received_for_all_cells    ${timeout}
    ${end_time}=    Get Time    epoch
    ${used_time}=    Evaluate    ${end_time}-${start_time}
    ${timeout_1}=    Evaluate    ${timeout}-${used_time}
    Airphone Setup X2 Connection    timeout=${timeout_1}


Check All Cells Received SIB2
    Log To Console    ...wait sib2 message for all cells...
    ${egate_file}    Set Variable    ${WTS_DIR}/egate_console.log
    Wait Until Keyword Succeeds    300     15     _sim_state_is_active
    ${cell_id_list}=    Airphone Get Cell Id List
    ${cell_num}    Get Length    ${cell_id_list}
    Log To Console   cell_num=${cell_num} and cell_id_list=${cell_id_list}
    Wait Until Keyword Succeeds    600s    20s    Check Egate Log With Message    ${egate_file}
    ...    SystemInformationBlockType2-NR updated    ${cell_num}

Check Egate Log With Message
    [Arguments]    ${egate_file}     ${msg_regexp}    ${times}=1
    [Documentation]    This keyword is to check special message in egate log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | egate_file | Yes | the path of egate log |
    ...    | msg_regexp | Yes | the check point, message or regexp both ok |
    ...    | times | No | the times of check point repeat  |
    ...
    ...    | Examples: |
    ...    | Check Egate Log With Message | ${egate_file} | SystemInformationBlockType1 | 4 |
    ...
#    ute_wtssim.Execute Egate Command    sim_log_set
    airphone_execute_egate_command    sim_log_set
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}     Get Lines Matching Regexp    ${content}    ${msg_regexp}    partial_match=true
    Log    ${match_list}
    ${repert_times}    Get Count    ${match_list}    ${msg_regexp}
    Should Be True    ${repert_times}>=${times}