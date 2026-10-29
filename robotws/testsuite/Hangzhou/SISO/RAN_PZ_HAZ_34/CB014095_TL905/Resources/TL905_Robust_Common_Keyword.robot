*** Settings ***

Documentation
...   author: lixia tang
...   squad group: MMW_SG3
...   contact: lixia.tang@nokia-sbell.com
...   Feature CB009801 in 5G24R2 program


Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_reset_from_GUI.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Baseband_module_reset_via_WEBUI.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Baseband_module_lock_unlock_via_WEBUI.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot

Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/parse_soap.py

Library    parse_soap.SOAPParser    WITH NAME    soapp
Library           OperatingSystem
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf        WITH NAME    scf
Library           taf.sbts.oam.coam.admin   WITH NAME   coam
Library           taf.selenium.sbts  WITH NAME   selenium_coam
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.collectors.core   WITH NAME   core
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library           taf.hw.pdu           WITH NAME    pdu
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           DateTime


*** Variables ***
${mrbts_ID_enb}        ${tl.enbs[0].instance_id}
${MRBTS_ID}                  ${tl.gnbs[0].instance_id}
${NRBTS_ID}                  ${tl.gnbs[0].global_bts_id}
${connection}    COAM
${ALLOWED_ALARMS}    '4592', '61524', '61649', '61652', '4334', '4340', '4654', '4655', '4681', '61524', '7313', '6826', '62003'
...    '4741', '61641', '7300', '7319', '6327' '4293', '6825', '6832', '6829', '49', '4614', '50', '4003', '7509'

${TS_CASE_LOG_PATH}    /home/ute/Case_Logs/slimcell
${TEST_LOG_DIRECTORY}    /home/ute/Case_Logs/robust
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}     ${tl.test_pc.default_ssh_connection_details.password}
${DU_OAM_IP}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_ADDR}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}

${model}           HBTE
${ru_pdu_ip}       ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${ru_pdu_port}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${alarm_filter}    4003
${scf_file_path}    ${commissionings_path}HGZ/${testline_name}

${LOCK_CELLS}    ${CURDIR}/CELL_LOCK.json
${UNLOCK_CELLS}    ${CURDIR}/CELL_UNLOCK.json
${LOCK_RU}    ${CURDIR}/RU_LOCK.json
${UNLOCK_RU}    ${CURDIR}/RU_UNLOCK.json

${DELETE_CELLS}    ${CURDIR}/delta_delete_cell_1_5_10.json
${ADD_CELLS}    ${CURDIR}/delta_add_cell_72e.json

${ue_type}    ${tl.ues[-1].capabilities[-1]}

${gNb_CuType}    SA

${ul_power_port_list}           ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}           ${tl.ues[0].iperf_details.ports[3:6]}


*** Keywords ***

####case setup/teatdowm##############
Test Case setup
    Run Keyword And Ignore Error    robot_common_operations.Common case setup    fail_with_alarms=False
    Check Testline Status after Upgrade

Test Case teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown

Check Testline Status after Upgrade
    log to console     \n Check Testline Status after Upgrade
    Connect to gnb coam via ssl    connection=${connection}
    ${status}    Check Cells Onair And No Unexpected Alarm    Check_timer=30s
    Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Check Cells Onair And No Unexpected Alarm
    [Arguments]    ${Check_timer}=5min    ${Interval}=10s
    log to console     Check Cells Onair And No Unexpected Alarm
    ${run_status}    run keyword and return status    Wait Until Keyword Succeeds
    ...              ${Check_timer}   ${Interval}   COAM Check BTS All Cells Onair
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check BTS All Cells Status
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check BTS All RU Status
    ${alarm_status}    run keyword and return status    Check No Unexpected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No Unexpected History Alarm
    ${alarm_status}    Evaluate    ${alarm_status} and ${history_alarm_status}
    ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    Run keyword and continue on failure    Should Be Equal    ${status}    pass
    [Return]    ${status}

COAM Check BTS All Cells Onair
    [Arguments]   ${connection}=${connection}
    log to console     Check all cells onair
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${len_lte}    Get Length    ${bts_info['cells']['lte']}
    ${len_nr}    Get Length    ${bts_info['cells']['nr']}
    Run Keyword If    ${len_lte} > 0    Get All Cells Onair Status   cell_list=${bts_info['cells']['lte']}
    Run Keyword If    ${len_nr} > 0    Get All Cells Onair Status    cell_list=${bts_info['cells']['nr']}

COAM Check BTS All Cells Status
    [Arguments]   ${connection}=${connection}
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${len_lte}    Get Length    ${bts_info['cells']['lte']}
    ${len_nr}    Get Length    ${bts_info['cells']['nr']}
    Run Keyword If    ${len_lte} > 0    Get All Cells Current Status   cell_list=${bts_info['cells']['lte']}
    Run Keyword If    ${len_nr} > 0    Get All Cells Current Status    cell_list=${bts_info['cells']['nr']}

