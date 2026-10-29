*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007511_AQQL/resource/CB007511_Common_KW.robot
*** Variables ***
${time_in_seconds}   300

*** Keywords ***
Delete NRPGRP and related parameters
    [Arguments]  ${NRPGRP_ID}=${1}
    log to console  \n delete NRPGRP-${NRPGRP_ID}
    ${object_list}    selenium_coam.get_object_name_list    object_name=NRPGRP-${NRPGRP_ID}
    ${object_num}   Get Length   ${object_list}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...   filter_param=Activate load-based PS control logic enhancement
    ...   abbr=actLbpsCtrlLogicEnh    new_value=false
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...   filter_param=Activate NR cell-level extended configurations for MIMO muting and cell switch off
    ...   abbr=actNrExtCellSOMethod    new_value=false
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving
    ...    abbr=actNrLBPowerSaving    new_value=false
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based mMIMO TX power saving
    ...    abbr=actNrLBmMimoRTXPowerSaving    new_value=false
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate mixed mode load-based power saving
    ...    abbr=actNrMixedSOMethod    new_value=false
    Run Keyword If  ${object_num}!=${0}    selenium_coam.remove_object    object_name=NRPGRP-${NRPGRP_ID}    timeout=15
    Run Keyword If  ${object_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${object_num}!=${0}    selenium_coam.activate_plan
    sleep    60
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}

Configure time window for RU deep sleep
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Configure time window for RU deep sleep
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.11.2023 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Run Keyword And Ignore Error    Delete NRPGRP and related parameters
    log to console  \n Enable 5GC007511 Energy Saving Mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP
    log to console  \n Enable CB010766 RU Deep Sleep mode
    ${startTime}   ${startDate}   ${dayOfWeek}   Get start time after some seconds   time_in_seconds=${time_in_seconds}
    ${startTime}   Get Substring   ${startTime} 	0  5
    ${dayOfWeek}   Get Substring   ${dayOfWeek} 	0  3
    Modify CB010766 RU Deep Sleep mode Parameter   actRadioDeepSleepTimeSchedule=true
    ...   dayOfWeek=${dayOfWeek}   startTime=${startTime}
    Online Remove deepSleepTimeSchedule
    #${power_meassure_1}  Get RMOD Power Measurement
    [Teardown]    Run keywords    Wait until keyword succeeds    12min    20s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser2

Activate RU Deep Sleep Mode when the time window starts
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Activate RU Deep Sleep Mode when the time window starts
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.11.2023 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Run Keyword And Ignore Error    Delete NRPGRP and related parameters
    log to console  \n Enable 5GC007511 Energy Saving Mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP
    log to console  \n Enable CB010766 RU Deep Sleep mode
    ${startTime}   ${startDate}   ${dayOfWeek}   Get start time after some seconds   time_in_seconds=${time_in_seconds}
    ${startTime}   Get Substring   ${startTime} 	0  5
    ${dayOfWeek}   Get Substring   ${dayOfWeek} 	0  3
    Modify CB010766 RU Deep Sleep mode Parameter   actRadioDeepSleepTimeSchedule=true
    ...   dayOfWeek=${dayOfWeek}   startTime=${startTime}

    log to console  \n Lock all cells
    Run Keyword If  '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'   Get X2 link shutdown waiting time
    ...   ELSE   set test variable   ${X2_link_shutdown_time}   ${0}
    ${lock_list}  Get All Cell Id
    Lock cells or groups and check status  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
        ...    gnb_type='${gNb_CuType}'

    ${time_tmp}=   Convert To Integer  ${time_in_seconds}
    log to console  \n Wait ${time_tmp+600}s
    Sleep    ${time_tmp+600}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser2
    wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
    Wait until keyword succeeds    5min    30s    RU Status Info Should Be Sleep
    Unlock cells or groups and check status from sleep mode  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
    Online Remove deepSleepTimeSchedule
    #${power_meassure_1}  Get RMOD Power Measurement
    [Teardown]    Run keywords    Wait until keyword succeeds    12min    20s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser2

