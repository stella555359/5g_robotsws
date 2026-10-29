*** Settings ***
Documentation      author: Bin Wang
...                 contact: bin.3.wang@nokia-sbell.com
...                This robot file is for CB012611

Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Library          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.sbts.oam.coam.admin  WITH NAME   coam
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
Library           SSHLibrary
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
*** Variables ***
${USER_LOG_DIR}        /opt/ute/Logs
${WTS_FILE_PATH}       ${tl.core.dir_path}
#${TS_CASE_LOG_PATH}      ${output_dir}
${SAVE LOG DIRECTORY}      ${output_dir}
@{timezone_list}      (GMT+8) Asia/Shanghai    (GMT+0) Europe/London
${if_pdl_check}    True

${UTE_IP}              ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}        ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}        ${tl.test_pc.default_ssh_connection_details.password}

${ASIK_LMP_IP_Secondary}    ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}

${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_LMP_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_LMP_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${WEBUI_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${distname}                 ${MRBTS_ID}/${NRBTS_ID}

${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${model}    ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}


##################define these variable for convenient############################
${ALIAS_ABIO}     abio
${ALIAS_ASIK}     asik
${ALIAS_ASIK_SLAVE}    asik_slave
${ALIAS_UTE}      ute
########################END of alias Define#######################################
${BTSSWServerPath}          https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
*** Keywords ***

CB012611_Site_reset_down_time
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB012611['loop_times']}
            ...  ${duration_target}=${CASE_INPUT_CB012611['duration_target']}
            ...  ${cell_index_e}=${CASE_INPUT_CB012611['cell_index_e']}
    Log to console    kill LokiA and LokiB to trigger fault252
    wait until keyword succeeds    1min    10s    SSH to SBTS and Execute Commands
    ...                                       host=${CASE_INPUT_CB012611['host']}
    ...                                       username=${CASE_INPUT_CB012611['username']}
    ...                                       password=${CASE_INPUT_CB012611['password']}
    ...                                       command1=${CASE_INPUT_CB012611['command1']}
    ...                                       command2=${CASE_INPUT_CB012611['command2']}
    Wait until keyword succeeds    2min    20s    COAM_WebEM.Login
    Wait Until Keyword Succeeds    2min    20s    Check fault report or not    fault_ID=${252}    alarm_ID=${7100}
    Run Keyword And Ignore error    COAM_WebEM.Logout
    log to console    Start to Reset site
    ${duration_KPI}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        log to console   Site reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.reset_site
        sleep    10s
        Run Keyword And Ignore error   COAM_WebEM.Logout
        wait until keyword succeeds   15min   30s    KW.checkSomeCellsOnair    cell_index=${cell_index_e}
        ${end_time}    Get Time    epoch
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}

TC.CB012611_RAT_Hard_reset_down_time
    [Documentation]     Test case is to test KPI10b RAT hard Reset down time when one loki HW failure
    [Arguments]  ${KPI10b_loop_times}=${CASE_INPUT_CB012611['KPI10b_loop_times']}
            ...  ${KPI10b_duration_target}=${CASE_INPUT_CB012611['KPI10b_duration_target']}
            ...  ${cell_index_e}=${CASE_INPUT_CB012611['KPI10b_cell_index_e']}
    Log to console    trigger I2C failure on Loki-A and check Fault 252
    KW.Trigger_I2C_failure
    Wait until keyword succeeds    2min    20s    COAM_WebEM.Login
#    Wait Until Keyword Succeeds    2min    20s    Check fault report or not    fault_ID=${252}    alarm_ID=${7100}
    Wait Until Keyword Succeeds    2min    20s    KW.CheckFault252
    Run Keyword And Ignore error    COAM_WebEM.Logout
    log to console    Start to Reset RAT
    ${duration_KPI10b}      set variable    0
    FOR  ${i}  IN RANGE  1  ${KPI10b_loop_times}+1
        log to console   Site reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   10s    selenium_sbts.reset_nr   with_hard=${True}    with_graceful=${False}
        sleep    10s
        Run Keyword And Ignore error   COAM_WebEM.Logout
        sleep  1min
        wait until keyword succeeds   25min   30s    KW.checkSomeCellsOnair    cell_index=${cell_index_e}
        ${end_time}    Get Time    epoch
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI10b}=    Evaluate    ${duration_tmp} + ${duration_KPI10b}
        Set test Variable    ${duration_KPI10b}    ${duration_KPI10b}
    END
    ${duration_KPI10b}    Evaluate   round(${duration_KPI10b}/${KPI10b_loop_times}, 2)
    Should be true     ${duration_KPI10b} < ${KPI10b_duration_target}

