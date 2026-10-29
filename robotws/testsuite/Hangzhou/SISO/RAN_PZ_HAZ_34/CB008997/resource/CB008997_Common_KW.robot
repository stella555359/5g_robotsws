*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Library      taf.selenium.sbts      WITH NAME    sbts_sm
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot


*** Variables ***

*** Keywords ***
step ${step_id}: Check power consumption counter with uDTX ${actMicroDtx} on OnAir state
    [Arguments]
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Log to console    step ${step_id}: Check power consumption with uDTX ${actMicroDtx} on OnAir state
    ${actMicroDtx_value}   set variable if   '${actMicroDtx}'=='disabled'    false    true

#    ${actMicroDTXAdvanced_orig}   Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#    ...    filter_param=Activate micro discontinued transmission advanced
    Run Keyword If    '${actMicroDtx_value}'=='false'    Run Keywords
    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=${actMicroDtx_value}
    ...    AND
    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=${actMicroDtx_value}
    ...    ELSE    Run Keywords
    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=${actMicroDtx_value}
    ...    AND
    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=${actMicroDtx_value}

#    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=${actMicroDtx_value}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    abbr=actPowerMeter    new_value=true
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS Energy Consumption    abbr=mtBtsEnergyMonitoring    new_value=15min
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS SM Energy Monitoring    abbr=mtSBTSSmEnergyMonitoring    new_value=15min
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS RFM energy monitoring    abbr=mtSBTSRfmEnergyMonitoring    new_value=15min
    sleep  1min

    Connect to gnb coam via ssl
    Wait until keyword succeeds    20 min    20 sec    COAM Check GNB cell on air
    ${RMOD_Power}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    set test variable   ${diff_num}   ${0}
    ${diff_num}=    run keyword if      '${step_id}'=='7'
    ...    Evaluate    abs(${RMOD_Power}-${RMOD_Power_2})

    run keyword if      '${step_id}'=='4'
    ...    Should Be True    ${RMOD_Power} < ${RMOD_Power_2}
    ...    ELSE IF   '${step_id}'=='7'
    ...    Should Be True    ${diff_num} < ${30}

    [Teardown]  CleanFirefox

step ${step_id}: Note the values of RU power consumption
    [Arguments]
    Log to console   step ${step_id}: Note the values of RU power consumption
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${RMOD_Power}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    Should Be True    ${RMOD_Power} >0
    Set Test Variable   ${RMOD_Power_${step_id}}   ${RMOD_Power}
    [Teardown]  CleanFirefox

step ${step_id}: Change actMicroDtx parameter from ${old_value} to ${new_value}
    [Arguments]
    Log to console    step ${step_id}: Change actMicroDtx parameter from ${old_value} to ${new_value}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}

    Run Keyword If    '${new_value}'=='false'    Run Keywords
    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=${new_value}
    ...    AND
    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=${new_value}
    ...    ELSE    Run Keywords
    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=${new_value}
    ...    AND
    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=${new_value}

#    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=${new_value}
    [Teardown]  CleanFirefox

CleanFirefox
    Log to Console    CleanFirefox
    Run Keyword And Ignore Error  Selenium Logout And Close Browser
    Run Keyword And Ignore Error  COAM Teardown gnb connections
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver
