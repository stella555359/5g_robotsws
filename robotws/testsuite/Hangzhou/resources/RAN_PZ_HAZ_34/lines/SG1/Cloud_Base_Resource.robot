*** Settings ***
Resource        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Library         taf.collectors.core   WITH NAME   core
Library         taf.collectors.btslog  WITH NAME   btslog
Library         taf.ul.oam_kpi_calculations.utilities
Library         ute_reporting_portal
Library         taf.rfrl.common_resources.oam_kpi.report_oam_kpi  WITH NAME   report_oam_kpi
Library         taf.ul.oam_kpi_calculations  WITH NAME  oam_kpi_calculations
Library         OperatingSystem
Library         taf.ul.vdu.helm                       WITH NAME    helm
Resource        taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource        taf/rfrl/bts/robot/common/gnb_cell.robot
Resource        taf/rfrl/bts/robot/common/gnb_ru.robot
Resource        taf/rfrl/bts/robot/common/gnb_log.robot

Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot

Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Documentation
...    Author:
...    Contact:
...    squad
...    Feature
*** Keywords ***
KW.ConvertDateTimeToTimeStamp
    [Arguments]    ${isotime}
    ${result}    ${last}    Split String From Right	 string=${isotime}   separator=.     max_split=1
    ${result}=     Replace String    ${result}    T   ${SPACE}
    ${result}    DateTime.Convert Date    ${result}    result_format=%s
    [Return]    ${result}
KW.vDUGetAndCheckAlarm
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${GnbReset}=False    ${startTimeStamp}=0
    ${connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459   61649    61618    61011    4590    4681
    Run Keyword if   '${GnbReset}' == 'True'    append to list    ${Fault_whitelist}    4592
    #${startTimeStamp}    KW.ConvertDateTimeToTimeStamp    ${startTime}
    ${active_alarm}     vdu.vdu_get_active_alarms    paging=${False}    vdu_connection=${connection}
    ${history_alarm}    vdu.vdu_get_historical_alarms    paging=${False}    vdu_connection=${connection}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm["alarms"]}
         ${appear_time}    KW.ConvertDateTimeToTimeStamp    ${item["appear_time"]}
         Run Keyword if   ${appear_time}<${startTimeStamp}    Continue For Loop
         ${fault_id}    get from dictionary    ${item}    fault_id
         append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm["alarms"]}
         ${appear_time}    KW.ConvertDateTimeToTimeStamp    ${item["appear_time"]}
         Run Keyword if   ${appear_time}<${startTimeStamp}    Continue For Loop
         ${fault_id}    get from dictionary    ${item}    fault_id
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    ${alarm_result}=    run keyword and return status    should be empty    ${unexpect_fault}
    [Return]    ${alarm_result}
    [Teardown]    KW.vDULogout   vdu_connection=${connection}

KW.vCUGetAndCheckAlarm
    [Arguments]    ${gnb_index}=0   ${GnbReset}=False    ${startTimeStamp}=0
    ${connection}    KW.vCULogin    gnb_index=${gnb_index}
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459   61649    61618    61011    4590    4681
    Run Keyword if   '${GnbReset}' == 'True'    append to list    ${Fault_whitelist}    4592
    #${startTimeStamp}    KW.ConvertDateTimeToTimeStamp    ${startTime}
    ${active_alarm}     cu.get_active_alarms    paging=${False}    connection=${connection}
    ${history_alarm}    cu.get_historical_alarms    paging=${False}    connection=${connection}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm["alarms"]}
         ${appear_time}    KW.ConvertDateTimeToTimeStamp    ${item["appear_time"]}
         Run Keyword if   ${appear_time}<${startTimeStamp}    Continue For Loop
         ${fault_id}    get from dictionary    ${item}    fault_id
         append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm["alarms"]}
         ${appear_time}    KW.ConvertDateTimeToTimeStamp    ${item["appear_time"]}
         Run Keyword if   ${appear_time}<${startTimeStamp}    Continue For Loop
         ${fault_id}    get from dictionary    ${item}    fault_id
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    ${alarm_result}=    run keyword and return status    should be empty    ${unexpect_fault}
    [Return]    ${alarm_result}
    [Teardown]    KW.vCULogout   connection=${connection}

KW.vCUGetActiveAlarm
    [Arguments]    ${gnb_index}=0   ${GnbReset}=False    ${startTimeStamp}=0
	log    ${GnbReset}
    ${connection}    KW.vCULogin    gnb_index=${gnb_index}
    ${active_alarm}     cu.get_active_alarms    paging=${False}    connection=${connection}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm["alarms"]}
         ${appear_time}    KW.ConvertDateTimeToTimeStamp    ${item["appear_time"]}
         Run Keyword if   ${appear_time}<${startTimeStamp}    Continue For Loop
         ${fault_id}    get from dictionary    ${item}    fault_id
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    [Return]    ${fault_id_list}
    [Teardown]    KW.vCULogout   connection=${connection}

