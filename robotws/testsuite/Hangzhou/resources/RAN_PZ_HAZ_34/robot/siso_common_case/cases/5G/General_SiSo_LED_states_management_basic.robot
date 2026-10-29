*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_LED_states_management_basic
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to frame structure
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.04.2020    - Created
    ...    OWNER_tingting.zhong@nokia-sbell.com
    [Arguments]  ${ru_index}=1
    Perform RU Power reset    ru_index=${ru_index}
    sleep    90
    ${led_status_list}  create list  YELLOW YELLOW  YELLOW OFF  GREEN GREEN
    ${new_timestamp}  Check LED Status In RU Log    led_status_list=${led_status_list}    log_name=power_reset    ru_index=${ru_index}
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    Perform RU Lock And Unlock    ru_index=${ru_index}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    ${led_status_list_1}  create list  YELLOW YELLOW  GREEN GREEN
    ${new_timestamp}  Check LED Status In RU Log    led_status_list=${led_status_list_1}    log_name=lock_and_unlock    ru_index=${ru_index}
    ...    timestamp=${new_timestamp}
    [Teardown]  Selenium Logout And Close Browser
