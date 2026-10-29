*** Settings ***
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/9925_variables.py

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
${CB009925_json_path}    ${CURDIR}/json
${lock_cell}    ${CB009925_json_path}/lock_cell.json
${recovery_after_RU_reset}    ${CB009925_json_path}/recovery_after_RU_reset.json
${disable_9925_and_10766}    ${CB009925_json_path}/disable_9925_and_10766.json
${awake_power_AENB}    260
${awake_power_RU}    260
${sleep_power_AENB}    160
${sleep_power_RU}    120
${sleep_power_SBTS23R2}    160
@{cell_id1}    ${1}
@{lte_cellid}    ${401}
${MAX_LOOP}    3
${power_all}    0
${ui_version_xiaomi}    Mi12UI13.0.12
*** Keywords ***
Case Preparation
    ${SCF_9925}    Replace String    ${Golden_SCF_Path}    .xml    _9359_16DL8UL.xml
    set suite variable  ${SCF_9925}
    Commissioning SCF And Check On Air   scf_path=${SCF_9925}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_9925}    value=${10}

CB009925 modify the parameter
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    coam.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=GNB_OAM

CB009925 get parameter value via COAM
    [Arguments]     ${class_name}    ${pattern}    ${connection}=GNB_OAM
    ${MO_tmp}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}
    ${distname}    Set variable    ${MO_tmp[0]['distName']}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

CB009925 get RU Power State
    [Arguments]     ${ru_index}=1   ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}    connection=${connection}
	[Return]    ${ru_status['status']['powerState']}

CB009925 get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${time}

CB009925 check power after RU enter deep sleep by RU type
    [Arguments]    ${interval}
    ${RU_Type}   Get RU type
    ${wait_time}    CB009925 get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    sleep    ${interval}
    selenium login and disable screen lock
    ${counter_3C4}    Get PM Counter via Webem    counter_id=M40003C4    interval=${interval}
    ${counter_3C4}    Evaluate    ${counter_3C4}/1000
    ${release}    Get program version based on gNB active version
    ${AENB_diff}    Get the diff    ${counter_3C4}    ${sleep_power_AENB}
    ${AEQY_diff}    Run Keyword If   "${release}"=="SBTS23R2"
    ...    Get the diff    ${counter_3C4}    ${sleep_power_SBTS23R2}
    ...    ELSE    Get the diff    ${counter_3C4}    ${sleep_power_RU}
    ${tmp_AENB}=   Evaluate    ${sleep_power_AENB}*0.1
    ${tmp_AEQY}=   Evaluate    ${sleep_power_RU}*0.1
    Run Keyword If    '${RU_Type}'=='AENB'    Should be True    ${AENB_diff} < ${tmp_AENB}
    ...    ELSE    Should be True    ${AEQY_diff} < ${tmp_AEQY}
    [Teardown]    selenium logout and close browser

CB009925 check power after RU exit deep sleep by RU type
    ${RU_Type}   Get RU type
    sleep    4min
    selenium login and disable screen lock
    ${power_after}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=1min
    Run Keyword If    '${RU_Type}'=='AENB'    Should be True    ${power_after} > ${awake_power_AENB}
    ...    ELSE    Should be True    ${power_after} > ${awake_power_RU}
    [Teardown]    selenium logout and close browser

CB009925 Check RU Power State
    [Arguments]     ${expect_state}=SLEEP
    ${powerState}    CB009925 get RU Power State
	Should Be Equal As Strings  ${powerState}  ${expect_state}

CB009925 Check cell EnergySaving state
    [Arguments]     ${class_name}    ${expect_energySavingState}=energySaving
    ${energy_State}=  CB009925 get parameter value via COAM    class_name=${class_name}    pattern=energySavingState
    Should Be Equal As Strings    ${energy_State}   ${expect_energySavingState}

CB009925 unblock cell by cell index
    [Arguments]     ${idx}
    selenium_coam.unblock_cell    cell_idx=${idx}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
    Wait Until Keyword Succeeds   12min  10 sec   cell should be unblocked   cell_idx=${idx}    cell_group_idx=${cellgrp_id}

