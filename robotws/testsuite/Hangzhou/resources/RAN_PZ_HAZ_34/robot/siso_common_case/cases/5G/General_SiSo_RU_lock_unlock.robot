*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot

*** Keywords ***
General_SiSo_RU_lock_unlock
    [Documentation]
    ...    *****************
    ...    Owner_zhenzhen.ren@nokia-sbell.com
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
    [Arguments]  ${with_call}=${True}    ${4G_check}=${False}    ${ue_num}=1    ${special_ru}=AVQL
    ${start_time}    robot.libraries.DateTime.get current date
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    ${cell_num}    get length  ${cell_list}
    log to console    ${ue_num}
    sort list    ${cell_list}
    Lock all RUs and check all status    ru_index_list=${ru_index_list}
    ...    cell_list=${cell_list}    gnb_type='${gNb_CuType}'    ue_num=${ue_num}    with_call=${with_call}    4G_check=${4G_check}
    ...    special_ru=${special_ru}
    Close Start Up View    timeout=60
    UnLock all RUs and check all status    ru_index_list=${ru_index_list}    cell_list=${cell_list}
    ...    gnb_type='${gNb_CuType}'    start_time=${start_time}    ue_num=${ue_num}    with_call=${with_call}    4G_check=${4G_check}
    ...    special_ru=${special_ru}
    run keyword if    ${cell_num}>1 and '${gNb_CuType}'=='NSA' and ${with_call}   start traffic all cells nsa    cell_list=${cell_list}
    ...    4G_check=${4G_check}
    run keyword if    ${cell_num}>1 and '${gNb_CuType}'=='SA' and ${with_call}    start traffic all cells sa     cell_list=${cell_list}
    ...    ue_num=${ue_num}    4G_check=${4G_check}
    [Teardown]    Run Keywords    excute ru unlock    ru_index_list=${ru_index_list}    AND
    ...    Selenium Logout And Close Browser
