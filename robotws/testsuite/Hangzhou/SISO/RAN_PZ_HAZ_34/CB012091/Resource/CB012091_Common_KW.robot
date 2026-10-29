*** Settings ***
Documentation     author: Lin jiangjing
...               Group: HGZ_SG8
...               contact: jiangjing.lin@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Variables    ../TestData/12091_variables.py

*** Variables ***
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}
${sleep_after_SLEEP_EXTREME}    7min
${SLEEP_EXTREME_check_time}    30min
#@{nr_cell_1_2}    ${1}    ${2}
#@{nr_cell_other}    ${2}    ${3}    ${4}
#@{all_nr_cells}    ${1}    ${2}    ${3}    ${4}
*** Keywords ***
RU returning from PowerSaving Mode to normal operation due to at least one carrier enabling on RU triggered by 5GC000431
    [Arguments]    ${nrpgrp_index}=0    ${ru_index}=1
#    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=49
#    AlarmWatchdog.add_allow_alarms    fault_id=4589
    log to console    commission scf
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    log to console    enable 431 (set lbpsSuspended to notSuspended)
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    ...    lbpsSuspended=notSuspended
    log to console    **************************step1******************************************************
    log to console    set 10776(deepSleepTimeSchedule) time to current time, set windowDuration to 600
    check and change time schedule by rmodid    windowDuration=600
    log to console    set NRPGRP(lbpsPeriodList) to current time
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    SG8 common Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    log to console    block nr cell2, cell3 and cell4
    Block all nr cell  block_list=${nr_cell_other}
    log to console    check nr cell2, cell3 and cell4 are blocked
    Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${2}    operationalState=disabled
    ...    usageState=idle    blockState=blocked
    Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${3}    operationalState=disabled
    ...    usageState=idle    blockState=blocked
    Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${4}    operationalState=disabled
    ...    usageState=idle    blockState=blocked
    log to console    check nr cell1 enter energysaving mode
    Wait Until Keyword Succeeds    5min    5s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
    log to console    check RU Power state is SLEEP_EXTREME
    Wait Until Keyword Succeeds    ${SLEEP_EXTREME_check_time}    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    **************************step2******************************************************
    log to console    disable 431 (set lbpsSuspended to suspend)
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    ...    lbpsSuspended=suspended
    log to console    check RU power state is AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    check cell1 exit energysaving mode
    Wait Until Keyword Succeeds    10min    5s    Check cell EnergySaving state via COAM    expect_energySavingState=notEnergySaving
    log to console    **************************step3******************************************************
    log to console    make call for nr cell1 and check tput
    data_transfer_common    tput_self_define=${tput_12091}    cell_id=${nr_cell_1}    target_avg_percent=${0.85}
    ...    min_percent=${0.5}    loop_times=${1}    duration=${300}
    log to console    **************************step4******************************************************
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset    ru_index=${ru_index}
    Sleep    30s
    Wait Until Keyword Succeeds    10min    5s    COAM Check GNB RU status
    sleep    120min
    log to console    enable 431 (set lbpsSuspended to notsuspend)
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    ...    lbpsSuspended=notSuspended
    log to console    check cell1 enter energysaving mode
    Wait Until Keyword Succeeds    5min    5s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
    log to console    check RU Power state is SLEEP_EXTREME
    Wait Until Keyword Succeeds    ${SLEEP_EXTREME_check_time}    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    **************************step5*****************************************************
    log to console    unblock cell2, cell3 and cell4
    UnBlock all nr cell  block_list=${nr_cell_other}
    log to console    check nr cell2, cell3 and cell4 are unblocked
    Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${2}    operationalState=enabled
    ...    usageState=active    blockState=unblocked
    Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${3}    operationalState=enabled
    ...    usageState=active    blockState=unblocked
    Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${4}    operationalState=enabled
    ...    usageState=active    blockState=unblocked
    log to console    disable 431 (set lbpsSuspended to suspend)
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    ...    lbpsSuspended=suspended
    log to console    check RU power state is AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    **************************step6*****************************************************
    log to console    make call for nr cell2 and check tput
    log to console    modify qrx for cell 2, modify cell2 to -40, modify cell1 to -22
    sleep    120min
    Set qRxLevMin For Nr Call    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    nr_cell_all=${all_nr_cells}    cell_id_call=${nr_cell_2}[0]
    ...    qRxLevMin_call=${-40}    qRxLevMin_other=${-22}
    data_transfer_common    tput_self_define=${tput_12091}    cell_id=${nr_cell_2}    target_avg_percent=${0.85}
    ...    min_percent=${0.5}    loop_times=${1}    duration=${300}
    [Teardown]    Run keywords    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=10    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=49    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=4589


