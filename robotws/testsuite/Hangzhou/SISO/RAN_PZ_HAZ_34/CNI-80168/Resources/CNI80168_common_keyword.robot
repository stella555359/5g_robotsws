*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Variables   ../TestData/CNI80168_variables.py
Library    ../lib/time_compare.py

Documentation
...    author: LinJiangjing
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${time_gap_max}    65
${time_gap_min}    50

*** Keywords ***
CNI-80168_01_ Alarm_7653 CELL FAULTY FOR NRCELL reporting_Critical_When_16to32_ pipes_Broken_made1
    # log in ru (default login node is node0)
    Connect to RU With Allocated IP
    # log in node2, excute the 1-4 cmd on node2
    ${cmds_ul}    Get values from specified List    origin_list=${AEQV_UL_CM}    index_start=${0}    index_end=${4}
    ${cmds_dl}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${0}    index_end=${4}
    Connect To Node Via RU Connection    node_id=2
    execute command on specified Node    node_id=2    cmd_list=${cmds_ul}
    execute command on specified Node    node_id=2    cmd_list=${cmds_dl}
    csn.Disconnect    connection=node_2
    csn.Disconnect    connection=RU
    sleep    65min
    # check fault 2922 and 2923 not reported after about 65 minutes
    Expect fault should absent    faultId=2922
    Expect fault should absent    faultId=2923
    [Teardown]    Run Keywords    Perform BTS Site Reset    AND    Sleep    60s
    ...    AND    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair

CNI-80168_02_ Alarm_7654 CELL OPERATION DEGRADED FOR NRCELL reporting _Major_ When_5to32_ pipes_Broken_made1
    ${supplAlarmInfo_2922}=    catenate    SEPARATOR=    The Massive MIMO Active Antenna connected to /MRBTS-1/RAT-1/RUNTIME_VIEW-1/M
    ...    RBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1 has 16 TX degraded pipe(s)
    ${supplAlarmInfo_2923}=    catenate    SEPARATOR=    The Massive MIMO Active Antenna connected to /MRBTS-1/RAT-1/RUNTIME_VIEW-1/M
    ...    RBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1 has 16 RX degraded pipe(s)
    # log in ru (default login node is node0)
    Connect to RU With Allocated IP
    # log in node2, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node2
    Connect To Node Via RU Connection    node_id=2
    execute command on specified Node    node_id=2    cmd_list=${AEQV_UL_CM}
    execute command on specified Node    node_id=2    cmd_list=${AEQV_DL_CM}
    csn.Disconnect    connection=node_2
    # log in node3, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node3
    Connect To Node Via RU Connection    node_id=3
    execute command on specified Node    node_id=3    cmd_list=${AEQV_UL_CM}
    execute command on specified Node    node_id=3    cmd_list=${AEQV_DL_CM}
    csn.Disconnect    connection=node_3
    csn.Disconnect    connection=RU
    # check fault reported after about 55-65 minutes later. fault should be checked with Alarm/Alarm ID/Fault ID/Fault name
    ${start_time}    get_current_time
    sleep    55min
    wait until keyword succeeds  15min  1min    Expected Fault And Alarm Should Be Present    FaultID=2922
    ...    FaultName=Antenna calibration error caused by transmission path (Tx) failure
    ...    AlarmID=7116    AlarmName=BASE STATION SERVICE PROBLEM
    ...    supplAlarmInfo=${supplAlarmInfo_2922}    StartTime=${start_time}
    wait until keyword succeeds  15min  1min    Expected Fault And Alarm Should Be Present    FaultID=2923
    ...    FaultName=Antenna calibration error caused by reception path (Rx) failure
    ...    AlarmID=7116    AlarmName=BASE STATION SERVICE PROBLEM
    ...    supplAlarmInfo=${supplAlarmInfo_2923}    StartTime=${start_time}
    [Teardown]    Run Keywords    Perform BTS Site Reset    AND    Sleep    60s
    ...    AND    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair

