*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Keywords ***
RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is entering deep sleep mode
    ...    when all carriers are deactivated
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.09.2020 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}

    #e.g. ${configuration} = 1S-2CC-8D-4U
    ${config}    get current bts configuration
    #special handle for 1S-2CC when lbpsSOMethod=mixed switch off
    ${flagConf}    run keyword and return status    Should contain    ${config}    1S-2CC
#    Run Keyword If   '${flagConf}'=='${True}'    Run Keyword And Ignore Error    Prepare for delete NRPGRP

#    Run Keyword And Ignore Error    Online delete NRPGRP
#    Online NRPGRP addition
    log to console  \n Enable 5GC000431
#    Run Keyword And Ignore Error    Selenium Logout And Close Browser
#    wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
    Modify 5GC000431 CB007511 Parameter   actNrLBPowerSaving=true   energySavingMode=DEEPSLEEP
#    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=true
#    log to console  \n Enable CB007511
#    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
#    ...    filter_param=Energy Saving Mode control    abbr=energySavingMode    new_value=DEEPSLEEP
    log to console  \n Wait 1000s
    Wait until keyword succeeds    5min    10s    Enable RU eth for syslog
    sleep    1000
    Wait until keyword succeeds    5min    10s    Enable RU eth for syslog
    Run Keyword And Ignore Error    Selenium Logout And Close Browser2
    wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
    Wait until keyword succeeds    5min    30s    RU1_AQQL Status Info Should Be Sleep
    ${power_meassure_1}  Get RMOD Power Measurement
    [Teardown]    Run keywords    Run Keyword And Ignore Error    Modify 5GC000431 CB007511 Parameter   actNrLBPowerSaving=false
     ...   energySavingMode=NORMAL
#    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
#    ...    AND   Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
#    ...    filter_param=Energy Saving Mode control    abbr=energySavingMode    new_value=NORMAL
#    ...    AND   selenium_coam.reset_ru  ru_index=${1}
    ...    AND   Wait until keyword succeeds    12min    20s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser2
    #[Teardown]    run keywords    Commissioning SCF And Check On Air    scf_path=${Case_SCF_Path}    AND
    #...    Selenium Logout And Close Browser

Selenium Logout And Close Browser2
    Run Keyword And Ignore Error    Close Start Up View    timeout=5
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
    Run Keyword And Ignore Error    selenium_coam.close_browser

Modify 5GC000431 CB007511 Parameter
    [Arguments]    ${actNrLBPowerSaving}=true   ${energySavingMode}=DEEPSLEEP
    Log to console    Modify 5GC000431 CB007511 Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving
    ...    abbr=actNrLBPowerSaving
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving  p_name=actNrLBPowerSaving  value=${actNrLBPowerSaving}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${actNrLBPowerSaving}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control
    ...    abbr=energySavingMode
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control  p_name=energySavingMode  value=${energySavingMode}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${energySavingMode}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_change_of_EnergySavingMode
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is returning from deep sleep mode to normal mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.09.2020 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}

    #e.g. ${configuration} = 1S-2CC-8D-4U
    ${config}    get current bts configuration
    #special handle for 1S-2CC when lbpsSOMethod=mixed switch off
    ${flagConf}    run keyword and return status    Should contain    ${config}    1S-2CC
#    Run Keyword If   '${flagConf}'=='${True}'    Run Keyword And Ignore Error    Prepare for delete NRPGRP

#    Run Keyword And Ignore Error    Online delete NRPGRP
#    Online NRPGRP addition
    log to console  \n Enable 5GC000431
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=true
    log to console  \n Enable CB007511
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control    abbr=energySavingMode    new_value=DEEPSLEEP
    #Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ${power_meassure_0}  Get RMOD Power Measurement
    log to console  \n Wait 900s
    sleep    900
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
    Wait until keyword succeeds    5min    30s    RU1_AQQL Status Info Should Be Sleep
    ${power_meassure_1}  Get RMOD Power Measurement
    log to console  \n disable CB007511
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control    abbr=energySavingMode    new_value=NORMAL
    sleep    300
    ##[after PR739900] The cells in power saving group don't have to be brought to notEnergySaving state after RU exits deep sleep mode##
    Wait until keyword succeeds    5min    30s    Cell Status Info Should Be Energy Saving State
    Wait until keyword succeeds    5min    30s    RU Status Info Should Be AWAKE but Idle
    ${power_meassure_2}  Get RMOD Power Measurement
    should be true      ${power_meassure_1} < ${power_meassure_0}
    should be true      ${power_meassure_2} < ${power_meassure_0}
    [Teardown]    Run keywords    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    ...    AND   Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control    abbr=energySavingMode    new_value=NORMAL
    ...    AND   Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser

RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_disable_5GC000431
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is returning from deep sleep mode to normal mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.09.2020 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    [Arguments]    ${LOOPS}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}

    #e.g. ${configuration} = 1S-2CC-8D-4U
    ${config}    get current bts configuration
    #special handle for 1S-2CC when lbpsSOMethod=mixed switch off
    ${flagConf}    run keyword and return status    Should contain    ${config}    1S-2CC
#    Run Keyword If   '${flagConf}'=='${True}'    Run Keyword And Ignore Error    Prepare for delete NRPGRP

#    Run Keyword And Ignore Error    Online delete NRPGRP
#    Online NRPGRP addition
    log to console  \n Enable 5GC000431
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console  \n Enable CB007511
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control    abbr=energySavingMode    new_value=DEEPSLEEP
    # Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    FOR   ${loop}  IN RANGE  ${LOOPS}
            Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
            ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=true
            log to console  \n Enable CB007511
            #Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
            log to console  \n Wait 900s
            sleep    900
            Run Keyword And Ignore Error    Selenium Logout And Close Browser
            wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
            Wait until keyword succeeds    5min    30s    RU1_AQQL Status Info Should Be Sleep
            ${power_meassure_1}  Get RMOD Power Measurement
            log to console  \n disable 5GC000431
            Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
            ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
            sleep    300
            Wait until keyword succeeds    5min    30s    RU Status Info Should Be Normal
            ${power_meassure_2}  Get RMOD Power Measurement
            should be true      ${power_meassure_1} < ${power_meassure_2}
    END
    [Teardown]    Run keywords    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    ...    AND   Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control    abbr=energySavingMode    new_value=NORMAL
    ...    AND   Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser

RU_entering_deep_sleep_mode_after_all_cells_locked
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is entering deep sleep mode
    ...    when all carriers are deactivated
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.09.2020 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    [Arguments]    ${LOOPS}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock    version=${stream}

    #e.g. ${configuration} = 1S-2CC-8D-4U
    ${config}    get current bts configuration
    #special handle for 1S-2CC when lbpsSOMethod=mixed switch off
    ${flagConf}    run keyword and return status    Should contain    ${config}    1S-2CC
#    Run Keyword If   '${flagConf}'=='${True}'    Run Keyword And Ignore Error    Prepare for delete NRPGRP

#    Run Keyword And Ignore Error    Online delete NRPGRP
#    Online NRPGRP addition
    log to console  \n Disable 5GC000431
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    log to console  \n Enable CB007511
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control    abbr=energySavingMode    new_value=DEEPSLEEP
    # Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    log to console  \n Lock all cells
    ${lock_list}  Get All Cell Id
    FOR  ${loop}  IN RANGE  ${LOOPS}
        Lock cells or groups and check status  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
            ...    gnb_type='${gNb_CuType}'
        log to console  \n Wait 600s
        sleep    600
        Run Keyword And Ignore Error    Selenium Logout And Close Browser
        wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
        Wait until keyword succeeds    5min    30s    RU1_AQQL Status Info Should Be Sleep
        Unlock cells or groups and check status from sleep mode  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
        sleep    300
        Wait until keyword succeeds    5min    30s    RU Status Info Should Be Normal
    END
    [Teardown]    Run keywords    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    ...    AND   Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control    abbr=energySavingMode    new_value=NORMAL
    ...    AND   Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser

RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_at_least_one_cell_unlocked
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is leaving deep sleep mode
    ...    when all carriers are activated
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.09.2020 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    RU_entering_deep_sleep_mode_after_all_cells_locked    LOOPS=${3}

Enable RU eth for syslog
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${made2_status}    run keyword and return status     Should contain    ${ru_type_init}    AQQ
    ${cmd_temp}   set variable if    ${made2_status}   sudo lmi-eth on
    ...    sudo lmi-eth on
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log   \n${output}     console=yes
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Unlock cells or groups and check status from sleep mode
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

RU1_AQQL Status Info Should Be Sleep
    [Arguments]    ${ru_index}=${1}  ${connection}=GNB_OAM
    log to console  \nRU_${ru_index} Status Should Be Sleep
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
    Should Be Equal As Strings   ${power_State}    SLEEP

RU Status Info Should Be AWAKE but Idle
    [Arguments]    ${ru_index}=${1}  ${connection}=GNB_OAM
    log to console  \nRU_${ru_index} Status Should Be Sleep\n
    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
    FOR    ${ru_info}  IN  @{ru_info_list}
        ${ru_Index}    Set Variable    ${ru_info["ru_index"]}
        ${usage_State}     Set Variable    ${ru_info["usageState"]}
        ${power_State}     Set Variable    ${ru_info["powerState"]}
        Exit For Loop If  '${ru_Index}'=='1'
    END
    Should Be Equal As Strings   ${usage_State}    Idle
    Should Be Equal As Strings   ${power_State}    AWAKE
