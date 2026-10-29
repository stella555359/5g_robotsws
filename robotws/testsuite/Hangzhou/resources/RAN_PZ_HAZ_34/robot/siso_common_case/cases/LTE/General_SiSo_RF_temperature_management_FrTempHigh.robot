*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/5GC000399_Keyword.robot

*** Variables ***

*** Keywords ***
General_SiSo_RF_temperature_management_FrTempHigh
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this TC is to check if temperature related fault 1936 FrTempHigh is reported correctly.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 31.10.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${target_value}=20.0    ${tcs_file}=tcs
    ${Thigh_init}    get parameter value from tcs json file    ru_index=${ru_index}    filter_name=Thigh    tcs_file=${tcs_file}
    log to console   \n init Thigh value:${Thigh_init}
    log to console    \n Trigger Fault 1936
    modify parameter value In tcs json file with RU reset LTE    init_value=${Thigh_init}    target_value=${target_value}
    ...    filter_name=Thigh    ru_index=${ru_index}    tcs_file=${tcs_file}
    Wait until keyword succeeds    20min    20s    verify all cells should be onair    cell_type=${cell_type}
    log to console   \n Check Fault 1936 Appear in RawAlarmHistory
    Wait until keyword succeeds    10min    30s    Check Alarm Exist in RawAlarmHistory for LTE    alarm_filter=1936
    [Teardown]    run keywords    modify parameter value In tcs json file with RU reset LTE    init_value=${target_value}
    ...    target_value=${Thigh_init}    filter_name=Thigh    ru_index=${ru_index}    tcs_file=${tcs_file}    AND    Wait until keyword succeeds
    ...    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
