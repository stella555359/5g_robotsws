*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Liu Jia
...              Contact: jia-rebecca.liu@nokia-sbell.com
...              Already verified equipment: Multi pioneer Ues

Library     taf.ue.pioneer.client        WITH NAME      client
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/pioneer_dltraffic.py
Library     pioneer_dltraffic.Pioneer_DL_Traffic     WITH NAME    Pioneer_DL_Traffic
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot

*** Variables ***
${UEPC_host}                  ${tl.ues[0].ssh_connection_details.addr}
${UEPC_username}              ${tl.ues[0].ssh_connection_details.username}
${UEPC_password}              ${tl.ues[0].ssh_connection_details.password}
${app_address}                ${tl.appserver[1].ssh_connection_details.addr}
${DL_PORT}                    ${tl.ues[0].iperf_details.port}
${SA_atcommand}               AT+GTSET="5GSACTR",1
${SA_GTSET}                   AT+GTACT=14
${NSA_atcommand}              AT+GTSET="5GSACTR",0
${NSA_GTSET}                  AT+GTACT=17
${mPDU_atcommand}             at$qcrmcall=1,1
${NSA_ENDC}                   AT+QNWPREFCFG="mode_pref",LTE:NR5G
${SA_LOCK}                    AT+QNWPREFCFG="nr5g_disable_mode" ,1
${SA_NRONLY}                  AT+QNWPREFCFG="mode_pref",NR5G
${SA_UNLOCK}                  AT+QNWPREFCFG="nr5g_disable_mode" ,0
${ATI_Atcommand}                               ati

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare MultiUE with client
    [Arguments]    ${host}=${UEPC_host}    ${username}=${UEPC_username}
        ...    ${password}=${UEPC_password}    ${alias}=pioneer    ${ue_alias}=multiUE
        ...    ${until_timeout}=${300}    ${port}=30999
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    client.setup_service
    ...    host=${host}
    ...    port=${port}
    ...    ssh_username=${username}
    ...    ssh_password=${password}
    ...    alias=${alias}
    Run Keyword And Ignore Error    client.stoplog      service=${alias}
    Get imei_list from ue_infos    alias=${alias}
    ${ue_num}=    get length    ${imei_list}
    ${uegroup}    create list
    FOR    ${i}    IN RANGE     ${ue_num}
      client.require_ue    imei=${imei_list}[${i}]    service=${alias}    ue_alias=${ue_alias}${i}
      Append To List     ${uegroup}     ${ue_alias}${i}
    END
    Set Suite Variable    ${uegroup}
    Run Keyword And Ignore Error    client.poweroff     ue=${uegroup}    until_timeout=${until_timeout}
    sleep    5s
#    Run Keyword And Ignore Error    client.poweron     ue=${uegroup}    until_timeout=${until_timeout}
#    sleep    1min
#    Run Keyword And Ignore Error    client.detach    ue=${uegroup}    until_timeout=${until_timeout}    withpdu=1
#    sleep    5s
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    sleep    5s
    client.startlog    logpath=d:/pioneer_logs/${time_stamp}/    logname=ta_log    service=${alias}
    sleep    1s

Prepare pioneer_MultiUE new version
    [Arguments]    ${host}=${UEPC_host}    ${username}=${UEPC_username}
        ...    ${password}=${UEPC_password}    ${alias}=pioneer    ${ue_alias}=multiUE
        ...    ${until_timeout}=${300}    ${port}=30999    ${UE_mode}=5G_SA
        ...    ${timeout}=${600}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    client.setup_service     host=${host}
    ...                      port=${port}
    ...                      ssh_username=${username}
    ...                      ssh_password=${password}
    ...                      alias=${alias}
    ...                      timeout=${timeout}
    Run Keyword And Ignore Error    client.stoplog      service=${alias}
    Get imei_list from ue_infos    alias=${alias}
    ${ue_num}=    get length    ${imei_list}
    ${uegroup}    create list
    FOR    ${i}    IN RANGE     ${ue_num}
      client.require_ue    imei=${imei_list}[${i}]    service=${alias}    ue_alias=${ue_alias}${i}
      Append To List     ${uegroup}     ${ue_alias}${i}
    END
    Set Suite Variable    ${uegroup}
    FOR    ${m}    IN     @{uegroup}
        ${status_att}    check_dingli_multiUE_status_new    ue_alias=${m}    until_timeout=${until_timeout}
        run keyword if    ${status_att} == ${True}    client.poweroff    ue=${m}    until_timeout=${until_timeout}
    END
    ${ati_result}     client.sendat     command=${ATI_Atcommand}    until_timeout=${until_timeout}    ue=${uegroup}[0]
    ${ati_value}     Get Regexp Matches     ${ati_result}[Param][Back]     (.*?)Revision:    1
    Run Keyword If     'RG' in '${ati_value}[0]'
    ...     MAKE YiYuan_multiue set SA_NSA mode new    UE_mode=${UE_mode}    until_timeout=${until_timeout}
    ...     ELSE IF     'FM' in '${ati_value}[0]'
    ...     MAKE GuangHeTong_multiue set SA_NSA mode new    UE_mode=${UE_mode}    until_timeout=${until_timeout}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    sleep    5s
    client.startlog    logpath=d:/pioneer_logs/${time_stamp}/    logname=ta_log    service=${alias}
    sleep    1s

