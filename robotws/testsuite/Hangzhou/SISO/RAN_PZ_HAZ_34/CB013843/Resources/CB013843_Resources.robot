*** Settings ***
Documentation      author: Cheng Jiajing
...                contact: jiajing.1.cheng@nokia-sbell.com
...                This robot file is for CB013843

Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000829/Resources/5GC000829-Resource.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Library          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py
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

CB013843_T07_Unlock_Lane_for_Target_SFP_Object_under_BBMOD_where_RF_is_connected
    [Documentation]
    FOR  ${i}  IN RANGE  1  ${CASE_INPUT_CB013843['retry_times']}+1
        Log to console     Loop ${i}  start
        Wait until keyword succeeds    2min    20s    COAM_WebEM.Login
        AlarmWatchdog.add_allow_alarms    fault_id=10
        AlarmWatchdog.add_allow_alarms    fault_id=1815
        AlarmWatchdog.add_allow_alarms    fault_id=16
        AlarmWatchdog.add_allow_alarms    fault_id=4298
        AlarmWatchdog.add_allow_alarms    fault_id=1868
        AlarmWatchdog.add_allow_alarms    fault_id=61009
        Log to console     Loop ${i} Lock BBMOD4 SFP Lane
        KW.Lock_SFP_Lane_BBMOD4
        Run Keyword And Ignore error      Wait Until Keyword Succeeds    3min    20s    KW.CheckFault10
#        Wait Until Keyword Succeeds    10min    20s    KW.CheckFaultDisapear10
        sleep    10min
        AlarmWatchdog.remove_allow_alarms    fault_id=10
        Run Keyword And Ignore error      Wait Until Keyword Succeeds    3min    20s    KW.CheckFault16
        Wait Until Keyword Succeeds    3min    20s    KW.CheckFaultDisapear16
        AlarmWatchdog.remove_allow_alarms    fault_id=16
        Log to console     Loop ${i} Check Fault 1815
        Wait Until Keyword Succeeds    12min    20s    KW.CheckFault1815
    #    wait until keyword succeeds   5min   30s    COAM_Admin.CheckAllCellsOnair
        Log to console     Loop ${i} unLock SFP Lane
        KW.UnLock_SFP_Lane
        log to console    Check cells onair
        Wait Until Keyword Succeeds    3min    20s    KW.CheckFaultDisapear1815
        Run Keyword And Ignore error    COAM_WebEM.Logout
        wait until keyword succeeds   10min   30s    COAM_Admin.CheckAllCellsOnair
        AlarmWatchdog.remove_allow_alarms    fault_id=1815
        AlarmWatchdog.remove_allow_alarms    fault_id=4298
        AlarmWatchdog.remove_allow_alarms    fault_id=1868
        AlarmWatchdog.remove_allow_alarms    fault_id=61009
    END

KW.TestSuilt.Start_CB013843
    TestSuilt.Start
    Import Variables    ${CFGFILE_PATH}/TLConfiguration.py
    Basic.CheckVariableValid    var=CASE_INPUT_CB013843['retry_times']    default_value=1    is_digit=True
    set suite variable    ${OAM_TYPE}    COAM
    set suite variable    ${TLDelta_PATH_ON_GIT}    ${CFGFILE_PATH}
    gNB.FormatBTSID       MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}

KW.TestSuilt.Stop_CB013843
    robot_common_operations.Common Suite Teardown
    TestSuilt.Stop

TestCase.Start_CB013843
    [Documentation]    start with capture log
    TestCase.Start
#    CI_interface.Common Case Setup
    Run Keyword And Ignore Error    BtsLog.StartBTSlogCollection
    log to console     Case Start

Teardown Case_CB013843
#    robot_common_operations.Common Case Teardown
    TestCase.Stop
    Teardown case if case fail
    Run Keyword And Ignore error    btslog.stopbtslogcollectionandgetlog
    Run Keyword And Ignore error    KW.Teardown_UnLock_SFP_Lane_Recover

