*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Keywords ***
RU_returning_from_SLEEP_EXTREME_to_normal_operation_due_to_change_of_EnergySavingMode
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is returning from extreme deep sleep mode to normal mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.11.2025 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}

#    Run Keyword And Ignore Error    Online delete NRPGRP
#    Online NRPGRP addition

    log to console  \n Enable 5GC000431 - cell energy saving mode
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    version=${stream}
    ${orig_ESMvalue}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=true
    log to console  \n Enable CB012091 - RU extreme deep sleep mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP_EXTREME_SFP
    #Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    #${power_meassure_0}  Get RMOD Power Measurement
    log to console  \n Wait 900s
    sleep    900
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
    Wait until keyword succeeds    5min    30s    RU1 Status Info Should Be SLEEP_EXTREME
    #${power_meassure_1}  Get RMOD Power Measurement
    log to console  \n disable CB012091 - RU extreme deep sleep mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=NORMAL
    sleep    300
    ##[after PR739900] The cells in power saving group don't have to be brought to notEnergySaving state after RU exits deep sleep mode##
    Wait until keyword succeeds    5min    30s    Cell Status Info from specific RU Should Be Energy Saving State   ru_index=${1}
    Wait until keyword succeeds    5min    30s    RU1 Status Info Should Be AWAKE but Idle
    # ${power_meassure_2}  Get RMOD Power Measurement
    # should be true      ${power_meassure_1} < ${power_meassure_0}
    # should be true      ${power_meassure_2} < ${power_meassure_0}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    ...    AND    wait until keyword succeeds    3x   20s    Selenium Login And Disable Screen Lock    version=${stream}
    ...    AND    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    ...    AND   Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=${orig_ESMvalue}
    ...    AND   Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser

RU_returning_from_SLEEP_EXTREME_to_normal_operation_due_to_disable_5GC000431
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is returning from extreme deep sleep mode to normal mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.11.2025 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    [Arguments]    ${LOOPS}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}

#    Run Keyword And Ignore Error    Online delete NRPGRP
#    Online NRPGRP addition

    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console  \n Enable CB012091 - RU extreme deep sleep mode
    ${orig_ESMvalue}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP_EXTREME_SFP
    # Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    FOR   ${loop}  IN RANGE  ${LOOPS}
        log to console  \n Enable 5GC000431 - cell energy saving mode
        Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=true
        log to console  \n Enable CB012091 - RU extreme deep sleep mode
        #Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
        log to console  \n Wait 900s
        sleep    900
        Run Keyword And Ignore Error    Selenium Logout And Close Browser
        wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
        Wait until keyword succeeds    5min    30s    RU1 Status Info Should Be SLEEP_EXTREME
        #${power_meassure_1}  Get RMOD Power Measurement
        log to console  \n disable 5GC000431 - cell energy saving mode
        Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
        sleep    300
        Wait until keyword succeeds    5min    30s    RU Status Info Should Be Normal
        #${power_meassure_2}  Get RMOD Power Measurement
        #should be true      ${power_meassure_1} < ${power_meassure_2}
    END
    [Teardown]    Run keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    ...    AND    wait until keyword succeeds    3x   20s    Selenium Login And Disable Screen Lock    version=${stream}
    ...    AND    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    ...    AND   Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=${orig_ESMvalue}
    ...    AND   Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser

RU_returning_from_SLEEP_EXTREME_to_normal_operation_due_to_at_least_one_cell_unlocked
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is entering extrem deep sleep mode
    ...    when all carriers are deactivated
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.11.2025 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    [Arguments]    ${LOOPS}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock    version=${stream}

#    Run Keyword And Ignore Error    Online delete NRPGRP
#    Online NRPGRP addition

    log to console  \n Disable 5GC000431 - cell energy saving mode
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    version=${stream}
    ${orig_ESMvalue}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    log to console  \n Enable CB012091 - RU extreme deep sleep mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP_EXTREME_SFP
    # Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    log to console  \n Lock all cells
    ${lock_list}  Get All Cell Id    ru_index=1
    FOR  ${loop}  IN RANGE  ${LOOPS}
        Lock cells or groups and check status  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
            ...    gnb_type='${gNb_CuType}'
        log to console  \n Wait 600s
        sleep    600
        Run Keyword And Ignore Error    Selenium Logout And Close Browser
        wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
        Wait until keyword succeeds    5min    30s    RU1 Status Info Should Be SLEEP_EXTREME
        Unlock cells or groups and check status from extreme sleep mode   lock_list=${lock_list}
        ...  is_group=${False}  check_alarm=${False}
        sleep    300
        Wait until keyword succeeds    5min    30s    RU Status Info Should Be Normal
    END
    [Teardown]    Run keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    ...    AND    wait until keyword succeeds    3x   20s    Selenium Login And Disable Screen Lock    version=${stream}
    ...    AND    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    ...    AND   Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=${orig_ESMvalue}
    ...    AND   Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser

Unlock cells or groups and check status from extreme sleep mode
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${lock_list}  ${is_group}=${True}  ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    ${output}   set variable if      ${is_group}==${False}    NRCELL-    NRCELLGRP-
    connect to gnb coam via ssl    connection=${connection}
    FOR    ${idx}  IN  @{lock_list}
        log to console  \n***unLock ${output}${idx} and check status***
        run keyword if    ${is_group}==${True}
        ...    perform_cell_group_unlock_via_admin  cellgrp_id=${idx}    connection=${connection}    lock_timeout=120
        ...    ELSE
        ...    perform_cell_unlock_via_admin    cell_id=${idx}    connection=${connection}    lock_timeout=120
        run keyword if    ${is_group}==${True}
        ...    Wait Until Keyword Succeeds   10 min  20 sec    Check cells under group should be unlocked   cell_group_idx=${idx}
        ...    connection=${connection}
        ...    ELSE
        ...    Wait Until Keyword Succeeds   10 min  20 sec   Check cell should be unlocked   cell_id=${idx}    connection=${connection}
    END
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  Wait For Expect Fault To Disappear  faultId=7300   timeout=600   AND
    ...    Wait For Expect Fault To Disappear  faultId=7319   timeout=300
    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair

RU1 Status Info Should Be SLEEP_EXTREME
    [Arguments]    ${ru_index}=${1}  ${connection}=GNB_OAM
    log to console  \nRU_${ru_index} Status Should Be SLEEP_EXTREME
    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
#    FOR    ${ru_info}  IN  @{ru_info_list}
#        ${product_Name}    Set Variable    ${ru_info["productName"]}
#        ${usage_State}     Set Variable    ${ru_info["usageState"]}
#        ${power_State}     Set Variable    ${ru_info["powerState"]}
#        Exit For Loop If  '${product_Name}'=='AQQL'
#    END
#    Should Be Equal As Strings   ${usage_State}    Idle
#    Should Be Equal As Strings   ${power_State}    SLEEP
##    Should Be Equal As Strings   ${ru_info_list[0]["usageState"]}    Idle
##    Should Be Equal As Strings   ${ru_info_list[0]["powerState"]}    SLEEP
    FOR    ${ru_info}  IN  @{ru_info_list}
        ${ru_Index}    Set Variable    ${ru_info["ru_index"]}
        ${usage_State}     Set Variable    ${ru_info["usageState"]}
        ${power_State}     Set Variable    ${ru_info["powerState"]}
        Exit For Loop If  '${ru_Index}'=='1'
    END
    Should Be Equal As Strings   ${usage_State}    Idle
    Should Be Equal As Strings   ${power_State}    SLEEP_EXTREME

RU1 Status Info Should Be AWAKE but Idle
    [Arguments]    ${ru_index}=${1}  ${connection}=GNB_OAM
    log to console  \nRU_${ru_index} Status Should Be AWAKE\n
    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
    FOR    ${ru_info}  IN  @{ru_info_list}
        ${ru_Index}    Set Variable    ${ru_info["ru_index"]}
        ${usage_State}     Set Variable    ${ru_info["usageState"]}
        ${power_State}     Set Variable    ${ru_info["powerState"]}
        Exit For Loop If  '${ru_Index}'=='1'
    END
    Should Be Equal As Strings   ${usage_State}    Idle
    Should Be Equal As Strings   ${power_State}    AWAKE

Cell Status Info from specific RU Should Be Energy Saving State
    [Arguments]    ${ru_index}=${None}    ${connection}=GNB_OAM
    log to console  \nCell Status Should Be Energy Saving State
    # ${cell_list}    ${nr_lte_concurrent}    coam_gnb_classical.Get All Cell Id From RU    ru_index=${ru_index}
    # ...    connection=${connection}
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell}  IN  @{cell_info_list}
        Run Keyword If    ${cell["ru_index"]}!=${ru_index} and ${ru_index}!=${None}     Continue For Loop
        Should Be Equal As Strings   ${cell["energySavingState"]}    energySaving
        Should Be Equal As Strings   ${cell["operationalState"]}    disabled
        Should Be Equal As Strings   ${cell["availabilityStatus"]}    off line
        Should Be Equal As Strings   ${cell["usageState"]}    Idle
    END
