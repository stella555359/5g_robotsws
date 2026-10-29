*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Variables ***

*** Keywords ***
General_microDTXAdvanced_when_Cell_locked
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify micro DTX Advanced when Cell locked
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 23.06.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}
    Get X2 link shutdown waiting time
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=true
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=true
    ${cell_list}    Get All Cell Id    ru_index=${ru_index}
    Lock cells or groups and check status    lock_list=${cell_list}  is_group=${False}
    ...    check_alarm=${False}    gnb_type='${gNb_CuType}'
    ${power_with_cell_lock}  Get RMOD Power Measurement    ru_index=${ru_index}
    Unlock cells or groups and check status  lock_list=${cell_list}  is_group=${False}
    ...    check_alarm=${False}    gnb_type='${gNb_CuType}'
    ${power_with_cell_unlock}  Get RMOD Power Measurement    ru_index=${ru_index}
    ${p_value}    Evaluate    "%.3f" % ((${power_with_cell_unlock}-${power_with_cell_lock})/${power_with_cell_unlock})
    ${per_value}    Evaluate    ${p_value}*100
    log to console   \n Power Saving Percent:${per_value}%
    should be true      0 < ${p_value} < 0.3
    [Teardown]  selenium logout and close browser
