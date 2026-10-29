*** Settings ***
Documentation    These are common keywords for CB009563 related cases
...              Please do not modify the file without notification to author
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    testsuite/Hangzhou/RRM/RAN_L1_SW_CN_5/resources/BTS/coam_siso_common.robot
Library           taf.sbts.oam.coam.admin                WITH NAME    coam
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009826/Resource/gnb_para.py
Library     taf.hw.rf_attenuator    WITH NAME    att

*** Variables ***
${MRBTS_ID}            MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}            NRBTS-${tl.gnbs[0].global_bts_id}
${gnb_index}    0
${du_index}     0
${common_unit_index}  0
${att_ipaddr}               ${tl.attenuator.ip_addr}
${att_port_number}          ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_0}               ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_api_port}             ${tl.attenuator.port}
${vendor}                   HBTE
${HBTE_max_value}           ${127}
${model}    PA-16-16-6-127-0.5-B-S

*** Keywords ***
BB reset and check status via coam
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_index}
        ...    reset_type=Warm    force_radio_reset=${True}    timeout=${300}    connection=${connection}
        sleep    10s
        Wait Until Keyword Succeeds    5min    60s    Check BBMOD status
    END
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status

Check BBMOD status
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM    ${operationalState}=enabled
                 ...    ${adminState}=unlocked    ${usageState}=active    ${proStatus}=configured
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['operationalState'].lower()}       ${operationalState}
                                  ...  msg=Current bbmod operationalState is not in ${operationalState} status
    Should be equal as strings    ${bbmod_status['status']['administrativeState'].lower()}    ${adminState}
                                  ...  msg=Current bbmod administrativeState is not in ${adminState} status
    Should be equal as strings    ${bbmod_status['status']['usageState'].lower()}       ${usageState}
                                  ...  msg=Current bbmod usageState is not in ${usageState} status
    Should be equal as strings    ${bbmod_status['status']['proceduralStatus'].lower()}       ${proStatus}
                                  ...  msg=Current bbmod proceduralStatus is not in ${proStatus} status
Check all the Cell status
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=50
                 ...    ${operationalState}=enabled    ${adminState}=unlocked    ${usageState}=active
                 ...    ${proStatus}=configured    ${blockState}=unblocked
    Log to console    Check all NR and LTE cells status
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}    ${operationalState}
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     ${adminState}
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}    ${blockState}
        Should Be Equal As Strings    ${cell['status']['usageState'].lower()}    ${usageState}
        Should Be Equal As Strings    ${cell['status']['proceduralStatus'].lower()}    ${proStatus}
    END
Cell_block_and_unblock
    [Arguments]    ${connection}=GNB_OAM
    Log To Console    block Cell
    coam.block_cell    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3    connection=${connection}
    ...    timeout=60
    sleep    10
    Wait Until Keyword Succeeds    5min    60s    Check single NR cell status    cell_idx=1
    ...    operationalState=disabled     usageState=idle    blockState=blocked
    Log To Console    Unblock Cell
    coam.unblock_cell    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3    connection=${connection}
    ...    timeout=60
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status
Check single NR cell status
    [Arguments]   ${cell_idx}=0   ${connection}=GNB_OAM    ${timeout}=20
                 ...    ${operationalState}=enabled    ${adminState}=unlocked    ${usageState}=active
                 ...    ${proStatus}=configured    ${blockState}=unblocked
    Log to console    Check cell ${cell_idx} of ${cell_type} configuration status
    ${cells_info}   coam.get_cells_info    cell_type=nr   timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        run keyword if  '${cell['globalCellId']}'!='${cell_idx}'    Continue For Loop
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}    ${operationalState}
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     ${adminState}
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}    ${blockState}
        Should Be Equal As Strings    ${cell['status']['usageState'].lower()}    ${usageState}
        Should Be Equal As Strings    ${cell['status']['proceduralStatus'].lower()}    ${proStatus}
    END
RU_lock_and_unlock
    [Arguments]    ${connection}=GNB_OAM
    Log To Console    Lock RU
    coam.lock    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3    timeout=${60}    connection=${connection}
    sleep    3s
    coam_siso_common.RU Should Be Locked     ru_index=3    connection=${connection}
    Log To Console    Ulock RU
    coam.unlock    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3    timeout=${60}    connection=${connection}
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status
modify_parameter_recommissioning
    [Arguments]    ${connection}=GNB_OAM
	log to console    start to modify parameter
	${out_parameters_list}     taf.sbts.oam.coam.admin.get_managed_objects
       ...    class_name=NRBTS_A    connection=${connection}
    ${out_parameter}    Get From Dictionary    ${out_parameters_list[0]}    parameters
    ${parameter_value}    Get From Dictionary    ${out_parameter}     trsBurstSize
    ${expected_value}	   Set Variable If	  "${parameter_value}"=="b6440000" 	  b8400000    b6440000
    Run Keyword and Continue on Failure    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
	...    parameter=trsBurstSize   operation=update    value=${expected_value}
    ...   connection=${connection}   skip_parameter_relation_errors=False    timeout=900
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status
update parameter
    [Arguments]    ${parameters_list}    ${timeout}=${300}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_list}    timeout=${timeout}
reset RU
    [Arguments]    ${connection}=GNB_OAM
    coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-3   force_radio_reset=${True}
        ...    timeout=${600}    connection=${connection}
    sleep    10s
power reset RMOD1
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    CB009061_common_keyword.PB.PowerOnOff     pdu_ip=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
    ...    model=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
    ...    Action=both
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status
PB.PowerOnOff
    [Arguments]    ${pdu_ip}    ${Port_Number}    ${Action}=power_off    ${model}=HBTE
    pdu.Setup Pdu       host=${pdu_ip}    model=${model}
    Run Keyword If    '${Action}'=='power_off'    pdu.power_off    port=${Port_Number}
    ...    ELSE IF   '${Action}'=='power_on'    pdu.power_on    port=${Port_Number}
    ...    ELSE IF   '${Action}'=='both'    Run Keywords    pdu.power_off    port=${Port_Number}    AND    sleep    10s
    ...    AND    pdu.power_on    port=${Port_Number}
reset site
    [Arguments]    ${connection}=GNB_OAM
    coam.reset_site    timeout=${600}    connection=${connection}
    sleep    10s
