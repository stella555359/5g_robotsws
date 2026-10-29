*** Settings ***
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Library    Telnet
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Variables    ../TestData/CB007447_variables.py

Documentation
...    author: jiangjing lin
...    contact: jiangjing lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${lp_s}    50
${lp_l}    5000
@{cell_1}    ${1}
@{nrpgrp}    ${1}

*** Keywords ***
CB007447_Short_PL_SL_break_with_energysaving
    Modify lbpsPeriodList to trigger cell switch off
    log to console    trigger short_pl_break
    Short_PL_break_with_energysaving
    log to console    trigger short_sl_break
    Short_SL_break_with_energysaving
    Suspended or notSuspended energysaving by coam
    Wait until keyword succeeds    5min    30s    Check all cells info should be onair
    log to console    check active and history alarm
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
#    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
#    should be true    ${history_alarm_status}
    log to console    check data transfer is possible
    data_transfer_common    tput_self_define=${tput_define_7447}    cell_id=${cell_1}        target_avg_percent=0.6    min_percent=0.5

add fault to the allowed history fault list
    [Arguments]    ${faultId}
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault_dic}
    Set test Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}


Commissioning SCF And Check BTS On Air
    [Arguments]    ${scf_name}=energysaving
    log to console    import scf of ${scf_name}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${scf_name}.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    15min    180s    Check all cells info should be onair
    log to console    check active and history alarm
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
#    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
#    should be true    ${history_alarm_status}

Modify lbpsPeriodList to trigger cell switch off
    [Arguments]    ${lbpsDuration}=${60}
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
    log to console    begin to modify lbpsDayOfWeek,lbpsStartTimeHour,etc to local time
    FOR    ${nrpgrp_index}    IN    @{nrpgrp}
        ${nrpgrp_index}    Convert To Integer    ${nrpgrp_index}
        SG8 common Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
        ...    lbpsDayOfWeek=${Week}    lbpsStartTimeHour=${lbpsStartTimeHour}
        ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsDuration=${lbpsDuration}
    END
    sleep    5min
    Wait Until Keyword Succeeds    5min   30s    check all the nr cells enter energysaving or notEnergySaving

check all the nr cells enter energysaving or notEnergySaving
    [Arguments]    ${expect_state}=energySaving
    log to console    check cell energysaving status should be '${expect_state}'
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${cell_index}    Convert To Integer    ${cell_index}
        Check cell EnergySaving state via COAM    expect_energySavingState=${expect_state}    cellID=${cell_index}
    END

