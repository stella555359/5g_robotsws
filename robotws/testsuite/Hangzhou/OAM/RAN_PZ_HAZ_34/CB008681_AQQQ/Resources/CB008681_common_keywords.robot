*** Settings ***
Resource    ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot

Variables    ./variables_CB008681.py

Documentation
...    author: Chen Shufei
...    contact: shufei.chen@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***


*** Keywords ***
CB008181_SR_C_13_RU_reset_duration_KPI51a
    [Arguments]   ${RF_Reset_Times}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        WEbUIResetWithRetryTimes    RF_Reset_Times=${RF_Reset_Times}  ru_index=${ru_index}
    END

WEbUIResetWithRetryTimes
    [Arguments]   ${RF_Reset_Times}  ${ru_index}
    FOR    ${i}    IN RANGE    ${RF_Reset_Times}
        ${res}     run keyword and ignore error    WEbUIResetWithRetry    retry_times=${RF_Reset_Times}  ru_index=${ru_index}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        should be true    ${duration_time_tmp}<${RU_reset_time_expect[0]}
    END

WEbUIResetWithRetry
    [Arguments]    ${retry_times}  ${ru_index}  ${gnb_index}=${0}
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    ${timestartTmp}   Get Current Date
    selenium_coam.reset_ru  ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}
    sleep    30s
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all the cells Should Be On Air
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800   pass      fail
    Selenium Logout And Close Browser
    [Return]    ${reset_status}   ${duration_time_tmp}

Check all the cells Should Be On Air
    [Arguments]    ${connection}=GNB_OAM
    Wait until keyword succeeds    20 min    1 sec   verify all cells should be onair    connection=${connection}

CB008181_SR_C_14_RU_power_reset_KPI154a
    [Arguments]    ${RF_Poweron_Times}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        RFPoweronWithRetryTimes    RF_Poweron_Times=${RF_Poweron_Times}  ru_index=${ru_index}
    END

RFPoweronWithRetryTimes
    [Arguments]   ${RF_Poweron_Times}  ${ru_index}
    FOR    ${i}    IN RANGE    ${RF_Poweron_Times}
        ${res}     run keyword and ignore error    RFPoweronWithRetry    retry_times=${RF_Poweron_Times}  ru_index=${ru_index}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        should be true    ${duration_time_tmp}<${RU_PowerOn_time_expect[0]}
    END


RFPoweronWithRetry
    [Arguments]    ${retry_times}  ${ru_index}
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait Until Keyword Succeeds    10min    15 sec    RU Should Be Power Off    ru_index=${ru_index}
    ${timestartTmp}   Get Current Date
    sleep    30s
    Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all the cells Should Be On Air
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800   pass      fail
    [Return]    ${reset_status}   ${duration_time_tmp}

CB008181_SR_C_12_Cell_unblock_duration_KPI17b
    [Arguments]  ${Cell_unblock_Times}
    ${cell_id_list}  Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_id_list}
        CellunblockWithRetryTimes    Cell_unblock_Times=${Cell_unblock_Times}  cell_index=${cell_index}
    END