check_dingli_multiUE_status_new
    [Arguments]    ${ue_alias}    ${until_timeout}=${600}
    ${status}    client.get_attach_status    ue=${ue_alias}    until_timeout=${until_timeout}
    Run Keyword If     '${status}[Param][AttachStatus]' == 'Attached'
    ...                client.poweroff     ue=${ue_alias}    until_timeout=${until_timeout}
    [Return]    ${status}




MAKE YiYuan_multiue set SA_NSA mode new
    [Arguments]     ${UE_mode}    ${until_timeout}
    FOR     ${n}    IN    @{uegroup}
      YY MULTIUE NSA_SA MODE HO     UE_mode=${UE_mode}     until_timeout=${until_timeout}      ue=${n}
    END

MAKE GuangHeTong_multiue set SA_NSA mode new
    [Arguments]     ${UE_mode}    ${until_timeout}
    FOR     ${n}    IN    @{uegroup}
      GHT MULTIUE NSA_SA MODE HO     UE_mode=${UE_mode}     until_timeout=${until_timeout}      ue=${n}
    END



################################## STEP2: UE ATTACH ##################################
MultiUE one Attach with client
    [Arguments]      ${UE_mode}=5G_SA    ${until_timeout}=${300}      ${ue_alias}=${uegroup}[0]     ${apn}=dxdata1
#    ...             ${manufacturer}=NULL
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue: for one UE, please set ${ue}=${uegroup}[0]
#    Run Keyword If    '${NRBTS_ID}' == '10175'
#    ...                GHT MULTIUE NSA_SA MODE HO    UE_mode=${UE_mode}     until_timeout=${until_timeout}     ue=${ue_alias}
#    ...      ELSE      YY MULTIUE NSA_SA MODE HO     UE_mode=${UE_mode}     until_timeout=${until_timeout}     ue=${ue_alias}
    ${ati_result}     client.sendat     command=${ATI_Atcommand}    until_timeout=${until_timeout}    ue=${ue_alias}
    ${ati_value}     Get Regexp Matches     ${ati_result}[Param][Back]     (.*?)Revision:    1
    Run Keyword If     'RG' in '${ati_value}[0]'
    ...     YY MULTIUE NSA_SA MODE HO     UE_mode=${UE_mode}     until_timeout=${until_timeout}      ue=${ue_alias}
    ...     ELSE IF     'FM' in '${ati_value}[0]'
    ...     GHT MULTIUE NSA_SA MODE HO     UE_mode=${UE_mode}     until_timeout=${until_timeout}      ue=${ue_alias}
    FOR    ${index}    IN RANGE      0    3
        ${attach_status}    Get MultiUE attach status    ue=${ue_alias}    until_timeout=${until_timeout}
        sleep    1s
        run keyword if    '${attach_status}' == 'Attached'
        ...     client.poweroff    ue=${ue_alias}    until_timeout=${300}

        sleep    2s
        client.poweron     ue=${ue_alias}    until_timeout=${until_timeout}
#        Run keyword if     "${manufacturer}" == "NULL"
#        ...    client.attach    uemode=${UE_mode}     ue=${ue_alias}    until_timeout=${until_timeout}
#        ...    ELSE    run keywords    client.poweroff     ue=${ue_alias}    until_timeout=${until_timeout}
#        ...    AND     sleep    2s
#        ...    AND    client.poweron     ue=${ue_alias}    until_timeout=${until_timeout}
        Run keyword and Ignore Error      client.sendat    command=${mPDU_atcommand}    until_timeout=${until_timeout}    ue=${ue_alias}
        sleep    15s
        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=${until_timeout}
        ...                                                                        apn=${apn}     ue=${ue_alias}
        Exit For Loop If    ${upd_info}[Param][State]==0
    END
    set suite variable    ${upd_info}
    set suite variable    ${${ue_alias}_IP}    ${upd_info}[Param][IP]

