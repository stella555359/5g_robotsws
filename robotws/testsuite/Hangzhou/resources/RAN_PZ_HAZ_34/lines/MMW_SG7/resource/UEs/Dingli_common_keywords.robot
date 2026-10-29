*** Settings ***
Documentation    This is for DingLi keywords.
...              Please do not modify the file without notification to author
...              Author: Flora.Du@nokia-sbell.com

Library     taf.ue.pioneer.client        WITH NAME      client

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Keywords.robot

*** Variables ***
${SA_atcommand}               AT+GTSET="5GSACTR",1
${SA_GTSET}                   AT+GTACT=14
${NSA_atcommand}              AT+GTSET="5GSACTR",0
${NSA_GTSET}                  AT+GTACT=17
${mPDU_atcommand}             at$qcrmcall=1,1
${lock_band_atcommand}        AT+GTACT=14,,,5071
${disable_auto_connect_atcommand}    AT+GTAUTOCONNECT=0


*** Keywords ***
#---------------new version with taf.ue.pioneer.client ------------------------------#
#-----UE prepare  -------#
DingLi_Client.UE Prepare
    [Arguments]    ${ue_index}=${0}    ${alias}=pioneer    ${ue_alias}=multiUE
        ...    ${until_timeout}=${300}    ${port}=30999
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ${ue_host}    Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${uepc_username}    Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${uepc_password}    Set Variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    client.setup_service
    ...    host=${ue_host}
    ...    port=${port}
    ...    ssh_username=${uepc_username}
    ...    ssh_password=${uepc_password}
    ...    alias=${alias}
    Run Keyword And Ignore Error    client.stoplog      service=${alias}
    @{UEs_info}    client.prepare_ues    service=${alias}
    ${imei_list}    create list
    FOR    ${item}    IN    @{UEs_info}
      Append To List     ${imei_list}     ${item}[imei]
    END
    Remove values From List    ${imei_list}    ERROR
    Set Suite Variable    ${imei_list}
    ${ue_num}=    get length    ${imei_list}
    ${uegroup}    create list
    FOR    ${i}    IN RANGE     ${ue_num}
      client.require_ue    imei=${imei_list}[${i}]    service=${alias}    ue_alias=${ue_alias}${i}
      Append To List     ${uegroup}     ${ue_alias}${i}
    END
    Set Suite Variable    ${uegroup}
    Run Keyword And Ignore Error    client.poweroff     ue=${uegroup}    until_timeout=${300}
    sleep    10s
    Run Keyword And Ignore Error    client.poweron     ue=${uegroup}    until_timeout=${300}
    sleep    1min
#    Run Keyword And Ignore Error    client.detach    ue=${uegroup}    until_timeout=${300}    withpdu=1
#    sleep    5s
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    sleep    5s
#    client.startlog    logpath=d:/pioneer_logs/${time_stamp}/    logname=ta_log    service=${alias}
    sleep    1s

#-----UE SA/NSA mode change  -------#
DingLi_Client.SA And NSA Mode Change
    [Arguments]    ${ues_index}=${${0}}    ${until_timeout}=${300}    ${UE_mode}=5G_SA
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        DingLi_Client.Deployment SA And NSA Mode    UE_mode=${UE_mode}     until_timeout=${until_timeout}      ue=${uegroup}[${index}]
        Sleep  5sec
    END

DingLi_Client.UE Attach
    [Arguments]    ${ues_index}=${${0}}    ${until_timeout}=${300}    ${apn}=stdata1    ${UE_mode}=5G_SA