Case Preparation
    COAM Create log directory
	Connect to gnb coam via ssl
	${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    CI_commssion.common commissioning    gnb_index=${gnb_index}   du_index=${du_index}
    ...    common_unit_index=${common_unit_index}
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections
TC.reset_RMOD_loop
    [Documentation]   This is for all RU soft reset
    [Arguments]    ${KPI51A_MAX}    ${repeat_times}    ${fail_loop_max}      ${connection}=GNB_OAM
    ${Fault_ID} =    Set Variable   10
    ${Fault_ID1} =    Set Variable   4590
    ${Fault_ID2} =    Set Variable   1815
    Set suite variable     ${ALLOWED_ALARMS_KPI51a}      ${ALLOWED_ALARMS}
    Append to list   ${ALLOWED_ALARMS_KPI51a}    ${Fault_ID}
    Append to list   ${ALLOWED_ALARMS_KPI51a}    ${Fault_ID1}
    Append to list   ${ALLOWED_ALARMS_KPI51a}    ${Fault_ID2}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
         ${case_status}    RUN KEYWORD AND CONTINUE ON FAILURE
         ...    KW.reset_RMOD    KPI51A_MAX=${KPI51A_MAX}      connection=${connection}
        Append To List    ${result_list}    ${case_status[0]}
        ${fail_num}    Count Values In List    ${result_list}     False
        log to console    This soft reset RMOD loop${i} is ${case_status[0]} and kpi is ${case_status[1]}
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown
KW.reset_RMOD
    [Arguments]    ${KPI51A_MAX}=${500}      ${connection}=GNB_OAM
    ims_keywords.check_instance_connection    gnbbbu
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
#    ${connection}    Connect to DU by ADMIN API
    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    Run Keyword And Return Status
    ...    wait until keyword succeeds   3min   3s    coam.reset_unit
    ...    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-3    timeout=600    connection=${connection}
    Timer.Start
	log to console    check all cell status start
	Run Keyword and Continue on Failure
    ...    Wait Until Keyword Succeeds    15min    1s     Check all the Cell status
    ${duration_1}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${timestamp_log}    ALLOWED_ALARMS=${ALLOWED_ALARMS_KPI51a}    referrence_time=${referrence_time}
    ${test_status}	   Set Variable If
    ...    "${history_alarm_status}"=="False" and "${alarm_status}"=="False" and ${10}<${duration_1}<${KPI51A_MAX}
    ...    pass      fail
    ${snapshot_file}    Run Keyword If    '${test_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop
    Run Keyword If    '${test_status}'=='pass'     Run Keyword And Ignore Error
     ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${test_status}    pass
    [Return]    ${test_status}    ${duration_1}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1
TC.power_reset_RMOD_loop
    [Documentation]   This is for all RU cold reset
    [Arguments]    ${KPI54A_MAX}    ${repeat_times}    ${fail_loop_max}
    ${Fault_ID} =    Set Variable   10
    ${Fault_ID1} =    Set Variable   4590
    ${Fault_ID2} =    Set Variable   1815
    Set suite variable     ${ALLOWED_ALARMS_KPI54a}      ${ALLOWED_ALARMS}
    Append to list   ${ALLOWED_ALARMS_KPI54a}    ${Fault_ID}
    Append to list   ${ALLOWED_ALARMS_KPI54a}    ${Fault_ID1}
    Append to list   ${ALLOWED_ALARMS_KPI54a}    ${Fault_ID2}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
         ${case_status}    RUN KEYWORD AND CONTINUE ON FAILURE
         ...    KW.power_reset_RMOD    KPI51A_MAX=${KPI54A_MAX}
        Append To List    ${result_list}    ${case_status[0]}
        ${fail_num}    Count Values In List    ${result_list}     False
        log to console    This power reset RMOD loop${i} is ${case_status[0]} and kpi is ${case_status[1]}
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown
KW.power_reset_RMOD
    [Arguments]    ${KPI51A_MAX}=${500}
    ims_keywords.check_instance_connection    gnbbbu
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    Connect to gnb coam via ssl
    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    CB009061_common_keyword.PB.PowerOnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
    ...    model=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
    ...    Action=both
    Timer.Start
	log to console    check all cell status start
	Run Keyword and Continue on Failure
    ...    Wait Until Keyword Succeeds    15min    1s     Check all the Cell status
    ${duration_1}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${timestamp_log}    ALLOWED_ALARMS=${ALLOWED_ALARMS_KPI51a}    referrence_time=${referrence_time}
    ${test_status}	   Set Variable If
    ...    "${history_alarm_status}"=="False" and "${alarm_status}"=="False" and ${10}<${duration_1}<${KPI51A_MAX}
    ...    pass      fail
    ${snapshot_file}    Run Keyword If    '${test_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop
    Run Keyword If    '${test_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${test_status}    pass
    [Return]    ${test_status}    ${duration_1}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1
TC.block_unblock_cell_loop
    [Documentation]   This is for cell block and unblock
    [Arguments]    ${KPI17A_MAX}    ${KPI17B_MAX}    ${repeat_times}    ${fail_loop_max}      ${connection}=GNB_OAM
     ${Fault_ID} =    Set Variable   49
#     ${Fault_ID1} =    Set Variable   4590
#     ${Fault_ID2} =    Set Variable   1815
     Set suite variable     ${ALLOWED_ALARMS_KPI17}      ${ALLOWED_ALARMS}
     Append to list   ${ALLOWED_ALARMS_KPI17}    ${Fault_ID}
#     Append to list   ${ALLOWED_ALARMS_KPI17}    ${Fault_ID1}
#     Append to list   ${ALLOWED_ALARMS_KPI17A}    ${Fault_ID2}
     @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
         ${case_status}    RUN KEYWORD AND CONTINUE ON FAILURE
         ...    KW.block_unblock_cell    KPI17A_MAX=${KPI17A_MAX}      KPI17B_MAX=${KPI17B_MAX}      connection=${connection}
        Append To List    ${result_list}    ${case_status[0]}
        ${fail_num}    Count Values In List    ${result_list}     False
        log to console    This block and unblock cell loop${i} is ${case_status[0]} and kpi is ${case_status[1]}
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown
KW.block_unblock_cell
    [Arguments]    ${KPI17A_MAX}=${50}      ${KPI17B_MAX}=${50}      ${connection}=GNB_OAM
    ims_keywords.check_instance_connection    gnbbbu
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    Connect to gnb coam via ssl
    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...      coam.block_cell    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3    connection=${connection}
    ...      timeout=60
    Timer.Start
	log to console    check all cell status start
	Wait Until Keyword Succeeds    1min    1s    Check single NR cell status    cell_idx=3
    ...    operationalState=disabled     usageState=idle    blockState=blocked
     ${duration_1}     Timer.Stop
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...      coam.unblock_cell    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3    connection=${connection}
    ...      timeout=60
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    Timer.Start
	log to console    check all cell status start
    Wait Until Keyword Succeeds    1min    1s    Check all the Cell status
    ${duration_2}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${timestamp_log}    ALLOWED_ALARMS=${ALLOWED_ALARMS_KPI17}    referrence_time=${referrence_time}
    ${test_status}	   Set Variable If
    ...    "${history_alarm_status}"=="False" and "${alarm_status}"=="False" and ${duration_1}<${KPI17A_MAX} and ${duration_2}<${KPI17B_MAX}
    ...    pass      fail
    ${snapshot_file}    Run Keyword If    '${test_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop
     Run Keyword If    '${test_status}'=='pass'     Run Keyword And Ignore Error
     ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${test_status}    pass
    [Return]    ${test_status}    ${duration_1}      ${duration_2}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1
TC.reset_site_loop
    [Documentation]   This is for site reset
    [Arguments]    ${KPI1a_MAX}    ${repeat_times}    ${fail_loop_max}      ${connection}=GNB_OAM
    ${Fault_ID} =    Set Variable   4590
#   ${Fault_ID1} =    Set Variable   4590
#   ${Fault_ID2} =    Set Variable   1815
    Set suite variable     ${ALLOWED_ALARMS_KPI1a}      ${ALLOWED_ALARMS}
    Append to list   ${ALLOWED_ALARMS_KPI1a}    ${Fault_ID}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
         ${case_status}    RUN KEYWORD AND CONTINUE ON FAILURE
         ...    KW.reset_site    KPI1a_MAX=${KPI1a_MAX}      connection=${connection}
        Append To List    ${result_list}    ${case_status[0]}
        ${fail_num}    Count Values In List    ${result_list}     False
        log to console    This site reset loop${i} is ${case_status[0]} and kpi is ${case_status[1]}
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown
KW.reset_site
    [Arguments]    ${KPI1a_MAX}=${500}      ${connection}=GNB_OAM
    ims_keywords.check_instance_connection    gnbbbu
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
#    ${connection}    Connect to DU by ADMIN API
    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    Run Keyword And Return Status
    ...    wait until keyword succeeds   3min   3s    coam.reset_site      connection=${connection}
    Timer.Start
	log to console    check all cell status start
	Run Keyword and Continue on Failure
    ...    Wait Until Keyword Succeeds    15min    1s     Check all the Cell status
    ${duration_1}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${timestamp_log}    ALLOWED_ALARMS=${ALLOWED_ALARMS_KPI1a}    referrence_time=${referrence_time}
    ${test_status}	   Set Variable If
    ...    "${history_alarm_status}"=="False" and "${alarm_status}"=="False" and ${10}<${duration_1}<${KPI1a_MAX}
    ...    pass      fail
    ${snapshot_file}    Run Keyword If    '${test_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop
    Run Keyword If    '${test_status}'=='pass'     Run Keyword And Ignore Error
     ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${test_status}    pass
    [Return]    ${test_status}    ${duration_1}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1

Start traffic and check result
    [Arguments]    ${dltp_expected}=540  ${data_send_dl}=560M    ${data_send_ul}=70M
	...             ${ultp_expected}=50    ${tp_direction}=both    ${sleep_time}=1m
	...             ${call_duration}=2m     ${target_avg_percent}=0.98      ${min_percent}=0.55
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}
    AAsys log captrue    sleep_time=${sleep_time}
    Run keyword and continue on failure    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}
    ...    call_duration=${call_duration}      target_avg_percent=${target_avg_percent}    min_percent=${min_percent}


