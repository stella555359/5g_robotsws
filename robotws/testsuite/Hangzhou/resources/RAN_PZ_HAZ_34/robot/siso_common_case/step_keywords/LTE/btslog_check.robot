*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library        taf.selenium.sbts        WITH NAME        selenium_coam
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot


*** Variables ***


*** Keywords ***
Btslog Check Cell Block Duration
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${cell_block_durtion}=10
    log to console    \ncheck cell ${cell_id} block duration in btslog
    ${cell_info}    set variable    /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-${cell_id}
    ${cmd}     Catenate
    ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep 'Block operation for: ${cell_info}'|awk '{print $7}'|head -n 1|tail -1
    ${blockcell_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${blockcell_startTime}
    ${blockcell_startTime}    DateTime.convert date
    ...    ${blockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate
    ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep '${cell_info} status change to operational state: Disabled, availability status: Offline'|
    ...    awk '{print $7}'|head -n 1|tail -1
    ${blockcell_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${blockcell_endTime}
    ${blockcell_endTime}    DateTime.convert date
    ...     ${blockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${blockcell_duration}    Evaluate    ${blockcell_endTime}-${blockcell_startTime}
    log to console   \ncell ${cell_id} block duration is ${blockcell_duration}
    run keyword and continue on failure    Should Be True
    ...    ${blockcell_duration}<=${cell_block_durtion} and ${blockcell_duration}>${0}

Btslog Check Cell Unblock Duration
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${cell_unblock_durtion}=30
    log to console    \ncheck cell ${cell_id} unblock duration in btslog
    ${cell_info}    set variable    /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-${cell_id}
    ${cmd}     Catenate
    ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep 'Unblock operation for: ${cell_info}'|awk '{print $7}'|head -n 1|tail -1
    ${unblockcell_startTime}     run    command=${cmd}
    Should Not Be Empty     ${unblockcell_startTime}
    ${unblockcell_startTime}    DateTime.convert date
    ...     ${unblockcell_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep 'LTE-${cell_id} has been changed from Offline to Online'|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${unblockcell_endTime}     run    command=${cmd}
    Should Not Be Empty     ${unblockcell_endTime}
    ${unblockcell_endTime}    DateTime.convert date
    ...      ${unblockcell_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${unblockcell_duration}    Evaluate    ${unblockcell_endTime}-${unblockcell_startTime}
    run keyword and continue on failure    Should Be True
    ...    ${unblockcell_duration}<=${cell_unblock_durtion} and ${unblockcell_duration}>${0}
    log to console   \ncell ${cell_id} unblock duration is ${unblockcell_duration}

Btslog Check RU Power On Startup Duration
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${ru_power_on_startup_duration}=360
    log to console    \ncheck ru ${ru_index} power on startup duration
    ${cmd}     Catenate
    ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep 'updateRuStatusFromRmod rmodWasReset'|awk '{print $7}'|head -n 1|tail -1
    ${power_on_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${power_on_startTime}
    ${power_on_startTime}    DateTime.convert date
    ...    ${power_on_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cell_onair_endTime}    set variable    ${0}
    ${cell_id_list}    Get All Cell Id    ru_index=${ru_index}    cell_type=${cell_type}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${cell_info}    set variable    /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-${cell_id}
        ${cmd}     Catenate
        ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep '${cell_info} has been changed from Offline to Online'|
        ...    awk '{print $7}'|head -n 1|tail -1
        ${get_cell_onair_endTime}=     run    command=${cmd}
        Should Not Be Empty     ${get_cell_onair_endTime}
        ${get_cell_onair_endTime}    DateTime.convert date
        ...     ${get_cell_onair_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        ${cell_onair_endTime}    set variable if    ${get_cell_onair_endTime}>${cell_onair_endTime}
        ...    ${get_cell_onair_endTime}    ${get_cell_onair_endTime}
    END
    ${power_on_ru_startup_duration}    Evaluate    ${cell_onair_endTime}-${power_on_startTime}
    log to console   \nru ${ru_index} power on startup duration is ${power_on_ru_startup_duration}
    run keyword and continue on failure    Should Be True
    ...    ${power_on_ru_startup_duration}<=${ru_power_on_startup_duration} and ${power_on_ru_startup_duration}>${0}