CB009925 unblock all cells
    selenium login and disable screen lock
    CB009925 unblock cell by cell index    idx=1
    UnBlock LTE cells and check status    block_list=${lte_cellid}
    [Teardown]    selenium logout and close browser

CB009925 Change lbpsPeriodList by Coam
    [Arguments]    ${dist_name}    ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1440    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    ...    ${connection}=GNB_OAM
    ${tmp}    create lbpsPeriodList list    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsDuration=${lbpsDuration}    lbpsStartTimeHour=${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    ${lbpsPeriodList}      create dictionary
    ...    dist_name    ${dist_name}
    ...    parameter    lbpsPeriodList
    ...    value        ${tmp}
    ${parameters}    Create List    ${lbpsPeriodList}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    20s

create deepSleepTimeSchedule list
    [Arguments]    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35
    ${tmp}    create dictionary
    ...    dayOfWeek    ${dayOfWeek}
    ...    startTime    ${startTime}
    ...    windowDuration    ${windowDuration}
    ${tmp}     Create List    ${tmp}
    [Return]    ${tmp}

CB0010766 Change deepSleepTimeSchedule by Coam
    [Arguments]    ${dist_name}    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35    ${connection}=GNB_OAM
    ${tmp}    create deepSleepTimeSchedule list    dayOfWeek=${dayOfWeek}    startTime=${startTime}    windowDuration=${windowDuration}
    ${deepSleepTimeSchedule}      create dictionary
    ...    dist_name    ${dist_name}
    ...    parameter    deepSleepTimeSchedule
    ...    value        ${tmp}
    ${parameters}    Create List    ${deepSleepTimeSchedule}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    20s

Get average power value when all cells onair
    sleep    5min
    selenium login and disable screen lock
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
        sleep    1min
        ${power}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=1min
        ${power_all}=    Evaluate    ${power}+${power_all}
    END
    ${power_average}=    Evaluate    ${power_all}/${MAX_LOOP}
    selenium logout and close browser
    [Return]    ${power_average}

CB0010766 recovery ENV
    [Arguments]   ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    CB009925 recovery ENV due IWK    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=false

check all cells always keep in energysaving
    FOR    ${TEST_LOOP}    IN RANGE    0    50
        CB009925 Check cell EnergySaving state    class_name=NRCELL_R
        CB009925 Check cell EnergySaving state    class_name=LNCEL_R
        sleep    5s
    END
    Wait Until Keyword Succeeds    4min    5s    CB009925 Check RU Power State    expect_state=AWAKE
    FOR    ${TEST_LOOP}    IN RANGE    0    25
        CB009925 Check cell EnergySaving state    class_name=NRCELL_R
        CB009925 Check cell EnergySaving state    class_name=LNCEL_R
        sleep    5s
    END

CB010766-SR-A-8 Activate RU deep sleep mode when feature flag enable
    FOR    ${TEST_LOOP}    IN RANGE    0    3
        log to console    ++++ start test loop ${TEST_LOOP} ++++	
        Connect to gnb coam via ssl
        Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        Wait until keyword succeeds    5min    30s    verify all cells should be onair
        ${power_average}    Get average power value when all cells onair
        data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
        ...    target_avg_percent=0.2    min_percent=0.1    ui_version=${ui_version_xiaomi}
         ${average_old}    get_average_list    output_info_list=${output}
        ${dl_old}    set variable    ${average_old}[1]
        ${ul_old}    set variable    ${average_old}[0]
        log to console    ++++ enable 10766 431 and not reach deep sleep time window  ++++
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
        ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
        ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}    addonehour=True
        CB0010766 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${Week}
        ...    startTime=${startTime}
        CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
        ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
        CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/PSGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
        ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=true
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-2160     parameter_name=actLBPowerSaving    value=true
        sleep    60s
        Wait Until Keyword Succeeds    12min    30s    CB009925 Check cell EnergySaving state    class_name=NRCELL_R
        Wait Until Keyword Succeeds    10min    30s    CB009925 Check cell EnergySaving state    class_name=LNCEL_R
        sleep    360s
        CB009925 Check RU Power State    expect_state=AWAKE
        log to console    ++++ reach deep sleep time window and check RU enter deep sleep ++++
        ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
        ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
        CB0010766 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1
        ...    dayOfWeek=${lbpsDayOfWeek}    startTime=${startTime}    windowDuration=1440
        Wait Until Keyword Succeeds    6min    30s    CB009925 Check RU Power State
        CB009925 check power after RU enter deep sleep by RU type    interval=15min
        log to console    ++++ Exit Time Window and RU awake ++++
        CB0010766 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1
        ...    dayOfWeek=${lbpsDayOfWeek}    startTime=${startTime}    windowDuration=35
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1
        ...    parameter_name=advanceTimeForRURestore    value=20
        check all cells always keep in energysaving
        ${power_average_new}    Get average power value when all cells onair
        Should be True    ${power_average_new} > ${sleep_power_AENB}
        log to console    ++++ disable actRadioDeepSleepTimeSchedule and RU enter deep sleep ++++
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter_name=actRadioDeepSleepTimeSchedule    value=false
        Wait Until Keyword Succeeds    6min    30s    CB009925 Check RU Power State
        ${power_average_tmp}    Get average power value when all cells onair
        ${power_average_diff_tmp}    Get the diff    ${power_average_tmp}    ${sleep_power_AENB}
        ${tmp_power_average}=   Evaluate    ${sleep_power_AENB}*0.1
        Should be True    ${power_average_diff_tmp} < ${tmp_power_average}
        log to console    ++++ disable 431 and RU awake ++++
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=false
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-2160     parameter_name=actLBPowerSaving    value=false
        Wait until keyword succeeds    12min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        Wait until keyword succeeds    10min    30s    verify all cells should be onair
        Wait Until Keyword Succeeds    10min    30s    CB009925 Check RU Power State    expect_state=AWAKE
        ${power_average_new}    Get average power value when all cells onair
        ${power_average_diff}    Get the diff    ${power_average_new}    ${power_average}
        ${tmp_power_average}=   Evaluate    ${power_average}*0.1
        Should be True    ${power_average_diff} < ${tmp_power_average}
        data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
        ...    target_avg_percent=0.2    min_percent=0.1    ui_version=${ui_version_xiaomi}
        ${average_new}    get_average_list    output_info_list=${output}
        ${dl_new}    set variable    ${average_new}[1]
        ${ul_new}    set variable    ${average_new}[0]
        ${ul_diff}    Get the diff    ${ul_new}    ${ul_old}
        ${dl_diff}    Get the diff    ${dl_new}    ${dl_old}
        ${tmp_ul}=   Evaluate    ${ul_old}*0.1
        ${tmp_dl}=   Evaluate    ${dl_old}*0.1
        Should be True    ${ul_diff} < ${tmp_ul}
        Should be True    ${dl_diff} < ${tmp_dl}
        sleep    30s
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error    CB0010766 recovery ENV    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}