Awake RU from deep sleep when the time window ends
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Awake RU from deep sleep when the time window ends
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.11.2023 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Run Keyword And Ignore Error    Delete NRPGRP and related parameters
    log to console  \n Enable 5GC007511 Energy Saving Mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP
    log to console  \n Enable CB010766 RU Deep Sleep mode
    ${startTime}   ${startDate}   ${dayOfWeek}   Get start time after some seconds   time_in_seconds=${time_in_seconds}
    ${startTime}   Get Substring   ${startTime} 	0  5
    ${dayOfWeek}   Get Substring   ${dayOfWeek} 	0  3
    Modify CB010766 RU Deep Sleep mode Parameter   actRadioDeepSleepTimeSchedule=true
    ...   dayOfWeek=${dayOfWeek}   startTime=${startTime}

    log to console  \n Lock all cells
    Run Keyword If  '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'   Get X2 link shutdown waiting time
    ...   ELSE   set test variable   ${X2_link_shutdown_time}   ${0}
    ${lock_list}  Get All Cell Id
    Lock cells or groups and check status  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
        ...    gnb_type='${gNb_CuType}'

    ${time_tmp}=   Convert To Integer  ${time_in_seconds}
    log to console  \n Wait ${time_tmp+600}s
    Sleep    ${time_tmp+600}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser2
    wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
    Wait until keyword succeeds    5min    30s    RU Status Info Should Be Sleep
    log to console   Wait 30min, awake RU from deep sleep when the time window ends
    Sleep    ${1800}
    Wait until keyword succeeds    5min    30s    RU Status Info Should Be AWAKE
    Unlock cells or groups and check status from sleep mode  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
    Online Remove deepSleepTimeSchedule
    #${power_meassure_1}  Get RMOD Power Measurement
    [Teardown]    Run keywords    Wait until keyword succeeds    12min    20s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser2

Change RU deep sleep mode when time window is re-configured
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Change RU deep sleep mode when time window is re-configured
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.11.2023 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
#    Run Keyword And Ignore Error    Delete NRPGRP and related parameters
    log to console  \n Enable 5GC007511 Energy Saving Mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP
    log to console  \n Enable CB010766 RU Deep Sleep mode
    ${startTime}   ${startDate}   ${dayOfWeek}   Get start time after some seconds   time_in_seconds=${3600}
    ${startTime}   Get Substring   ${startTime} 	0  5
    ${dayOfWeek}   Get Substring   ${dayOfWeek} 	0  3
    Modify CB010766 RU Deep Sleep mode Parameter   actRadioDeepSleepTimeSchedule=true
    ...   dayOfWeek=${dayOfWeek}   startTime=${startTime}

    log to console  \n Lock all cells
    Run Keyword If  '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'   Get X2 link shutdown waiting time
    ...   ELSE   set test variable   ${X2_link_shutdown_time}   ${0}
    ${lock_list}  Get All Cell Id
    Lock cells or groups and check status  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
        ...    gnb_type='${gNb_CuType}'
    Sleep    ${900}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser2
    wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
    Wait until keyword succeeds    5min    30s    RU Status Info Should Be AWAKE
    ${startTime}   ${startDate}   ${dayOfWeek}   Get start time after some seconds   time_in_seconds=${120}
    ${startTime}   Get Substring   ${startTime} 	0  5
    ${dayOfWeek}   Get Substring   ${dayOfWeek} 	0  3
    Reconfig CB010766 RU Deep Sleep mode Parameter   dayOfWeek=${dayOfWeek}   startTime=${startTime}
    Sleep    ${600}
    Wait until keyword succeeds    5min    30s    RU1_AQQL Status Info Should Be Sleep
    Unlock cells or groups and check status from sleep mode  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
    Online Remove deepSleepTimeSchedule
    Sleep    ${300}
    #${power_meassure_1}  Get RMOD Power Measurement
    [Teardown]    Run keywords    Wait until keyword succeeds    12min    20s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser2