MultiUEs Attach with client
    [Arguments]    ${ue}=${uegroup}     ${until_timeout}=${300}    ${apn}=dxdata1    ${UE_mode}=5G_SA
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue: for multi UE, please set ${ue}=${uegroup}
    ${ue_num}      get length    ${uegroup}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        Run Keyword If    '${MRBTS_ID}' == '10175'
        ...                GHT MULTIUE NSA_SA MODE HO    UE_mode=${UE_mode}     until_timeout=${until_timeout}      ue=${uegroup}[${i}]
        ...      ELSE      YY MULTIUE NSA_SA MODE HO     UE_mode=${UE_mode}     until_timeout=${until_timeout}      ue=${uegroup}[${i}]
    END
    client.poweron     ue=${uegroup}    until_timeout=${until_timeout}
#    Run keyword if     "${manufacturer}" == "NULL"    client.attach    uemode=${UE_mode}     ue=${uegroup}    until_timeout=${until_timeout}
#    ...    ELSE    run keywords    client.poweroff     ue=${uegroup}    until_timeout=${until_timeout}
#    ...    AND     sleep    2s
#    ...    AND    client.poweron     ue=${uegroup}    until_timeout=${until_timeout}
    Run keyword and Ignore Error      client.sendat    command=${mPDU_atcommand}    until_timeout=${until_timeout}    ue=${uegroup}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        Run keyword and Ignore Error     client.sendat    command=${mPDU_atcommand}    until_timeout=${until_timeout}    ue=${uegroup}[${i}]
        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=${until_timeout}
        ...                                                                        apn=${apn}     ue=${uegroup}[${i}]
        should be true    ${upd_info}[Param][State]==0
        set suite variable    ${${uegroup}[${i}]_IP}    ${upd_info}[Param][IP]
    END

Dingli_single_multiUE attach without mode
    [Arguments]    ${ue_alias}=${uegroup}[0]    ${until_timeout}=${600}    ${apn}=dxdata2
    client.poweron     ue=${ue_alias}    until_timeout=${until_timeout}
    sleep    5s    reason=wait for UE attach
    ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=${until_timeout}
    ...                                                                        apn=${apn}     ue=${ue_alias}
    should be true    ${upd_info}[Param][State] == 0
    [Return]     ${upd_info}

Dingli_multiUEs attach without mode
    [Arguments]    ${ue_alias}=${uegroup}    ${until_timeout}=${600}
    client.poweron     ue=${ue_alias}    until_timeout=${until_timeout}

Dingli_single_multiUE detach with poweroff
    [Arguments]    ${ue_alias}=${uegroup}[0]    ${until_timeout}=${600}
    client.poweroff     ue=${ue_alias}    until_timeout=${until_timeout}

Dingli_multiUEs detach with poweroff
    [Arguments]    ${ue_alias}=${uegroup}    ${until_timeout}=${600}
    client.poweroff     ue=${ue_alias}    until_timeout=${until_timeout}

Dingli_single_multiUE_attach_new_version
    [Arguments]    ${ue_alias}=${uegroup}[0]    ${until_timeout}=${600}    ${apn}=weistatic
    ${attach_status}    Run Keyword And Return Status    client.poweron     ue=${ue_alias}    until_timeout=${until_timeout}
    Run Keyword If    '${attach_status}' == 'False'
    ...    run keywords    client.poweroff     ue=${ue_alias}    until_timeout=${until_timeout}
    ...    AND    sleep    30s
    ...    AND    client.poweron     ue=${ue_alias}    until_timeout=${until_timeout}
    sleep    5s    reason=wait for UE attach
    ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=${until_timeout}
    ...                                                                        apn=${apn}     ue=${ue_alias}
    should be true    ${upd_info}[Param][State] == 0
    [Return]     ${upd_info}


################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for verify attach
    Log    Already verified inside UE Attach.


################################## STEP3: START DATA TRANSFER ##################################

