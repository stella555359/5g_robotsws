*** Settings ***
Documentation
...   author: lixia tang
...   contact: lixia.tang@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB010969 in 5G25R1 program


Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Library           OperatingSystem
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf        WITH NAME    scf
Library           taf.sbts.oam.coam.admin   WITH NAME   coam
Library           taf.selenium.sbts  WITH NAME   selenium_coam
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.collectors.core   WITH NAME   core
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library           taf.hw.pdu           WITH NAME    pdu

*** Variables ***
${mrbts_ID_enb}        ${tl.enbs[0].instance_id}
${MRBTS_ID}                  ${tl.gnbs[0].instance_id}
${NRBTS_ID}                  ${tl.gnbs[0].global_bts_id}
${connection}    COAM
${ALLOWED_ALARMS}    '61524', '61652', '4654', '4655', '49', '4003', '50', '4592', '4614', '61649', '61675', '4334', '4420'

${TEST_LOG_DIRECTORY}    /home/ute/Case_Logs/CRT
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


${apn_addr}    wap2.nokia.com
${attach_mode}    5G_SA
${SA_UE_MODE}    SA
${SA_attach_mode}    5G_SA
${data_tranfer}     660Mbits/sec
${ul_duration}     20
${dl_duration}     20
${SA_nettype}    SA+NSA
${normal_dl_tp}    119
${normal_ul_tp}    12
${half_dl_tp}    65
${ue_type}    ${tl.ues[-1].capabilities[-1]}

${gNB_PB_IP}            ${tl.pdus[0].addr}
${gNB_PB_Port}          ${tl.pdus[0].port_numbers}
${PDU_LOGIN}            ${tl.pdus[0].login}
${PDU_PASSWORD}         ${tl.pdus[0].password}
${gNB_alias}            ASOG_PDU

${Exception_string}    fatality|SW_FAILURE|Spurious warm reset|coreDumpEnabled=true
${SCF_Path}    /home/ute/Case_Logs/CRT/SCF_backup.xml

*** Keywords ***

####case setup/teatdowm##############
Case Setup
    log to console    \n in case setup stage
    robot_common_operations.Common case setup    fail_with_alarms=False
    Check Testline Status after Upgrade

Case Teardown
    log to console    \n in teardown stage
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown

prepare for BTSLog
    log to console    \n prepare for BTSLog
    Start Btslog Collect
    ${btslog_name}    Stop Btslog Collect

Start Btslog Collect
    log to console    \n Start Btslog Collect
    [Arguments]    ${names}=btslog   ${btslog_path}=/opt/btslog/btslog
    ...            ${btslog_launcher_path}=/opt/btslog/btslog_launcher    #${log_dir}=/home/ute/btslog/
    Log To Console    \n ### Btslog Collect Start ###
    csn.Connect to    hostname=${ute_host}    username=${ute_name}    password=${ute_password}    alias=ute
    ${executor_test_vm}=  Create Dictionary
    ...  host=${ute_host}
    ...  user=${ute_name}
    ...  password=${ute_password}
    btslog.Create Btslog Collector    name=${names}    btslog_path=${btslog_path}
    ...                               btslog_launcher_path=${btslog_launcher_path}
    ...                               executor=${executor_test_vm}
    btslog.Set Suite Alias    ${names}
    core.Setup Collectors    names=${names}
    core.Start Collectors    names=${names}
    sleep    5s

Stop Btslog Collect
    log to console    \n Stop Btslog Collect
    [Arguments]    ${names}=btslog
    Log To Console    \n ### Btslog Collect Stop ###
    core.Stop Collectors    names=${names}
    core.Collect Collectors    names=${names}    target_dir=${TEST_LOG_DIRECTORY}
    core.Teardown Collectors    names=${names}
    ${btslog_name}    Join Path    ${TEST_LOG_DIRECTORY}    ${names}
    [Return]    ${btslog_name}

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
    Wait Until Keyword Succeeds    7min    1min    COAM Check All NR Cells Onair

Conect to DU COAM
    [Arguments]    ${connection}=${connection}
    coam.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}


Collect snapshot logs
    log to console    Collect snapshot logs
    ${sw_version} =     coam.get_sw_version    connection=${connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    Set variable
    ...    ${TEST_LOG_DIRECTORY}/Snapshot_${sw_version}_${timestamp}_Fault_${Active_FaultID}-${History_FaultID}.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}


Check No expected Active Alarm
    log to console    Check No expected Active Alarm
    @{alarm info}    coam.get_alarms   timeout=60    connection=${connection}    detailed_output=False
    FOR    ${alarm}  IN      @{alarm info}
    Set Suite Variable    ${Active_FaultID}    ${alarm['faultId']}
    Should contain    ${ALLOWED_ALARMS}    '${alarm['faultId']}'
    END

Check No expected History Alarm
    log to console    Check No expected History Alarm
    #Conect to DU COAM
    @{alarm info}    coam.get_historic_alarms   timeout=60    load_history=True    connection=${connection}
    FOR    ${alarm}  IN      @{alarm info}
        Set Suite Variable    ${History_FaultID}    ${alarm['faultId']}
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
        #...      should not contain    ${output.lower()}    degraded    AND
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
        ${status}       Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
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
         Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
     END
     FOR  ${cellinfo}   IN  @{ltecell}
        ${dist_Name}    set variable    ${cellinfo['id']['configuration']}
        log to console    Block LTE cell
        COAM Block Cell    dist_name=${dist_Name}
        Wait Until Keyword Succeeds    15s   3s     Fault With Alarm Should Be Present
         ...    FaultID=${49}    AlarmID=${7102}
         log to console    Unblock LTE cell
         wait until keyword succeeds   1min   10s    COAM Unblock Cell    dist_name=${dist_Name}
         Wait Until Keyword Succeeds   10m   10s   COAM Check All NR Cells Onair
     END
     [teardown]    Run Keyword And Ignore error    COAM Logout

Block NR cells for ${num} times
    log to console    Block NR cells for ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Block and Unblock cells loop ${i}
        ${run_status}    run keyword and return status       Block NR Cell
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

Block NR Cell
    Conect to DU COAM
    ${nrcell}   coam.get_cells_info    cell_type=nr    connection=${connection}
    FOR  ${cellinfo}   IN  @{nrcell}
        ${dist_Name}    set variable    ${cellinfo['id']['configuration']}
        log to console    Block NR cell
        COAM Block Cell    dist_name=${dist_Name}
        Wait Until Keyword Succeeds    15s   3s     Fault With Alarm Should Be Present
         ...    FaultID=${49}    AlarmID=${7102}
         log to console    unblock NR cell
         wait until keyword succeeds   1min   10s    COAM Unblock Cell    dist_name=${dist_Name}
         Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
     END

###Site Reset ####
Site reset ${num} times
    log to console    Site reset ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Site Reset loop ${i}
        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        wait until keyword succeeds   1min   2s    COAM Reset Site
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
        ${Syslog_result}    Check Exception in Syslog    log_file=${syslog_file}
        ...    filter_string=${Exception_string}
        Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR Cells Status
        Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR RU Status
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True" and "${Syslog_result}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5m   30s   COAM Check All NR Cells Onair
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

Check Exception in Syslog
    [Arguments]    ${log_file}    ${filter_string}
    ${status}    set variable    True
    ${syslog_file}    set variable    ${log_file.strip('./')}
    ${date}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${output}    OperatingSystem.Run
    ...    command=cat /tmp/btslog2/${syslog_file} | grep -E '${filter_string}'
    ${length}    Get Length    ${output}
    ${status}    set variable if    ${length}>0    False    True
    Run Keyword If    ${length}>0    log to console    -----Attention:There are ${filter_string} logs: ${length}
    Run Keyword If    ${length}>0    OperatingSystem.Run    command=cp /tmp/btslog2/${syslog_file} ${TEST_LOG_DIRECTORY}/SYSLOG_Crash_${date}.LOG
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    True
    ###collect logs if there is trs-vpp crash in syslog
    ${trsvpp_output}    OperatingSystem.Run
    ...    command=cat /tmp/btslog2/${syslog_file} | grep 'SW_FAILURE' | grep 'trs-vpp'
    ${length}    Get Length    ${trsvpp_output}
    Run Keyword If    ${length}>0    Run Keyword And Ignore Error    Execute VPPOPG Command and Download Result Files
    [Return]    ${status}

Execute VPPOPG Command and Download Result Files
    csn.Connect to    hostname=${DU_OAM_IP}    username=toor4nsn    password=oZPS0POrRieRtu    alias=bts
    csn.Upload File    local_path=/home/ute/CIENV/vppopg.sh    remote_path=/user/toor4nsn/vppopg.sh    connection=bts
    csn.execute    command=chmod 777 /user/toor4nsn/vppopg.sh    connection=bts
    csn.execute    command=rm /tmp/vppopg_console_ouput.log    connection=bts
    csn.execute    command=sh /user/toor4nsn/vppopg.sh    connection=bts
    ${date}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    csn.download_file    remote_path=/tmp/vppopg_console_ouput.log
    ...    local_path=${TEST_LOG_DIRECTORY}/vppopg_console_ouput_${date}.log   connection=bts
    sleep    2s
    csn.download_file    remote_path=/tmp/vpp_opg.log    local_path=${TEST_LOG_DIRECTORY}/vpp_opg_${date}.log    connection=bts
    sleep    2s
    [Teardown]    csn.disconnect    connection=bts

SCF Commission ${num} times
    log to console    SCF Commission ${num} times
    Conect to DU COAM
    coam.get_current_scf_file   local_dir_path=${TEST_LOG_DIRECTORY}   file_name=SCF_backup.xml   connection=${connection}   timeout=30
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    SCF Commission loop ${i}
        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    coam.perform_commissioning    scf_file=${SCF_Path}
        ...   skip_parameter_relation_errors=True   timeout=600   connection=${connection}
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
        Run Keyword If    '${run_status}'=='False'   Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR Cells Status
        Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR RU Status
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
        ${Syslog_result}    Run Keyword And Ignore error    Check Exception in Syslog    log_file=${syslog_file}
        ...    filter_string=${Exception_string}
        ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True" and "${Syslog_result[1]}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'   Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5m   30s   COAM Check All NR Cells Onair
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]   Run Keyword And Ignore error    COAM Logout

Reset Site without HWF ${num} Times
    log to console    Reset Site without HWF ${num} Times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    \n Reset Site without HWF loop ${i}
        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    wait until keyword succeeds   3min   2s    coam.reset_site
        ...    connection=${connection}    reset_without_ru=${True}
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
        Run Keyword If    '${run_status}'=='False'   Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR Cells Status
        Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR RU Status
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
        ${Syslog_result}    Run Keyword And Ignore error    Check Exception in Syslog    log_file=${syslog_file}
        ...    filter_string=${Exception_string}
        ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True" and "${Syslog_result[1]}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'   Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5m   30s   COAM Check All NR Cells Onair
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

###NR Reset####
NR reset ${num} times
    log to console    NR reset ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    NR Reset loop ${i}
        Run Keyword And Ignore error    coam.rat_reset    rat_type=NR    connection=${connection}    reset_type=Hard
        sleep    2min
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
        Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR Cells Status
        Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR RU Status
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5m   30s   COAM Check All NR Cells Onair
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
        Run Keyword And Ignore error    coam.rat_reset    rat_type=LTE    connection=${connection}
        sleep    5min
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
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
        ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
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
        Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
     END
     FOR  ${cellinfo}   IN  @{ltecell}
        ${dist_Name}    set variable    ${cellinfo['id']['configuration']}
        log to console    Lock LTE cell
        COAM Lock Cell    dist_name=${dist_Name}
        log to console    Unlock LTE cell
        wait until keyword succeeds   1min   10s    COAM Unlock Cell    dist_name=${dist_Name}
        Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
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
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
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
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
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

##########Block and Unblock site#############
Block and Unblock site ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Block and Unblock site loop ${i}
        COAM WEBUI Login
        Wait until keyword succeeds   1min   2s    selenium_coam.block_site
        Wait Until Keyword Succeeds    120s   20s     Fault With Alarm Should Be Present
        ...    FaultID=${50}    AlarmID=${7102}
        log to console    Unblock site
        Wait until keyword succeeds   1min   2s    selenium_coam.unblock_site
        COAM WEBUI Logout
        ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   2m   30s   COAM Check All NR Cells Onair
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
     END
     [teardown]    Run Keyword And Ignore error    COAM Logout