CNI-80168_03_ Alarm_7655 CELL NOTIFICATION FOR NRCELL reporting _Minor_When _3to4_ pipes_Broken_made1_backup
    ${supplAlarmInfo_2922}=    catenate    SEPARATOR=    The Massive MIMO Active Antenna connected to /MRBTS-1/RAT-1/RUNTIME_VIEW-1/M
    ...    RBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1 has 16 TX degraded pipe(s)
    ${supplAlarmInfo_2923}=    catenate    SEPARATOR=    The Massive MIMO Active Antenna connected to /MRBTS-1/RAT-1/RUNTIME_VIEW-1/M
    ...    RBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1 has 16 RX degraded pipe(s)
    # log in ru (default login node is node0)
    Connect to RU With Allocated IP
   # log in node2, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node2
    Connect To Node Via RU Connection    node_id=2
    execute command on specified Node    node_id=2    cmd_list=${AEQV_UL_CM}
    execute command on specified Node    node_id=2    cmd_list=${AEQV_DL_CM}
    csn.Disconnect    connection=node_2
    # log in node3, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node3
    Connect To Node Via RU Connection    node_id=3
    execute command on specified Node    node_id=3    cmd_list=${AEQV_UL_CM}
    execute command on specified Node    node_id=3    cmd_list=${AEQV_DL_CM}
    csn.Disconnect    connection=node_3
    # log in node4, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node4
    Connect To Node Via RU Connection    node_id=4
    execute command on specified Node    node_id=4    cmd_list=${AEQV_UL_CM}
    execute command on specified Node    node_id=4    cmd_list=${AEQV_DL_CM}
    csn.Disconnect    connection=node_4
    csn.Disconnect    connection=RU
    ${start_time}    get_current_time
    sleep    55min
    # check fault reported after about 55-65 minutes later. fault should be checked with Alarm/Alarm ID/Fault ID/Fault name
    wait until keyword succeeds  15min  1min    Expected Fault And Alarm Should Be Present    FaultID=2922
    ...    FaultName=Antenna calibration error caused by transmission path (Tx) failure
    ...    AlarmID=7116    AlarmName=BASE STATION SERVICE PROBLEM
    ...    supplAlarmInfo=${supplAlarmInfo_2922}    StartTime=${start_time}
    wait until keyword succeeds  15min  1min    Expected Fault And Alarm Should Be Present    FaultID=2923
    ...    FaultName=Antenna calibration error caused by reception path (Rx) failure
    ...    AlarmID=7116    AlarmName=BASE STATION SERVICE PROBLEM
    ...    supplAlarmInfo=${supplAlarmInfo_2923}    StartTime=${start_time}
    [Teardown]    Run Keywords    Perform BTS Site Reset    AND    Sleep    60s
    ...    AND    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair

CNI-80168_03_ Alarm_7655 CELL NOTIFICATION FOR NRCELL reporting _Minor_When _3to4_ pipes_Broken_made1
    Connect to Common Unit Master
    log to console    *******************scenario 1***********************************************
    log to console    log in ru (default login node is node0)
    Connect to RU With Allocated IP
    log to console    log in node2, excute the 1-4 cmd on node2
    ${cmds_ul}    Get values from specified List    origin_list=${AEQV_UL_CM}    index_start=${0}    index_end=${4}
    ${cmds_dl}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${0}    index_end=${8}
#    Connect To Node Via RU Connection    node_id=2    cmds_ul=${cmds_ul}    cmds_dl=${cmds_dl}
    execute command on specified Node    node_ip=192.168.101.3    cmd_list=${cmds_ul}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    execute command on specified Node    node_ip=192.168.101.3    cmd_list=${cmds_dl}
#    csn.Disconnect    connection=node_2
    csn.Disconnect    connection=RU
    sleep    70min
    log to console    check fault 2922 and 2923 not reported after about 70 minutes
    Expect fault should absent    faultId=2922
    Expect fault should absent    faultId=2923
    Run Keywords    Perform BTS Site Reset    AND    Sleep    60s
    ...    AND    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    ...    AND    csn.disconnect    connection=ASIK Master
    log to console    *******************scenario 2***********************************************
    Connect to Common Unit Master
    #${supplAlarmInfo_2922}=    catenate    SEPARATOR=    The Massive MIMO Active Antenna connected to /MRBTS-1/RAT-1/RUNTIME_VIEW-1/M
    #...    RBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1 has 16 TX degraded pipe(s)
    ${supplAlarmInfo_2922}=    catenate    SEPARATOR=    /RMOD_R-1 has 16 TX degraded pipe(s)
    #${supplAlarmInfo_2923}=    catenate    SEPARATOR=    The Massive MIMO Active Antenna connected to /MRBTS-1/RAT-1/RUNTIME_VIEW-1/M
    #...    RBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1 has 16 RX degraded pipe(s)
    ${supplAlarmInfo_2923}=    catenate    SEPARATOR=    /RMOD_R-1 has 16 RX degraded pipe(s)
    log to console    log in ru (default login node is node0)
    Connect to RU With Allocated IP
    log to console    log in node2, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node2