Prepare UE for ${ue_type}
    log to console      Prepare UE for ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}    reset_sol=ue_reboot
	sleep    40s

UE Attach for ${ue_type}
    log to console      UE Attach for ${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start traffic according to direction and protocol
    [Arguments]  ${data_send_dl}    ${data_send_ul}=60M     ${tp_direction}=both
    log to console      Start traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${data_send_ul}    duration=1400    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${data_send_dl}    duration=1400    ue_type=${ue_type}    seg_size=${seg_size}    protocol=${protocol}
	...    process_num=${process_num}    window=32M
    sleep    5s


Check throughput according to direction and protocol
    [Arguments]    ${dltp_expected}    ${ultp_expected}=58    ${tp_direction}=both
    ...    ${call_duration}=2m     ${target_avg_percent}=0.98      ${min_percent}=0.55
    log to console      Check throughput
	${log}    Run keyword and continue on failure    power_ue.Collect Tput
	...    ue_type=${ue_type}    duration=${call_duration}    filter=L2Lo
	Set Suite Variable     ${log}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'
    ...    Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    log=${log}    cells=@{list_of_cell}
    ...    target_throughput=${dltp_expected}    actCarrierAggregation=${False}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'
    ...    Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=UL    log=${log}    cells=@{list_of_cell}
    ...    target_throughput=${ultp_expected}    actCarrierAggregation=${False}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}

