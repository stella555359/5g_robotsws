*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
#*** Variables ***

*** Keywords ***
General_SiSo_RF_module_reset_from_GUI
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of radio module reset triggered by user from GUI with use of RP1 messaging.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.19.2019  - Created
    ...    *******************
    ...    Owner_aaron.deng@nokia-sbell.com
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ...    ${suite_name}=default    ${test_name}=default    ${ue_num_each_call}=1
    ${ru_index_list}  Get All RU Index    connection=${connection}
    wait until keyword succeeds    3x    5sec    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n***RF Module index ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    END
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${gnb_index}    connection=${connection}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}    connection=${connection}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
        ...    suite_name=${suite_name}    test_name=${test_name}    ue_num_each_call=${ue_num_each_call}
    END
    Check RF Startup and Gnb Status    ${ru_index_list}    gnb_index=${gnb_index}    connection=${connection}
    verify all cells should be onair    connection=${connection}
    [Teardown]  Selenium Logout And Close Browser
