*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Library     taf.selenium.sbts    WITH NAME    selenium_coam
*** Variables ***

*** Variables ***

*** Keywords ***
Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify success rate of gNB site reset activated from
    ...    WebUI interface.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.6.25 - - Created
    ...    - 2023.10.07 - - Updated by mengting.li@nokia-sbell.com from PZ tribe task that ST case TA should match as QC step
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${cell_list}=${None}    ${ue_num_for_call_per_cell}=1    ${dl_tp}=128  ${ul_tp}=12
    ...    ${duration}=${60}    ${protocol}=udp    ${check_wait_time}=30    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.5    ${min_percent}=0.1
    log to console    \n***prepare ue***
    Simple UE L3 Call And Throughput    cell_list=${cell_list}    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
    ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    duration=${duration}    protocol=${protocol}    check_wait_time=${check_wait_time}    log=${log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    FOR	${i}	IN RANGE	3
        log to console    \n***Perform BTS Site Reset LTE***
        selenium_coam.reset_lte    cancel=${True}
        selenium_coam.reset_site    with_graceful=${False}
        sleep    240s
        ${is_startup_window_exist}      selenium_coam.start_up_view_window_exists
        Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
        Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
        sleep    3s
        Simple UE L3 Call And Throughput    cell_list=${cell_list}    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
        ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}
        ...    duration=${duration}    protocol=${protocol}    check_wait_time=${check_wait_time}    log=${log}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        sleep    3s
    END
    [Teardown]    Manual_SiSo_SM_BTS_Site_Reset_teardown

Manual_SiSo_SM_BTS_Site_Reset_teardown
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