#    Connect To Node Via RU Connection    node_id=2
#    execute command on specified Node    node_id=2    cmd_list=${AEQV_UL_CM}
#    execute command on specified Node    node_id=2    cmd_list=${AEQV_DL_CM}
#    csn.Disconnect    connection=node_2
    execute command on specified Node    node_ip=192.168.101.3    cmd_list=${AEQV_UL_CM}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_0_8}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${0}    index_end=${8}
    execute command on specified Node    node_ip=192.168.101.3    cmd_list=${AEQV_DL_CM_0_8}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_9_16}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${8}    index_end=${16}
    execute command on specified Node    node_ip=192.168.101.3    cmd_list=${AEQV_DL_CM_9_16}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    log to console    log in node3, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node3
#    Connect To Node Via RU Connection    node_id=3
#    execute command on specified Node    node_id=3    cmd_list=${AEQV_UL_CM}
#    execute command on specified Node    node_id=3    cmd_list=${AEQV_DL_CM}
#    csn.Disconnect    connection=node_3
    execute command on specified Node    node_ip=192.168.101.4    cmd_list=${AEQV_UL_CM}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_0_8}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${0}    index_end=${8}
    execute command on specified Node    node_ip=192.168.101.4    cmd_list=${AEQV_DL_CM_0_8}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_9_16}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${8}    index_end=${16}
    execute command on specified Node    node_ip=192.168.101.4    cmd_list=${AEQV_DL_CM_9_16}
    log to console    check fault reported after about 55-65 minutes later
    ${start_time}    get_current_time
    sleep    55min
    wait until keyword succeeds  15min  1min    Expected Fault And Alarm Should Be Present    FaultID=2922
    ...    FaultName=Antenna calibration error caused by transmission path (Tx) failure
    ...    AlarmID=7116    AlarmName=BASE STATION SERVICE PROBLEM
    ...    supplAlarmInfo=${supplAlarmInfo_2922}    StartTime=${start_time}
    wait until keyword succeeds  15min  1min    Expected Fault And Alarm Should Be Present    FaultID=2923
    ...    FaultName=Antenna calibration error caused by reception path (Rx) failure
    ...    AlarmID=7116    AlarmName=BASE STATION SERVICE PROBLEM
    ...    supplAlarmInfo=${supplAlarmInfo_2923}    StartTime=${start_time}
    Run Keywords    Perform BTS Site Reset    AND    Sleep    60s
    ...    AND    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    ...    AND    csn.disconnect    connection=ASIK Master
    log to console    *******************scenario 3***********************************************
    Connect to Common Unit Master
#    ${supplAlarmInfo_2922_2}=    catenate    SEPARATOR=    The Massive MIMO Active Antenna connected to /MRBTS-1/RAT-1/RUNTIME_VIEW-1/M
#    ...    RBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1 has 24 TX degraded pipe(s)
#    ${supplAlarmInfo_2923_2}=    catenate    SEPARATOR=    The Massive MIMO Active Antenna connected to /MRBTS-1/RAT-1/RUNTIME_VIEW-1/M
#    ...    RBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1 has 24 RX degraded pipe(s)
    ${supplAlarmInfo_2922_2}=    catenate    SEPARATOR=    /RMOD_R-1 has 24 TX degraded pipe(s)
    ${supplAlarmInfo_2923_2}=    catenate    SEPARATOR=    /RMOD_R-1 has 24 RX degraded pipe(s)
    log to console    log in ru (default login node is node0)
    Connect to RU With Allocated IP
    log to console    log in node2, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node2
#    Connect To Node Via RU Connection    node_id=2
#    execute command on specified Node    node_id=2    cmd_list=${AEQV_UL_CM}
#    execute command on specified Node    node_id=2    cmd_list=${AEQV_DL_CM}
#    csn.Disconnect    connection=node_2
    execute command on specified Node    node_ip=192.168.101.3    cmd_list=${AEQV_UL_CM}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_0_8}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${0}    index_end=${8}
    execute command on specified Node    node_ip=192.168.101.3    cmd_list=${AEQV_DL_CM_0_8}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_9_16}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${8}    index_end=${16}
    execute command on specified Node    node_ip=192.168.101.3    cmd_list=${AEQV_DL_CM_9_16}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    log to console    log in node3, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node3
