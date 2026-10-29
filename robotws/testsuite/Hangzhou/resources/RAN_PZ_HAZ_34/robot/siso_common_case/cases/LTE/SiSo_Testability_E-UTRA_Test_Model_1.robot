*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Library     taf.selenium.sbts  WITH NAME  selenium_coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
*** Variables ***


*** Keywords ***
SiSo_Testability_E-UTRA_Test_Model_1
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Purpose of this test case is to verify LTE test model
    ...		set by operator via WebEM/SCF.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 7.4.2022 - - Created
    ...    - 30.1.2023 - - fix https://jiradc.ext.net.nokia.com/browse/LEOPARD-952
    ...    *******************
    ...    yue.2.liu@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${ul_dl_configuration}=3
    Enable Test Dedicated State
    ${local_cell}    Get Local Cell Name    cell_id=${cell_id}
    ${physical_cell_id}    Get Cell PCI    cell_id=${cell_id}
    Lte Downlink testmodel    local_cell=${local_cell}    test_model=E-TM1.1
    ...    physical_cell_id=${physical_cell_id}    ul_dl_configuration=${ul_dl_configuration}
    ...    test_id=${1}
    Stop Lte Downlink testmodel    test_id=${1}
    Lte Downlink testmodel    local_cell=${local_cell}    test_model=E-TM1.2
    ...    physical_cell_id=${physical_cell_id}    ul_dl_configuration=${ul_dl_configuration}
    ...    test_id=${2}
    Stop Lte Downlink testmodel    test_id=${2}
    Disable Test Dedicated State
    [Teardown]   Selenium Logout And Close Browser

Get Local Cell Name
    [Arguments]  ${cell_id}=1
    ${cell_name}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/LNBTS-${nrbtsID}/LNCEL-${cell_id}
    ...    filter_param=Cell name
    ${name_len}    get length    ${cell_name}
    ${local_name}    set variable if    ${name_len}==${0}    LNCEL-${cell_id}    ${cell_name}
    [Return]  ${local_name}

Get Cell PCI
    [Arguments]  ${cell_id}=1
    ${physical_cell_id}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/LNBTS-${nrbtsID}/LNCEL-${cell_id}
    ...    filter_param=Physical layer cell identity
    [Return]  ${physical_cell_id}

Enable Test Dedicated State
    [Arguments]  ${ru_index}=1
    log to console    \enable test dedicated state
    Close Start Up View    timeout=30
    selenium_coam.enable_test_dedicated_state
    sleep    3min
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}
    ...    password=${http_password}
    Wait until keyword succeeds    8 min    20 sec    RU Should Be Online    ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    30s    Cell Status Info Should Be Disabled    bs_blocked=Unblocked    cell_type=${cell_type}

Disable Test Dedicated State
    log to console    \disable test dedicated state
    Close Start Up View    timeout=30
    selenium_coam.disable_test_dedicated_state
    Wait Until Keyword Succeeds    5min    30s    Verify all cells should be onair    cell_type=${cell_type}

Lte Downlink testmodel
    [Arguments]  ${local_cell}=Lte_Cell1   ${test_model}=E-TM1.1    ${physical_cell_id}=1    ${ul_dl_configuration}=3
    ...    ${test_id}=${1}
    log to console    \dLte Downlink testmodel ${test_model}
    Close Start Up View    timeout=30
    selenium_coam.start_lte_downlink_test     local_cell=${local_cell}    test_model=${test_model}
    ...    physical_cell_id=${physical_cell_id}    ul_dl_configuration=${ul_dl_configuration}
    ${output}    selenium_coam.wait_for_lte_downlink_test_to_start    test_id=${test_id}
    should contain    ${output}    succeed

Stop Lte Downlink testmodel
    [Arguments]  ${test_id}=${1}
    sleep    2min
    Close Start Up View    timeout=30
    selenium_coam.stop_lte_downlink_test    test_id=${test_id}
    selenium_coam.wait_for_lte_downlink_test_to_stop    test_id=${test_id}   timeout=60
    sleep    10s