CB009925-SR-A RU returning from PowerSaving Mode to normal operation due to at least one carrier enabling on RU triggered by 5GC000431
    FOR    ${TEST_LOOP}    IN RANGE    0    3
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        Wait until keyword succeeds    5min    30s    verify all cells should be onair
        data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
        ...    target_avg_percent=0.2    min_percent=0.1    ui_version=${ui_version_xiaomi}
        ${average_old}    get_average_list    output_info_list=${output}
        ${dl_old}    set variable    ${average_old}[1]
        ${ul_old}    set variable    ${average_old}[0]
        log to console    ++++ enable 431 and RU enter deep sleep ++++
        ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
        CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
        ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
        CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/PSGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
        ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=true
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-2160     parameter_name=actLBPowerSaving    value=true
        sleep    60s
        Wait Until Keyword Succeeds    12min    30s    CB009925 Check cell EnergySaving state    class_name=NRCELL_R
        Wait Until Keyword Succeeds    10min    30s    CB009925 Check cell EnergySaving state    class_name=LNCEL_R
        Wait Until Keyword Succeeds    8min    30s    CB009925 Check RU Power State
        CB009925 check power after RU enter deep sleep by RU type    interval=15min
        sleep    30s
        log to console    ++++ disable 431 and RU exit deep sleep ++++
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=false
        CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-2160     parameter_name=actLBPowerSaving    value=false
        sleep    30s
        Wait until keyword succeeds    12min    30s    verify all cells should be onair
        Wait until keyword succeeds    12min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        Wait Until Keyword Succeeds    5min    30s    CB009925 Check RU Power State    expect_state=AWAKE
        CB009925 check power after RU exit deep sleep by RU type
        data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
        ...    target_avg_percent=0.2    min_percent=0.1    ui_version=${ui_version_xiaomi}
        ${average_new}    get_average_list    output_info_list=${output}
        ${dl_new}    set variable    ${average_new}[1]
        ${ul_new}    set variable    ${average_new}[0]
        ${ul_diff}    Get the diff    ${ul_new}    ${ul_old}
        ${dl_diff}    Get the diff    ${dl_new}    ${dl_old}
        ${tmp_ul}=   Evaluate    ${ul_old}*0.1
        ${tmp_dl}=   Evaluate    ${dl_old}*0.1
        Should be True    ${ul_diff} < ${tmp_ul}
        Should be True    ${dl_diff} < ${tmp_dl}
        sleep    30s
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error    CB009925 recovery ENV due IWK    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}

CB009925 recovery ENV due IWK
    [Arguments]   ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsDuration=${lbpsDuration}
    CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/PSGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsDuration=${lbpsDuration}
    CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=true
    CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-2160     parameter_name=actLBPowerSaving    value=true

CB009925-SR-A RU entering deep sleep mode during low traffic periods with 5GC000431 enabled
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/PSGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=true
    sleep    60s
    Wait Until Keyword Succeeds    12min    30s    CB009925 Check cell EnergySaving state    class_name=NRCELL_R
    Wait Until Keyword Succeeds    10min    30s    CB009925 Check cell EnergySaving state    class_name=LNCEL_R
    Wait Until Keyword Succeeds    8min    30s    CB009925 Check RU Power State
    CB009925 check power after RU enter deep sleep by RU type    interval=15min
    CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=false
    sleep    30s
    Wait until keyword succeeds    12min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    [Teardown]    run keyword and ignore error    CB009925 recovery ENV due IWK    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}

CB009925-SR-A RU returning from PowerSaving Mode to normal operation due to at least one cell unlocked
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}    tput_from=tput_define
    ...    target_avg_percent=0.2    min_percent=0.1    ui_version=${ui_version_xiaomi}
    ${average_old}    get_average_list    output_info_list=${output}
    ${dl_old}    set variable    ${average_old}[1]
    ${ul_old}    set variable    ${average_old}[0]
    log to console    ++++ block all cells and RU enter deep sleep ++++
    selenium login and disable screen lock
    Get X2 link shutdown waiting time
    ${block_list_nr}    Create List    1
    Block cells and check status    block_list=${block_list_nr}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    Block LTE cells and check status    block_list=${lte_cellid}
    sleep    30s
    selenium logout and close browser
    Wait Until Keyword Succeeds    8min    30s    CB009925 Check RU Power State
    CB009925 check power after RU enter deep sleep by RU type    interval=15min
    sleep    60s
    selenium login and disable screen lock
    log to console    ++++ unblock one cell and RU awake ++++
    CB009925 unblock cell by cell index    idx=1
    sleep    60s
    selenium logout and close browser
    Wait Until Keyword Succeeds    10min    30s    CB009925 Check RU Power State    expect_state=AWAKE
    sleep    60s
    log to console    ++++ recovery env and call ++++
    selenium login and disable screen lock
    UnBlock LTE cells and check status    block_list=${lte_cellid}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    CB009925 check power after RU exit deep sleep by RU type
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}    tput_from=tput_define
    ...    target_avg_percent=0.2    min_percent=0.1    ui_version=${ui_version_xiaomi}
    ${average_new}    get_average_list    output_info_list=${output}
    ${dl_new}    set variable    ${average_new}[1]
    ${ul_new}    set variable    ${average_new}[0]
    ${ul_diff}    Get the diff    ${ul_new}    ${ul_old}
    ${dl_diff}    Get the diff    ${dl_new}    ${dl_old}
    ${tmp_ul}=   Evaluate    ${ul_old}*0.1
    ${tmp_dl}=   Evaluate    ${dl_old}*0.1
    Should be True    ${ul_diff} < ${tmp_ul}
    Should be True    ${dl_diff} < ${tmp_dl}
    sleep    30s
    [Teardown]    Run Keywords    run keyword and ignore error    CB009925 unblock all cells    AND
    ...    selenium logout and close browser