KW.Teardown_UnLock_SFP_Lane_Recover
    Wait until keyword succeeds    2min    20s    COAM_WebEM.Login
    Run Keyword And Ignore error    KW.UnLock_SFP_Lane
    Run Keyword And Ignore error    COAM_WebEM.Logout
    wait until keyword succeeds   15min   30s    COAM_Admin.CheckAllCellsOnair


KW.Lock_SFP_Lane_BBMOD4
    log to console    Start to Lock SFP
    selenium_coam.lock_lane_from_sfp    hw_name=BBMOD-4     object_name=RF1    lane_id=LANE-1
    selenium_coam.lock_lane_from_sfp    hw_name=BBMOD-4     object_name=RF5    lane_id=LANE-1
    selenium_coam.lock_lane_from_sfp    hw_name=BBMOD-4     object_name=RF9    lane_id=LANE-1

KW.Lock_SFP_Lane_BBMOD1
    log to console    Start to Lock SFP
    selenium_coam.lock_lane_from_sfp    hw_name=BBMOD-1     object_name=RF2    lane_id=LANE-1

KW.Lock_SFP_Lane_BBMOD2
    log to console    Start to Lock SFP
    selenium_coam.lock_lane_from_sfp    hw_name=BBMOD-2     object_name=RF7    lane_id=LANE-1

KW.UnLock_SFP_Lane
    log to console    Start to UnLock SFP
    selenium_coam.unlock_lane_from_sfp    hw_name=BBMOD-4     object_name=RF1    lane_id=LANE-1
    selenium_coam.unlock_lane_from_sfp    hw_name=BBMOD-4     object_name=RF5    lane_id=LANE-1
    selenium_coam.unlock_lane_from_sfp    hw_name=BBMOD-4     object_name=RF9    lane_id=LANE-1

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

KW.CheckFault1815
    [Arguments]    ${ExpectFaultName}=Not able to synchronize baseband bus   ${connection}=Trunk_roll_check
    ...   ${ExpectAlarmName}=BASE STATION INFORMATION
    ...   ${ExpectconfigObjectName_1}=MRBTS-430/EQM-1/HWTOP-1/CABLINK-111
    ...   ${ExpectconfigObjectName_2}=MRBTS-430/EQM-1/HWTOP-1/CABLINK-115
    ...   ${ExpectconfigObjectName_3}=MRBTS-430/EQM-1/HWTOP-1/CABLINK-119
    Log          ${ExpectFaultName}
    Log          ${ExpectAlarmName}
    run keyword if    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl
    ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
    ${active_alarm}    coam.get_active_alarms    connection=${connection}    timeout=${100}
    ${result1}    set variable    ${False}
    ${result2}    set variable    ${True}
    ${resultfull}    set variable    ${False}
    ${index}    set variable     ${0}
    FOR    ${item}    IN   @{active_alarm}
        ${Fault_id}      get from dictionary    ${item}    faultId
        ${Fault_name}    get from dictionary    ${item}    faultName
        ${Alarm_id}      get from dictionary    ${item}    alarmId
        ${Alarm_name}    get from dictionary    ${item}    alarmName
        ${configObjectName}     get from dictionary    ${item}     configObjectName
        ${result1}    set variable if   '${Fault_id}'=='1815' and '${Fault_name}'=='${ExpectFaultName}'    ${True}    ${False}
 #       ${result2}	  set variable if   '${Alarm_id}'=='7115' and '${Alarm_name}'=='${ExpectAlarmName}'    ${True}    ${False}
        ${result3}   Run Keyword And Return Status       Should Contain Any          ${configObjectName}
        ...            ${ExpectconfigObjectName_1}     ${ExpectconfigObjectName_2}     ${ExpectconfigObjectName_3}
        ${resultfull}	  set variable if   '${result1}'=='${True}' and '${result2}'=='${True}' and '${result3}'=='${True}'      ${True}    ${False}
        ${index}    set variable if   '${resultfull}'=='${True}'        ${index+1}          ${index}
    END
    should be true    '${index}'=='3'
    [Teardown]  coam.teardown    connection=${connection}

