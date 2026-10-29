*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/btslog_check.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Variables      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
*** Variables ***

*** Keywords ***
KPI_51_SiSo_Manual_RU_reset_downtime
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this test case is to verify the KPI#51a/b, the Radio Unit (RU) Reset downtime.
    ...    This Test Case is needed to be executed in order to collect the measurements for KPI comparison
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 06.01.2023 - - Created
    ...    - 10.17.2023 - - Update by mengting.li@nokia-sbell.com, task from tribe PZ, common TA case step should match with QC case step
    ...    - 01.30.2024 - - Update by kaihui.fan@nokia-sbell.com, match rf7.1 ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1679?filter=-2
    ...    - 04.11.2024 - - Update by kaihui.fan@nokis-sbell.com, ticket: https://jiradc.ext.net.nokia.com/browse/LEOPARD-1912
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${ru_reset_startup_duration}=240  ${special_ru}=AEQQ
    run keyword and ignore error    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    Start Btslog With Path Check
    Selenium Login And Disable Screen Lock
    log to console    \n***RF Module index ${ru_index} Reset from GUI***
    selenium_coam.reset_ru    ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    ${led_status_list}  create list  YELLOW YELLOW  YELLOW OFF  GREEN GREEN
    ${if_special}   Run Keyword And Return Status   should match regexp    ${special_ru}    AVQ*
    ${new_timestamp}    Run Keyword If  not ${if_special}   Check LED Status In RU Log
    ...   led_status_list=${led_status_list}    log_name=ru_reset    ru_index=${ru_index}
    Run Keyword If  not ${if_special}   KPI_51_SiSo_Manual_RU_reset_downtime_Alarm_check    is_check_historyalarm=${True}
    ...   ELSE    Specific History Alarm Should Not Exist    fault_id=10    connection=GNB_OAM
    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    Btslog Check RU Reset On Startup Duration     ru_index=${ru_index}
    ...                                           ru_reset_startup_duration=${ru_reset_startup_duration}
    [Teardown]  selenium logout and close browser

KPI_51_SiSo_Manual_RU_reset_downtime_Alarm_check
    [Arguments]    ${is_check_historyalarm}=${False}    ${connection}=GNB_OAM
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=${connection}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    run keyword if    ${is_check_historyalarm}    should be true    ${history_alarm_status}

Specific History Alarm Should Not Exist
   [Arguments]   ${fault_10}=10  ${connection}=GNB_OAM
   ${historical_alarms}=   coam.get_historic_alarms   connection=${connection}     timeout=100   load_history=${True}
   ${alarm_num}    Get Length    ${historical_alarms}
   ${present_status}    Set Variable    ${False}
   FOR  ${alarm}  IN  @{historical_alarms}
      Exit For Loop If    ${alarm_num}==${0}
      ${present_status}    Run Keyword And Return Status
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}
     Exit For Loop If    ${present_status}
   END
   Run Keyword If    ${present_status}    Fail    faultId ${faultId} is present on gnb.