CB009925-SR-A RU entering deep sleep mode after all cells blocked
    selenium login and disable screen lock
    Get X2 link shutdown waiting time
    ${block_list_NR}    Create List    1
    Block cells and check status    block_list=${block_list_NR}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    Block LTE cells and check status    block_list=${lte_cellid}
    sleep    30s
    selenium logout and close browser
    Wait Until Keyword Succeeds    12min    30s    CB009925 Check RU Power State
    CB009925 check power after RU enter deep sleep by RU type    interval=15min
    sleep    60s
    CB009925 unblock all cells
    Wait until keyword succeeds    10min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    Run Keywords    run keyword and ignore error    CB009925 unblock all cells    AND
    ...    selenium logout and close browser

Entering_Exiting_Deep_Sleep_Mode_IWK_With_CB009925
    log to console    ++++ enable 10766 431 and cell enter energysaving, RU enter deepsleep ++++
    CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
    CB0010766 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${lbpsDayOfWeek}
    ...    startTime=${startTime}    windowDuration=1440
    CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsDuration=40
    CB009925 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/PSGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsDuration=40
    CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=true
    CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-2160     parameter_name=actLBPowerSaving    value=true
    sleep    60s
    Wait Until Keyword Succeeds    12min    30s    CB009925 Check cell EnergySaving state    class_name=NRCELL_R
    Wait Until Keyword Succeeds    10min    30s    CB009925 Check cell EnergySaving state    class_name=LNCEL_R
    Wait Until Keyword Succeeds    8min    30s    CB009925 Check RU Power State
    log to console    ++++ disable 10766 9925 ++++
    coam.perform_delta_recommissioning    delta_file=${disable_9925_and_10766}    connection=GNB_OAM
    check all cells always keep in energysaving
    log to console    ++++ 431,7416 end time arrived ++++
    Wait Until Keyword Succeeds    40min    60s    CB009925 Check cell EnergySaving state    class_name=NRCELL_R
    ...    expect_energySavingState=notEnergySaving
    Wait Until Keyword Succeeds    40min    60s    CB009925 Check cell EnergySaving state    class_name=LNCEL_R
    ...    expect_energySavingState=notEnergySaving
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Wait until keyword succeeds    5min    30s    verify all cells should be onair

CB009925-SR-A RU Recovery case recovery ENV
    Connect to gnb coam via ssl
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-1    connection=GNB_OAM
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/LNCEL-401    connection=GNB_OAM

CB009925-SR-A RU Recovery during deep sleep mode due to RU restart
    CB009925 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    FOR    ${TEST_LOOP}    IN RANGE    0    3
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        log to console    ++++ block cell and RU enter deep sleep ++++
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-1    connection=GNB_OAM
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/LNCEL-401    connection=GNB_OAM
        ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
        ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
        CB0010766 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${lbpsDayOfWeek}
        ...    startTime=${startTime}    windowDuration=1440
        sleep    10s
        Wait Until Keyword Succeeds    8min    30s    CB009925 Check RU Power State
        sleep    30s
        log to console    ++++ reset RU ++++
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    force_radio_reset=${True}
        ...    timeout=${600}    connection=GNB_OAM
#        sleep    30s
#        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline
        Wait Until Keyword Succeeds    10min    5s    CB009925 Check RU Power State    expect_state=AWAKE
	    sleep    30s
        Wait Until Keyword Succeeds    8min    30s    CB009925 Check RU Power State
        log to console    ++++ unblock cell ++++
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-1    connection=GNB_OAM
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/LNCEL-401    connection=GNB_OAM
        sleep    30s
        Wait Until Keyword Succeeds    8min    5s    CB009925 Check RU Power State    expect_state=AWAKE
        Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        Wait until keyword succeeds    5min    30s    verify all cells should be onair
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error    CB009925-SR-A RU Recovery case recovery ENV