KW.CheckFault10
    [Arguments]    ${fault_name}=No connection to unit

    ${active_alarm}    selenium_coam.get_active_alarm_info
    ${history_alarm}    selenium_coam.get_history_alarm_info
    ${result1}    set variable    ${False}
    FOR    ${item}    IN   @{active_alarm}
        ${id}    get from dictionary    ${item}    Fault ID
        ${name}    get from dictionary    ${item}    Fault name
        ${result1}    set variable if   '${id}'=='10' and '${name}'=='${fault_name}'    ${True}    ${False}
        Exit For Loop If    '${result1}'=='${True}'
    END
    ${result2}    set variable    ${False}
    FOR    ${item}    IN   @{history_alarm}
        ${id}    get from dictionary    ${item}    Fault ID
        ${name}    get from dictionary    ${item}    Fault name
        ${result2}    set variable if   '${id}'=='10' and '${name}'=='${fault_name}'    ${True}    ${False}
        Exit For Loop If    '${result2}'=='${True}'
    END
    should be true    '${result1}'=='${True}' or '${result2}'=='${True}'

KW.CheckFault16
    [Arguments]    ${fault_name}=Unit synchronization failed
    ${active_alarm}    selenium_coam.get_active_alarm_info
    ${history_alarm}    selenium_coam.get_history_alarm_info
    ${result1}    set variable    ${False}
    FOR    ${item}    IN   @{active_alarm}
        ${id}    get from dictionary    ${item}    Fault ID
        ${name}    get from dictionary    ${item}    Fault name
        ${result1}    set variable if   '${id}'=='16' and '${name}'=='${fault_name}'    ${True}    ${False}
        Exit For Loop If    '${result1}'=='${True}'
    END
    ${result2}    set variable    ${False}
    FOR    ${item}    IN   @{history_alarm}
        ${id}    get from dictionary    ${item}    Fault ID
        ${name}    get from dictionary    ${item}    Fault name
        ${result2}    set variable if   '${id}'=='16' and '${name}'=='${fault_name}'    ${True}    ${False}
        Exit For Loop If    '${result2}'=='${True}'
    END
    should be true    '${result1}'=='${True}' or '${result2}'=='${True}'

KW.CheckFaultDisapear1815
   [Arguments]    ${connection}=Trunk_roll_check
   run keyword if    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
   ...    ELSE    Connect to gnb coam via ssl
   ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
   ${active_alarm}    coam.get_active_alarms    connection=${connection}    timeout=${100}
   FOR    ${item}    IN   @{active_alarm}
       ${Fault_id}      get from dictionary    ${item}    faultId
       Run Keyword if    '${Fault_id}'=='1815' or '${Fault_id}'=='61009'   Fail    fault 1815 not disapeared, keep checking
   END

KW.CheckFaultDisapear10
   ${res}    Run Keyword And Return Status    KW.Check_Fault_from_Active_Alarms   target_fault_id=10
   Should not be true    ${res}

KW.CheckFaultDisapear16
   ${res}    Run Keyword And Return Status    KW.Check_Fault_from_Active_Alarms   target_fault_id=16
   Should not be true    ${res}

KW.checkSomeCellsOnair
    [Documentation]   This kw is to check cells on non-failure cells are online in COAM
    [Arguments]     ${cell_index}=[1,2,3]
    Log to console    start to check cell status
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    FOR    ${cellindex}    IN     @{cell_index}
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cellindex}
        log    ${cell_info} and ${cell_info['Status']['Availability status']}
        Should be equal as strings
        ...      ${cell_info['Status']['Operational state']}    Enabled    ignore_case=${True}
    END
    Run Keyword And Ignore error   COAM_WebEM.Logout