KW.vDUGetActiveAlarm
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${GnbReset}=False    ${startTimeStamp}=0
	log    ${GnbReset}
    ${connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${active_alarm}     vdu.vdu_get_active_alarms    paging=${False}    vdu_connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{active_alarm["alarms"]}
         ${appear_time}    KW.ConvertDateTimeToTimeStamp    ${item["appear_time"]}
         Run Keyword if   ${appear_time}<${startTimeStamp}    Continue For Loop
         ${fault_id}    get from dictionary    ${item}    fault_id
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    [Return]    ${fault_id_list}
    [Teardown]    KW.vDULogout   vdu_connection=${connection}

#KW.vDUGetAlarms
#    [Arguments]    ${filterAlarmID}=''    ${gnb_index}=0    ${vdu_index}=0    ${history}=false
#    ${connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    ${activeAlarmDic}  run keyword if   '${history}'=='true'   vdu.vdu_get_historical_alarms    paging=${False}    vdu_connection=${connection}
#    ...    ELSE    vdu.vdu_get_active_alarms    paging=${False}    vdu_connection=${connection}
#    ${filterAlarmIDStr}    run keyword if   ${filterAlarmID}!=''    Split String    ${filterAlarmID}    ,
#    ...    ELSE    create list
#    ${len}    Get Length    ${filterAlarmIDStr}
#
#    ${filterAlarmIDs}    run keyword if   ${len}>0    Evaluate    list(map(int, ${filterAlarmIDStr}))
#    ...    ELSE    create list
#
#    ${filtered_alarms}    run keyword if   ${len}>0
#    ...    Evaluate    [alarm for alarm in @{activeAlarmDic["alarms"]} if alarm["alarm_id"] in @{filterAlarmIDs}]
#    ...    ELSE    set variable    ${activeAlarmDic["alarms"]}
#    [Return]    ${filtered_alarms}
#    [Teardown]    KW.vDULogout   vdu_connection=${connection}
#
#KW.vCUGetAlarms
#    [Arguments]    ${filterAlarmID}=''    ${gnb_index}=0   ${history}=false
#    ${connection}    KW.vCULogin    gnb_index=${gnb_index}
#    ${activeAlarmDic}  run keyword if   '${history}'=='true'   cu.get_historical_alarms    paging=${False}    connection=${connection}
#    ...    ELSE    cu.get_active_alarms    paging=${False}    connection=${connection}
#    ${filterAlarmIDStr}    run keyword if   ${filterAlarmID}!=''    Split String    ${filterAlarmID}    ,
#    ...    ELSE    create list
#    ${len}    Get Length    ${filterAlarmIDStr}
#
#    ${filterAlarmIDs}    run keyword if   ${len}>0    Evaluate    list(map(int, ${filterAlarmIDStr}))
#    ...    ELSE    create list
#
#    ${filtered_alarms}    run keyword if   ${len}>0
#    ...    Evaluate    [alarm for alarm in @{activeAlarmDic["alarms"]} if alarm["alarm_id"] in @{filterAlarmIDs}]
#    ...    ELSE    set variable    ${activeAlarmDic["alarms"]}
#    [Return]    ${filtered_alarms}
#    [Teardown]    KW.vCULogout   connection=${connection}

KW.CheckvCUCoreDump
    [Arguments]    ${gnb_index}=0
    ${conn_alias}    KW.connect_CU_server    gnb_index=${gnb_index}
    ${rawCoreDumps}    ssh.Execute    command=sudo coredumpctl list|grep present
    ...    connection=${conn_alias}
    ${result}    ssh.Execute    command=sudo coredumpctl list|grep present|awk '{print $2,$3}'
    ...    connection=${conn_alias}
    #${result}    run    cat /home/ute/TAF/test
    KW.disconnect_CU_server    conn_alias=${conn_alias}
    ${length}	 Get Length	   ${result}
    return from keyword if    ${result.count('No coredumps found')}>0 or ${length}==0
    ${coreDumps}    Split String    ${result}    \r\n
    ${current}    KW.GetCurrentTimeTick
    FOR    ${coreDump}    IN    @{coreDumps}
        ${timestamp} =    Convert Date    ${coreDump}    result_format=%s
        run keyword if    ${timestamp}>${loopStartTime}    run keywords
        ...    set test variable   ${loopStatus}    failed
        ...    AND    Fail    CoreDump is generated in this loop
    END

KW.CheckvDUCoreDump
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    ${conn_alias}    KW.connect_DU_server    gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${rawCoreDumps}    ssh.Execute    command=sudo coredumpctl list|grep present
    ...    connection=${conn_alias}
    ${result}    ssh.Execute    command=sudo coredumpctl list|grep present|awk '{print $2,$3}'
    ...    connection=${conn_alias}
    KW.disconnect_DU_server    conn_alias=${conn_alias}
    ${length}	 Get Length	   ${result}
    return from keyword if    ${result.count('No coredumps found')}>0 or ${length}==0
    ${coreDumps}    Split String    ${result}    \r\n
    ${current}    KW.GetCurrentTimeTick
    FOR    ${coreDump}    IN    @{coreDumps}
        ${timestamp} =    Convert Date    ${coreDump}    result_format=%s
        run keyword if    ${timestamp}>${loopStartTime}    run keywords
        ...    set test variable   ${loopStatus}    failed
        ...    AND    Fail    CoreDump is generated in this loop
    END

KW.vDUGetParmeters
    [Arguments]    ${mo_dn}    ${parameter}    ${gnb_index}=0    ${vdu_index}=0
    ${connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${parameters}    vdu.search_parameter_of_current_plan    mo_dn=${mo_dn}    para_name=${parameter}    vdu_connection=${connection}
    [Return]    ${parameters}
    [Teardown]    KW.vDULogout   vdu_connection=${connection}

KW.vDUSetParmeters
    [Arguments]    ${mo_dn}    ${parameter}    ${value}    ${gnb_index}=0    ${vdu_index}=0
    ${connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${jsonContent}=    Create Dictionary    distName=${mo_dn}    operation=update
    ${jsonParm}=    Create Dictionary    parameterName=${parameter}    value=${value}    operation=update
    ${jsonParms}=    Create List    ${jsonParm}
    Set To Dictionary    ${jsonContent}    parameters=${jsonParms}
    ${json_string}=    Convert To String    ${jsonContent}
    ${json_string}=     Replace String    ${json_string}    '   "
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=timestamp
    ${timestamp}    robot.libraries.DateTime.convert date    ${timestamp}    epoch
    ${timestamp}    evaluate    int(round(${timestamp} * 1000))

    Create File     ${LOG_PATH}/update_${timestamp}.json    [${json_string}]
    log to console    Start
    wait until keyword succeeds    5min    1min    vdu.perform_delta_recommissioning
    ...                            delta_file=${LOG_PATH}/update_${timestamp}.json    vdu_connection=${connection}
    [Teardown]    KW.vDULogout   vdu_connection=${connection}

KW.CheckCellStatus
    [Arguments]    ${cell_id}    ${operational_state}=nonee    ${availability_status}=nonee
    ...    ${administrative_state}=nonee    ${blocking_state}=nonee    ${procedural_status}=nonee     ${vdu_connection}=none
    log to console    ${procedural_status}
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${vdu_connection}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword if    '${cell_id}'!='${cell}[id]'    Continue For Loop
        Run keyword if  '${operational_state}'!='nonee'    Should Be Equal As Strings  ${cell["operational_state"]}    ${operational_state}
        Run keyword if  '${availability_status}'!='nonee'    Should Be Equal As Strings  ${cell["availability_status"]}    ${availability_status}
        Run keyword if  '${administrative_state}'!='nonee'    Should Be Equal As Strings  ${cell["administrative_state"]}    ${administrative_state}
        Run keyword if  '${blocking_state}'!='nonee'    Should Be Equal As Strings  ${cell["blocking_state"]}    ${blocking_state}
        #Should Be Equal As Strings  ${cell["procedural_status"]}    ${procedural_status}
    END

KW.vDUGetSnapshot
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    ${connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${snapshot}    vdu.Get_Local_Snapshot    ${LOG_PATH}    compressed_or_not=True
    log to console    vDU snapshot has been saved to ${snapshot}
    [Return]    ${snapshot}
    [Teardown]    KW.vDULogout   vdu_connection=${connection}

KW.vCUGetSnapshot
    [Arguments]    ${gnb_index}=0
    ${connection}    KW.vCULogin    gnb_index=${gnb_index}
    ${snapshot}    cu.Get_Local_Snapshot    ${LOG_PATH}    connection=${connection}
    log to console    vCU snapshot has been saved to ${snapshot}
    [Return]    ${snapshot}
    [Teardown]    KW.vCULogout   connection=${connection}

KW.vDULogin
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    ${vdu_connection}    vdu.connect to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    [Return]    ${vdu_connection}

KW.vCULogin
    [Arguments]   ${gnb_index}=0
    ${connection}    cu.connect to    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    [Return]    ${connection}
KW.vDULogout
    [Arguments]    ${vdu_connection}=None
    Run Keyword and Ignore Error    vdu.disconnect    vdu_connection=${vdu_connection}
KW.vCULogout
    [Arguments]    ${connection}=None
    Run Keyword and Ignore Error    cu.disconnect    connection=${connection}

KW.connect_CU_server
    [Arguments]   ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
#    ssh.Connect to    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
#    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
#    ...    alias=${conn_alias}
    ssh.Connect to    hostname=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...    username=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ...    alias=${conn_alias}
    [Return]    ${conn_alias}

KW.disconnect_CU_server
    [Arguments]   ${conn_alias}
    run keyword and ignore error    ssh.disconnect    connection=${conn_alias}

KW.connect_DU_server
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ...    alias=${conn_alias}
    [Return]    ${conn_alias}

KW.disconnect_DU_server
    [Arguments]   ${conn_alias}
    run keyword and ignore error    ssh.disconnect    connection=${conn_alias}

KW.GetCurrentTimeTick
    ${current_time}    Get Time    epoch
    ${current_tick}    Convert To Integer    ${current_time}
    [Return]    ${current_tick}