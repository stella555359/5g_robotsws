*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
#*** Variables ***
#
*** Keywords ***
General_RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is entering deep sleep mode
    ...    when all carriers are deactivated
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.09.2020 - - Created
    ...    - 23.08.2023 - - Modified by LEOPARD-1406
    ...    - 17.12.2024 - - Modifed by https://jiradc.ext.net.nokia.com/browse/LEOPARD-2318
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    Prepare for delete NRPGRP
    Online delete NRPGRP
    ${cell_list}    get all cell id
    Online NRPGRP addition    cell_num=${{len(${cell_list})}}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS Energy Consumption    abbr=mtBtsEnergyMonitoring    new_value=15min
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS SM Energy Monitoring    abbr=mtSBTSSmEnergyMonitoring    new_value=15min
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS RFM energy monitoring    abbr=mtSBTSRfmEnergyMonitoring    new_value=15min
    log to console  \n Enable 5GC000431
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=true
    log to console  \n Enable CB007511
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    log to console  \n Wait 330s
    sleep    330
    Wait until keyword succeeds    5min    30s    Cell Status Info Should Be Energy Saving State    cell_index=1
    Wait until keyword succeeds    5min    30s    Cell Status Info Should Be Not Energy Saving State    cell_index=2
    log to console  \n Wait 330s
    sleep    330
    Wait until keyword succeeds    5min    30s    Cell Status Info Should Be Energy Saving State
    log to console  \n Wait 330s
    sleep    330
    Wait until keyword succeeds    10min    30s    RU Status Info Should Be Sleep
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable    ${split_version}[0]
    ${measured_object}  Set variable If    '${stream}' >= 'SBTS25R2'   ENERGY EFFICIENCY    ${None}
    check the real time power value    object_names=RMOD
    ...   measured_object=${measured_object}    interval=15min
    check the real time power value    object_names=SMOD    interval=15min
    Check M4000X Counter internal relationship
    [Teardown]    run keywords    Commissioning SCF And Check On Air    scf_path=${Case_SCF_Path}    AND
    ...    Selenium Logout And Close Browser