Get All Cells Current Status
    [Arguments]    ${cell_list}
    @{cell_status_list}    create list
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        run keyword and ignore error    Set variable    ${status['operationalState']}
        run keyword and ignore error    Append To List    ${cell_status_list}    ${status['operationalState']}
    END

Get All Cells Onair Status
    [Arguments]    ${cell_list}
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        ${output}    convert to string    ${status}
        Run Keywords
        ...      Should Be Equal   ${status['blockingState']}   Unblocked   AND
        ...      should not contain    ${output.lower()}    degraded    AND
        ...      Should Be Equal   ${status['operationalState']}   enabled
    END

COAM Check BTS All RU Status
    [Arguments]   ${connection}=${connection}
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{ru_status_list}    create list
    FOR  ${ru}  IN  @{list_RUs}
        ${status}   Set Variable   ${ru['status']}
        run keyword and ignore error    Set variable    ${status['operationalState']}
        run keyword and ignore error    Append To List    ${ru_status_list}    ${status['operationalState']}
    END


Check No Unexpected Active Alarm
    log to console    Check No Unexpected Active Alarm
    @{alarm info}    coam.get_alarms   timeout=60    connection=${connection}    detailed_output=False
    FOR    ${alarm}  IN      @{alarm info}
        Set Suite Variable    ${Active_FaultID}    ${alarm['faultId']}
        Should contain    ${ALLOWED_ALARMS}    '${alarm['faultId']}'
    END

Check No Unexpected History Alarm
    log to console    Check No Unexpected History Alarm
    @{alarm info}    coam.get_historic_alarms   timeout=60    load_history=True    connection=${connection}
    FOR    ${alarm}  IN      @{alarm info}
        Set Suite Variable    ${History_FaultID}    ${alarm['faultId']}
        Should contain    ${ALLOWED_ALARMS}    '${alarm['faultId']}'
    END

Case Setup
    log to console    \n in case setup stage
    Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
    Run Keyword And Ignore Error    robot_common_operations.Common case setup

case teardown
    log to console    \n in teardown stage
    Run Keyword And Ignore Error     admin_cli.teardown    connection=${connection}
    Run Keyword And Ignore Error     csn.Disconnect     connection=ute
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


Scf commission and wait on-air
    [Arguments]   ${scf_name}   ${connection}=${connection}
    log to console    \n scf commission and wait for on-air
    Conect to DU COAM
    admin_cli.perform_commissioning
    ...   scf_file=${scf_file_path}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
	sleep    60s
    ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
    ${alarm_status}    run keyword and return status    Check No expected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
    ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
    ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
    ${snapshot_file}    Run Keyword If    '${status}'=='fail'
    ...    Run Keyword And Ignore error    Collect snapshot logs
    [teardown]    Run Keyword And Ignore error    COAM Logout


Get program version
    [Documentation]    Author: Ding Binmei
    ...                Description: Change the implementation to get program info from GNB.
    ...                Retrun with ${program_version}, valid output: 19A, 19B, 20B, master, ...
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    ${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    [Return]    ${program_version}

Set PA prepare
    @{channels}=    create list    9    10    11    12
    Modify HBTE Channel Vaules    channels=${channels}    value=20    ru_id=1    gnb_id=0

Modify HBTE Channel Vaules
    [Arguments]    ${channels}    ${value}=63    ${ru_id}=0    ${gnb_id}=0
    #${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=HBTE
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}


Conect to DU COAM
    [Arguments]    ${connection}=${connection}
    coam.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}


Collect snapshot logs
    log to console    Collect snapshot logs
    sleep    20s
    #Run Keyword And Ignore Error    run    command=rm -rf ${TS_CASE_LOG_PATH}/*
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${snapshot_file}    set variable    Snapshot_MRBTS-${MRBTS_ID}_TL905_${timestamp_log}.zip
    admin_cli.collect_snapshot    target_file_name=${TEST_LOG_DIRECTORY}/${snapshot_file}      timeout=600    connection=COAM

Collect snapshot logs for fault 10
    log to console    Collect snapshot logs for fault10
    sleep    7min
    #Run Keyword And Ignore Error    run    command=rm -rf ${TS_CASE_LOG_PATH}/*
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${snapshot_file}    set variable    Snapshot_MRBTS-${MRBTS_ID}_TL905_${timestamp_log}.zip
    admin_cli.collect_snapshot    target_file_name=${TEST_LOG_DIRECTORY}/${snapshot_file}      timeout=600    connection=COAM


Check No expected Active Alarm
    log to console    Check No expected Active Alarm
    @{alarm info}    coam.get_alarms   timeout=60    connection=${connection}    detailed_output=False
    FOR    ${alarm}  IN      @{alarm info}
        Should contain    ${ALLOWED_ALARMS}    '${alarm['faultId']}'
     END