KW.TestSuilt.Start_CB012611
    TestSuilt.Start
    Import Variables    ${CFGFILE_PATH}/TLConfiguration.py
    set suite variable    ${OAM_TYPE}    COAM
    set suite variable    ${TLDelta_PATH_ON_GIT}    ${CFGFILE_PATH}
    gNB.FormatBTSID       MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}

SSH to SBTS and Execute Commands
    [Arguments]  ${host}=0.0.0.0
    ...          ${port}=22
    ...          ${username}=Null
    ...          ${password}=Null
    ...          ${command1}=Null
    ...          ${command2}=Null
    wait until keyword succeeds     60s    10s     SSHLibrary.Open Connection
    ...                host=${host}
    ...                port=${port}
    wait until keyword succeeds     60s    10s     SSHLibrary.Login
    ...                username=${username}
    ...                password=${password}
    ${output}=    SSHLibrary.Execute Command    ${command1}
    Sleep  10s
    ${output}=    SSHLibrary.Execute Command    ${command2}
    Sleep  10s
    SSHLibrary.close connection


KW.TestSuilt.Stop_CB012611
    robot_common_operations.Common Suite Teardown
    TestSuilt.Stop

Teardown Case_CB012611
    robot_common_operations.Common Case Teardown
    Teardown case if case fail
    Run Keyword And Ignore error    btslog.stopbtslogcollectionandgetlog
    KW.PowerResetgNBAndWaitCellOnAir

Teardown Case_KPI10b_CB012611
    robot_common_operations.Common Case Teardown
    Teardown case if case fail
    Run Keyword And Ignore error    btslog.stopbtslogcollectionandgetlog
    Run Keyword And Ignore error     KW.Restore_I2C_failure
    KW.PowerResetgNBAndWaitCellOnAir
    Sleep   300s

KW.PowerResetgNBAndWaitCellOnAir
    Wait until keyword succeeds   2min   20s    Power.ResetgNB
            ...    pdu_ip=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
            ...    Port_Number=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
            ...    model=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    wait until keyword succeeds   15min   30s    COAM_Admin.CheckAllCellsOnair

KW.Trigger_I2C_failure
    log to console  \n trigger loki I2C failure
    ssh.Connect to    hostname=${ASIK_IP}   username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}   alias=${ALIAS_ASIK}
    ssh.Connect to    hostname=fsp-1a   username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}   alias=${ALIAS_ABIO}
    ...          proxy=${ALIAS_ASIK}
    FOR   ${i}    IN RANGE    2    6
        log    ${i}
        ssh.execute    command=cd /sys/kernel/debug/oip-${i}-0054;echo 0x17 > addr    connection=${ALIAS_ABIO}
        sleep    3s
        ssh.execute    command=cd /sys/kernel/debug/oip-${i}-0054;echo 3 > data;cat data    connection=${ALIAS_ABIO}
    END
    run keyword and ignore error    ssh.disconnect    connection=${ALIAS_ABIO}
    run keyword and ignore error    ssh.disconnect    connection=${ALIAS_ASIK}
    [Teardown]     run keyword and ignore error    ssh.disconnect    connection=${ALIAS_ABIO}

KW.Restore_I2C_failure
    log to console  \n Restore loki I2C default value
    ssh.Connect to    hostname=${ASIK_IP}   username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}   alias=${ALIAS_ASIK}
    ssh.Connect to    hostname=fsp-1a   username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}   alias=${ALIAS_ABIO}
    ...          proxy=${ALIAS_ASIK}
    FOR   ${i}    IN RANGE    2    6
        log    ${i}
        ssh.execute    command=cd /sys/kernel/debug/oip-${i}-0054;echo 0x17 > addr       connection=${ALIAS_ABIO}
        sleep    3s
        ssh.execute    command=cd /sys/kernel/debug/oip-${i}-0054;echo 0 > data;cat data     connection=${ALIAS_ABIO}
    END
    run keyword and ignore error    ssh.disconnect    connection=${ALIAS_ABIO}
    run keyword and ignore error    ssh.disconnect    connection=${ALIAS_ASIK}
    [Teardown]     run keyword and ignore error    ssh.disconnect    connection=${ALIAS_ABIO}

Teardown case if case fail
    [Arguments]
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    log     ${TEST STATUS}
    run keyword if test failed    WEBUI.Collect snapshot
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache

GNB.kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

WEBUI.Collect snapshot
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

KW.CP_GetgNBType
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNb_CuType}    Set Variable   ${BTSInfo['gNbCuType']}
    [Return]   ${gNb_CuType}

Check fault report or not
    [Arguments]  ${fault_ID}=NULL    ${alarm_ID}=NULL    ${connection}=Trunk_roll_check
    run keyword if    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl
    ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
    @{expect_fault}    Create List    ${fault_ID}
    @{expect_alarm}    Create List    ${alarm_ID}
    ${active_alarms}    coam.get_active_alarms    connection=${connection}    timeout=${100}
    FOR   ${active_alarm}    IN   @{active_alarms}
            ${check_fault}    run keyword and return status    Collections.List Should Contain Value    ${expect_fault}
            ...    ${active_alarm['faultId']}
            Continue For Loop If    '${check_fault}'=='False'
            ${check_alarm}    run keyword and return status    Collections.List Should Contain Value    ${expect_alarm}
            ...    ${active_alarm['alarmId']}
            Should be true    '${check_alarm}'=='True'
    END
    [Teardown]  coam.teardown    connection=${connection}

KW.CheckFault252
    [Arguments]    ${ExpectFaultName}=Baseband Module Hardware Failure   ${connection}=Trunk_roll_check
    ...   ${ExpectAlarmName}=BASE STATION HARDWARE PROBLEM
    ...   ${ExpectAlarmInfo}=SoC_B:3
    run keyword if    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl
    ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
    ${active_alarm}    coam.get_active_alarms    connection=${connection}    timeout=${100}
    ${result1}    set variable    ${False}
    ${result2}    set variable    ${False}
    ${result3}    set variable    ${False}
    ${resultfull}    set variable    ${False}
    FOR    ${item}    IN   @{active_alarm}
        ${Fault_id}      get from dictionary    ${item}    faultId
        ${Fault_name}    get from dictionary    ${item}    faultName
        ${Alarm_id}      get from dictionary    ${item}    alarmId
        ${Alarm_name}    get from dictionary    ${item}    alarmName
#		${supplAlarmInfo}     Run Keyword And Ignore error      get from dictionary    ${item}     supplAlarmInfo
        ${result1}    set variable if   '${Fault_id}'=='252' and '${Fault_name}'=='${ExpectFaultName}'    ${True}    ${False}
        ${result2}	  set variable if   '${Alarm_id}'=='7100' and '${Alarm_name}'=='${ExpectAlarmName}'    ${True}    ${False}
        Log to console      ${ExpectAlarmInfo}
#		${result3}	  set variable if   '${supplAlarmInfo['1']}'=='${ExpectAlarmInfo}'    ${True}    ${False}
#		${resultfull}	  set variable if   '${result1}'=='${True}' and '${result2}'=='${True}' and '${result3}'=='${True}'    ${True}    ${False}
        ${resultfull}	  set variable if   '${result1}'=='${True}' and '${result2}'=='${True}'    ${True}    ${False}
        Exit For Loop If    '${resultfull}'=='${True}'
    END
    should be true    '${resultfull}'=='${True}'
    [Teardown]  coam.teardown    connection=${connection}

TestCase.Start_CB012611
    [Documentation]    start with capture log
    robot_common_operations.Common Case Setup    allowed_faults_ids=252,1868,10,4590
    CI_interface.Common Case Setup
    Run Keyword And Ignore Error    BtsLog.StartBTSlogCollection
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${Active_SW_version}    string.split string    string=${version}[Active]
    set suite variable    ${Active_SW_version}
    ${SW1}    string.split string    string=${version}[Active]    separator=_
    ${Active_SwVersion111}     convert to string    ${SW1}[-5]
    set suite variable    ${Active_SwVersion111}
    COAM_Admin.commission    ${CFGFILE_PATH}/${Active_SwVersion111}_SCF_with_CB012611.xml
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Ignore error   COAM_WebEM.Logout

KW.checkSomeCellsOnair
    [Documentation]   This kw is to check cells on non-failure loki are online in COAM
    [Arguments]     ${cell_index}=[2]
    Log to console    start to check cell status
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    FOR    ${cellindex}    IN     @{cell_index}
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cellindex}
        log    ${cell_info} and ${cell_info['Status']['Availability status']}
        Should be equal as strings
        ...      ${cell_info['Status']['Operational state']}    Enabled    ignore_case=${True}
    END
    Run Keyword And Ignore error   COAM_WebEM.Logout