Suspended or notSuspended energysaving by coam
    [Arguments]    ${connection}=GNB_OAM    ${value}=suspended
    log to console   modify nrpgrp to ${value}
    ${suspendvalue_dic}      create dictionary    lbpsSuspended    ${value}
    ${suspendvalue_list}    create list    ${suspendvalue_dic}
    ${value_list}    create list
    FOR    ${nrpgrp_index}    IN    @{nrpgrp}
        ${value_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
        ...    parameter    lbpsPeriodList
        ...    value    ${suspendvalue_list}
        append to list    ${value_list}   ${value_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${value_list}    connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s

Short_PL_break_with_energysaving
    log to console    step 3.1: get name of the primary link (Link mode doesn't contain synchronization)
    ${primary_link_name}    Get Primary Link Name
    log to console    primary link name is: ${primary_link_name}
    log to console    step 3.2: get port for primary link (CABLINK_R-1001: 3.3.5, CABLINK_R-1002: 3.3.6)
    ${primary_link_port}    Get Port By Link Name    link_name=${primary_link_name}
    log to console    step 3.3: execute command: opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    ${command}    set variable    opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    Login Switch And Send Cmd    command=${command}
    sleep    10s
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=GNB_OAM
    should be true    ${ru_status}
    log to console    Check cell in energysaving state during next 10min
    Check cell in energysaving state within 10min

Short_SL_break_with_energysaving
    log to console    step 3.1: get name of the secondary link (Link mode doesn't contain synchronization)
    ${secondary_link_name}    Get Secondary Link Name
    log to console    secondary link is : ${secondary_link_name}
    log to console    step 3.2: get port for secondary link (CABLINK_R-1001: 3.3.5, CABLINK_R-1002: 3.3.6)
    ${secondary_link_port}    Get Port By Link Name    link_name=${secondary_link_name}
    log to console    step 3.3: execute command: opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${secondary_link_port}
    ${command}    set variable    opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${secondary_link_port}
    Login Switch And Send Cmd    command=${command}
    sleep    10s
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=GNB_OAM
    should be true    ${ru_status}
    log to console    Check cell in energysaving state during next 10min
    Check cell in energysaving state within 10min

Check cell in energysaving state within 10min
    [Arguments]    ${Max_loop}=${10}
     FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    check cell should in energysaving state:${index}min
        ${status}   Run Keyword And Return Status    check all the nr cells enter energysaving or notEnergySaving
        Run Keyword If    ${status} == ${False}
        ...    Fail    cell not in energysaving state
        log to console     sleep 1 min
        sleep    1min
     END

CB007447_Long_PL_break_with_recovery_AHEH
    [Arguments]    ${connection}=GNB_OAM
    ...    ${addr}=${tl.optical_switches[0].addr}
    ...    ${port}=${tl.optical_switches[0].port}
    ...    ${username}=${tl.optical_switches[0].username}
    ...    ${password}=${tl.optical_switches[0].password}
    log to console    ${addr}
    log to console    ${port}
    log to console    ${username}
    log to console    ${password}
    ${bts_info}    coam.get_bts_info    connection=${connection}
    FOR    ${cable}    IN    @{bts_info['cables']}
        ${synchronization}    set variable    ${cable['linkMode']['synchronization']}
        Exit For Loop If    '${synchronization}'=='True'
    END
    ${internal}    set variable    ${cable['id']['internal']}
    @{internal}    Split String    ${internal}    /
    ${ru_port}    Run Keyword If   '${internal}[-1]'=='CABLINK_R-1001'    Set Variable   1.1.5   ELSE   Set Variable   1.1.6
    log to console    ru_port is ${ru_port}
    Telnet.Open Connection    host=${addr}   port=${port}
    ${status}    Run Keyword And Return Status     Telnet.login    username=act-user::${username}:::${password}    password=${EMPTY}
    ...    login_prompt=${EMPTY}    password_prompt=${EMPTY}
    should be equal    '${status}'    'True'
    ${command}    set variable    opr-link-flap:::::lowperiod=${lp_l}ms,highperiod=1000ms,repeat=1,ports=${ru_port}
    log to console    ${command}
    Telnet.Write    ${command}
    Wait Until Keyword Succeeds    1min    1s    Expect Fault Should Present   faultId=1815
    sleep    30s
    Wait until keyword succeeds    15min    30s    verify all cells should be onair
    Telnet.Write    canc-user:::::exitsessy

Get Primary Link Name
    [Arguments]    ${connection}=GNB_OAM
    ${bts_info}    coam.get_bts_info    connection=${connection}
    FOR    ${cable}    IN    @{bts_info['cables']}
        ${synchronization}    set variable    ${cable['linkMode']['synchronization']}
        Exit For Loop If    '${synchronization}'=='True'
    END
    ${internal}    set variable    ${cable['id']['internal']}
    @{internal}    Split String    ${internal}    /
    ${primary_link_name}    set variable    ${internal}[-1]
    [Return]    ${primary_link_name}

Get Secondary Link Name
    [Arguments]    ${connection}=GNB_OAM
    ${bts_info}    coam.get_bts_info    connection=${connection}
    FOR    ${cable}    IN    @{bts_info['cables']}
        ${synchronization}    set variable    ${cable['linkMode']['synchronization']}
        Exit For Loop If    '${synchronization}'=='False'
    END
    ${internal}    set variable    ${cable['id']['internal']}
    @{internal}    Split String    ${internal}    /
    ${secondary_link_name}    set variable    ${internal}[-1]
    [Return]    ${secondary_link_name}

Get Port By Link Name
    [Arguments]    ${link_name}    ${parimary_port}=3.3.5    ${secondary_port}=3.3.6
    ${port}    run keyword if    '${link_name}'=='CABLINK_R-1001'    set variable    ${parimary_port}
    ...    ELSE     set variable    ${secondary_port}
    [Return]    ${port}

Set CpriSyncBreakTime
    [Arguments]    ${cpriSyncBreakTime}=600ms
    Selenium Login And Disable Screen Lock
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1
    ...    filter_param=CPRI sync break time    abbr=cpriSyncBreakTime    new_value=${cpriSyncBreakTime}
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${300}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

Login Switch And Send Cmd
    [Arguments]    ${command}
    ...    ${addr}=${tl.optical_switches[0].addr}
    ...    ${port}=${tl.optical_switches[0].port}
    ...    ${username}=${tl.optical_switches[0].username}
    ...    ${password}=${tl.optical_switches[0].password}
    Telnet.Open Connection    host=${addr}   port=${port}
    ${status}    Run Keyword And Return Status     Telnet.login    username=act-user::${username}:::${password}    password=${EMPTY}
    ...    login_prompt=${EMPTY}    password_prompt=${EMPTY}
    should be equal    '${status}'    'True'
    Telnet.Write    ${command}
    sleep    2s
    Telnet.Write    canc-user:::::exitsessy

CB007447_Long_SL_break_with_recovery
#    log to console    step 3: set cpriSyncBreakTime to 600ms
#    Set CpriSyncBreakTime
    log to console    step 4.1: get name of the secondary link (Link mode doesn't contain synchronization)
    ${secondary_link_name}    Get Secondary Link Name
    log to console    secondary link is : ${secondary_link_name}
    log to console    step 4.2:get port for secondary link (CABLINK_R-1001: 3.3.5, CABLINK_R-1002: 3.3.6)
    ${secondary_link_port}    Get Port By Link Name    link_name=${secondary_link_name}
    log to console    step 4.3: execute command: opr-link-flap:::::lowperiod=${lp_l}ms,highperiod=1000ms,repeat=1,ports=${secondary_link_port}
    ${command}    set variable    opr-link-flap:::::lowperiod=${lp_l}ms,highperiod=1000ms,repeat=1,ports=${secondary_link_port}
    Login Switch And Send Cmd    command=${command}
#    log to console    check fault 4760 raised from secondary link
#    Wait Until Keyword Succeeds    3min    2s    Expect History Fault Should Present   faultId=4760    source=${secondary_link_name}
    log to console    step 5.1: check bts on onair
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    sleep    10s
    log to console    step 5.2: check data transfer is possible
    data_transfer_common    tput_self_define=${tput_define_7447}    cell_id=${cell_1}    target_avg_percent=0.98    min_percent=0.85

CB007447_Long_PL_break_with_recovery
    log to console    step 3.1: get name of the primary link (Link mode doesn't contain synchronization)
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    AlarmWatchdog.add_allow_alarms    fault_id=10
    ${primary_link_name}    Get Primary Link Name
    log to console    primary link name is: ${primary_link_name}
    log to console    step 3.2: get port for primary link (CABLINK_R-1001: 3.3.5, CABLINK_R-1002: 3.3.6)
    ${primary_link_port}    Get Port By Link Name    link_name=${primary_link_name}
    log to console    step 3.3: execute command: opr-link-flap:::::lowperiod=${lp_l}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    ${command}    set variable    opr-link-flap:::::lowperiod=${lp_l}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    Login Switch And Send Cmd    command=${command}
#    log to console    check fault 4760 raised from  both link
#    Wait Until Keyword Succeeds    3min    2s    Expect History Fault Should Present   faultId=4760    source=CABLINK_R-1001
#    Wait Until Keyword Succeeds    3min    2s    Expect History Fault Should Present   faultId=4760    source=CABLINK_R-1002
    log to console    check fault 4590 in history alarm
    Wait Until Keyword Succeeds    3min    2s    Expect History Fault Should Present   faultId=4590
    log to console    step 4.1: check bts on onair
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    log to console    step 4.2: check data transfer is possible
    data_transfer_common    tput_self_define=${tput_define_7447}    cell_id=${cell_1}

CB007447_Short_PL_break_with_recovery
    log to console    step 3.1: get name of the primary link (Link mode doesn't contain synchronization)
    ${primary_link_name}    Get Primary Link Name
    log to console    primary link name is: ${primary_link_name}
    log to console    step 3.2: get port for primary link (CABLINK_R-1001: 3.3.5, CABLINK_R-1002: 3.3.6)
    ${primary_link_port}    Get Port By Link Name    link_name=${primary_link_name}
    log to console    step 3.3: execute command: opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    ${command}    set variable    opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    Login Switch And Send Cmd    command=${command}
    sleep    10s
    log to console    step 4.1: check bts on onair
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
#    log to console    check fault 4721 raised from both link by bts log
#    Run Keyword And Ignore Error  Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
#    ${btslog_path}    set variable    ${SAVE LOG DIRECTORY}/btslog
#    OperatingSystem.Run    command=tar -zxvf ${btslog_path}/syslog_files.tgz -C ${btslog_path}
#    sleep    2s
#    ${cmd}    set variable    ls -l ${SAVE LOG DIRECTORY}/btslog|grep -v syslog_files.tgz | awk '{print $9}'
#    ${syslog_name}    OperatingSystem.Run    command=${cmd}
#    ${syslog_name}    Replace String    ${syslog_name}    \n    ${EMPTY}
#    log to console    syslog_name is ${syslog_name}
#    ${fault_info}    set variable    Report fault with FaultNotifParams, faultId = 4721.*faultyObject = .*${primary_link_name}
#    ${cmd}    set variable    cat ${btslog_path}/${syslog_name} |grep '${fault_info}'|wc -l
#    ${ret}    OperatingSystem.Run    command=${cmd}
#    should contain    ${ret}    1
#    ${fault_info}    set variable    Report fault with FaultNotifParams, faultId = 4721.*faultyObject = .*CABLINK_R-1002
#    ${cmd}    set variable    cat ${btslog_path}/${syslog_name} |grep '${fault_info}'|wc -l
#    ${ret}    OperatingSystem.Run    command=${cmd}
#    should contain    ${ret}    1
    log to console    step 4.2: check data transfer is possible
    data_transfer_common    tput_self_define=${tput_define_7447}    cell_id=${cell_1}        target_avg_percent=0.6    min_percent=0.5

CB007447_Short_SL_break_with_recovery
    log to console    step 3.1: get name of the secondary link (Link mode doesn't contain synchronization)
    ${secondary_link_name}    Get Secondary Link Name
    log to console    secondary link is : ${secondary_link_name}
    log to console    step 3.2: get port for secondary link (CABLINK_R-1001: 3.3.5, CABLINK_R-1002: 3.3.6)
    ${secondary_link_port}    Get Port By Link Name    link_name=${secondary_link_name}
    log to console    step 3.3: execute command: opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${secondary_link_port}
    ${command}    set variable    opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${secondary_link_port}
    Login Switch And Send Cmd    command=${command}
    sleep    10s
    log to console    step 4.1: check bts on onair
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
#    log to console    check fault 4721 raised from secondary link by bts log
#    Run Keyword And Ignore Error  Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
#    ${btslog_path}    set variable    ${SAVE LOG DIRECTORY}/btslog
#    OperatingSystem.Run    command=tar -zxvf ${btslog_path}/syslog_files.tgz -C ${btslog_path}
#    sleep    2s
#    ${cmd}    set variable    ls -l ${SAVE LOG DIRECTORY}/btslog|grep -v syslog_files.tgz | awk '{print $9}'
#    ${syslog_name}    OperatingSystem.Run    command=${cmd}
#    ${syslog_name}    Replace String    ${syslog_name}    \n    ${EMPTY}
#    log to console    syslog_name is ${syslog_name}
#    ${fault_info}    set variable    Report fault with FaultNotifParams, faultId = 4721.*faultyObject = .*${secondary_link_name}
#    ${cmd}    set variable    cat ${btslog_path}/${syslog_name} |grep '${fault_info}'|wc -l
#    ${ret}    OperatingSystem.Run    command=${cmd}
#    should contain    ${ret}    1
    log to console    step 4.2: check data transfer is possible
    data_transfer_common    tput_self_define=${tput_define_7447}    cell_id=${cell_1}    target_avg_percent=0.6    min_percent=0.5

CB007447_Long_short_link_break_counter_check_with_webem_and_netact
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    AlarmWatchdog.add_allow_alarms    fault_id=10
    ${primary_link_name}    Get Primary Link Name
    log to console    primary link name is: ${primary_link_name}
    ${primary_link_port}    Get Port By Link Name    link_name=${primary_link_name}
    ${secondary_link_name}    Get Secondary Link Name
    log to console    secondary link is : ${secondary_link_name}
    ${secondary_link_port}    Get Port By Link Name    link_name=${secondary_link_name}
    log to console    get Counter cpriShortLinkBreak M40015C10 value for primary link
    ${BBMOD_index}    run keyword if    '${primary_link_name}'=='CABLINK_R-1001'    set variable    BBMOD-1    ELSE
    ...    set variable    BBMOD-2
    Selenium Login And Disable Screen Lock
    ${btsName}    selenium_coam.get_bts_name
    ${M40015C10_SFP1_PATH}=    catenate    SEPARATOR=    [${btsName}] MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/${BBMOD_index}/SFP-1/L
    ...    ANE-1/SBTS_SFP_BBMOD_LANE/FH_LINK_BREAK_SHORT
    ${M40015C10_SFP1}    selenium_coam.get_bts_counters_info    counter_id=M40015C10    full_path=${M40015C10_SFP1_PATH}
    ${time}    Get Dictionary Keys    ${M40015C10_SFP1}
    ${time_M40015C10_SFP1_before}    set variable    ${time}[-1]
    ${value}    Get Dictionary Values    ${M40015C10_SFP1}
    ${value_M40015C10_SFP1_before}    set variable    ${value}[-1]
    log to console    value_M40015C10_SFP1_before is : ${value_M40015C10_SFP1_before}
    log to console    step 3: execute command: opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    ${command}    set variable    opr-link-flap:::::lowperiod=${lp_s}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    Login Switch And Send Cmd    command=${command}
    sleep    10s
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
#    log to console    check Fault 4721 raised from primary link by bts log
#    Run Keyword And Ignore Error  Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
#    ${btslog_path}    set variable    ${SAVE LOG DIRECTORY}/btslog
#    OperatingSystem.Run    command=tar -zxvf ${btslog_path}/syslog_files.tgz -C ${btslog_path}
#    sleep    2s
#    ${cmd}    set variable    ls -l ${SAVE LOG DIRECTORY}/btslog|grep -v syslog_files.tgz | awk '{print $9}'
#    ${syslog_name}    OperatingSystem.Run    command=${cmd}
#    ${syslog_name}    Replace String    ${syslog_name}    \n    ${EMPTY}
#    log to console    syslog_name is ${syslog_name}
#    ${fault_info}    set variable    Report fault with FaultNotifParams, faultId = 4721.*faultyObject = .*${primary_link_name}
#    ${cmd}    set variable    cat ${btslog_path}/${syslog_name} |grep '${fault_info}'|wc -l
#    ${ret}    OperatingSystem.Run    command=${cmd}
#    should contain    ${ret}    1
    ${primary_link_name}    Get Primary Link Name
    log to console    primary link name is: ${primary_link_name}
    ${primary_link_port}    Get Port By Link Name    link_name=${primary_link_name}
    ${secondary_link_name}    Get Secondary Link Name
    log to console    secondary link is : ${secondary_link_name}
    ${secondary_link_port}    Get Port By Link Name    link_name=${secondary_link_name}
    log to console    check Counter cpriShortLinkBreak M40015C10 incremented by 1 for primary link
    ${value_M40015C10_SFP1_after}    get next count value for pointed counter    counter_id=M40015C10    full_path=${M40015C10_SFP1_PATH}
    ...    last_report_time=${time_M40015C10_SFP1_before}
    log to console    value_M40015C10_SFP1_after is : ${value_M40015C10_SFP1_after}
    ${res}    evaluate    ${value_M40015C10_SFP1_before}+1 <= ${value_M40015C10_SFP1_after}
    log to console    res is : ${res}
#    ${value_M40015C10_SFP1_after}    run keyword if    '${res}'=='False'    run keywords    sleep    300s    AND
#    ...    get next count value for pointed counter    counter_id=M40015C10    full_path=${M40015C10_SFP1_PATH}
#    ...    last_report_time=${time_M40015C10_SFP1_before}    ELSE    set variable    ${value_M40015C10_SFP1_after}
#    ${res}    evaluate    ${value_M40015C10_SFP1_before}+1 <= ${value_M40015C10_SFP1_after}
    ${res}    Check Count One More Time If Needed    res=${res}    counter_id=M40015C10    sfp_path=${M40015C10_SFP1_PATH}
    ...    last_report_time=${time_M40015C10_SFP1_before}    counter_before=${value_M40015C10_SFP1_before}
    should be equal    '${res}'    'True'
    log to console    check cell onair
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    log to console    get Counter cpriShortLinkBreak M40015C11 value for primary link
    ${M40015C11_SFP1_PATH}=    catenate    SEPARATOR=    [${btsName}] MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/${BBMOD_index}/SFP-1/L
    ...    ANE-1/SBTS_SFP_BBMOD_LANE/FH_LINK_BREAK_LONG
    ${M40015C11_SFP1}    selenium_coam.get_bts_counters_info    counter_id=M40015C11    full_path=${M40015C11_SFP1_PATH}
    ${time}    Get Dictionary Keys    ${M40015C11_SFP1}
    ${time_M40015C11_SFP1_before}    set variable    ${time}[-1]
    ${value}    Get Dictionary Values    ${M40015C11_SFP1}
    ${value_M40015C11_SFP1_before}    set variable    ${value}[-1]
    log to console    value_M40015C11_SFP1_before is : ${value_M40015C11_SFP1_before}
    log to console    step 4: execute command: opr-link-flap:::::lowperiod=${lp_l}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    ${command}    set variable    opr-link-flap:::::lowperiod=${lp_l}ms,highperiod=1000ms,repeat=1,ports=${primary_link_port}
    Login Switch And Send Cmd    command=${command}
#    log to console    check Fault 4760 raised from both link
#    Wait Until Keyword Succeeds    3min    2s    Expect History Fault Should Present   faultId=4760    source=CABLINK_R-1001
#    Wait Until Keyword Succeeds    3min    2s    Expect History Fault Should Present   faultId=4760    source=CABLINK_R-1002
    log to console    check fault 4590 in history alarm
    Wait Until Keyword Succeeds    3min    2s    Expect History Fault Should Present   faultId=4590
    log to console    check Counter cpriLongLinkBreak M40015C11 incremented by 1 for primary link
    ${value_M40015C11_SFP1_after}    get next count value for pointed counter    counter_id=M40015C11    full_path=${M40015C11_SFP1_PATH}
    ...    last_report_time=${time_M40015C11_SFP1_before}
    log to console    value_M40015C11_SFP1_after is : ${value_M40015C11_SFP1_after}
    ${res}    evaluate    ${value_M40015C11_SFP1_before}+1 <= ${value_M40015C11_SFP1_after}
    log to console    res is : ${res}
#    ${value_M40015C11_SFP1_after}     run keyword if    '${res}'=='False'    run keywords    sleep    300s    AND
#    ...    get next count value for pointed counter    counter_id=M40015C11    full_path=${M40015C11_SFP1_PATH}
#    ...    last_report_time=${time_M40015C11_SFP1_before}    ELSE    set variable    ${value_M40015C11_SFP1_after}
#    ${res}    evaluate    ${value_M40015C11_SFP1_before}+1 <= ${value_M40015C11_SFP1_after}
    ${res}    Check Count One More Time If Needed    res=${res}    counter_id=M40015C11    sfp_path=${M40015C11_SFP1_PATH}
    ...    last_report_time=${time_M40015C11_SFP1_before}    counter_before=${value_M40015C11_SFP1_before}
    should be equal    '${res}'    'True'
    log to console    check check cell onair
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    [Teardown]    Selenium Logout And Close Browser

Check Count One More Time If Needed
    [Arguments]    ${res}    ${counter_id}    ${sfp_path}    ${last_report_time}    ${counter_before}
    return from keyword if    '${res}'=='True'      ${res}
    sleep    300s
    ${counter_after}    get next count value for pointed counter    counter_id=${counter_id}    full_path=${sfp_path}
    ...    last_report_time=${last_report_time}
    ${res}    evaluate    ${counter_before}+1 <= ${counter_after}
    log to console    res is : ${res}
    [Return]    ${res}

CB007447_Link_break_with_RU_reset
    [Arguments]    ${ru_index}=${1}
    log to console    step 3: reset radio on webem
    Perform RU Reset
#   sleep    30s
    log to console    check ru reseted...
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    5s    RU Should Be Offline    ru_index=${ru_index}
    log to console    step 4.1: check bts on onair
#    Wait until keyword succeeds    10min    10s    verify all cells should be onair

    Wait until keyword succeeds    10min    5s    Check all cells info should be onair
    log to console    step 4.2: check data transfer is possible
    data_transfer_common    tput_self_define=${tput_define_7447}    cell_id=${cell_1}    target_avg_percent=0.6    min_percent=0.5

get next count value for pointed counter
    [Arguments]     ${counter_id}    ${full_path}    ${last_report_time}    ${max_loop}=60
    FOR    ${i}    IN RANGE    0    ${max_loop}
        ${counter_info}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${full_path}
        ${time}    Get Dictionary Keys    ${counter_info}
        ${time}    set variable    ${time}[-1]
        ${value}    Get Dictionary Values    ${counter_info}
        ${value}    set variable    ${value}[-1]
        Exit For Loop If    '${last_report_time}'!='${time}'
        sleep    10s
    END
    log to console    ${time}    ${value}
    [Return]    ${value}

Expect History Fault Should Present
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['supplAlarmInfo']} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    ...               add ${supplementary_not_contain} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}     ${supplementary}=${None}    ${supplementary_not_contain}=${None}
    ...            ${timeout}=10
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_historic_alarms    connection=${connection}    timeout=${timeout}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}    AND
                  ...                      Run Keyword If    '${Supplementary}'!='${None}'
                  ...                      Should Contain   ${alarm['supplAlarmInfo']}    ${Supplementary}    AND
                  ...                      Run Keyword If    '${supplementary_not_contain}'!='${None}'
                  ...                      Should not Contain   ${alarm['supplAlarmInfo']}    ${supplementary_not_contain}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Output RU logs to control PC
    log to console    login asik
    Connect to Common Unit Master    alias=ASIK Master
    log to console    delete /user/toor4nsn/.ssh/known_hosts
    csn.Send Command    command=rm -rf /user/toor4nsn/.ssh/known_hosts    connection=ASIK Master
    log to console    login ru
    Connect to RU With Allocated IP    ru_username=root
    log to console    execute command: rad -mpw 0x10043 0xC738
    csn.send command    command=ccsShell.sh rad -mpw 0x10043 0xC738    connection=RU
    sleep    2s
    ${output}      csn.read output          connection=RU
    log to console    ${output}
    Should Contain    ${output}    written succesfully
    log to console    execute command: rad -mpw 0x10042 0xc0a864c8
    csn.send command    command=ccsShell.sh rad -mpw 0x10042 0xc0a864c8    connection=RU
    sleep    2s
    ${output}      csn.read output          connection=RU
    log to console    ${output}
    Should Contain    ${output}    written succesfully
    log to console    execute command: rad -mpw 0x10041 0x2
    csn.send command    command=ccsShell.sh rad -mpw 0x10041 0x2    connection=RU
    sleep    2s
    ${output}      csn.read output          connection=RU
    log to console    ${output}
    Should Contain    ${output}    written succesfully
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections
