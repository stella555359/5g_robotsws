*** Settings ***
Resource    ./CB007331_common_keyword.robot
Variables    ../TestData/variable_9104.py
Library    ../lib/CB007331.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot

Documentation
...    author: jiangjing lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***


*** Keywords ***
General_SiSo_Cell_block_and_unblock_AZQF_9104
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}    ${protocol}=udp    ${duration}=${30}
    ...    ${gnb_index}=0    ${du_index}=0    ${ue_ul_layer}=1    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    ${cells_other}    Get Other Ids    id_list=${cell_id_list}    given_id=${cell_id}[0]
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Block cells and check status    block_list=${cells_other}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}
    ...    target_avg_percent=${0.85}    min_percent=${0.80}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    UnBlock cells and check status    block_list=${cells_other}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Block cells and check status    block_list=${cell_id}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    UnBlock cells and check status    block_list=${cell_id}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}
    ...    target_avg_percent=${0.85}    min_percent=${0.80}
    [Teardown]    run keyword and ignore error    UnBlock cells and check status in teardown step
    ...    block_list=${cells_other}    check_alarm=${False}    gnb_type=${gNb_CuType}

General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS_Concurrent_9104
    [Arguments]    ${tput_self_define}    ${cell_id}=${None}    ${duration}=${600}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}