#    Run Keyword And Ignore Error    client.detach    ue=${uegroup}    until_timeout=${300}    withpdu=1
    Sleep    10sec
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        log to console    start to attach ${uegroup}[${index}]
        ${status}    ${attach_status}    Run Keyword And Ignore Error    DingLi_Client.Get MultiUE attach status
        ...    ue=${uegroup}[${index}]    until_timeout=${until_timeout}
        sleep    1s
        run keyword if    '${attach_status}' == 'Attached'    Run Keywords
        ...    Run Keyword And Ignore Error    client.poweroff     ue=${uegroup}    until_timeout=${300}    AND
        ...    sleep    8s    AND
        ...    Run Keyword And Ignore Error    client.poweron     ue=${uegroup}    until_timeout=${300}    AND
        ...    sleep    1min    AND
        ...    Run Keyword And Ignore Error    client.detach    ue=${uegroup}[${index}]    until_timeout=${300}    withpdu=1
        sleep    5s
        run keyword if    '${UE_mode}' == '5G_SA'
        ...    Run Keyword And Ignore Error    client.sendat    command=${lock_band_atcommand}    until_timeout=${until_timeout}
        ...    ue=${uegroup}[${index}]
        sleep    15s
        Run Keyword And Ignore Error    client.sendat    command=${disable_auto_connect_atcommand}
        ...    until_timeout=${until_timeout}    ue=${uegroup}[${index}]
        sleep   3s
        ${status}    ${attach_status}    Run Keyword And Ignore Error    DingLi_Client.Get MultiUE attach status
        ...    ue=${uegroup}[${index}]    until_timeout=${until_timeout}
        sleep   5s
        log to console    ---UE status is ${status} before do attach---
        Run Keyword And Ignore Error    client.attach    uemode=${UE_mode}     ue=${uegroup}[${index}]
        ...    until_timeout=${until_timeout}
        Sleep  60sec
        ${status}    ${attach_status}    Run Keyword And Ignore Error    DingLi_Client.Get MultiUE attach status
        ...    ue=${uegroup}[${index}]    until_timeout=${until_timeout}
    END
    FOR    ${index}    IN    @{ues_index}
        log to console    start to get ueip to ${uegroup}[${index}]
        Run Keyword And Continue On Failure    client.sendat    command=${mPDU_atcommand}    until_timeout=${until_timeout}
        ...    ue=${uegroup}[${index}]
        ${upd_info}    Run Keyword And Continue On Failure   client.getpduinfo    until_timeout=${until_timeout}
        ...    apn=${apn}     ue=${uegroup}[${index}]
        should be true    ${upd_info}[Param][State]==0
        Set Test variable    ${UE${index}_IP}    ${upd_info}[Param][IP]
        Sleep  5sec
        log to console    ${uegroup}[${index}] ip is: ${upd_info}[Param][IP]
    END

DingLi_Client.Test DL Data
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0}}
    ...            ${dl_protocol}=udp
    ...            ${start_keep_on_duration}=9999
    ...            ${dl_throughput}=200M
    ...            ${dl_length}=1400B
    ...            ${seg_size}=${1372}
    ...            ${window}=2M
    ...            ${process_num}=${5}
    ...            ${ul_protocol}=UDP
    ...            ${ul_throughput}=200000
    ...            ${ul_buffersize}=1024
    ...            ${packetsize}=1400
    ...            ${ue_index_in_tl}=${0}
    ...            ${whether_start_dl_call}=${True}
    ...            ${whether_start_ul_call}=${True}
    Run Keyword If    ${whether_start_dl_call}    Run Keyword And Continue On Failure
    ...    DingLi_Client.Start DL Data Transfer    ues_index=${ues_index}
    ...                                            dl_throughput=${dl_throughput}
    ...                                            ue_index_in_tl=${ue_index_in_tl}
    ...                                            dl_protocol=${dl_protocol}
    ...                                            ue_index_in_tl=${ue_index_in_tl}
    ...                                            process_num=${process_num}
    ...                                            seg_size=${seg_size}
    ...                                            window=${window}
    ...                                            dl_length=${dl_length}
    ...                                            start_keep_on_duration=${start_keep_on_duration}

#-----UE start traffic  -------#
DingLi_Client.Start Data Transfer
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0}}
    ...            ${dl_protocol}=udp
    ...            ${start_keep_on_duration}=9999
    ...            ${dl_throughput}=200M
    ...            ${dl_length}=1400B
    ...            ${seg_size}=${1372}
    ...            ${window}=2M
    ...            ${process_num}=${5}
    ...            ${ul_protocol}=UDP
    ...            ${ul_throughput}=200000
    ...            ${ul_buffersize}=1024
    ...            ${packetsize}=1400
    ...            ${ue_index_in_tl}=${0}
    ...            ${whether_start_dl_call}=${True}
    ...            ${whether_start_ul_call}=${True}
    Run Keyword If    ${whether_start_dl_call}    Run Keyword And Continue On Failure
    ...    DingLi_Client.Start DL Data Transfer    ues_index=${ues_index}
    ...                                            dl_throughput=${dl_throughput}
    ...                                            ue_index_in_tl=${ue_index_in_tl}
    ...                                            dl_protocol=${dl_protocol}
    ...                                            ue_index_in_tl=${ue_index_in_tl}
    ...                                            process_num=${process_num}
    ...                                            seg_size=${seg_size}
    ...                                            window=${window}
    ...                                            dl_length=${dl_length}
    ...                                            start_keep_on_duration=${start_keep_on_duration}
    Run Keyword If    ${whether_start_ul_call}    Run Keyword And Continue On Failure
    ...    DingLi_Client.Start UL Data Transfer
    ...    ues_index=${ues_index}
    ...    ul_protocol=${ul_protocol}
    ...    ul_throughput=${ul_throughput}
    ...    ul_buffersize=${ul_buffersize}
    ...    packetsize=${packetsize}
    ...    ue_index_in_tl=${ue_index_in_tl}