##########RU Operation#############
RU Reset Lock Reset Unlock for ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU Reset Lock Reset Unlock loop ${i}
        ${run_status}    run keyword and return status       run keyword and ignore error    RU Reset Lock Reset Unlock loop
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

RU Reset Lock Reset Unlock loop
    log to console    RU Reset Lock Reset Unlock loop
    Conect to DU COAM
    ${rmods}   coam.get_frm   connection=${connection}
    ${rf_num}   Get Length   ${rmods}
    FOR   ${index}    IN RANGE    ${rf_num}
        ${dist_name}   Set Variable   ${rmods[${index}]['id']['configuration']}
        log to console    Lock RU
        COAM Lock RU    dist_name=${dist_name}
        Wait Until Keyword Succeeds   2m   10s    COAM Check All Cells availabilityStatus
        log to console    Reset RU
        run keyword and ignore error    COAM Reset RMOD    dist_name=${dist_name}
        sleep    3min
        log to console    Unlock RU
        COAM Unlock RU    dist_name=${dist_name}
        sleep   20s
        Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

RU Reset for ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU Reset loop ${i}
        ${run_status}    run keyword and return status       run keyword and ignore error    RU Reset loop
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   2m   10s   COAM Check All NR Cells Onair
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
     END
     [teardown]    Run Keyword And Ignore error    COAM Logout

RU Reset loop
    log to console    RU Reset loop
    Conect to DU COAM
    ${rmods}   coam.get_frm   connection=${connection}
    ${rf_num}   Get Length   ${rmods}
    FOR   ${index}    IN RANGE    ${rf_num}
        ${dist_name}   Set Variable   ${rmods[${index}]['id']['configuration']}
        log to console    Reset RU
        run keyword and ignore error    COAM Reset RMOD    dist_name=${dist_name}
        #sleep    3min
        Wait Until Keyword Succeeds   2m   10s   COAM Check All NR Cells Onair
    END

RU Lock Unlock for ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU Lock Unlock loop ${i}
        ${run_status}    run keyword and return status       run keyword and ignore error    RU Lock Unlock loop
        ${alarm_status}    run keyword and return status    Check No expected Active Alarm
        ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
        ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
        ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   2m   10s   COAM Check All NR Cells Onair
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
     END
     [teardown]    Run Keyword And Ignore error    COAM Logout

RU Lock Unlock loop
    log to console    RU Lock Unlock loop
    Conect to DU COAM
    ${rmods}   coam.get_frm   connection=${connection}
    ${rf_num}   Get Length   ${rmods}
    FOR   ${index}    IN RANGE    ${rf_num}
        ${dist_name}   Set Variable   ${rmods[${index}]['id']['configuration']}
        log to console    Lock RU
        COAM Lock RU    dist_name=${dist_name}
        #Wait Until Keyword Succeeds   2m   10s    COAM Check All Cells availabilityStatus
        log to console    Unlock RU
        COAM Unlock RU    dist_name=${dist_name}
        sleep   20s
        Wait Until Keyword Succeeds   2m   10s   COAM Check All NR Cells Onair
    END

##########DU Power off/on#############
Power Reset gNB ${num} times
    Conect to DU COAM
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
       log to console    Power Reset gNB loop ${i}
       Power Reset DU
       sleep    300s
       ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   5m   10s   COAM Check All NR Cells Onair
       ${alarm_status}    run keyword and return status    Check No expected Active Alarm
       ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
       ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
       ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
       ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
       Run Keyword And Ignore error    Wait Until Keyword Succeeds   2m   10s   COAM Check All NR Cells Onair
       Append To List    ${result_list}    ${status}
       ${fail_num}     Collections.Count Values In List   ${result_list}     fail
       BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    Run Keyword And Ignore error    COAM Logout