Check No expected History Alarm
    log to console    Check No expected History Alarm
    #Conect to DU COAM
    @{alarm info}    coam.get_historic_alarms   timeout=60    load_history=True    connection=${connection}
    FOR    ${alarm}  IN      @{alarm info}
        Should contain    ${ALLOWED_ALARMS}    '${alarm['faultId']}'
     END
     #Run Keyword And Ignore Error    COAM Logout

COAM Check All NR Cells Onair
    [Arguments]   ${connection}=COAM
    log to console     Check NR cells onair
    #Conect to DU COAM
    ${cell_list}   COAM Get Cell List   connection=${connection}
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        ${output}    convert to string    ${status}
        Run Keywords
        ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
        ...      should not contain    ${output.lower()}    degraded    AND
        ...      Should Be Equal   ${status['operationalState']}   enabled
    END

##########Block and Unblock Cell#############
Block NR and LTE cells for ${num} times
    log to console    Block NR and LTE cells for ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        Blog to console    Block and Unblock cells loop ${i}
        ${run_status}    run keyword and return status       Block NR and LTE Cell
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     'fail'
        BuiltIn.Exit For Loop If     ${fail_num}>=3
     END

Block NR and LTE Cell
    Conect to DU COAM
    ${nrcell}   coam.get_cells_info    cell_type=nr    connection=${connection}
    ${ltecell}   coam.get_cells_info    cell_type=lte    connection=${connection}
    FOR  ${cellinfo}   IN  @{nrcell}
        ${dist_Name}    set variable    ${cellinfo['id']['configuration']}
        log to console    Block NR cell
        COAM Block Cell    dist_name=${dist_Name}
        Wait Until Keyword Succeeds    15s   3s     Fault With Alarm Should Be Present
         ...    FaultID=${49}    AlarmID=${7102}
         log to console    unblock NR cell
         wait until keyword succeeds   1min   10s    COAM Unblock Cell    dist_name=${dist_Name}
         Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
     END
     FOR  ${cellinfo}   IN  @{ltecell}
        ${dist_Name}    set variable    ${cellinfo['id']['configuration']}
        log to console    Block LTE cell
        COAM Block Cell    dist_name=${dist_Name}
        Wait Until Keyword Succeeds    15s   3s     Fault With Alarm Should Be Present
         ...    FaultID=${49}    AlarmID=${7102}
         log to console    Unblock LTE cell
         wait until keyword succeeds   1min   10s    COAM Unblock Cell    dist_name=${dist_Name}
         Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
     END
     [teardown]    Run Keyword And Ignore error    COAM Logout

###Site Reset ####
Site reset ${num} times
    log to console    Site reset ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Site Reset loop ${i}
        #wait until keyword succeeds   1min   2s    COAM Reset Site
        ${run_status1}    run keyword and return status     wait until keyword succeeds   5min   5s    COAM Reset Site without radio reset
        ${run_status2}    run keyword and return status     Wait Until Keyword Succeeds   15m   1m   COAM Check All NR Cells Onair
        ${run_status}  Evaluate  ${run_status1} and ${run_status2}
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

COAM Reset Site without radio reset
    [Documentation]   COAM Reset Site without radio reset And Wait For Reconnection.
    [Arguments]   ${wait_for_reconnection}=${True}    ${reset_without_ru}=${True}   ${connection}=COAM
    coam.reset_site   connection=${connection}    reset_without_ru=${reset_without_ru}
	...    wait_for_reconnection=${wait_for_reconnection}   timeout=${900}



###NR Reset####
NR reset ${num} times
    log to console    NR reset ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    NR Reset loop ${i}
        #Run Keyword And Ignore error    coam.rat_reset    rat_type=NR    connection=${connection}
        ${run_status1}    run keyword and return status     Run Keyword And Ignore error    COAM Reset RAT    rat_type=NR    connection=${connection}
        ${run_status2}    run keyword and return status     Wait Until Keyword Succeeds   15m   1m   COAM Check All NR Cells Onair
        ${run_status}  Evaluate  ${run_status1} and ${run_status2}
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout


###NR and LTE Reset####
LTE reset ${num} times
    log to console    LTE reset ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    LTE Reset loop ${i}
        Run Keyword And Ignore error    coam.reset_rat    rat_type=LTE    connection=${connection}
        sleep    5min
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     'fail'
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]   Run Keyword And Ignore error    COAM Logout

####Lock and Unlock cells#####
Lock NR and LTE cells for ${num} times
    log to console    Lock NR and LTE cells for ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Lock NR and LTE cells loop ${i}
        ${run_status}    run keyword and return status       Lock NR and LTE Cell
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     'fail'
        BuiltIn.Exit For Loop If     ${fail_num}>=3
     END
     [teardown]   Run Keyword And Ignore error    COAM Logout

