*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
#*** Variables ***

*** Keywords ***
General_SiSo_Cell_block_and_unblock
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify cell and group cell block/ unblock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    ...    Notice: if cell group has servals cell, get ue failed
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}
    ...  ${call_keyword}=Get UE From Init File and Make call
    Get X2 link shutdown waiting time
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Cell_block_and_unblock  cell_type=nr    with_call=${with_call}  with_peak=${with_peak}  call_keyword=${call_keyword}
    Cell_block_and_unblock  cell_type=lte    with_call=${with_call}  with_peak=${with_peak}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Selenium Logout And Close Browser

Cell_block_and_unblock
    [Arguments]  ${cell_type}=nr    ${with_call}=${True}  ${with_peak}=${False}
    ...  ${call_keyword}=Get UE From Init File and Make call
    ${cell_id_list}  Get All Cell Id    cell_type=${cell_type}
    ${cell_num}    get length  ${cell_id_list}
    ${technology}  set variable  ${cell_type.upper()}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Block and UnBlock Cells and L3call    block_list=${cell_id_list}   technology=${technology}   with_call=${with_call}  with_peak=${with_peak}
    ...  call_keyword=${call_keyword}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
#    run keyword if  ${cell_num}>1  Block and UnBlock Cells  block_list=${cell_id_list}   technology=${technology}
#    [Teardown]    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_id_list}
#    ...    technology=${technology}    gnb_type='${gNb_CuType}'