#    Connect To Node Via RU Connection    node_id=3
#    execute command on specified Node    node_id=3    cmd_list=${AEQV_UL_CM}
#    execute command on specified Node    node_id=3    cmd_list=${AEQV_DL_CM}
#    csn.Disconnect    connection=node_3
    execute command on specified Node    node_ip=192.168.101.4    cmd_list=${AEQV_UL_CM}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_0_8}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${0}    index_end=${8}
    execute command on specified Node    node_ip=192.168.101.4    cmd_list=${AEQV_DL_CM_0_8}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_9_16}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${8}    index_end=${16}
    execute command on specified Node    node_ip=192.168.101.4    cmd_list=${AEQV_DL_CM_9_16}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    log to console    log in node4, excute 8 cmds of AEQV_DL_CM and 8 cmds of AEQV_DL_CM  on node4
#    Connect To Node Via RU Connection    node_id=4
#    execute command on specified Node    node_id=4    cmd_list=${AEQV_UL_CM}
#    execute command on specified Node    node_id=4    cmd_list=${AEQV_DL_CM}
#    csn.Disconnect    connection=node_4
    execute command on specified Node    node_ip=192.168.101.5    cmd_list=${AEQV_UL_CM}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_0_8}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${0}    index_end=${8}
    execute command on specified Node    node_ip=192.168.101.5    cmd_list=${AEQV_DL_CM_0_8}
    csn.Disconnect    connection=RU
    Connect to RU With Allocated IP
    ${AEQV_DL_CM_9_16}    Get values from specified List    origin_list=${AEQV_DL_CM}    index_start=${8}    index_end=${16}
    execute command on specified Node    node_ip=192.168.101.5    cmd_list=${AEQV_DL_CM_9_16}
    csn.Disconnect    connection=RU
    ${start_time}    get_current_time
    sleep    55min
    log to console    check fault reported after about 55-65 minutes later
    wait until keyword succeeds  15min  1min    Expected Fault And Alarm Should Be Present    FaultID=2922
    ...    FaultName=Antenna calibration error caused by transmission path (Tx) failure
    ...    AlarmID=7116    AlarmName=BASE STATION SERVICE PROBLEM
    ...    supplAlarmInfo=${supplAlarmInfo_2922_2}    StartTime=${start_time}
    wait until keyword succeeds  15min  1min    Expected Fault And Alarm Should Be Present    FaultID=2923
    ...    FaultName=Antenna calibration error caused by reception path (Rx) failure
    ...    AlarmID=7116    AlarmName=BASE STATION SERVICE PROBLEM
    ...    supplAlarmInfo=${supplAlarmInfo_2923_2}    StartTime=${start_time}
    [Teardown]    Run Keywords    Perform BTS Site Reset    AND    Sleep    60s
    ...    AND    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    ...    AND    csn.disconnect    connection=ASIK Master

#Connect To Node Via RU Connection
#    [Arguments]    ${cmds_ul}    ${cmds_dl}    ${node_id}    ${nodes}=${Node}    ${ru_alias}=RU
#    ${nodes_length}    Get Length    ${nodes}
#    FOR    ${i}    IN RANGE    0    ${nodes_length}
#        ${node_ip}    run keyword if    ${Node[${i}]}[id]==${node_id}    set variable    ${Node[${i}]}[ip]
#        execute command on specified Node    node_ip=${node_ip}    cmd_list=${cmds_ul}
#        execute command on specified Node    node_ip=${node_ip}    cmd_list=${cmds_dl}
#        Exit For Loop If    '${node_ip}'!='${None}'
#    END
#    csn.connect to    hostname=${node_ip}
#    ...               username=${service_username}
#    ...               password=${service_password}
#    ...               alias=${node_alias}
#    ...               proxy=${ru_alias}

Connect To Node Via RU Connection
    [Arguments]    ${node_id}    ${node_alias}=node_${node_id}    ${nodes}=${Node}    ${ru_alias}=RU
    ${nodes_length}    Get Length    ${nodes}
    FOR    ${i}    IN RANGE    0    ${nodes_length}
        ${node_ip}    run keyword if    ${Node[${i}]}[id]==${node_id}    set variable    ${Node[${i}]}[ip]
        Exit For Loop If    '${node_ip}'!='${None}'
    END
    csn.connect to    hostname=${node_ip}
    ...               username=${root_username}
    ...               password=${root_password}
    ...               alias=${node_alias}
    ...               proxy=${ru_alias}