Lock NR and LTE Cell
    Conect to DU COAM
    ${nrcell}   coam.get_cells_info    cell_type=nr    connection=${connection}
    ${ltecell}   coam.get_cells_info    cell_type=lte    connection=${connection}
    FOR  ${cellinfo}   IN  @{nrcell}
        ${dist_Name}    set variable    ${cellinfo['id']['configuration']}
        log to console    Lock NR cell
        COAM Lock Cell    dist_name=${dist_Name}
        log to console    unlock NR cell
        wait until keyword succeeds   1min   10s    COAM Unlock Cell   dist_name=${dist_Name}
        Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
     END
     FOR  ${cellinfo}   IN  @{ltecell}
        ${dist_Name}    set variable    ${cellinfo['id']['configuration']}
        log to console    Lock LTE cell
        COAM Lock Cell    dist_name=${dist_Name}
        log to console    Unlock LTE cell
        wait until keyword succeeds   1min   10s    COAM Unlock Cell    dist_name=${dist_Name}
        Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
     END
     [teardown]   Run Keyword And Ignore error    COAM Logout

##########Block and Unblock NR#############
Block and Unblock NR ${num} times
    log to console    Block and Unblock NR
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Block and Unblock NR loop ${i}
        Wait until keyword succeeds   10min   60s    coam.block_rat    rat=NR    connection=${connection}
        Wait Until Keyword Succeeds    15s   66ms     Fault With Alarm Should Be Present
        ...    FaultID=${4614}    AlarmID=${7102}
        Wait until keyword succeeds   10min   60s    coam.unblock_rat    rat=NR    connection=${connection}
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     'fail'
        BuiltIn.Exit For Loop If     ${fail_num}>=3
     END
     [teardown]    Run Keyword And Ignore error    COAM Logout


##########Block and Unblock LTE#############
Block and Unblock LTE ${num} times
    log to console    Block and Unblock LTE
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Block and Unblock LTE loop ${i}
        Wait until keyword succeeds   10min   60s    coam.block_rat    rat=LTE    connection=${connection}
        Wait Until Keyword Succeeds    15s   2s     Fault With Alarm Should Be Present
        ...    FaultID=${4614}    AlarmID=${7102}
        Wait until keyword succeeds   1min   2s    coam.unblock_rat    rat=LTE    connection=${connection}
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     'fail'
        BuiltIn.Exit For Loop If     ${fail_num}>=3
     END
     [teardown]    Run Keyword And Ignore error    COAM Logout

##########Block and Unblock site#############
Block and Unblock site ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        Conect to DU COAM
        log to console    Block and Unblock site ${i} times
        ${run_status1}    run keyword and return status     wait until keyword succeeds   1min   2s    site Block/Unblock
        ${run_status2}    run keyword and return status     Wait Until Keyword Succeeds   15m   1m   COAM Check All NR Cells Onair
        ${run_status}  Evaluate  ${run_status1} and ${run_status2}
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
        Run Keyword And Ignore error    COAM Logout
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout


site Block/Unblock
    [Arguments]   ${connection}=COAM
    coam.block   connection=${connection}   timeout=${600}
    coam.unblock   connection=${connection}   timeout=${600}



##########RU Power off/on#############
Power Reset gNB ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
       log to console    Power Reset gNB loop ${i}
       ${run_status}    Power Reset
       ${alarm_status}    run keyword and return status    Check No expected Active Alarm
       ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
       ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
       ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
       ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
       Append To List    ${result_list}    ${status}
       ${fail_num}     Collections.Count Values In List   ${result_list}     'fail'
       BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    Run Keyword And Ignore error    COAM Logout
    [teardown]    Run Keyword And Ignore error
    ...    pdu.power_on     port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...              pdu_device=du_pdu

Power Reset
    log to console    Power off DU
    pdu.setup_pdu    model=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    ...              host=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...              alias=du_pdu
    pdu.power_off    port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...              pdu_device=du_pdu
    sleep    3s
    log to console    Power on DU
    pdu.power_on     port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...              pdu_device=du_pdu
    Wait Until Keyword Succeeds   15m   1m   COAM Check All NR Cells Onair

##########RU Power off/on#############
RU Power Off and Power On ${num} times
    Conect to DU COAM
     @{result_list}    create list
    ${ru_num}    Get RU Number
    FOR   ${RMOD_ID}   IN RANGE   ${ru_num}
        RU Power ON and OFF    RMOD_ID=${RMOD_ID}
    END
    ${RMOD_ID}    BuiltIn.Evaluate    random.randint(0,${ru_num}-1)    random
    FOR   ${i}   IN RANGE   ${num}
       log to console    RU Power Off and Power On loop ${i}
       ${status}    RU Power ON and OFF    RMOD_ID=${RMOD_ID}
       Append To List    ${result_list}    ${status}
       ${fail_num}     Collections.Count Values In List   ${result_list}     ${False}
       BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    Run Keyword And Ignore error    COAM Logout
    [teardown]    Run Keyword And Ignore error    Power on RU ${RMOD_ID}