#-----UE stop traffic  -------#
DingLi_Client.Stop Data Transfer
    [Arguments]    ${ues_index}=${${0}}    ${ue_index_in_tl}=${0}
    Run Keyword And Continue On Failure    DingLi_Client.Stop UL Data Transfer    ues_index=${ues_index}
    Run Keyword And Continue On Failure    DingLi_Client.Stop DL Data Transfer    ues_index=${ues_index}
    ...                                                                           ue_index_in_tl=${ue_index_in_tl}

#-----UE detach  -------#
DingLi_Client.Detach
    [Arguments]    ${ues_index}=${${0}}    ${until_timeout}=${300}    ${alias}=pioneer
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        Run Keyword And Continue On Failure    client.detach    ue=${uegroup}[${index}]    until_timeout=${300}    withpdu=1
    END


#-----UE teardown  -------#
DingLi_Client.Teardown
    [Arguments]    ${ues_index}=${${0}}    ${ue_index_in_tl}=${0}
#    Run Keyword And Continue On Failure    client.stoplog    service=pioneer
    Run Keyword And Continue On Failure    client.release_ues    service=pioneer
    Run Keyword And Continue On Failure    client.teardown_service    service=pioneer

#-----used keywords -------#
DingLi_Client.Start DL Data Transfer
    [Arguments]    ${ues_index}=${${0}}
    ...            ${ue_index_in_tl}=${0}
    ...            ${process_num}=${5}
    ...            ${dl_protocol}=udp
    ...            ${start_keep_on_duration}=9999
    ...            ${dl_throughput}=2500M
    ...            ${dl_length}=1400B
    ...            ${seg_size}=${1372}
    ...            ${window}=2M
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    ${dl_port}    Set Variable    ${tl.ues[${ue_index_in_tl}].iperf_details.port}
    ${process_num}    Set Variable If    '${dl_protocol}'=='udp'     1    ${process_num}
    FOR    ${index}    IN    @{ues_index}
        Log To Console    ${\n}INFO:-- start to DL call for ${uegroup}[${index}]--
        Run Keyword And Continue On Failure    DingLi_Client.Start DL traffic via iperf on Appserver
        ...                                    ue_addr=${UE${index}_IP}
        ...                                    dl_time=${start_keep_on_duration}
        ...                                    dl_port=${dl_port}
        ...                                    dl_throughput=${dl_throughput}
        ...                                    dl_length=${dl_length}
        ...                                    protocol=${dl_protocol}
        ...                                    process_num=${process_num}
        ...                                    seg_size=${seg_size}
        ...                                    window=${window}
        ...                                    ue_index=${ue_index_in_tl}
        Sleep    5sec
        ${dl_port}    Evaluate    ${dl_port}+1
    END

DingLi_Client.Start UL Data Transfer
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0}}
    ...            ${ul_protocol}=UDP
    ...            ${ul_throughput}=250000
    ...            ${ul_buffersize}=1024
    ...            ${packetsize}=1400
    ...            ${ue_index_in_tl}=${0}
    Log To Console    ${\n}INFO:-- start to UL call --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    ${ue_host}    Set Variable    ${tl.ues[${ue_index_in_tl}].ssh_connection_details.addr}
    ${ul_port}    Set Variable    ${tl.ues[${ue_index_in_tl}].iperf_details.port}
    ${ue_port}    Evaluate    ${ul_port}+2
    FOR    ${index}    IN    @{ues_index}
        Log To Console    ${\n}INFO:-- start to UL call for ${uegroup}[${index}]--
        Run Keyword And Continue On Failure    client.startultraffic
        ...    protocol=${ul_protocol}
        ...    address=${ue_host}
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

DingLi_Client.Start DL traffic via iperf on Appserver
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${5}
    ...    ${seg_size}=${1180}    ${window}=2M
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}'    connection=APPserver
#    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${process_num} -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=APPserver
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf    ue_index=${ue_index}
    ...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}    process_num=${process_num}    seg_size=${seg_size}
    ...    window=${window}
    sleep    3s
#    Check the iperf progress exist    connection=APPserver    port=${dl_port}
    [Teardown]    csn.disconnect    connection=APPserver

DingLi_Client.Stop UL Data Transfer
    [Arguments]    ${ues_index}=${${0}}
    Log To Console    ${\n}INFO:-- start to stop call --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        Run Keyword And Continue On Failure    client.stopultraffic    until_timeout=${300}    ue=${uegroup}[${index}]
        Sleep   5sec
    END

DingLi_Client.Check traffic with pioneer client
    [Arguments]    ${tput_target}    ${ues_index}=${${0}}   ${direction}=ul
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

DingLi_Client.Stop DL Data Transfer
    [Arguments]    ${ues_index}=${${0}}    ${ue_index_in_tl}=${0}
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${ue_index}    IN    @{ues_index}
        ${port}    Set Variable    ${tl.ues[${ue_index_in_tl}].iperf_details.port}
        Run Keyword And Continue On Failure    Close the iperf process on APPserver    port=${port}
        ${port}    Evaluate    ${port}+1
    END

DingLi_Client.Deployment SA And NSA Mode
    [Arguments]    ${UE_mode}=5G_SA     ${until_timeout}=${300}    ${ue}=multiUE0
    Run Keyword If    '${UE_mode}' == '5G_NSA'    Run Keywords
    ...    client.sendat    command=${NSA_atcommand}    until_timeout=${until_timeout}    ue=${ue}
    ...    AND    client.sendat    command=${NSA_GTSET}    until_timeout=${until_timeout}    ue=${ue}
    ...    ELSE IF    '${UE_mode}' == '5G_SA'    Run Keywords
    ...    client.sendat    command=${SA_atcommand}    until_timeout=${until_timeout}    ue=${ue}
    ...    AND    client.sendat    command=${SA_GTSET}    until_timeout=${until_timeout}    ue=${ue}

DingLi_Client.Get MultiUE attach status
    [Arguments]    ${ue}=${uegroup}    ${until_timeout}=${300}
    ${attach_status}    client.get_attach_status    ue=${ue}    until_timeout=${until_timeout}
    ${attach_info}=    set variable    ${attach_status['Param']['AttachStatus']}
    [Return]     ${attach_info}

DingLi_Client.Check PCI In Attach Info
    [Arguments]    ${ues_index}=${${0}}    ${expect_pci}=666
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${ue_index}    IN    @{ues_index}
        ${attach_status}    client.get_attach_status    ue=${uegroup}[${ue_index}]    until_timeout=${300}
        ${attach_pci}    set variable    ${attach_status['Param']['CellInfoList'][0]['PCI']}
        Run Keyword And Continue On Failure    Should Be Equal As Integers   ${expect_pci}    ${attach_pci}
        ...    msg=UE-${ue_index} attach failed, to the incorrect gnb , pci is ${attach_pci}.
    END

DingLi_Client.Get Statistics Results
    [Arguments]    ${ues_index}=${${0}}
    FOR    ${index}    IN    @{ues_index}
        Run Keyword And Ignore Error    client.start_statistics    ues=${uegroup}
        sleep  10sec
        ${status}    ${result}    Run Keyword And Ignore Error    client.get_statistics_result    ue=${uegroup[${index}]}
        ...    until_timeout=${300}
        Run Keyword And Ignore Error    client.stop_statistics    ues=${uegroup}
    END

#---------------old version ------------------------------#
DingLi.UE Prepare for UES
    [Arguments]    ${ues_index}=${${0}}    ${whether_do_ue_prepare}=${True}    ${get_spark_license}=${False}
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    ${attachinfo_dict}    create dictionary
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword If    ${whether_do_ue_prepare}    Procedures.UE Prepare
        ...                                           ue_index=${ue_index}
        ...                                           ue_type=huawei_sigspark
        ...                                           get_spark_license=${get_spark_license}
    END

