*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot

*** Keywords ***
General_RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_change_of_EnergySavingMode
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is returning from deep sleep mode to normal mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.09.2020 - - Created
    ...    - 30.01.2024 - - Modify by https://jiradc.ext.net.nokia.com/browse/LEOPARD-1684
    ...    - 17.12.2024 - - Modifed by https://jiradc.ext.net.nokia.com/browse/LEOPARD-2318
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=1
    Selenium Login And Disable Screen Lock
    sleep    1830
    ${cell_id_list}  Get All Cell Id    ru_index=${ru_index}    cell_type=${cell_type}
    FOR  ${cell_id}  IN  @{cell_id_list}
        Check M55601 Counter internal relationship    cell_id=${cell_id}
    END
    Prepare for delete NRPGRP
    Online delete NRPGRP
    Online NRPGRP addition    cell_num=${{len($cell_id_list)}}    cell_id_list=${cell_id_list}
    log to console  \n Enable 5GC000431
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=true
    Wait until keyword succeeds    15min    30s    All Cells in Site should be Energy Saving State
    log to console  \n Enable CB007511
    Check And Modify Energy Saving Mode On WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    new_value=DEEPSLEEP
    Wait until keyword succeeds    10min    30s    RU Status Info Should Be as Expect
    ...    usageState=Idle    powerState=SLEEP
    sleep    120
    FOR  ${cell_id}  IN  @{cell_id_list}
        Check M55601 Counter internal relationship    cell_id=${cell_id}
    END
    ${power_meassure_1}  Get RMOD Power Measurement
    log to console  \n disable CB007511
    Check And Modify Energy Saving Mode On WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    new_value=NORMAL
    Wait until keyword succeeds    5min    5s    RU Status Info Should Be as Expect
    ...    operationalState=disabled    availabilityStatus=off line
    Wait until keyword succeeds    5min    5s    RU Status Info Should Be as Expect
    ...    usageState=Idle    powerState=AWAKE
    Wait until keyword succeeds    3min    5s    All Cells in Site should be Energy Saving State
    ${power_meassure_2}  Get RMOD Power Measurement
    ${sub_value}    Evaluate    ${power_meassure_2}-${power_meassure_1}
    ${expected_power_saving}    Evaluate    ${power_meassure_2} * 0.5
    should be true    ${sub_value} >= ${expected_power_saving}
    [Teardown]    Run keywords    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    ...    AND   Check And Modify Energy Saving Mode On WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    AND   Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser

All Cells in Site should be Energy Saving State
    ${cell_list}    get all cell id
    FOR    ${cell_id}    IN    @{cell_list}
        Cell Status Info Should Be Energy Saving State    cell_index=${cell_id}
    END