RU Power ON and OFF
    log to console    RU Power ON and OFF
    [Arguments]   ${RMOD_ID}
    Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
    wait until keyword succeeds   1min   20s    Power off RU ${RMOD_ID}
    Wait Until Keyword Succeeds    30s   5s     Fault With Alarm Should Be Present
    ...    FaultID=${10}    AlarmID=${7116}
    ${status1}    run keyword and return status    COAM Check All Cells availabilityStatus
    wait until keyword succeeds   3min   30s    Power on RU ${RMOD_ID}
    Wait Until Keyword Succeeds    10min    1min    Check fault Cancelled on WebEM
    ...    alarm_filter=${alarm_filter}
    ${status2}    run keyword and return status     Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
    ${status_list}    create list   ${status1}    ${status2}
    ${status}     run keyword and return status    Collections.List Should Not Contain Value    ${status_list}   ${False}
    ${snapshot_file}    Run Keyword If    ${status}==${False}
    ...    Run Keyword And Ignore error    Collect snapshot logs
    [Return]    ${status}

COAM Check All Cells availabilityStatus
    log to console    COAM Check All Cells availabilityStatus
    [Arguments]   ${connection}=COAM
    Conect to DU COAM
    ${cell_list}   COAM Get Cell List   connection=${connection}
    @{cell_status_list}    create list
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        run keyword and ignore error    Set variable    ${status['availabilityStatus']}
        run keyword and ignore error    Append To List    ${cell_status_list}    ${status['availabilityStatus']}
    END
    ${lte_cell_list}   COAM Get LTE Cell List    connection=${connection}
    FOR   ${cell}   IN   @{lte_cell_list}
        ${status}   Set Variable   ${cell['status']}
        run keyword and ignore error    Set variable    ${status['availabilityStatus']}
        run keyword and ignore error    Append To List    ${cell_status_list}    ${status['availabilityStatus']}
    END
    ${Degraded_num}     Collections.Count Values In List   ${cell_status_list}     degraded
    Should Be True    ${Degraded_num}==${4}


COAM Get LTE Cell List
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${cell_list}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']['lte']}
    ...   ELSE   Set Variable   ${bts_info['cells']['lte']}
    [Return]   ${cell_list}

Check fault Cancelled on WebEM
    [Arguments]    ${alarm_filter}
    COAM WEBUI Login
    @{alarm info}=    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=60
    should be empty    ${alarm_info}
    run keyword and ignore error    COAM WEBUI Logout

##########Power off/on RU#############
Power off RU ${index}
    log to console    Power off RU ${index}
    pdu.setup_pdu    model=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.pdu.vendor}
    ...              host=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.pdu.addr}
    ...              alias=ru_pdu_${index}
    pdu.power_off    port=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.port_no}
    ...              pdu_device=ru_pdu_${index}


Power on RU ${index}
    log to console    Power on RU ${index}
    pdu.setup_pdu    model=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.pdu.vendor}
    ...              host=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.pdu.addr}
    ...              alias=ru_pdu_${index}
    pdu.power_on     port=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.port_no}
    ...              pdu_device=ru_pdu_${index}

##########lock/unlock Cablink#############
RU Cablink Lock Unlock for ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU Cablink Lock Unlock loop ${i}
        ${run_status2}    run keyword and return status       Locked RU Cablink ${3}
        ${run_status3}    run keyword and return status       COAM Check All Cells availabilityStatus
        ${alarm_status}    run keyword and return status      Check No expected Active Alarm
        ${run_status5}    run keyword and return status       Unlocked RU Cablink ${3}
        ${status}    run keyword and return status       Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${run_status2}    run keyword and return status       Locked RU Cablink ${1}
        ${run_status3}    run keyword and return status       COAM Check All Cells availabilityStatus
        ${alarm_status}    run keyword and return status      Check No expected Active Alarm
        ${run_status5}    run keyword and return status       Unlocked RU Cablink ${1}
        ${status}    run keyword and return status       Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${run_status2}    run keyword and return status       Locked RU Cablink ${2}
        ${run_status3}    run keyword and return status       COAM Check All Cells availabilityStatus
        ${alarm_status}    run keyword and return status      Check No expected Active Alarm
        ${run_status5}    run keyword and return status       Unlocked RU Cablink ${2}
        ${status}    run keyword and return status       Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     'fail'
        BuiltIn.Exit For Loop If     ${fail_num}>=3
     END

