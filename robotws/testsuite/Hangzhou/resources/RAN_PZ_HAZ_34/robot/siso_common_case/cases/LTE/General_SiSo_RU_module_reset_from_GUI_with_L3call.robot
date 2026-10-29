*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

*** Variables ***


*** Keywords ***
General_SiSo_RF_module_reset_from_GUI
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of radio module reset triggered by user from GUI with use of RP1 messaging.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.7.4  - Created
    ...    *******************
    ...    Owner_jiayi.tangg@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${cell_list}=${None}    ${ue_num_for_call_per_cell}=1    ${dl_tp}=128  ${ul_tp}=12
    ...    ${duration}=${60}    ${protocol}=udp    ${check_wait_time}=30    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.3    ${min_percent}=0.1    ${scf_path}=${Golden_SCF_Path}
    ${ru_index_list}     Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n***RF Module index ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    END
    Sleep    60s

    Wait Until Keyword Succeeds    20min    5s    verify all cells should be onair    cell_type=${cell_type}
    log to console    \n***prepare ue***
    FOR  ${ru_index}  IN  @{ru_index_list}
        Simple UE L3 Call And Throughput    cell_list=${cell_list}    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
        ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}
        ...    duration=${duration}    protocol=${protocol}    check_wait_time=${check_wait_time}    log=${log}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${scf_path}
        sleep    3s
        END
     [Teardown]    General_SiSo_RF_module_reset_from_GUI_Teardown

General_SiSo_RF_module_reset_from_GUI_Teardown
    Selenium Logout And Close Browser