#execute command on specified Node
#    [Arguments]    ${node_id}    ${cmd_list}
#    FOR    ${cmd}    IN    @{cmd_list}
#        csn.execute    command=${cmd}    connection=node_${node_id}
#        sleep    1s
#    END

execute command on specified Node
    [Arguments]    ${node_ip}    ${cmd_list}
    csn.Send Command    command=which sudo    connection=RU
    Sleep    10s
    ${sudo}  csn.Read Output    connection=RU
    ${sudo}    Replace String    ${sudo}    \n    ${EMPTY}
    FOR    ${cmd}    IN    @{cmd_list}
#        cmd    set variable    ${node_ip} ${sudo} ${cmd}
        csn.Send Command    command=ssh ${node_ip} ${sudo} ${cmd}    connection=RU
        sleep    1s
    END

Expected Fault And Alarm Should Be Present
    [Arguments]  ${FaultID}     ${FaultName}    ${AlarmID}    ${AlarmName}    ${StartTime}    ${supplAlarmInfo}    ${alias}=GNB_OAM
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=${alias}
    ${len}    Get Length    ${active_alarms}
    ${fault_alarm_list}    Create List
    ${status_fault}    set variable    ${False}
    FOR    ${i}    IN RANGE    ${len}
        ${f_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        ${f_name}    Get From Dictionary    ${active_alarms[${i}]}    faultName
        ${a_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        ${a_name}    Get From Dictionary    ${active_alarms[${i}]}    alarmName
        ${appear_time}    Get From Dictionary    ${active_alarms[${i}]}    btsLastUpdateTime
        ${supplementary}    Run keyword and ignore error    Get From Dictionary    ${active_alarms[${i}]}    supplAlarmInfo
        ${fault_status}    Run keyword If    '${f_id}'=='${FaultID}' and '${f_name}'=='${FaultName}'    set variable    ${True}
        ${alarm_status}    Run keyword If    '${a_id}'=='${AlarmID}' and '${a_name}'=='${AlarmName}'    set variable    ${True}
        ${supplementary_status}    Run Keyword And Return Status    should contain    ${supplementary}[1]  ${supplAlarmInfo}
#        Run keyword If    '${fault_status}'=='${True}' and '${alarm_status}'=='${True}' and "${supplementary}[1]"=="${supplAlarmInfo}"
#        ...    run keywords    set status_fault to True    AND    exit for loop
        Run keyword If    '${supplementary_status}'=='${True}' and '${fault_status}'=='${True}' and '${alarm_status}'=='${True}'
        ...    run keywords    set status_fault to True    AND    exit for loop
    END
    ${appeared_time}    time_convert    time_original=${appear_time}
    ${time_gap}    run keyword if    '${status_fault}'=='True'    calculate_delta_minutes    time1=${StartTime}    time2=${appeared_time}    ELSE
    ...    set variable    ${0}
    should be true    ${time_gap_max}>=${time_gap}>=${time_gap_min}

Check No Unexpect Alarms
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}

set status_fault to True
    ${status_fault}    set variable    ${True}
    Set test variable      ${status_fault}

Modify risingTime Value In Json File
    [Arguments]    ${init_value}=999999999    ${target_value}=1000    ${ru_index}=1
    log to console    \n Modify Tdanger Value In Json File
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect To RU Via FHNET Container With Pointed Account    ru_username=rfsw    ru_password=gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    csn.Send command    command=${sudo} touch /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /cofi /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/cofi action fetch DECODED "faults.bin" "/run/faults.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.Send command  command=cat /run/faults.json | grep -i risingTime_ms    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} sed -i 's/"risingTime_ms": ${init_value},/"risingTime_ms": ${target_value},/g' /run/faults.json
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} cat /run/faults.json | grep -i risingTime_ms    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/cofi action store PERMANENT DECODED "faults.bin" "/run/faults.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.Send command    command=${sudo} reboot    connection=RU_${ru_index}
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    sleep    60s
    Wait Until Keyword Succeeds    20min    1min    RU Should Be Online    ru_index=${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Connect To RU Via FHNET Container With Pointed Account
    [Arguments]    ${container_alias}=Container    ${ru_alias}=RU
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...            ${ru_index}=${1}
    ...            ${coam_connection}=GNB_OAM
    ${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${coam_connection}
    ${ru_ip_addr}  Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${coam_connection}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    csn.connect to    hostname=${fhnet_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${asik_alias}
    Run Keyword    csn.connect to    hostname=${ru_ip_addr}    username=${ru_username}    password=${ru_password}
    ...    alias=${ru_alias}    proxy=${container_alias}
