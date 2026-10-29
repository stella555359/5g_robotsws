*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot


*** Keywords ***
General_Power_Meter_counter_update_for_energy_consumption
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the case is to check Power Meter counter update for energy consumption.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 06.17.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    abbr=actPowerMeter    new_value=true
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS Energy Consumption    abbr=mtBtsEnergyMonitoring    new_value=15min
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS SM Energy Monitoring    abbr=mtSBTSSmEnergyMonitoring    new_value=15min
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS RFM energy monitoring    abbr=mtSBTSRfmEnergyMonitoring    new_value=15min
    sleep  1min
    ${RMOD_Power}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    Should Be True    ${RMOD_Power} >0
    ${SMOD_Power}    ${wait_time}    Get real time power measurements via Webem    object_names=SMOD    interval=15min
    Should Be True    ${SMOD_Power} >0
    log to console    \nWait 29 mins
    sleep  29min
    Check M40002 Counter
    Check M40003 Counter
    Check M40004 Counter
    Check M4000X Counter internal relationship
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    abbr=actPowerMeter    new_value=false
    sleep  60
    Wait until keyword succeeds    10min    180s    Check M40002 Counter Not Work
    Wait until keyword succeeds    10min    180s    Check M40003 Counter Not Work
    Wait until keyword succeeds    10min    180s    Check M40004 Counter Not Work
