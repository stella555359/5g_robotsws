*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
*** Variables ***

*** Keywords ***
General_SiSo_Beamforming_calibration
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check if calibration of beamforming can be activated
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.13.2021 - - Created
    ...    - 09.10.2021 - - Add step: https://jiradc.ext.net.nokia.com/browse/LEOPARD-560
    ...    - 25.05.2022 - - Modify step: https://jiradc.ext.net.nokia.com/browse/LEOPARD-668
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${check_time}=15    ${connection}=GNB_OAM
    log to console    \n***SITE Reset from GUI***
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    connection=${connection}    graceful_cell_shutdown=${False}
    sleep    60s
    Wait Until Keyword Succeeds    3min    5s    Connect to gnb coam via ssl
    Check All Components Status    operation_component=site    gnb_type=${gNb_CuType}
    log to console    sleep ${check_time}min to get beamforming calibration
    sleep  ${check_time}min
    ${ru_index_list}    get all ru index    connection=${connection}
    ${ru_num}    get length    ${ru_index_list}
    ${collect_file_mum}    set variable    ${0}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${status}    run keyword and return status    Collect RF Logs To TestPC    ru_index=${ru_index}    log_name=ru_fault_history_log
        run keyword if    ${status}    run keyword and continue on failure    Check fault history log    log_name=ru_fault_history_log
        ${collect_file_mum}    set variable if    not ${status}    ${collect_file_mum+1}    ${collect_file_mum}
    END
    ${bf_status}    Run Keyword And Return Status    Check RU Beamforming Status    check_count=${True}
    ...    check_ru_connect=${False}    connection=${connection}
    should be true  ${bf_status}
    should be true  ${collect_file_mum}<${ru_num}