${Operate} RU Cablink ${value}
    log to console    ${Operate} RU Cablink
    Conect to DU COAM
    coam.Perform Parameter Recommissioning
    ...   dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-${value}/LANE-1
    ...    parameter=administrativeState
    ...    value=${Operate}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    [teardown]    Run Keyword And Ignore error    COAM Logout

#####RU Power pff/on with L3 Call##############################
RU Power Off On ${num} times With L3 Call
    UE Prepare and UE attach
    UE Start DL UL Traffic
    Check DL and UL Throughput    exp_dl=${normal_dl_tp}    exp_ul=${normal_ul_tp}
    Conect to DU COAM
     @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU Power Off On With L3 Call loop ${i}
        wait until keyword succeeds   1min   20s    Power off RU ${3}
        Wait Until Keyword Succeeds    30s   5s     Fault With Alarm Should Be Present
        ...    FaultID=${10}    AlarmID=${7116}
        ${status1}    run keyword and return status    COAM Check All Cells availabilityStatus
        log to console    start check DL half TP
        ${half_tp_status}    run keyword and return status      Check DL and UL Throughput    exp_dl=${half_dl_tp}    exp_ul=${normal_ul_tp}
        Sleep    10s
        wait until keyword succeeds   3min   30s    Power on RU ${3}
        Wait Until Keyword Succeeds    10min    1min    Check fault Cancelled on WebEM
        ...    alarm_filter=${alarm_filter}
        ${status2}    run keyword and return status     Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
        log to console    start check DL full TP
        ${full_tp_status}    run keyword and return status     Check DL and UL Throughput    exp_dl=${normal_dl_tp}    exp_ul=${normal_ul_tp}
        ${status_list}    create list   ${status1}    ${status2}    ${half_tp_status}    ${full_tp_status}
        ${status}     run keyword and return status    Collections.List Should Not Contain Value    ${status_list}   ${False}
        ${snapshot_file}    Run Keyword If    ${status}==${False}
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     ${False}
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    Run Keyword And Ignore error    COAM Logout
    [teardown]    Run Keyword And Ignore error    Power on RU ${3}

#####RU Cbalink Lock/Unlock with L3 Call##############################
RU Cablink Lock Unlock for ${num} times With L3 Call
    UE Prepare and UE attach
    UE Start DL UL Traffic
    Check DL and UL Throughput    exp_dl=${normal_dl_tp}    exp_ul=${normal_ul_tp}
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU Cablink Lock Unlock With L3 Call for loop ${i}
        wait until keyword succeeds    1min    10s     Locked RU Cablink ${3}
        ${run_status1}    run keyword and return status       COAM Check All Cells availabilityStatus
        log to console    start check DL half TP
        ${half_tp_status}    run keyword and return status      Check DL and UL Throughput    exp_dl=${half_dl_tp}    exp_ul=${normal_ul_tp}
        ${alarm_status}    run keyword and return status      Check No expected Active Alarm
        log to console    start to unlock cablink
        wait until keyword succeeds    1min    10s    Unlocked RU Cablink ${3}
        ${run_status2}    run keyword and return status       Wait Until Keyword Succeeds   10m   1m   COAM Check All NR Cells Onair
        log to console    start check DL full TP
        ${full_tp_status}    run keyword and return status     Check DL and UL Throughput    exp_dl=${normal_dl_tp}    exp_ul=${normal_ul_tp}
        ${status_list}    create list   ${run_status1}    ${run_status2}    ${half_tp_status}    ${full_tp_status}
        ${status}     run keyword and return status    Collections.List Should Not Contain Value    ${status_list}   ${False}
        ${snapshot_file}    Run Keyword If    '${status}'==${False}
        ...    Run Keyword And Ignore error    Collect snapshot logs
        ${fail_num}     Collections.Count Values In List   ${result_list}     ${False}
        BuiltIn.Exit For Loop If     ${fail_num}>=3
     END
     Run Keyword And Ignore error    COAM Logout
     [teardown]    Run Keyword And Ignore error    Unlocked RU Cablink ${3}
########cell add/delete#####
delete cell
    log to console     Delete cell
    ADMIN Perform Delta Recommissioning                 delta_file=cell_deletion.json
    ...                                                 skip_parameter_relation_errors=True
    ${status}    run keyword and return status     Wait Until Keyword Succeeds   2m   10s   COAM Check All NR Cells Onair
    log to console     Delete cell success


add cell
    log to console     Add cell
    ADMIN Perform Delta Recommissioning                 delta_file=cell_addtion.json
    ...                                                 skip_parameter_relation_errors=True
    ${status}    run keyword and return status     Wait Until Keyword Succeeds   4m   10s   COAM Check All NR Cells Onair
    #${snapshot_file}    Run Keyword If    '${status}'=='False'
    #...    Run Keyword And Ignore error    Collect snapshot logs
    log to console     Add cell success

