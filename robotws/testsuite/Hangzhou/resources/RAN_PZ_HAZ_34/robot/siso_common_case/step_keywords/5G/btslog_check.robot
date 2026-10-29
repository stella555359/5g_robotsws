*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library        taf.selenium.sbts        WITH NAME        selenium_coam
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot


*** Keywords ***
Btslog Check RU Reset On Startup Duration
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${ru_reset_startup_duration}=360
    log to console    \ncheck ru ${ru_index} power on startup duration
#    ${cell_id_list}    Get All Cell Id    ru_index=${ru_index}
    ${first_cell_down_time}    Btslog Check Get First Cell Down Time
    ${last_cell_up_time}    Btslog Check Get Last Cell Up Time
    ${reset_ru_startup_duration}    Evaluate    ${last_cell_up_time}-${first_cell_down_time}
    log to console   \nru ${ru_index} reset duration is ${reset_ru_startup_duration}
    run keyword and continue on failure    Should Be True
    ...    ${reset_ru_startup_duration}<=${ru_reset_startup_duration} and ${reset_ru_startup_duration}>${0}

Btslog Check Get First Cell Down Time
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    ${first_cell_down_time}    set variable    ${0}
    ${cmd}     Catenate
    ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep 'has been changed from OnAirDone to Validated'|
    ...    awk '{print $7}'
    ${get_cell_down_time_str}=     Run    command=${cmd}
    ${get_cell_down_time_list}=  Split String   ${get_cell_down_time_str}   \n
    ${get_cell_down_time_list}=    Ignore Wrong Timestamp    timestamp_list=${get_cell_down_time_list}
    Should Not Be Empty     ${get_cell_down_time_list}
    ${get_cell_down_time_lenth}   Get Length   ${get_cell_down_time_list}
    @{get_cell_down_time_new_list}   Create List
    FOR    ${get_cell_down_time}    IN    @{get_cell_down_time_list}
        ${get_cell_down_time_new}    DateTime.convert date
        ...     ${get_cell_down_time.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        Append To List   ${get_cell_down_time_new_list}   ${get_cell_down_time_new}
    END
    Sort List   ${get_cell_down_time_new_list}
    Log Many   @{get_cell_down_time_new_list}
    ${first_cell_down_time}   Set Variable  ${get_cell_down_time_new_list[0]}
    [Return]  ${first_cell_down_time}

Btslog Check Get Last Cell Up Time
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    ${last_cell_up_time}    set variable    ${0}
    ${cmd}     Catenate
    ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep 'has been changed from Validated to OnAirDone'|
    ...    awk '{print $7}'
    ${get_cell_up_time_str}=     Run    command=${cmd}
    ${get_cell_up_time_list}=  Split String   ${get_cell_up_time_str}   \n
    ${get_cell_up_time_list}=    Ignore Wrong Timestamp    timestamp_list=${get_cell_up_time_list}
    Should Not Be Empty     ${get_cell_up_time_list}
    ${get_cell_up_time_lenth}   Get Length   ${get_cell_up_time_list}
    @{get_cell_up_time_new_list}   Create List
    FOR    ${get_cell_up_time}    IN    @{get_cell_up_time_list}
        ${get_cell_up_time_new}    DateTime.convert date
        ...     ${get_cell_up_time.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
        Append To List   ${get_cell_up_time_new_list}   ${get_cell_up_time_new}
    END
    Sort List   ${get_cell_up_time_new_list}
    Log Many   @{get_cell_up_time_new_list}
    ${last_cell_up_time}   Set Variable  ${get_cell_up_time_new_list[-1]}
    [Return]  ${last_cell_up_time}

Btslog Get Check Start time
   [Documentation]  Auther: tingting.zhong@nokia-sbell.com
   ${cmd}     Catenate
   ...    cat /tmp/btslog2/SYSLOG_*.LOG | grep 'has been changed from OnAirDone to Validated' |
   ...    awk -F'[<>]' '{print $2}' | sort | tail -1
   ${check_start_time}    run    command=${cmd}
   ${len}    get length    ${check_start_time}
   run keyword if    ${len}==0    run keywords
   ...    log to console    \nnot get cell down time failed, please check the btslog    AND
   ...    return from keyword    ${None}
   [Return]  ${check_start_time}

Btslog Check RU Reset no More than Once
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${check_start_time}    ${ru_index}=1
    ${ru_info}  COAM get ru detial info by ru index  ru_index=${ru_index}
    ${prodCode_str}    set variable    ${ru_info}[productCode]
    run    command=awk -F'[<>]' '{if ($2 > "${check_start_time}") print $0}' /tmp/btslog2/SYSLOG_*.LOG > /tmp/btslog2/${check_start_time}.LOG
    ${base}    set variable    updateRuStatusFromRmod: rmod.stateInfo: /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-${ru_index}
    ${grep}    set variable
    ...    grep '${base} | operationalState = Enabled | availabilityStatus = Online'
    ${get_times}    run    command=cat /tmp/btslog2/${check_start_time}.LOG|${grep}|wc -l
    ${get_times}    convert to integer    ${get_times}
    should be true    ${get_times}<=1    msg=ru ${ru_index} reset should no more than once

Ignore Wrong Timestamp
    [Arguments]  ${timestamp_list}
    ${final_timestamp_list}    Create List
    FOR    ${timestamp_item}    IN    @{timestamp_list}
        IF    ${{$timestamp_item.startswith('<') and $timestamp_item.endswith('>')}}
            Append To List    ${final_timestamp_list}    ${timestamp_item}
        END
    END
    [Return]  ${final_timestamp_list}