RU returning from PowerSaving Mode to normal operation due to RU lock
    [Arguments]    ${ru_lock_index}=${1}    ${connection}=GNB_OAM
    log to console    **************************step1******************************************************
    log to console    set 10776(deepSleepTimeSchedule) time to current time, set windowDuration to 600
    check and change time schedule by rmodid    windowDuration=600
    log to console    lock RU
    coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_lock_index}    connection=${connection}    timeout=180
    log to console    check RU Power state is SLEEP_EXTREME
    Wait Until Keyword Succeeds    ${SLEEP_EXTREME_check_time}    5s    expect_state=SLEEP_EXTREME
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    **************************step2******************************************************
    log to console    unlock RU
    coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_lock_index}    connection=${connection}    timeout=180
    log to console    check RU Power state is AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    **************************step3******************************************************
    log to console    make call for nr cells and check tput
    data_transfer_common    tput_self_define=${tput_12091}    cell_id=${nr_cell_1}    target_avg_percent=${0.85}
    ...    min_percent=${0.5}    loop_times=${1}    duration=${300}
    [Teardown]    Run keyword and ignore error    coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_lock_index}
    ...    connection=${connection}    timeout=180


RU Recovery during extreme deep sleep mode due to RU restart
    [Arguments]    ${ru_index}=1
#    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=49
#    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=4701
    log to console    commission scf
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
#    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
#    log to console    disable 431 (set lbpsSuspended to suspend)
#    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
#    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
#    ...    lbpsSuspended=suspended
    log to console    **************************step1******************************************************
    log to console    set 10776(deepSleepTimeSchedule) time to current time, set windowDuration to 600
    check and change time schedule by rmodid    windowDuration=600
    log to console    block all nr cells
    Block all nr cell  block_list=${all_nr_cells}
    log to console    check all nr cells blocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=disabled    usageState=idle    blockState=blocked
    END
    log to console    check RU Power state is SLEEP_EXTREME
    Wait Until Keyword Succeeds    ${SLEEP_EXTREME_check_time}    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    **************************step2******************************************************
    log to console    Reset RU
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset
    Sleep    30s
    log to console    check RU Power state is AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset    ru_index=${ru_index}
    Sleep    30s
    Wait Until Keyword Succeeds    10min    5s    COAM Check GNB RU status
    sleep    120min
    log to console    check RU Power state is SLEEP_EXTREME
    Wait Until Keyword Succeeds    ${SLEEP_EXTREME_check_time}    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    unblock all nr cells
    sleep    120min
    UnBlock all nr cell  block_list=${all_nr_cells}
    log to console    check all nr cells unblocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=enabled    usageState=active    blockState=unblocked
    END
    data_transfer_common    tput_self_define=${tput_12091}    cell_id=${nr_cell_1}    target_avg_percent=${0.85}
    ...    min_percent=${0.5}    loop_times=${1}    duration=${300}
    [Teardown]   Run keywords    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=10    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=49    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=4589    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=4701


RU returning from PowerSaving Mode to normal operation due to change of EnergySavingMode
    [Arguments]    ${ru_index}=1
#    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=49
#    AlarmWatchdog.add_allow_alarms    fault_id=4589
    log to console    commission scf
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
#    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
#    log to console    disable 431 (set lbpsSuspended to suspend)
#    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
#    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
#    ...    lbpsSuspended=suspended
    log to console    **************************step1******************************************************
    log to console    set 10776(deepSleepTimeSchedule) time to current time, set windowDuration to 600
    check and change time schedule by rmodid    windowDuration=600
    log to console    block all nr cells
    Block all nr cell  block_list=${all_nr_cells}
    log to console    set energySavingMode to DEEPSLEEP
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=DEEPSLEEP
    log to console    check all nr cells blocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=disabled    usageState=idle    blockState=blocked
    END
    log to console    check RU Power state is SLEEP
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP
    log to console    **************************step2******************************************************
    log to console    Change energySavingMode to DEEPSLEEP_EXTREME_SFP
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=DEEPSLEEP_EXTREME_SFP
    log to console    check RU Power state=SLEEP_EXTREME
    Wait Until Keyword Succeeds    ${SLEEP_EXTREME_check_time}    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    **************************step3******************************************************
    log to console    Set actRadioDeepSleepTimeSchedule to False
    #modify together on webui
