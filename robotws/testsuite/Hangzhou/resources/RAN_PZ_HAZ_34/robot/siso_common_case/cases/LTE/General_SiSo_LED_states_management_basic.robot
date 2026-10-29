*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot

*** Variables ***

*** Keywords ***
General_SiSo_LED_states_management_basic
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to frame structure
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 25.04.2022    - Created
    ...    OWNER_jiayi.tang@nokia-sbell.com
    [Arguments]  ${ru_index}=1
    Perform RU Power reset LTE    ru_index=${ru_index}
    ${led_status_list}  create list  YELLOW YELLOW  YELLOW OFF  GREEN GREEN
    ${new_timestamp}  Check LED Status In RU Log LTE    led_status_list=${led_status_list}    log_name=power_reset    ru_index=${ru_index}
    Close Start Up View Window    timeout=60
    Perform RU Lock And Unlock    ru_index=${ru_index}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
    ${led_status_list_1}  create list  YELLOW YELLOW  GREEN GREEN
    ${new_timestamp}  Check LED Status In RU Log LTE    led_status_list=${led_status_list_1}    log_name=lock_and_unlock    ru_index=${ru_index}
    ...    timestamp=${new_timestamp}