DingLi.UE attach for UES
    [Arguments]    ${ues_index}=${${0}}    ${ue_mode}=SA    ${enb_index}=${1}    ${whether_do_ue_prepare}=${False}
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    ${attachinfo_dict}    create dictionary
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword If    ${whether_do_ue_prepare}    Procedures.UE Prepare    ue_index=${ue_index}    ue_type=huawei_sigspark
        ${attach_info}    Procedures.UE Attach     ue_index=${ue_index}
        ...                                        ue_type=huawei_sigspark
        ...                                        ue_mode=${ue_mode}
        ...                                        enb_index=${enb_index}
        ...                                        is_power_ue_code=${True}
        ${ue_index}    Convert To String    ${ue_index}
        Set To Dictionary    ${attachinfo_dict}    ${ue_index}=${attach_info}
        Set Test Variable     ${UE${ue_index}_CRNTI}     ${attach_info['crnti']}
    END
    [Return]    ${attachinfo_dict}

DingLi.UE Deattach for UEs
    [Documentation]    Author: le.jia@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0}}    ${is_power_ue_code}=${True}
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=huawei_sigspark    ue_index=${ue_index}
    END

DingLi.Start Data Transfer
    [Arguments]     ${attachinfo_dict}
    ...             ${ues_index}=${${0}}
    ...             ${ue_mode}=SA
    ...             ${enb_index}=${1}
    ...             ${ul_throughput}=250M
    ...             ${dl_throughput}=1800MKbits/sec
    ...             ${start_keep_on_duration}=3600
    ...             ${ue_iperf_path}=/data/local/tmp/iperf
    ...             ${bbmod_slots}=1
    ...             ${whether_start_dl_call}=${True}
    ...             ${whether_start_ul_call}=${True}
    ...             ${apn_address}=stdata1
    ...             ${is_power_ue_code}=${True}
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
     FOR    ${ue_index}    IN    @{ues_index}
          ${attach_wireshark}    Set Variable If    '${ue_mode}'=='NSA'
          ...    ${attachinfo_dict['${ue_index}']['enb_wireshark_log_path']}    ${attachinfo_dict['${ue_index}']['cpif_log_path']}
          Run Keyword And Continue On Failure    Procedures.Start Data Transfer    ue_index=${ue_index}
          ...                                    cpif_log_path=${attach_wireshark}
          ...                                    ue_mode=${ue_mode}
          ...                                    ue_index=${ue_index}
          ...                                    start_keep_on_duration=${start_keep_on_duration}
          ...                                    ul_throughput=${ul_throughput}
          ...                                    dl_throughput=${dl_throughput}
          ...                                    iperf_path=${ue_iperf_path}
          ...                                    ue_type=huawei_sigspark
          ...                                    apn_address=${apn_address}
          ...                                    whether_start_dl_call=${whether_start_dl_call}
          ...                                    whether_start_ul_call=${whether_start_ul_call}
          ...                                    is_power_ue_code=${is_power_ue_code}
    END

DingLi.Stop UL Data Transfer
    [Arguments]    ${ues_index}=${${0}}    ${apn_address}=stdata1
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...                                                                      iperf_port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...                            iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
        Run Keyword And Ignore Error      power_ue.Stop traffic   ue_type=huawei_sigspark
        ...                               direction=ul    ue_index=${ue_index}    apn_address= ${apn_address}
    END

DingLi.Stop DL Data Transfer
    [Arguments]    ${ues_index}=${${0}}
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on APPserver
        ...    port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    END

DingLi.Stop Traffic
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0}}    ${apn_address}=dxdata2
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...    iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
        Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...                                                                      iperf_port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
        Run Keyword And Ignore Error      power_ue.Stop traffic   ue_type=huawei_sigspark
        ...                               direction=ul    ue_index=${ue_index}    apn_address= ${apn_address}
    END