#    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1    parameter_name=actRadioDeepSleepTimeSchedule
#    ...    value=false
#    log to console    Change energySavingMode to NORMAL
#    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
#    ...    value=NORMAL
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${modify_params}  create list
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate radio deep sleep time schedule    p_name=actRadioDeepSleepTimeSchedule    value=false
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    filter_param=Energy Saving Mode Activation    p_name=energySavingMode    value=NORMAL
    append to list    ${modify_params}    ${item}
    FOR    ${item}    IN    @{modify_params}
        selenium_coam.Set Parameter Value    dist_name=${item}[dist_name]    filter_param=${item}[filter_param]    abbr=${item}[p_name]
        ...    new_value=${item}[value]
    END
    selenium_coam.Validate Plan
    selenium_coam.Activate Plan    activate_plan_despite_errors=${true}    execute=${true}
    sleep    60s
    log to console    check RU power state is AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    unblock all nr cells
    UnBlock all nr cell  block_list=${all_nr_cells}
    log to console    check all nr cells unblocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=enabled    usageState=active    blockState=unblocked
    END
    log to console    check RU power state is AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    **************************step4******************************************************
    log to console    make call for nr cell1 and check tput
    sleep    120min
    data_transfer_common    tput_self_define=${tput_12091}    cell_id=${nr_cell_1}    target_avg_percent=${0.85}
    ...    min_percent=${0.5}    loop_times=${1}    duration=${300}
    [Teardown]    Run keywords    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=10    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=49    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=4589


RU returning from PowerSaving Mode to normal operation due to time window ends
#    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=49
#    AlarmWatchdog.add_allow_alarms    fault_id=4589
    log to console    commission scf
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
#    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
#    log to console    disable 431 (set lbpsSuspended to suspend)
#    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
#    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
#    ...    lbpsSuspended=suspended
    log to console    **************************step1******************************************************
    log to console    set 10776(deepSleepTimeSchedule) time to current time, set windowDuration to 600
    check and change time schedule by rmodid    windowDuration=600
    log to console    block all nr cells
    Block all nr cell  block_list=${all_nr_cells}
    log to console    check all nr cells blocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=disabled    usageState=idle    blockState=blocked
    END
    log to console    check RU Power state=SLEEP_EXTREME
    Wait Until Keyword Succeeds    ${SLEEP_EXTREME_check_time}    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    **************************step2******************************************************
    log to console    change deepSleepTimeSchedule out of currentime, such as tomorrow
    check and change time schedule by rmodid    addonehour=True
    log to console    RU power state is AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    **************************step3******************************************************
    log to console    unblocked all nr cells
    UnBlock all nr cell  block_list=${all_nr_cells}
    log to console    check all nr cells unblocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${1}
        ...    operationalState=enabled    usageState=active    blockState=unblocked
    END
    log to console    make call for nr cell1 and check tput
    data_transfer_common    tput_self_define=${tput_12091}    cell_id=${nr_cell_1}    target_avg_percent=${0.85}
    ...    min_percent=${0.5}    loop_times=${1}    duration=${300}
    [Teardown]    Run keywords    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=10    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=49    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=4589