Get start time after some seconds
    [Documentation]   Author: xuewen.zhang@nokia-sbell.com
    ...        Description: Get start time, start date, and weekday after add some seconds from current time
    ...        Return value: ${check_time}->hh:mm:ss   ${startDate}->YYYY-MM-DD
    ...        ${checkDay}->one value of [Monday Tuesday Wednesday Thursday Friday Saturday  Sunday]
    [Arguments]   ${time_in_seconds}=600
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${timeZone_path}   set variable if  '${stream}'<'SBTS25R1'   MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...    MRBTS-${MRBTS_ID}/MNL-1
    ${timeZone}    selenium_coam.get_parameter_value    dist_name=${timeZone_path}
    ...    filter_param=Time zone
    ...    abbr=timeZone
    #(GMT+8) Asia/Shanghai
    ${diff_hour_list}=    String.Get Regexp Matches    ${timeZone}    \(GMT(?P<diff_hour>[-+]\\d+)\)    diff_hour
    ${timestartTmp}   robot.libraries.DateTime.Get Current Date   UTC   ${diff_hour_list}[0] hours
    log to console   timeZone:${timeZone} current date:${timestartTmp} diff_hour:${diff_hour_list}[0]
    ${add_time} = 	robot.libraries.DateTime.Convert Time 	${time_in_seconds} 	timer 	exclude_milles=false
    ${date}=    robot.libraries.DateTime.Add Time To Date    ${timestartTmp}	${add_time}
    ${checkDay}=    robot.libraries.DateTime.Convert Date    ${date}    result_format=%A
    ${date}=    robot.libraries.DateTime.Convert Date   ${date}    exclude_millis=yes
    @{split_date}    string.split string    ${date}    separator=${SPACE}
    ${startDate}    set variable    ${split_date}[0]
    ${startTime}    set variable    ${split_date}[1]
    [Return]   ${startTime}   ${startDate}   ${checkDay}

Online Remove deepSleepTimeSchedule
    Run Keyword And Ignore Error    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Advance time to restore radio from deep sleep
    ...    abbr=advanceTimeForRURestore   node_index=${0}
    Run Keyword And Ignore Error    selenium_coam.remove_element
    ...   dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...   filter_param=RU deep sleep time schedule    abbr=deepSleepTimeSchedule
    Run Keyword And Ignore Error    selenium_coam.delete_parameter
    ...   dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...   filter_param=RU deep sleep time schedule    abbr=deepSleepTimeSchedule
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate radio deep sleep time schedule  abbr=actRadioDeepSleepTimeSchedule
    ...  new_value=false
    Run Keyword And Ignore Error    selenium_coam.validate_plan
    Run Keyword And Ignore Error    selenium_coam.activate_plan

Modify CB010766 RU Deep Sleep mode Parameter
    [Arguments]    ${actRadioDeepSleepTimeSchedule}=true   ${dayOfWeek}=Every day   ${startTime}=00:30
    ...   ${windowDuration}=35   ${advanceTimeForRURestore}=10
    Log to console    Modify CB010766 RU Deep Sleep mode Parameter
    Online Remove deepSleepTimeSchedule
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate radio deep sleep time schedule  abbr=actRadioDeepSleepTimeSchedule
    ...  new_value=${actRadioDeepSleepTimeSchedule}
    selenium_coam.add_element
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=RU deep sleep time schedule    abbr=deepSleepTimeSchedule    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Scheduled Day of RU deep sleep function
    ...    abbr=dayOfWeek
    ...    new_value=${dayOfWeek}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=RU deep sleep start time
    ...    abbr=startTime
    ...    new_value=${startTime}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Duration of the time window
    ...    abbr=windowDuration
    ...    new_value=${windowDuration}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Advance time to restore radio from deep sleep
    ...    abbr=advanceTimeForRURestore
    ...    new_value=${advanceTimeForRURestore}    node_index=${0}
    selenium_coam.validate_plan
    selenium_coam.activate_plan

Reconfig CB010766 RU Deep Sleep mode Parameter
    [Arguments]    ${dayOfWeek}=Every day   ${startTime}=00:30
    ...   ${windowDuration}=35
    Log to console    Reconfig CB010766 RU Deep Sleep mode Parameter

    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Scheduled Day of RU deep sleep function
    ...    abbr=dayOfWeek
    ...    new_value=${dayOfWeek}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=RU deep sleep start time
    ...    abbr=startTime
    ...    new_value=${startTime}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Duration of the time window
    ...    abbr=windowDuration
    ...    new_value=${windowDuration}    node_index=${0}
    selenium_coam.validate_plan
    selenium_coam.activate_plan

RU Status Info Should Be AWAKE
    [Arguments]    ${ru_index}=${1}  ${connection}=GNB_OAM
    log to console  \nRU Status Should Be AWAKE
    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
    FOR  ${ru}  IN  @{ru_info_list}
        Run Keyword If    ${ru["ru_index"]}!=${ru_index} and ${ru_index}!=${None}     Continue For Loop
        Should Be Equal As Strings   ${ru["operationalState"]}    enabled
        Should Be Equal As Strings   ${ru["availabilityStatus"]}    -
        Should Be Equal As Strings   ${ru["usageState"]}    Idle
        Should Be Equal As Strings   ${ru["proceduralStatus"]}    configured
        Should Be Equal As Strings   ${ru["powerState"]}    AWAKE
    END
