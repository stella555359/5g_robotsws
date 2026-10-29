*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Variables ***

*** Keywords ***
General_SiSo_RF_alarms_with_recovery
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify RU connection and fault reporting in WebUI.
    ...    RU should be affected by recoverable error triggered during normal BTS run
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 03.18.2020 - - Created
    ...    - 06.28.2020 - - Modified
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=1
    Modify Calibration File On RU Unit    current_name=calibration_dlpath1    new_name=calibration_dlpath1_bk    ru_index=${ru_index}
    Wait until keyword succeeds    20min    120s    RU Status Should Be Failed    ru_index=${ru_index}
    log to console    \n Check Alarm Exist in RawAlarmHistory
    Wait until keyword succeeds    10min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1901
	Wait until keyword succeeds    20min    120s    Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk
    ...    new_name=calibration_dlpath1    ru_index=${ru_index}
    log to console    \n Check Fault 1901 Absent on WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1901
    log to console    \n Check GNB cell on air
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]  Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk    new_name=calibration_dlpath1    ru_index=${ru_index}
