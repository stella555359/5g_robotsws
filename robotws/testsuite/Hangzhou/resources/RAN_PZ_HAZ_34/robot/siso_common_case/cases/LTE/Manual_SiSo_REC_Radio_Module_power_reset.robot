*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

*** Variables ***

*** Keywords ***
Manual_SiSo_REC_Radio_Module_power_reset
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To check RU recovery after power reset
    ...      during normal operation (OnAir state).
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 2022.7.20
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${cell_list}=${None}    ${ue_num_for_call_per_cell}=1    ${dl_tp}=128  ${ul_tp}=12
    ...    ${duration}=${60}    ${protocol}=udp    ${check_wait_time}=30    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.5    ${min_percent}=0.1
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off LTE    ru_index=${ru_index}    model=${tl.enbs[0].rms[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    Power On RU And Check LTE    ru_index_list=${ru_index_list}
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Simple UE L3 Call And Throughput    cell_list=${cell_list}    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
        ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}
        ...    duration=${duration}    protocol=${protocol}    check_wait_time=${check_wait_time}    log=${log}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        sleep    3s
    END
    [Teardown]    Manual_SiSo_REC_Radio_Module_power_reset_Teardown

Manual_SiSo_REC_Radio_Module_power_reset_Teardown
    Selenium Logout And Close Browser
