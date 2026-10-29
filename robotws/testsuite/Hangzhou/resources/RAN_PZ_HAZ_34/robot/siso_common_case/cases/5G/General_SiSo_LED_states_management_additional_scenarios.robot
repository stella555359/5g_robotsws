*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_LED_states_management_additional_scenarios
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that LEDs on radio module works as specified
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.08.2021    - Created
    ...    OWNER_jianhua.1.zhu@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${Tdanger_target}=30.0
    ${Tdanger_init}    Get Tdanger Value from Json File    ru_index=${ru_index}
    log to console   \n init Tdanger value:${Tdanger_init}
    log to console    \n Trigger Alarm 1937
    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_init}    target_value=${Tdanger_target}
    ...    cmd=touch    ru_index=${ru_index}
    log to console   \n Check Alarm 1937 Appear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1937
    ${led_status_list}  create list  YELLOW YELLOW   RED RED
    ${new_timestamp}  Check LED Status In RU Log    led_status_list=${led_status_list}    ru_index=${ru_index}   log_name=ru_log_1
    log to console    \n Recovery Alarm 1937
    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_target}    target_value=${Tdanger_init}
    ...    cmd=rm -rf    ru_index=${ru_index}
    log to console    \n Check Alarm 1937 Disappear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1937
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    ${led_status_list_1}  create list  YELLOW YELLOW  YELLOW OFF  GREEN GREEN
    ${new_timestamp}  Check LED Status In RU Log    led_status_list=${led_status_list_1}    ru_index=${ru_index}   log_name=ru_log_2
    [Teardown]  run keywords    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_target}
    ...    target_value=${Tdanger_init}    cmd=rm -rf    ru_index=${ru_index}    AND    coam wait gnb and cells ready
    ...    timeout=15min    gnb_type='${gNb_CuType}'