Start traffic with pioneer client
    [Arguments]    ${ue}=${uegroup}
    ...        ${protocol}=UDP    ${address}=${app_address}    ${port}=${DL_PORT}    ${testtime}=9999
    ...        ${buffersize}=0    ${packetsize}=1400    ${iperftype}=1    ${direction}=1
    ...        ${bandwidth}=1500000      ${threadcount}=5
    Run Keyword And Ignore Error    Stop clinet traffic    ue=${ue}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${0}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf3|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf3 -s -p ${port} &
    ...    connection=EPCAPP
    client.StartTraffic
    ...    protocol=${protocol}
    ...    address=${address}
    ...    port=${port}
    ...    testtime=${testtime}
    ...    buffersize=${buffersize}
    ...    packetsize=${packetsize}
    ...    iperftype=${iperftype}
    ...    direction=${direction}
    ...    bandwidth=${bandwidth}
    ...    threadcount=${threadcount}
    ...    ue=${ue}

Start UL Data Transfer with pioneer client
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    ...            ${ul_protocol}=UDP
    ...            ${ul_throughput}=2500000
    ...            ${ul_buffersize}=1024
    ...            ${packetsize}=1400
    ...            ${ue_index_in_tl}=${1}
    ...            ${refine_ue_port}=${None}
    ...            ${appserver_addr}=${tl.ues[${ue_index_in_tl}].iperf_details.ssh_connection_details.addr}
    Log To Console    ${\n}INFO:-- start to UL call --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    ${ue_port}    Set Variable If    '${refine_ue_port}'=='None'    ${tl.ues[${ue_index_in_tl}].iperf_details.port}    ${refine_ue_port}
    FOR    ${index}    IN    @{ues_index}
        Log To Console    ${\n}INFO:-- start to UL call for ${uegroup}[${index}]--
        Run Keyword And Continue On Failure    client.startultraffic
        ...    protocol=${ul_protocol}
        ...    address=${appserver_addr}
        ...    port=${ue_port}
        ...    testtime=9999
        ...    bandwidth=${ul_throughput}
        ...    buffersize=${ul_buffersize}
        ...    packetsize=${packetsize}
        ...    until_timeout=${300}
        ...    ue=${uegroup}[${index}]
        ${ue_port}    Evaluate    ${ue_port}+1
        Sleep   15sec
    END

Start MUE dltraffic with appserver
    [Arguments]    ${ue_addr}    ${dl_port}    ${dl_throughput}    ${dl_time}=9999    ${dl_length}=1400B
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${1}
    ...    ${seg_size}=${1180}    ${window}=2M
    wait until keyword succeeds    3x    10s     Start DL traffic via iperf on Appserver
    ...    ue_addr=${ue_addr}    dl_time=${dl_time}    dl_port=${dl_port}    dl_throughput=${dl_throughput}
    ...    dl_length=${dl_length}    appserver=${appserver}    protocol=${protocol}    ue_index=${ue_index}     process_num=${process_num}
    ...    seg_size=${seg_size}    window=${window}


Start multiUEs traffic with appserver
    [Arguments]    ${dl_tput_multiue}=${dl_tput_multiue}    ${DL_PORT}=${DL_PORT}    ${UE_define}=NULL    ${process_num}=${1}
    ${ue_len}    get length     ${uegroup}
    ${ue_num}    set variable if    '${UE_define}' == 'NULL'   ${ue_len}    ${UE_define}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        Start MUE dltraffic with appserver    ue_addr=${${uegroup}[${i}]_IP}     dl_port=${DL_PORT}    dl_throughput=${dl_tput_multiue}
        ...    process_num=${process_num}
        ${DL_PORT}    Evaluate    ${DL_PORT} + 100
    END

start dingli_UE Voice_Call
    [Arguments]    ${ue}    ${call_number}    ${call_connect_time}=${600}    ${call_duration}=${300}
    ...            ${longcall}=${True}    ${until_timeout}=${300}
    [Documentation]        call_connect_time: call keep timer
    ...                    call_duration:Call duration
    ...                    longcall:if set True, Call duration is not valid
    client.start_call    number=${call_number}
    ...                  connecttime=${call_connect_time}
    ...                  duration=${call_duration}
    ...                  longcall=${longcall}
    ...                  until_timeout=${until_timeout}
    ...                  ue=${ue}

stop dingli_UE Voice_Call
    [Arguments]    ${ue}    ${until_timeout}=${300}
    client.stop_test     ue=${ue}
    ...                  until_timeout=${until_timeout}



################################## STEP4: CHECK TRANSFER ##################################