Stop traffic according to direction and protocol
    [Arguments]  ${tp_direction}=both
    log to console      Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp


UE Detach for ${ue_type}
    log to console      UE Detach for ${ue_type}
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}



Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=5000   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    FOR  ${port_num}    IN RANGE    0    4
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END

Get NRCELL ID List Via Admin CLI
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${nr_cell_list}=    Get All Cell Id    cell_type=nr    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${nr_cell_list}

Block Cells Except One
    [Arguments]    @{nr_cell_list}    ${exception_cell_id}    ${connection}=GNB_OAM
    Log To Console    Block all cells except cell ${exception_cell_id}
    Connect to gnb coam via ssl
    FOR    ${cell_id}    IN    @{nr_cell_list}
        Continue For Loop If    ${cell_id} == ${exception_cell_id}
        coam.block_cell    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    timeout=60    connection=${connection}
        sleep    2s
        Log To Console    Wait for blocked cells to reach desired state
        Wait Until Keyword Succeeds    5min    60s    Check single NR cell status    cell_idx=${cell_id}
        ...    operationalState=disabled     usageState=idle    blockState=blocked
    END
Unblock Cells Except One
    [Arguments]    @{nr_cell_list}    ${exception_cell_id}    ${connection}=GNB_OAM
    Log To Console    unblock all cells except cell ${exception_cell_id}
    Connect to gnb coam via ssl
    FOR    ${cell_id}    IN    @{nr_cell_list}
        Continue For Loop If    ${cell_id} == ${exception_cell_id}
        coam.unblock_cell    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    timeout=60    connection=${connection}
        sleep    2s
    END
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status