CellunblockWithRetryTimes
    [Arguments]   ${Cell_unblock_Times}  ${cell_index}
    Selenium Login And Disable Screen Lock
    FOR    ${i}    IN RANGE    ${Cell_unblock_Times}
        ${res}     run keyword and ignore error    CellunblockWithRetry    retry_times=${Cell_unblock_Times}  cell_index=${cell_index}
        ${unblock_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        should be true    ${duration_time_tmp}<${cell_unblock_time_expect[0]}
    END
    [Teardown]  Selenium Logout And Close Browser

CellunblockWithRetry
    [Arguments]    ${retry_times}  ${cell_index}
    selenium_coam.block_cell    cell_idx=${cell_index}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
    Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${cell_index}   cell_group_idx=${cellgrp_id}
    log to console    Trigger cell unblock and start BTSLog
    Stop Btslog Collect    target_dir=/tmp/btslog2/
    run keyword and ignore error    run    command=rm /tmp/btslog2/* -rf
    Start Btslog With Path Check
    selenium_coam.unblock_cell    cell_idx=${cell_index}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
    ${unblock_status_Tmp}  Run Keyword And Return Status    check cell should be unblocked    cell_idx=${cell_index}  cell_group_idx=${cellgrp_id}
    Stop Btslog Collect    target_dir=/tmp/btslog2/
    Log To Console    Check unblockcell_duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "Write auditlog for UNBLOCK_IND"|
    ...       awk '{print $6}'|head -n 1|tail -1
    ${unblockcell_startTime}     run    command=${cmd}
    Should Not Be Empty     ${unblockcell_startTime}
    ${unblockcell_startTime}     convert date
    ...    ${unblockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...       awk '{print $6}'|head -n 1|tail -1
    ${unblockcell_endTime}     run    command=${cmd}
    Should Not Be Empty     ${unblockcell_endTime}
    ${unblockcell_endTime}        convert date
    ...     ${unblockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${unblockcell_duration}    Evaluate    ${unblockcell_endTime}-${unblockcell_startTime}
    ${unblock_status}	   Set Variable If	  "${unblock_status_Tmp}"=="True" and ${unblockcell_duration}<1800   pass
    [Return]    ${unblock_status}  ${unblockcell_duration}

check cell should be unblocked
    [Arguments]  ${cell_idx}  ${cell_group_idx}
    Wait Until Keyword Succeeds   5 min  1 sec   cell should be unblocked   cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}

CB008181_SR_C_10_Cell_unlock_duration_KPI16b
    [Arguments]  ${Cell_unlock_Times}
    ${cell_id_list}  Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_id_list}
        CellunlockWithRetryTimes    Cell_unlock_Times=${Cell_unlock_Times}  cell_index=${cell_index}
    END

CellunlockWithRetryTimes
    [Arguments]   ${Cell_unlock_Times}  ${cell_index}
    FOR    ${i}    IN RANGE    ${Cell_unlock_Times}
        ${res}     run keyword and ignore error    CellunlockWithRetry    retry_times=${Cell_unlock_Times}  cell_index=${cell_index}
        ${unlock_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        should be true    ${duration_time_tmp}<${cell_unlock_time_expect[0]}
    END

CellunlockWithRetry
    [Arguments]    ${retry_times}  ${cell_index}  ${connection}=GNB_OAM
    log to console    *****begin to lock the cell*******
    coam.lock    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    timeout=60    connection=${connection}
    sleep  15
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${cell_index}
    log to console    *****begin to unlock the cell*****
    Stop Btslog Collect    target_dir=/tmp/btslog2/
    run keyword and ignore error    run    command=rm /tmp/btslog2/* -rf
    Start Btslog With Path Check
    coam.unlock    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=${connection}
    ${unlock_status_Tmp}  Run Keyword And Return Status   check the cell unlocked   cell_id=${cell_index}
    Stop Btslog Collect    target_dir=/tmp/btslog2/
    Log To Console    Check unlockcell_duration
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "handleNewActivateRequest: activation started"|
    ...       awk '{print $6}'|head -n 1|tail -1
    ${unlockcell_startTime}     run    command=${cmd}
    Should Not Be Empty     ${unlockcell_startTime}
    ${unlockcell_startTime}     convert date
    ...     ${unlockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "has been changed from Validated to OnAirDone"|
    ...       awk '{print $6}'|head -n 1|tail -1
    ${unlockcell_endTime}     run    command=${cmd}
    Should Not Be Empty     ${unlockcell_endTime}
    ${unlockcell_endTime}        convert date
    ...      ${unlockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${unlockcell_duration}    Evaluate    ${unlockcell_endTime}-${unlockcell_startTime}
    ${unlock_status}	   Set Variable If	  "${unlock_status_Tmp}"=="True" and ${unlockcell_duration}<1800   pass
    [Return]    ${unlock_status}  ${unlockcell_duration}

check the cell unlocked
    [Arguments]  ${cell_id}
    Wait Until Keyword Succeeds   5 min  1 sec   Check cell should be unlocked   cell_id=${cell_id}

CB008181_SR_C_06_Site_Rest_downtime_KPI1a
    [Arguments]    ${Times}
    FOR    ${i}    IN RANGE    ${Times}
       ${res}     siteresetwithretrytimes
    END

siteresetwithretrytimes
    log to console    *****begin to reset site*******
    Selenium Login And Disable Screen Lock
    ${timestartTmp}   Get Current Date
    ${timestart}      convert date    ${timestartTmp}    epoch
    selenium_coam.reset_site
    sleep    5 min
    Check all the cells Should Be On Air
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    [Return]    ${duration_time_tmp}
    [Teardown]   Selenium Logout And Close Browser


CB008181_SR_C_08_Capacity_Module_Rest_downtime_KPI5
     [Arguments]    ${Times}
    FOR    ${i}    IN RANGE    ${Times}
       ${res}     ABIOresetwithretrytimes
    END

ABIOresetwithretrytimes
    log to console    *****begin to reset ABIO*******
    Selenium Login And Disable Screen Lock
    ${timestartTmp}   Get Current Date
    ${timestart}      convert date    ${timestartTmp}    epoch
    selenium_coam.reset_abil
    sleep    3 min
    Check all the cells Should Be On Air
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    [Return]    ${duration_time_tmp}
    [Teardown]   Selenium Logout And Close Browser