Power Reset DU
    log to console    Power reset DU
    pdu.setup_pdu    model=FPFH
    ...              host=${gNB_PB_IP}
    ...              alias=${gNB_alias}
    ...              login=${PDU_LOGIN}
    ...              password=${PDU_PASSWORD}
    pdu.reset_ports    ports=${gNB_PB_Port}
    ...                time_interval=${30}
    ...                pdu_device=${gNB_alias}

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
    Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
    wait until keyword succeeds   1min   20s    Power off RU ${RMOD_ID}
    Wait Until Keyword Succeeds    30s   5s     Fault With Alarm Should Be Present
    ...    FaultID=${10}    AlarmID=${7116}
    ${status1}    run keyword and return status    COAM Check All Cells availabilityStatus
    wait until keyword succeeds   3min   30s    Power on RU ${RMOD_ID}
    Wait Until Keyword Succeeds    10min    1min    Check fault Cancelled on WebEM
    ...    alarm_filter=${alarm_filter}
    ${status2}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
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
        ${status}    run keyword and return status       Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${run_status2}    run keyword and return status       Locked RU Cablink ${1}
        ${run_status3}    run keyword and return status       COAM Check All Cells availabilityStatus
        ${alarm_status}    run keyword and return status      Check No expected Active Alarm
        ${run_status5}    run keyword and return status       Unlocked RU Cablink ${1}
        ${status}    run keyword and return status       Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${run_status2}    run keyword and return status       Locked RU Cablink ${2}
        ${run_status3}    run keyword and return status       COAM Check All Cells availabilityStatus
        ${alarm_status}    run keyword and return status      Check No expected Active Alarm
        ${run_status5}    run keyword and return status       Unlocked RU Cablink ${2}
        ${status}    run keyword and return status       Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
        ${snapshot_file}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect snapshot logs
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
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
        ${status2}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
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
        ${run_status2}    run keyword and return status       Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
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

Recommission from N type to M type
    log to console     Recommission from N type to M type
    Conect to DU COAM
    COAM WEBUI Login
    ADMIN Perform Delta Recommissioning                 delta_file=N_to_M_type.json
    ...                                                 skip_parameter_relation_errors=True
    ${status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
    ${snapshot_file}    Run Keyword If    '${status}'=='False'
    ...    Run Keyword And Ignore error    Collect snapshot logs
    COAM Logout
    [teardown]    Run Keyword And Ignore error    COAM WEBUI Logout

Recommission from M type to N type
    log to console     Recommission from M type to N type
    Conect to DU COAM
    COAM WEBUI Login
    ADMIN Perform Delta Recommissioning                 delta_file=M_to_N_type.json
    ...                                                 skip_parameter_relation_errors=True
    ${status}    run keyword and return status     Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
    ${snapshot_file}    Run Keyword If    '${status}'=='False'
    ...    Run Keyword And Ignore error    Collect snapshot logs
    COAM Logout
    [teardown]    Run Keyword And Ignore error    COAM WEBUI Logout

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

COAM Check All NR Cells Status
    [Arguments]   ${connection}=COAM
    ${cell_list}   COAM Get Cell List   connection=${connection}
    @{cell_status_list}    create list
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        run keyword and ignore error    Set variable    ${status['operationalState']}
        run keyword and ignore error    Append To List    ${cell_status_list}    ${status['operationalState']}
    END

COAM Check All NR RU Status
    [Arguments]   ${connection}=COAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{ru_status_list}    create list
    FOR  ${ru}  IN  @{list_RUs}
        ${status}   Set Variable   ${ru['status']}
        run keyword and ignore error    Set variable    ${status['operationalState']}
        run keyword and ignore error    Append To List    ${ru_status_list}    ${status['operationalState']}
    END

Check Testline Status after Upgrade
    Conect to DU COAM
    ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   7m   10s   COAM Check All NR Cells Onair
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR Cells Status
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check All NR RU Status
    ${alarm_status}    run keyword and return status    Check No expected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No expected History Alarm
    ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
    ${status}       Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
    ${snapshot_file}    Run Keyword If    '${status}'=='fail'
    ...    Run Keyword And Ignore error    Collect snapshot logs
    [teardown]    Run Keyword And Ignore error    COAM Logout