Extreme Deep Sleep Mode temperature threshold impact_backup
    log to console    **************************step1******************************************************
    log to console    set 10776(deepSleepTimeSchedule) time to current time, set windowDuration to 600
    check and change time schedule by rmodid    windowDuration=600
    log to console    **************************step2******************************************************
    Tcs File Modify    T_edsm_high_target=20
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
    log to console    **************************step3******************************************************
    log to console    block all nr cells
    Block all nr cell  block_list=${all_nr_cells}
    log to console    check all nr cells blocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=disabled    usageState=idle    blockState=blocked
    END
    log to console    check RU Power state=AWAKE
    sleep    7min
    SG8 Check RU Power State by ru index    expect_state=AWAKE
    sleep    7min
    log to console    check RU Power state=AWAKE
    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    **************************step4******************************************************
    Tcs File Modify    T_edsm_high_target=65
    Wait Until Keyword Succeeds    10min    5s    COAM Check GNB RU status
    log to console    **************************step5******************************************************
    log to console    check RU Power state=SLEEP_EXTREME
    Wait Until Keyword Succeeds    ${SLEEP_EXTREME_check_time}    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    **************************step6******************************************************
    log to console    unblocked all nr cells
    UnBlock all nr cell  block_list=${all_nr_cells}
    log to console    check all nr cells unblocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=enabled    usageState=active    blockState=unblocked
    END
    log to console    check RU Power state=AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    make call for nr cell1 and check tput
    data_transfer_common    tput_self_define=${tput_12091}    cell_id=${nr_cell_1}    target_avg_percent=${0.85}
    ...    min_percent=${0.5}    loop_times=${1}    duration=${300}
    [Teardown]    Run keywords    Tcs File Modify    T_edsm_high_target=65    AND
    ...    Run keyword and ignore error    UnBlock all nr cell  block_list=${all_nr_cells}    AND
    ...    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair


Tcs File Modify
    [Arguments]    ${T_edsm_high_target}    ${ru_index}=1
    log to console    log in RU
    Run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${client}    set variable    frmonShellClient localhost 2000
    ${cmd}   Set Variable    echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    get tcs file
    ${cmd}   Set Variable    echo '/CI/ConfigAccess_Module action fetch DECODED "tcs_parameters.bin" "/tmp/tcs.json"'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    get original T_edsm_high value
    ${output}  csn.execute  command=${sudo} cat /tmp/tcs.json | grep -i T_edsm_high    connection=RU_${ru_index}
    ${pattern}   Set Variable    "T_edsm_high": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value_T_edsm_high}   Set Variable    @{init_value_list}[0]
    log to console    change T_edsm_high to 20 in tcs.json
    ${cmd}   Set Variable    ${sudo} sed -i 's/"T_edsm_high": ${init_value_T_edsm_high},/"T_edsm_high": ${T_edsm_high_target},/g' /tmp/tcs.json
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs_parameters.bin" "/tmp/tcs.json"'|${sudo} ${client}
    csn.Send command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    reboot RU
    csn.execute  command=sudo -i reboot    connection=RU_${ru_index}
    Sleep    120s
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}

Extreme Deep Sleep Mode temperature threshold impact
    [Arguments]    ${ru_index}=1
#    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=49
#    AlarmWatchdog.add_allow_alarms    fault_id=4589
    log to console    commission scf
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    log to console    **************************step1******************************************************
    log to console    set 10776(deepSleepTimeSchedule) time to current time, set windowDuration to 600
    check and change time schedule by rmodid    windowDuration=600
    log to console    **************************step2******************************************************
    Temperature override
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
    log to console    **************************step3******************************************************
    log to console    block all nr cells
    Block all nr cell  block_list=${all_nr_cells}
    log to console    check all nr cells blocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=disabled    usageState=idle    blockState=blocked
    END
    log to console    check RU Power state=AWAKE
    SG8 Check RU Power State by ru index    expect_state=AWAKE
    sleep    ${SLEEP_EXTREME_check_time}
    log to console    check RU Power state!=AWAKE
    ${status}    Run keyword and ignore error    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    Should be equal    ${status}[0]    FAIL
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    check RU Power state!=AWAKE
    ${status}    Run keyword and ignore error    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    Should be equal    ${status}[0]    FAIL
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    **************************step4******************************************************
    Wait Until keyword Succeeds    3x    10s    Perform RU Reset    ru_index=${ru_index}
    Sleep    30s
    Wait Until Keyword Succeeds    10min    5s    COAM Check GNB RU status
    log to console    **************************step5******************************************************
    log to console    check RU Power state=SLEEP_EXTREME
    Wait Until Keyword Succeeds    ${SLEEP_EXTREME_check_time}    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    ${sleep_after_SLEEP_EXTREME}
    log to console    **************************step6******************************************************
    log to console    unblocked all nr cells
    UnBlock all nr cell  block_list=${all_nr_cells}
    log to console    check all nr cells unblocked
    FOR    ${cell_idx}    IN    @{all_nr_cells}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=enabled    usageState=active    blockState=unblocked
    END
    log to console    check RU Power state=AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    make call for nr cell1 and check tput
    data_transfer_common    tput_self_define=${tput_12091}    cell_id=${nr_cell_1}    target_avg_percent=${0.85}
    ...    min_percent=${0.5}    loop_times=${1}    duration=${300}
    [Teardown]    Run keywords    Run keyword and ignore error    UnBlock all nr cell  block_list=${all_nr_cells}    AND
    ...    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair

get all nr cells id
    ${all_nr_cells}    Get All Cell Id    cell_type=nr
    Set Suite Variable    ${all_nr_cells}

get all nr cells id except cell1
    ${nr_cells}    Get All Cell Id    cell_type=nr
    Remove From List    ${nr_cells}    0
    ${nr_cell_other}    set variable    ${nr_cells}
    Set Suite Variable    ${nr_cell_other}

Temperature override
    [Arguments]    ${ru_index}=1
    log to console    log in RU
    Run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${client}    set variable    frmonShellClient localhost 2000
    ${cmd}   Set Variable    echo "/ action create ThermometerDevice /CI/thermometerDevice/temp/mars1/papsu1 /temp/mars1/papsu1"|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable    echo '/CI/thermometerDevice/temp/mars1/papsu1 action override TEMPERATURE 5'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable    echo '/CI/thermometerDevice/temp/mars1/papsu1 get temperature'|${sudo} ${client}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}

RU entering extreme deep sleep mode after all cells blocked
    [Arguments]    ${ru_index}=1
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=1907
    AlarmWatchdog.add_allow_alarms    fault_id=1911
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    log to console    set 10776(deepSleepTimeSchedule) time to current time, set windowDuration to 600
    check and change time schedule by rmodid    windowDuration=600
    log to console    **********************step1:  set EDSM on RU and trigger FID1907**********************
    log to console    set energySavingMode=DEEPSLEEP_EXTREME_SFP
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=DEEPSLEEP_EXTREME_SFP
    log to console    login ru by
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    log to console    execute    "echo 0xef > /sys/devices/platform/pss_pp_spi/fc800000.spi/spi_master/spi11/spi11.0/registers/output_state_qclk_0"
    ${cmd}    set variable    echo 0xef > /sys/devices/platform/pss_pp_spi/fc800000.spi/spi_master/spi11/spi11.0/registers/output_state_qclk_0
    ${output}    csn.execute  command=sudo su -c '${cmd}'    connection=RU_${ru_index}
    log to console    check fault 1907 reported on RU
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=1907
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}
    log to console    ******************step2: Block all cells and wait time then check RU status*************
    ${cell_id_list}  Get All Cell Id    cell_type=nr
    log to console    block all cells
    Block cells and check status   block_list=${cell_id_list}    check_alarm=False    gnb_type='${gNb_CuType}'
    log to console    wait 30 minutes
    sleep    30min
    log to console    check RU stay in  AWAKE
    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    **********************step3: cancel FID1907 ***************************************
    log to console    login ru
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    log to console    execute    "echo 0xff > /sys/devices/platform/pss_pp_spi/fc800000.spi/spi_master/spi11/spi11.0/registers/output_state_qclk_0"
    ${cmd}    set variable    echo 0xff > /sys/devices/platform/pss_pp_spi/fc800000.spi/spi_master/spi11/spi11.0/registers/output_state_qclk_0
    ${output}    csn.execute  command=sudo su -c '${cmd}'    connection=RU_${ru_index}
    log to console    reboot ru by command
    ${output}    csn.execute  command=sudo -i reboot    connection=RU_${ru_index}
    log to console    check fault 1907 disappear
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent    faultId=1907
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}
    log to console    **************************step4: keep all cells blocked and check RU status********************
    log to console    wait 15 minutes
    sleep    15min
    log to console    chekc RU enter EDSM(RUPower state=SLEEP_EXTREME)
    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    [Teardown]    run keywords    run keyword and ignore error    csn.Disconnect  connection=ASIK Master    AND
    ...    UnBlock cells and check status    block_list=${cell_id_list}    check_alarm=False    gnb_type='${gNb_CuType}'   AND
    ...    run keyword and ignore error    Selenium Logout And Close Browser
