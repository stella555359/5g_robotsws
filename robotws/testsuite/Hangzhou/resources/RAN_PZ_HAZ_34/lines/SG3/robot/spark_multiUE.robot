*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Liu Jia
...              Contact: jia-rebecca.liu@nokia-sbell.com
...              Already verified equipment: Multi pioneer Ues


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/Power_ue_supports/power_ue_throughput.robot
Library     taf.ue.spark.client       WITH NAME      spark_client

*** Variables ***
${UEPC_host}                  ${tl.ues[0].ssh_connection_details.addr}
${UEPC_username}              ${tl.ues[0].ssh_connection_details.username}
${UEPC_password}              ${tl.ues[0].ssh_connection_details.password}
${app_address}                ${tl.appserver[1].ssh_connection_details.addr}
${DL_PORT}                    ${tl.ues[0].iperf_details.port}
${enable_SAmode_command}      AT+QNWPREFCFG="nr5g_disable_mode",0
${disable_SAmode_command}     AT+QNWPREFCFG="nr5g_disable_mode",1
${SA_mode_pref}               AT+QNWPREFCFG="mode_pref",NR5G
${NSA_mode_pref}              AT+QNWPREFCFG="mode_pref",LTE:NR5G
${get_pduinfo_cmd}            AT+CGPADDR=1
*** Keywords ***
Spark_multiUE.prepare UE
    [Arguments]
    ...    ${spark_host}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${spark_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${spark_password}=${tl.ues[0].ssh_connection_details.password}
    ...    ${spark_port}=30999    ${spark_alias}=spark_ue
    ...    ${spark_logname}=spark_ta_log
    spark_client.setup_service    host=${spark_host}
    ...                           port=${spark_port}
    ...                           ssh_username=${spark_username}
    ...                           ssh_password=${spark_password}
    ...                           alias=${spark_alias}
    ${ues_info}    spark_client.prepare_ues      service=${spark_alias}
    ${ue_nums}    Get Length    ${ues_info}
    ${uegroup}    create list
#    Run Keyword And Ignore Error    spark_client.stoplog    service=${spark_alias}
    FOR    ${ue_i}    IN RANGE    ${ue_nums}
        spark_client.require_ue    imsi=${ues_info}[${ue_i}][imsi]    service=${spark_alias}    ue_alias=${ue_i}
        Append To List     ${uegroup}     ${ue_i}
    END
    Set Suite Variable    ${uegroup}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    spark_client.startlog    logpath=C:/spark_TA_log/${time_stamp}/    logname=${spark_logname}    service=${spark_alias}

Spark_multiUE.attach UE
    [Arguments]    ${ue_index}=${0}    ${spark_ue_mode}=5G_SA    ${timeout}=${60}
    Run Keyword If    '${spark_ue_mode}' == '5G_NSA'    Spark_multiUE.5G_NSA_mode    ue_index=${ue_index}
    ...    ELSE      Spark_multiUE.5G_SA_mode    ue_index=${ue_index}
    spark_client.poweron    until_timeout=${timeout}    ue=${ue_index}

Spark_multiUE.5G_SA_mode
    [Arguments]    ${ue_index}=${0}
    ...            ${enable_SAmode_command}=${enable_SAmode_command}    ${SA_mode_pref}=${SA_mode_pref}
    Wait Until Keyword Succeeds    5x    10s    spark_client.sendat    command=${enable_SAmode_command}    ue=${ue_index}
    Wait Until Keyword Succeeds    5x    10s    spark_client.sendat    command=${SA_mode_pref}    ue=${ue_index}

Spark_multiUE.5G_NSA_mode
    [Arguments]    ${ue_index}=${0}
    ...            ${disable_SAmode_command}=${disable_SAmode_command}    ${NSA_mode_pref}=${NSA_mode_pref}
    Wait Until Keyword Succeeds    5x    10s    spark_client.sendat    command=${disable_SAmode_command}    ue=${ue_index}
    Wait Until Keyword Succeeds    5x    10s    spark_client.sendat    command=${NSA_mode_pref}    ue=${ue_index}

Spark_multiUE.detach UE
    [Arguments]    ${ue_index}=${0}    ${timeout}=${60}
    spark_client.poweroff    until_timeout=${timeout}    ue=${ue_index}

Spark_multiUE.get UE ip
    [Arguments]    ${ue_index}=${0}
    ${pduinfo}    spark_client.sendat    command=${get_pduinfo_cmd}    ue=${ue_index}
    ${tiqu1}    Set Variable    ${pduinfo}[Param][Back]
    ${tiqu2}    Split String    ${tiqu1}    "
    ${UE_IP}    Set Variable    ${tiqu2}[1]
    [Return]    ${UE_IP}

Spark_multiUE.start UL traffic
    [Documentation]    ue: 1 # {-1, 1~n}, -1 means all UEs
    [Arguments]    ${ue_index}=${0}
    ...            ${traffic_protocol}=UDP
    ...            ${target_iperf_server}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...            ${target_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${testtime}=99999
    ...            ${bandwidth}=200000
    ...            ${buffersize}=1024
    ...            ${packetsize}=1400
    spark_client.startultraffic    protocol=${traffic_protocol}
    ...                            address=${target_iperf_server}
    ...                            port=${target_port}
    ...                            testtime=${testtime}
    ...                            bandwidth=${bandwidth}
    ...                            buffersize=${buffersize}
    ...                            packetsize=${packetsize}
    ...                            ue=${ue_index}
    sleep    30s     reason=wait for traffic start.

Spark_multiUE.stop UL traffic
    [Documentation]    ue: 1 # {-1, 1~n}, -1 means all UEs
    [Arguments]    ${ue_index}=${0}
    spark_client.stopultraffic    ue=${ue_index}

Spark_multiUE.stop ue log
    [Documentation]    execute Stoplog command to stop collecting logs
    [Arguments]    ${spark_service}=spark_ue
    spark_client.stoplog    service=${spark_service}

Spark_multiUE.get traffic from ue side
    [Documentation]    execute GetParamMAC command to get mac layer downlink/uplink throughput.
    ...    For tput_direction: should be MACDL/MACUL
    [Arguments]    ${ue_index}=${0}    ${tput_direction}=MACDL
    ${spark_mac_tput}    spark_client.getparammac    ue=${ue_index}
    ${spark_tput}    Evaluate    ${spark_mac_tput}[Param][${tput_direction}]/1000/1000
    [Return]    ${spark_tput}

Spark_multiUE.start DL traffic
    [Arguments]      ${dl_throughput}    ${ue_index}=${0}    ${dl_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...    ${dl_time}=9999    ${dl_length}=1400B
    ...    ${appserver}=APPserver    ${protocol}=udp    ${process_num}=${1}
    ...    ${seg_size}=${1180}    ${window}=2M
    ${ue_addr}    Spark_multiUE.get UE ip    ue_index=${ue_index}
    wait until keyword succeeds    3x    10s     Start DL traffic via iperf on Appserver
    ...    ue_addr=${ue_addr}    dl_time=${dl_time}    dl_port=${dl_port}    dl_throughput=${dl_throughput}
    ...    dl_length=${dl_length}    appserver=${appserver}    protocol=${protocol}    ue_index=${ue_index}     process_num=${process_num}
    ...    seg_size=${seg_size}    window=${window}

Spark_multiUE.stop DL traffic
    [Arguments]     ${ue_index}=${0}    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}    ${appserver}=APPserver
    Close the iperf process on APPserver    port=${iperf_port}    appserver=${appserver}


Spark_multiUE.get traffic from aasyslog
    [Arguments]    ${target_throughput}     ${cellid}    ${direction}=DL    ${duration}=3m    ${gnb_index}=${0}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85
    ${list_of_cell_ids}    Create list    ${cellid}
    ${log_path}     __Standard Capturing Aasyslog Throughput     duration=${duration}    gnb_index=${gnb_index}
    ${output}    __Standard Check Aasyslog Throughput    direction=${direction}    log=${log_path}    cells=${list_of_cell_ids}
    ...    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    actCarrierAggregation=${False}
    ...    customized_log_name=${None}    cell_indiv_tput=${None}
    [Return]    ${output}


Spark_multiUE.start call
    [Arguments]    ${DIAL}=006688    ${ue_index}=${0}
    ${call_status}    spark_client.sendat    command=ATD${DIAL};    ue=${ue_index}
    should be true    '${call_status}[Param][State]' == '0'

Spark_multiUE.stop call
    [Arguments]
    ${call_status}    spark_client.sendat    command=ATH    ue=${ue_index}
    should be true    '${call_status}[Param][State]' == '0'





#spark_MultiUE.Prepare UE
#    [Arguments]    ${detach_request}=${true}    ${power_reset}=true    ${ue_index}=${0}
#    ...            ${get_spark_license}=False
#    power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
#    ...    detach_request=${detach_request}    power_reset=${power_reset}    get_spark_license=${get_spark_license}
#
#spark_MultiUE.Attach
#    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA    ${4G_check}=False
#    ${res}    run keyword and ignore error   power_ue.UE Attach    attach_mode=${attach_mode}
#    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=true
#    sleep    10s
#    log    ${res}
#    run keyword if    '${res[0]}'!='PASS'   Run Keyword And Continue On Failure
#    ...    Basic.ThroughExceptionWithMsg    msg=Attach UE_${ue_index} Failed
#    ${res}    run keyword and ignore error   power_ue.Verify attach
#    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    4G_check=${4G_check}
#    run keyword if    '${res[0]}'!='PASS'   Run Keyword And Continue On Failure
#    ...     Basic.ThroughExceptionWithMsg    msg=Check Attach UE_${ue_index} Failed
#    log to console   UE attach completed
#
#spark_MutiUE.Get PDU IP
#    [Arguments]    ${ue_index}=${0}    ${APN}=dxdata1
#    ${IP}    Wait until keyword succeeds    4x   10s    Spark.get_pdu_ip
#    ...    apnaddress=${APN}     ue_alias=UE_${ue_index}
#    [Return]    ${IP}
#
#spark_MultiUE.Detach
#    [Arguments]    ${ue_index}=${0}
#    power_ue.UE Detach
#    ...   ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=True
#
#spark_MultiUE.Stop Traffic
#    [Arguments]    ${direction}=dl   ${ue_index}=${0}    ${APN}=dxdata1
#    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}     ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
#    power_ue.Stop traffic
#        ...    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}
#        ...    apn_address=${APN}
#        ...    iperf_port=${iperf_port}
#
#spark_MultiUE.Start Traffic
#    [Arguments]    ${throughput}=5   ${directiondirection}=dl   ${ue_index}=${0}
#     ...    ${duration}=600    ${protocol}=UDP    ${process_num}=1
#     ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}    ${APN}=dxdata1
#     ...    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}    ${ue_mode}=SA    ${throughout_bype}=MKbits/sec
#    power_ue.Start traffic
#        ...    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}
#        ...    throughput=${throughput}${throughout_bype}
#        ...    duration=${duration}
#        ...    apn_address=${APN}
#        ...    ue_mode=${ue_mode}
#        ...    iperf_port=${iperf_port}
#        ...    multidrb_QoS_dest=${None}
#        ...    protocol=${protocol}
#        ...    process_num=${process_num}
#
#spark_MultiUE.Make VONR call
#   [Arguments]    ${ue_index}=${ue_index_${gnb_instance0}}
#   spark.send AT command CPE     param=ATD006688;     ue_alias=UE_${ue_index}
#   ${Vonr_call_status}    Run Keyword And Continue On Failure   spark.get Vonr call status on ue
#   ...      ue_alias=UE_${ue_index}   param={"LastEventIndex":0}
#   run keyword if    '${Vonr_call_status}'=='True'    sleep    10s
#   ...    ELSE  Fail    VONR call failed
#
#spark_MultiUE.Change Network
#    [Arguments]    ${network}=LTE    ${ue_index}=${2}
#    MultiUE.Attach    ue_index=${ue_index}
#    Sleep    2s
#    Spark.send AT command CPE     param=at+QNWPREFCFG="mode_pref",${network};     ue_alias=UE_${ue_index}
#    Sleep    2s
#    [Teardown]    MultiUE.Detach    ue_index=${ue_index}
#
#spark_MultiUE.band restriction
#    [Arguments]    ${band}=2:25:41:66    ${ue_index}=${ue_index_${gnb_instance0}}
#    MultiUE.Attach    ue_index=${ue_index}
#    Sleep    2s
#    Spark.send AT command CPE     param=at+QNWPREFCFG="nr5g_band",${band};     ue_alias=UE_${ue_index}
#    Sleep    20s
#    [Teardown]    MultiUE.Detach    ue_index=${ue_index}
#
#spark_MultiUE.Change APN
#    [Arguments]    ${APN}=dxdata1    ${ue_index}=${ue_index_${gnb_instance0}}
#    MultiUE.Attach    ue_index=${ue_index}
#    Sleep    2s
#    Wait until keyword succeeds    4x   10s    Spark.send AT command CPE
#    ...    param=at+cgdcont=1,"IP","${APN}";     ue_alias=UE_${ue_index}
#    Sleep    2s
#    [Teardown]    MultiUE.Detach    ue_index=${ue_index}