Check one UE traffic with pioneer client
    [Arguments]    ${tput_target}    ${ue}=${uegroup}[0]    ${direction}=dl
    ${tput_dic}    client.getparammac    ue=${ue}
    ${tput_output}    run keyword if    '${direction}'=='ul'    Evaluate    ${tput_dic['Param']['MACUL']} / 1000 / 1000
    ...                 ELSE IF    '${direction}'=='dl'    Evaluate    ${tput_dic['Param']['MACDL']} / 1000 / 1000
    should be true    ${tput_output} > ${tput_target}
    [Return]    ${tput_output}

Check multiUEs traffic with pioneer client
    [Arguments]    ${tput_target}       ${direction}=dl    ${UE_define}=NULL
    ${ue_len}    get length     ${uegroup}
    ${ue_num}    set variable if    '${UE_define}' == 'NULL'    ${ue_len}    ${UE_define}
    FOR    ${i}    IN RANGE     0    ${ue_num}
      ${tput_dic}    client.getparammac    ue=${uegroup}[${i}]
      ${tput_output}    run keyword if    '${direction}'=='ul'    Evaluate    ${tput_dic['Param']['MACUL']} / 1000 / 1000
      ...                 ELSE IF    '${direction}'=='dl'    Evaluate    ${tput_dic['Param']['MACDL']} / 1000 / 1000
      should be true    ${tput_output} > ${tput_target}
    END

Check one multiUE traffic with aasyslog
    [Arguments]    ${target_throughput}     ${cellid}    ${direction}=DL    ${duration}=3m    ${gnb_index}=${0}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85
    ${list_of_cell_ids}    Create list    ${cellid}
    ${log_path}     __Standard Capturing Aasyslog Throughput     duration=${duration}    gnb_index=${gnb_index}
    ${output}    __Standard Check Aasyslog Throughput    direction=${direction}    log=${log_path}    cells=${list_of_cell_ids}
    ...    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    actCarrierAggregation=${False}
    ...    customized_log_name=${None}    cell_indiv_tput=${None}
    [Return]    ${output}

Check traffic with pioneer client with pioneer client
    [Arguments]    ${tput_target}    ${ues_index}=${${0},${1},${2},${3}}   ${direction}=ul
    Log To Console    ${\n}INFO:-- start to check ul tput --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        ${tput_dic}    Run Keyword And Continue On Failure    client.getparammac    ue=${uegroup}[${index}]
        ${tput_output}    run keyword if    '${direction}'=='ul'    Evaluate    ${tput_dic['Param']['MACUL']} / 1000 / 1000
        ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${tput_dic['Param']['MACDL']} / 1000 / 1000
        Run Keyword And Continue On Failure    should be true    ${tput_output} > ${tput_target}
    END

################################## STEP5: STOP DATA TRANSFER ##################################
Stop clinet traffic
    [Arguments]    ${ue}=${uegroup}    ${port}=${DL_PORT}
    ...    ${until_timeout}=${30}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${0}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf3|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    client.stop_test    ue=${ue}    until_timeout=${until_timeout}

Stop traffic with appserver
    [Arguments]     ${iperf_port}    ${appserver}=APPserver
    Close the iperf process on APPserver    port=${iperf_port}    appserver=${appserver}


Stop multiues traffic with appserver
    [Arguments]    ${appserver}=APPserver    ${DL_PORT}=${DL_PORT}    ${UE_define}=NULL
    ${ue_len}    get length     ${uegroup}
    ${ue_num}    set variable if    '${UE_define}' == 'NULL'   ${ue_len}    ${UE_define}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        Close the iperf process on APPserver    port=${DL_PORT}    appserver=${appserver}
        ${DL_PORT}    Evaluate    ${DL_PORT} + 100
    END

Stop UL Data Transfer with pioneer client
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    Log To Console    ${\n}INFO:-- start to stop call --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        Run Keyword And Continue On Failure    client.stopultraffic    until_timeout=${300}    ue=${uegroup}[${index}]
        Sleep   5sec
    END
################################## STEP6: UE DETACH ##################################

Detach MultiUE
    [Arguments]    ${ue}=${uegroup}[0]     ${until_timeout}=${300}
#    client.detach    ue=${ue}    until_timeout=${until_timeout}    withpdu=1
    client.poweroff     ue=${ue}    until_timeout=${until_timeout}