DingLi.Deployment SA And NSA Mode For 8UE Module
    [Documentation]    para:${ue_mode}  value can be "NSA or SA"
    ...                please note, for SA mode, select ${nettpye}=SA+NSA; for NSA mode, select ${nettpye}=NSA
    [Arguments]    ${ue_mode}=SA      ${ues_index}=${${1},${2},${3},${4}}
    ...            ${apn_address}=dxdata2
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${ue_index}    IN    @{ues_index}
        ${nettpye}    Set Variable If    '${ue_mode}'=='NSA'     NSA    SA+NSA
        Log To Console    \nStart to deployment UE${ue_index} to ${ue_mode} Mode.
        spark.config_5g_deployment    nettype=${nettpye}    ue_alias=UE_${ue_index}
    END

DingLi.Disable AutoConnect For 8UE Module
    [Arguments]    ${ues_index}=${${0}}
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${ue_index}    IN    @{ues_index}
        spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=AT+GTAUTOCONNECT=0
        Sleep    3s
    END

DingLi.Restart UE
    [Arguments]    ${ues_index}=${${0}}
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${ue_index}    IN    @{ues_index}
        spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=at+cfun=1,1
        Sleep    3s
    END
    Sleep    90s
    Run Keyword And Ignore Error    DingLi.Disable AutoConnect For 8UE Module    ues_index=${${1},${2},${3},${4}}
    Sleep    20sec

DingLi.UE Attach With WA Restart UE
    [Arguments]    ${ues_index}=${${0}}    ${ue_mode}=SA    ${enb_index}=${1}    ${whether_do_ue_prepare}=${False}
    ${status}    ${attach_info_first}     Run Keyword And Ignore Error    DingLi.UE attach for UES    ues_index=${ues_index}
    ...    ue_mode=${ue_mode}    enb_index=${enb_index}    whether_do_ue_prepare=${whether_do_ue_prepare}
    ${attach_info_second}    Run Keyword If    '${status}'=='FAIL'    Run Keywords    DingLi.Restart UE    ues_index=${ues_index}    AND
    ...    DingLi.UE attach for UES    ues_index=${ues_index}
    ...    ue_mode=${ue_mode}    enb_index=${enb_index}    whether_do_ue_prepare=${whether_do_ue_prepare}
    ${attach_info}    Set Variable If    '${status}'=='FAIL'    ${attach_info_second}    ${attach_info_first}
    [Return]    ${attach_info}

DingLi.UE Attach With Change SA And NSA Mode
    [Arguments]    ${ues_index}=${${0}    ${ue_mode}=SA    ${enb_index}=${1}
    Run Keyword And Ignore Error     DingLi.UE attach for UES    ues_index=${ues_index}    ue_mode=${ue_mode}    enb_index=${enb_index}
    Run Keyword And Ignore Error    DingLi.Disable AutoConnect For 8UE Module    ues_index=${ues_index}
    Sleep  2sec
    DingLi.Deployment SA And NSA Mode For 8UE Module    ue_mode=${ue_mode}   ues_index=${ues_index}
    Run Keyword And Ignore Error    DingLi.UE Deattach for UEs    ues_index=${ues_index}    is_power_ue_code=${True}
    ${attach_info}    DingLi.UE attach for UES    ues_index=${ues_index}    ue_mode=${ue_mode}   enb_index=${enb_index}
    [Return]    ${attach_info}


Dingli L3 Call And Verify Throughput
    [Arguments]    ${ul_data_transfer}    ${dl_data_transfer}    ${expect_ul_tput}    ${expect_dl_tput}
    ...            ${cellid}=2    ${is_do_require_ue}=${True}    ${target_avg_percent}=0.9    ${min_percent}=0.3    ${duration}=180
    #Change cellBarred Parameter Value On Gnb    pcell_index=${cellid}    exp_status=notBarred
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach    ues_index=${${0}}
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=666
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    DingLi_Client.Start Data Transfer    ues_index=${${0}}    ul_throughput=${ul_data_transfer}    dl_throughput=${dl_data_transfer}
    @{direction_component_list}    Create List    UL    DL
    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                         duration=${duration}
    ...                         expect_ul_tput=${expect_ul_tput}
    ...                         expect_dl_tput=${expect_dl_tput}
    ...                         cellid=${cellid}
    ...                         ue_type=huawei_sigspark
    ...                         check_source=aasyslog
    ...                         target_avg_percent=${target_avg_percent}
    ...                         min_percent=${min_percent}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer    AND
    ...                           Run Keyword And Ignore Error    DingLi_Client.Detach