Delete and add cells in ${num} loops
    Conect to DU COAM
    FOR   ${i}   IN RANGE   ${num}
        add cell
        sleep    10s
        delete cell
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
    END

    [teardown]    Run Keyword And Ignore error    COAM Logout



ADMIN Perform Delta Recommissioning
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=${False}
    ...            ${should_activate}=${True}
    ...            ${timeout}=300
    ...            ${connection}=${connection}
    coam.Perform Delta Recommissioning
    ...                                        delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}


Modify the normal cell to slim cell 49.5MHz
    [Arguments]    ${key_dl}    ${key_ul}    ${value}   ${cell_ID}
    log to console    Modify the normal cell to slim cell 49.5MHz
    ${slimRfFilterDL}    Create Dictionary    parameterName=${key_dl}   value=${value}  operation=update
    ${slimRfFilterUL}    Create Dictionary    parameterName=${key_ul}    value=${value}    operation=update
    @{slimstatus}    Create List    ${slimRfFilterDL}    ${slimRfFilterUL}
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_ID}
    ...    parameter=${slimstatus}    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

Extract Permanent from snapshot
    [Arguments]    ${snapshot_file}
    Log To Console    ExtractSnapshot_Started
    ${timestamp}    Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${zipout}    Set Variable    zipout_${timestamp}
    run     mkdir ${TS_CASE_LOG_PATH}
    run     mkdir ${TS_CASE_LOG_PATH}/${zipout}
    run     mkdir ${TS_CASE_LOG_PATH}/soap
    Log To Console    ExtractSnapshot_Started
    Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
    ${BTS_part_logs}=    Run    find ${TS_CASE_LOG_PATH}/${zipout} -name BTS_part*.zip | xargs mv -t ${TS_CASE_LOG_PATH}/soap
    ${log_file}    OperatingSystem.List Files In Directory    ${TS_CASE_LOG_PATH}/soap    BTS_part*.zip
    FOR    ${item}    IN     @{log_file}
        Extract Zip File    ${TS_CASE_LOG_PATH}/soap/${item}    ${TS_CASE_LOG_PATH}/soap
    END
    ${soap_log_file}    Run    find ${TS_CASE_LOG_PATH}/soap -name BTS_*UnitOAM_SOAP_Log.zip
    Extract Zip File    ${soap_log_file}    ${TS_CASE_LOG_PATH}/soap
    ${log_path}=    Run    find ${TS_CASE_LOG_PATH}/soap -name UnitOAM_SOAP_Log*.xml.gz
    ${soap_log_path}=    Run    gunzip ${log_path} && find ${TS_CASE_LOG_PATH}/soap -name UnitOAM_SOAP_Log*.xml

Check Soap log
    [Arguments]    ${distName}    ${expected_bandwidth}
    ${carrier_info_dict}    soapp.get_carrier_info    log_path=${TS_CASE_LOG_PATH}/soap/UnitOAM_SOAP_Log0.xml    distName_value=${distName}
    ${convert_carrier_info_dict}    soapp.tansfer_carrier_info_to_webUI_format    carrier_info_dict=${carrier_info_dict}
    ${value}    Get From Dictionary      ${convert_carrier_info_dict}    channels
    ${bandwidth}    Get From Dictionary      ${value}     bandwidth
    should be equal          ${bandwidth}    ${expected_bandwidth}


###RU Reset ####
RU reset ${num} times
    log to console    RU reset ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU reset loop ${i}
        Conect to DU COAM
        ${run_status1}    run keyword and return status     Reset RU reset
        ${run_status2}    run keyword and return status     Wait Until Keyword Succeeds   15m   1m   COAM Check All NR Cells Onair
        ${run_status}  Evaluate  ${run_status1} and ${run_status2}
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

Reset RU reset
    ${ru_index_list}  Get All RU Index   connection=COAM
    FOR  ${rmod_index}  IN  @{ru_index_list}
        COAM Reset RMOD    dist_name=MRBTS-10462/EQM-1/APEQM-1/RMOD-${rmod_index}
    END

RU lock/unlock ${num} times
    log to console    RU lock/unlock ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU lock/unlock loop ${i}
        Conect to DU COAM
        ${run_status1}    run keyword and return status     RU lock/unlock with detal JSON
        ${run_status2}    run keyword and return status     Wait Until Keyword Succeeds   15m   1m   COAM Check All NR Cells Onair
        ${run_status}  Evaluate  ${run_status1} and ${run_status2}
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

RU lock/unlock
    ${ru_index_list}  Get All RU Index   connection=COAM
    FOR  ${rmod_index}  IN  @{ru_index_list}
        COAM Lock RU    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-${rmod_index}
    END
    FOR  ${rmod_index}  IN  @{ru_index_list}
        COAM Unlock RU    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-${rmod_index}
    END