Detach MultiUEs
    [Arguments]    ${ue}=${uegroup}
    ${ue_num}      get length    ${ue}
    FOR    ${i}    IN RANGE     0    ${ue_num}
#        client.detach    ue=${ue}[${i}]    until_timeout=${300}    withpdu=1
        client.poweroff     ue=${ue}    until_timeout=${until_timeout}
    END

Detach MultiUE and stoplog
    [Arguments]    ${ue}=${uegroup}[0]     ${until_timeout}=${300}    ${alias}=pioneer
#    client.detach    ue=${ue}    until_timeout=${until_timeout}    withpdu=1
    client.poweroff     ue=${ue}    until_timeout=${until_timeout}
    client.stoplog      service=${alias}

Detach dingli_UE0 with poweroff
    [Arguments]    ${ue}=${uegroup}[0]     ${until_timeout}=${300}
    client.poweroff     ue=${ue}    until_timeout=${until_timeout}



################################# pioneer common keyword ################################
Get imei_list from ue_infos
    [Documentation]     get ue_imei info through prepare_ues
    [Arguments]    ${alias}=pioneer
    @{UEs_info}    client.prepare_ues    service=${alias}
    ${imei_list}    create list
    FOR    ${item}    IN    @{UEs_info}
      Append To List     ${imei_list}     ${item}[imei]
    END
    Remove values From List    ${imei_list}    ERROR
    Set Suite Variable    ${imei_list}


Combine UE Group
    log to console      Combine UE Group
    ${ue_num}    get length    ${imei_list}
    ${uegroup}    create list
    FOR    ${i}    IN RANGE    ${ue_num}
      client.require_ue    imei=${imei_list}[${i}]    service=${alias}    ue_alias=${ue_alias}${i}
      Append To List     ${uegroup}     ${ue_alias}${i}
    END
    Set Suite Variable    ${uegroup}


Get MultiUE attach status
    [Arguments]    ${ue}=${uegroup}    ${until_timeout}=${300}
    ${attach_status}    client.get_attach_status    ue=${ue}    until_timeout=${until_timeout}
    ${attach_info}=    set variable    ${attach_status['Param']['AttachStatus']}
    [Return]     ${attach_info}


one UE attach status
    [Arguments]    ${ue}=${uegroup}    ${until_timeout}=${300}
    ${attach_status}    client.get_attach_status    ue=${ue}    until_timeout=${until_timeout}
    ${attach_info}=    set variable    ${attach_status['Param']['AttachStatus']}
    [Return]     ${attach_info}

multiUEs attach status
    [Arguments]    ${ue}=${uegroup}    ${until_timeout}=${300}
    ${attach_status}    client.get_attach_status    ue=${ue}    until_timeout=${until_timeout}
    ${attach_info}=    set variable    ${attach_status['Param']['SubStates']}
    [Return]     ${attach_info}

YY MULTIUE NSA_SA MODE HO
    [Arguments]    ${UE_mode}=5G_SA     ${until_timeout}=${300}    ${ue}=multiUE0
    Run Keyword If    '${UE_mode}' == '5G_NSA'    Run Keywords
    ...    client.sendat    command=${NSA_ENDC}    until_timeout=${until_timeout}    ue=${ue}
    ...    AND    client.sendat    command=${SA_LOCK}    until_timeout=${until_timeout}    ue=${ue}
    ...    ELSE IF    '${UE_mode}' == '5G_SA'    Run Keywords
    ...    client.sendat    command=${SA_NRONLY}    until_timeout=${until_timeout}    ue=${ue}
    ...    AND    client.sendat    command=${SA_UNLOCK}    until_timeout=${until_timeout}    ue=${ue}


GHT MULTIUE NSA_SA MODE HO
    [Arguments]    ${UE_mode}=5G_SA     ${until_timeout}=${300}    ${ue}=multiUE0
    Run Keyword If    '${UE_mode}' == '5G_NSA'    Run Keywords
    ...    client.sendat    command=${NSA_atcommand}    until_timeout=${until_timeout}    ue=${ue}
    ...    AND    client.sendat    command=${NSA_GTSET}    until_timeout=${until_timeout}    ue=${ue}
    ...    ELSE IF    '${UE_mode}' == '5G_SA'    Run Keywords
    ...    client.sendat    command=${SA_atcommand}    until_timeout=${until_timeout}    ue=${ue}
    ...    AND    client.sendat    command=${SA_GTSET}    until_timeout=${until_timeout}    ue=${ue}