RU lock/unlock with detal JSON
###cell Lock/unlock ####
    log to console    RU Lock
    admin_cli.perform_delta_recommissioning    delta_file=${LOCK_RU}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=COAM
    sleep    16s
    log to console    RU Unlock
    admin_cli.perform_delta_recommissioning    delta_file=${UNLOCK_RU}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=COAM
    sleep    2s


GNB_OAM Logout
    [Arguments]   ${connection}=GNB_OAM
    coam.teardown      connection=${connection}

###BBMOD Reset ####
BBMOD reset ${num} times
    log to console    BBMOD reset ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    BBMOD Reset loop ${i}
        Conect to DU COAM
        ${run_status1}    run keyword and return status    Reset BBMOD reset
        ${run_status2}    run keyword and return status     Wait Until Keyword Succeeds   15m   1m   COAM Check All NR Cells Onair
        ${run_status}  Evaluate  ${run_status1} and ${run_status2}
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

Reset BBMOD reset
    ${bbmod_index_list}  Get All BBmod Index    connection=COAM
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        COAM Reset BBMOD    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-${bbmod_index}
    END


###BBMOD Lock/unlock ####
BBMOD lock/unlock ${num} times
    log to console    BBMOD lock/unlock ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    BBMOD lock/unlock loop ${i}
        Conect to DU COAM
        ${run_status1}    run keyword and return status     BBMOD lock/unlock
        ${run_status2}    run keyword and return status     Wait Until Keyword Succeeds   15m   1m   COAM Check All NR Cells Onair
        ${run_status}  Evaluate  ${run_status1} and ${run_status2}
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

BBMOD lock/unlock
    ${bbmod_index_list}  Get All BBmod Index    connection=COAM
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        COAM Lock BBMOD    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-${bbmod_index}
    END
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        COAM Unlock BBMOD    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-${bbmod_index}
    END

cell lock/unlock ${num} times
###cell Lock/unlock ####
    log to console    cell Lock/unlock ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    cell Lock/unlock loop ${i}
        Conect to DU COAM
        ${run_status1}    run keyword and return status     cell lock/unlock
        ${run_status2}    run keyword and return status     Wait Until Keyword Succeeds   9m   1m   COAM Check All NR Cells Onair
        ${run_status}  Evaluate  ${run_status1} and ${run_status2}
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

cell lock/unlock
###cell Lock/unlock ####
    log to console    cell Lock
    admin_cli.perform_delta_recommissioning    delta_file=${LOCK_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=COAM
    sleep    15s
    log to console    cell Unlock
    admin_cli.perform_delta_recommissioning    delta_file=${UNLOCK_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=COAM
    sleep    2s


### CELL delete and add ####
CELL delete and add ${num} times
    log to console    CELL delete and add ${num} times
    @{result_list}    create list
    Conect to DU COAM
    FOR   ${i}   IN RANGE   ${num}
        log to console    CELL delete and add in loop ${i}
        ${run_status1}    run keyword and return status     Cell delete and status check
        ${run_status2}    run keyword and return status     Cell Add and status check
        ${status}	   Set Variable If    "${run_status1}"=="True" and "${run_status2}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

Cell delete
###Cell delete ####
    log to console    Cell delete
    admin_cli.perform_delta_recommissioning    delta_file=${DELETE_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=COAM
    sleep    15s

Cell delete and status check
    log to console    Cell delete
    ${run_status11}    run keyword and return status     Cell delete
    ${run_status12}    run keyword and return status     Wait Until Keyword Succeeds   9m   1m   COAM Check All NR Cells Onair
    ${run_status1}  Evaluate  ${run_status11} and ${run_status12}
    ${alarm_status}    run keyword and return status    Check No expected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
    ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
    ${status}	   Set Variable If    "${run_status1}"=="True" and "${alarm_status}"=="True"    pass    fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
    ${snapshot_file}    Run Keyword If    '${status}'=='fail'
    ...    Run Keyword And Ignore error    Collect snapshot logs

Cell add
###Cell add ####
    log to console    Cell add
    admin_cli.perform_delta_recommissioning    delta_file=${ADD_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=COAM
    sleep    15s

Cell Add and status check
    log to console    Cell add
    ${run_status21}    run keyword and return status     Cell add
    ${run_status22}    run keyword and return status     Wait Until Keyword Succeeds   9m   1m   COAM Check All NR Cells Onair
    ${run_status2}  Evaluate  ${run_status21} and ${run_status22}
    ${alarm_status}    run keyword and return status    Check No expected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
    ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
    ${status}	   Set Variable If    "${run_status2}"=="True" and "${alarm_status}"=="True"    pass    fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
    ${snapshot_file}    Run Keyword If    '${status}'=='fail'
    ...    Run Keyword And Ignore error    Collect snapshot logs

