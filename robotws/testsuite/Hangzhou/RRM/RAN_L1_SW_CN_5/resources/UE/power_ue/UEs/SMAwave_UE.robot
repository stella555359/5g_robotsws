*** Settings ***
Documentation     author: Ye Dan Zhou
...               maintainer : Jingang Sun
...               contact: ye_dan.yz.zhou@nokia.com
...               jingang.sun@nokia-sbell.com
...               Generic UE keywords, refer to sample test case at below link
...               https://confluence.ext.net.nokia.com/display/NewMobility/How+to+use+UE+keywords+in+auto+TCs
Library           ute_async
Library           String
Library           Collections
Library           OperatingSystem
Library           ../../../python/DEV_UE.py    WITH NAME    UE
Library           ../../../python/smawave_operation.py    WITH NAME    SWO
Library           taf.config.scf    WITH NAME    scf
Library           taf.transport.ssh    WITH NAME    Csn_Inst


*** Variables ***
${ping_flag}      True
${add_default_route_flag}    True
${dl_async_flag}    False
${ul_async_flag}    False
${check_cmd}      atcmd /dev/ttyUSB1 115200 AT+COPS?
${onlinemode_cmd}     atcmd /dev/ttyUSB1 115200 AT+CFUN=1
${airplanemode_cmd}     atcmd /dev/ttyUSB1 115200 AT+CFUN=4
${prefer_SA_cmd}     atcmd /dev/ttyUSB1 115200 AT+GTACT=10
${comd_start_cmd}    /etc/init.d/comd start
${comd_stop_cmd}    /etc/init.d/comd stop
${firewall_stop_cmd}    /etc/init.d/firewall stop
${get_iperf_id_cmd}    /bin/ps | grep iperf | grep -v grep | awk '{print $1}'
${get_IPV4addr_cmd}    ifconfig usb0.1 | grep 'inet addr' | awk '{print $2}' | tr -d 'addr:'
${iperf_path}     /data/local/tmp/iperf
${check_attach_cmd}    atcmd /dev/ttyUSB1 115200 AT+GTCCINFO?
${ipv4_pattern}    (?<![\\.\\d])(([1-9]?\\d|1\\d\\d|2[0-4]\\d|25[0-5])\\.){3}([1-9]?\\d|1\\d\\d|2[0-4]\\d|25[0-5])(?![\\.\\d])
${check_freq_lock_cmd}    atcmd /dev/ttyUSB1 115200 AT+GTFREQLOCK?
${freq_lock_unlock_cmd}    atcmd /dev/ttyUSB1 115200 AT+GTFREQLOCK=


*** Keywords ***
All Setup
    OAM Setup
    Set UE Variables

Postconditions_ForCall
    Postconditions

Set UE Variables
    # ${ue_config} loaded from the testline configuration file
    ${ue_config}=    UE.Load Ue Config    ${tl}
    Return From Keyword If    ${ue_config}==None
    Log To Console    ue configuration was loaded, prepare UE env...
    ${ue_yaml}    Set Variable    ${ue_config}
    ${ue_inline}    Set Variable    ${ue_yaml['UE_POOLS']['AndroidUePool']['inline_config']}
    ${UE_NUM}=    Get length    ${ue_inline}
    &{5G_UEPC_DICT}    Create Dictionary
    &{4G_UEPC_DICT}    Create Dictionary
    FOR    ${i}    IN RANGE    ${UE_NUM}
        ${index}=    Evaluate    ${i}+1
        ${ue_name}    Set Variable    UE_${index}
        ${ue_details}    Set Variable    ${ue_inline['${ue_name}']}
        ${ue_constr}    Set Variable    ${ue_details['CONSTRUCTOR_PARAMETERS']}
        ${ue_config}    Set Variable    ${ue_constr['configuration']}
        ${cpc_ip}    Set Variable    ${ue_config['ue_pc_ip']}
        ${cpc_usr}    Set Variable    ${ue_config['login']}
        ${cpc_pwd}    Set Variable    ${ue_config['password']}
        ${sn}    Set Variable    ${ue_constr['serial_number']}
        ${pyro_dir}    Set Variable    ${ue_config['server_dir']}
        &{UEPC_DICT}=    Create Dictionary    cpc_ip=${cpc_ip}    cpc_usr=${cpc_usr}    cpc_pwd=${cpc_pwd}    sn=${sn}
        ...    cpc_pyrodir=${pyro_dir}

        Run Keyword If    '5G' in ${ue_details['CAPABILITIES']}    Set To Dictionary    ${5G_UEPC_DICT}    ${ue_name}    ${UEPC_DICT}
        Run Keyword If    '4G' in ${ue_details['CAPABILITIES']}    Set To Dictionary    ${4G_UEPC_DICT}    ${ue_name}    ${UEPC_DICT}
    END
    Set Suite Variable    ${5G_UEPC_DICT}
    Set Suite Variable    ${4G_UEPC_DICT}
    Set Suite Variable    ${UE_NUM}
    Set Suite Variable    ${ue_inline}
    SMAwave setup

SMAwave Ping peer before data transfer
    [Arguments]    ${ue_index}    ${packet_number}=10
    [Documentation]    This keyword used to ping peer from openwrt before data transfer.
    ...    Note : This keyword is just used for some abnormal SMAwave UEs as WA, it will be removed
    ...    or commented when related bug is resolved.
    ...    ue_index : UE identifier index
    ...    packet_number : ping packet number
    ...
    ...    Example : SMAwave Ping peer before data transfer 1 20
    ${ute_iperf_itf_ip}    Set Variable
    ...    ${ue_inline['${ue_index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['iperf_interface_ip']}
    ${ping_command}    Set Variable    /bin/ping -c ${packet_number} ${ute_iperf_itf_ip}
    Log To Console    \nINFO : Begin to execute ping command ${ping_command} on ${ue_index}.
    ${isPing}    Csn_Inst.execute    command=${ping_command}    timeout=20s    connection=SMA_${ue_index}
    Log To Console    \nINFO : ${isPing}.
    Should Contain    ${isPing}    0% packet loss    [ERROR]Failed to ping from UE to Iperf(${ute_iperf_itf_ip}).

Start and Verify Downlink TCP
    [Arguments]    ${ue_index}    ${duration}    ${iperf_throughput}    ${protocol}
    ...    ${dl_expect_tput}    ${dl_deviation}
    [Documentation]    This keyword used to perform TCP downlink traffic
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : dl
    ...    duration : data transfer duration in robot time string format
    ...    iperf_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp
    ...    dl_expect_tput : desired average data transfer throughput
    ...    dl_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Start and Verify Downlink TCP dl_test 1 dl 120s 80M tcp 70M 20%
    Wait Until Keyword Succeeds    3min    20s    Fetch SMAwave UE Addr    ${ue_index}
    SMAwave DL Traffic    ${ue_index}    ${duration}
    ...    ${iperf_throughput}    ${protocol}    ${dl_expect_tput}    ${dl_deviation}

Start and Verify Downlink UDP
    [Arguments]    ${ue_index}    ${duration}    ${iperf_throughput}    ${protocol}
    ...    ${dl_expect_tput}    ${dl_deviation}
    Wait Until Keyword Succeeds    3min    20s    Fetch SMAwave UE Addr    ${ue_index}
    SMAwave DL Traffic    ${ue_index}    ${duration}
    ...    ${iperf_throughput}    ${protocol}    ${dl_expect_tput}    ${dl_deviation}

SMAwave DL Traffic
    [Arguments]    ${ue_index}    ${duration}    ${iperf_throughput}    ${protocol}
    ...    ${dl_expect_tput}    ${dl_deviation}
    [Documentation]    This keyword used to perform and verify SMAwave UE downlink data transfer.
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : dl
    ...    duration : data transfer duration in robot time string format
    ...    iperf_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp or udp
    ...    dl_expect_tput : desired average data transfer throughput
    ...    dl_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : SMAwave DL Traffic dl_test 1 dl 120s 80M udp 70M 20%
    SMAwave Start DL Iperf Process    ${ue_index}    ${protocol}    ${iperf_throughput}    ${duration}
    Get and Kill Iperf Process on Openwrt    ${ue_index}
    SMAwave Calculate and Verify DL Tput    ${ue_index}    ${dl_expect_tput}    ${dl_deviation}
    [Teardown]    Get and Kill Iperf Process on Openwrt    ${ue_index}

SMAwave Start DL Iperf Process
    [Arguments]    ${index}    ${proto}    ${T_Put}    ${Tput_dura}
    [Documentation]    This keyword used to start iperf process on both UTE VM and openwrt for SMAwave UE DL data transfer
    ...    index : UE identifier index
    ...    proto : tcp or udp
    ...    T_Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...
    ...    Example : SMAwave Start DL Iperf Process 1 tcp 80M 120s.

    Login APP Server    APP_Server_${index}    ${index}

    ${T_Put_value}    Convert To String    ${T_Put}
    ${T_Put_value}    Convert To Integer    ${T_Put_value.upper().strip('M')}
    Run Keyword And Return If    ${T_Put_value} == 0    Log To Console    \n[WARN]: Skipping to start DL data due to T_Put = ${T_Put}.
    Log To Console    \nINFO: Begin to generate ${proto} port for DL data transfer.
    ${used_port_list}    SWO.Get Occupied Udp Port List
    ${iperf_port_num}    SWO.Get Availabel Udp Port    lines=${used_port_list}
    Log To Console    \nINFO: The ${proto} port used for ${index} DL data transfer is ${iperf_port_num}.
    ${dl_cmd_on_openwrt}    Run Keyword If    '${proto}'.lower() == 'tcp'
    ...    Set Variable    /usr/bin/iperf -s -p ${iperf_port_num} -i1 -t ${Tput_dura} -D > /tmp/openwrt_iperf_${index}.log
    ...    ELSE IF    '${proto}'.lower() == 'udp'
    ...    Set Variable    /usr/bin/iperf -s -u -l1400 -w10M -i1 -p ${iperf_port_num} -t ${Tput_dura} -D > /tmp/openwrt_iperf_${index}.log
    Csn_Inst.send_command    command=iptables -F    connection=SMA_${index}
    Csn_Inst.send_command    command=iptables -P INPUT ACCEPT    connection=SMA_${index}
    Csn_Inst.send_command    command=${dl_cmd_on_openwrt}    connection=SMA_${index}
    sleep    1s
    #Run Keyword If    '${ping_flag}' == 'True'    SMAwave Ping peer before data transfer    ${index}    5
    Log To Console    \nINFO: Begin to perform ${index} DL data traffic with throughput ${T_Put}.
    ${iperf_cmd_on_app}    Run Keyword If    '${proto}'.lower() == 'tcp'
    ...    Set Variable    iperf -c ${smawave_ue_addr} -p ${iperf_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400
    ...    ELSE IF    '${proto}'.lower() == 'udp'
    ...    Set Variable    iperf -c ${smawave_ue_addr} -u -i1 -l1400 -p ${iperf_port_num} -b ${T_Put} -t ${Tput_dura}

    #Csn_Inst.execute    command=${iperf_cmd_on_app}    connection=APP_Server_${index}
    Csn_Inst.send_command    command=${iperf_cmd_on_app}    connection=APP_Server_${index}
    sleep    1s
    ${isIperfStarting}    Csn_Inst.execute    command=ps -ef | grep iperf    connection=APP_Server_${index}
    Should Contain    ${isIperfStarting}    ${smawave_ue_addr}    [ERROR] Failed to perform DL data traffic on iperf server.
    Log To Console    \nINFO: Successfully perform ${index} DL data traffic with throughput ${T_Put} duration is ${Tput_dura}.
    [Teardown]    Run Keyword and ignore error    Logout APP Server    APP_Server_${index}

SMAwave and APPserver Stop Iperf Process
    [Arguments]    ${index}
    Csn_Inst.send_command    command=ps |grep iperf|grep -v grep| awk '{print $1}' | xargs kill -9    connection=SMA_${index}
    Login APP Server    APP_Server_${index}    ${index}
    Csn_Inst.send_command    command=ps -ef | grep iperf -s | grep -v grep| awk '{print $2}' | xargs kill -9    connection=APP_Server_${index}
    Csn_Inst.send_command    command=ps -ef | grep iperf -c ${smawave_ue_addr} | grep -v grep| awk '{print $2}' | xargs kill -9
    ...    connection=APP_Server_${index}
    [Teardown]    Run Keyword and ignore error    Logout APP Server    APP_Server_${index}

SMAwave Calculate and Verify DL Tput
    [Arguments]    ${index}    ${expect_tput}    ${deviation}
    [Documentation]    This keyword used to calculate and verify SMAwave UE DL T_Put with deviation
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : SMAwave Calculate and Verify DL Tput 1 180M 30%
    Csn_Inst.download_file    remote_path=/tmp/openwrt_iperf_${index}.log    local_path=${OUTPUT DIR}    connection=SMA_${index}
    ${dt_dl_row_list}    SWO.Parse Iperf Trace To Rows    file_to_be_parsed=${OUTPUT DIR}/openwrt_iperf_${index}.log
    Should Not Be Equal    ${dt_dl_row_list}    EMPTY    msg="DL traffic can't be reached, the iperf file is empty or not exist!"
    ${T_put}    SWO.Count Average Throughput    iperf_row_list=${dt_dl_row_list}
    ${return_result}    SWO.Check Tput With Deviation    expect_tput=${expect_tput}    average_tput=${T_put}    deviation=${deviation}
    Should Be Equal    ${return_result}    Success

Start and Verify Uplink TCP
    [Arguments]    ${ue_index}    ${duration}    ${iperf_ul_throughput}    ${protocol}
    ...    ${ul_expect_tput}    ${ul_deviation}
    [Documentation]    This keyword used to perform TCP uplink traffic
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : ul
    ...    duration : data transfer duration in robot time string format
    ...    iperf_ul_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp
    ...    ul_expect_tput : desired average data transfer throughput
    ...    ul_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Start and Verify Uplink TCP ul_test 1 ul 120s 30M tcp 25M 20%
    Wait Until Keyword Succeeds    3min    20s    Fetch SMAwave UE Addr    ${ue_index}
    SMAwave UL Traffic    ${ue_index}    ${duration}
    ...    ${iperf_ul_throughput}    ${protocol}    ${ul_expect_tput}    ${ul_deviation}

Start and Verify Uplink UDP
    [Arguments]    ${ue_index}    ${duration}    ${iperf_ul_throughput}    ${protocol}
    ...    ${ul_expect_tput}    ${ul_deviation}
    Wait Until Keyword Succeeds    3min    20s    Fetch SMAwave UE Addr    ${ue_index}
    SMAwave UL Traffic    ${ue_index}    ${duration}
    ...    ${iperf_ul_throughput}    ${protocol}    ${ul_expect_tput}    ${ul_deviation}

SMAwave UL Traffic
    [Arguments]    ${ue_index}    ${duration}    ${iperf_ul_throughput}    ${protocol}
    ...    ${ul_expect_tput}    ${ul_deviation}
    [Documentation]    This keyword used to perform and verify smawave UE uplink data traffic.
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : ul
    ...    duration : data transfer duration in robot time string format
    ...    iperf_ul_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp or udp
    ...    ul_expect_tput : desired average data transfer throughput
    ...    ul_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : SMAwave UL Traffic ul_test 1 ul 120s 30M udp 25M 20%
    SMAwave Start UL Iperf Process    ${ue_index}    ${protocol}    ${iperf_ul_throughput}    ${duration}
    SMAwave Calculate and Verify UL Tput    ${ue_index}    ${ul_expect_tput}    ${ul_deviation}

SMAwave Start UL Iperf Process
    [Arguments]    ${index}    ${proto}    ${T_Put}    ${Tput_dura}
    [Documentation]    This keyword used to start iperf process on both UTE VM and openwrt for SMAwave UE UL data transfer
    ...    index : UE identifier index
    ...    T_Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...
    ...    Example : SMAwave Start UL Iperf Process 1 tcp 30M 120s
    ${T_Put_value}    Convert To String    ${T_Put}
    ${T_Put_value}    Convert To Integer    ${T_Put_value.upper().strip('M')}
    Run Keyword And Return If    ${T_Put_value} == 0    Log To Console    \n[WARN]: Skipping to start UL data due to T_Put = ${T_Put}.
    Log To Console    \nINFO: Begin to generate ${proto} port for UL data transfer.
    ${used_port_list}    SWO.Get Occupied Udp Port List
    ${ul_port_num}    SWO.Get Availabel Udp Port    lines=${used_port_list}
    Log To Console    \nINFO: The ${proto} port used for ${index} UL data transfer is ${ul_port_num}.
    Log To Console    \nINFO: Begin to perform ${index} UL data traffic with T_Put ${T_Put}.
    ${app_server_addr}    Get From Dictionary    ${ute_iperf_itf_ip_dict}    ${index}
    ${ul_cmd_on_openwrt}    Run Keyword If    '${proto}'.lower() == 'tcp'
    ...    Set Variable    nohup /usr/bin/iperf -c ${app_server_addr} -p ${ul_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400 &
    ...    ELSE IF    '${proto}'.lower() == 'udp'
    ...    Set Variable    /usr/bin/iperf -c ${app_server_addr} -u -i1 -l1400 -p ${ul_port_num} -t ${Tput_dura} -b ${T_Put}
    Csn_Inst.send_command    command=iptables -P OUTPUT ACCEPT    connection=SMA_${index}
    Csn_Inst.send_command    command=${ul_cmd_on_openwrt}    connection=SMA_${index}
    ${ul_cmd_on_app_server}    Run Keyword If    '${proto}'.lower() == 'tcp'
    ...    Set Variable    nohup iperf -s -p ${ul_port_num} -t ${Tput_dura} -i1 > /tmp/ute_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${proto}'.lower() == 'udp'
    ...    Set Variable    iperf -s -u -i1 -p ${ul_port_num} -t ${Tput_dura} > /tmp/ute_iperf_${index}.log
    Csn_Inst.send_command    command=${ul_cmd_on_app_server}    connection=APP_Server_${index}
    sleep    1s
    ${isIperfStarting}    Csn_Inst.execute    command=ps | grep iperf | grep ${app_server_addr}    connection=SMA_${index}
    Should Contain    ${isIperfStarting}    ${app_server_addr}    [ERROR] Failed to perform ${index} UL data traffic.
    Log To Console    \nINFO: Successfully perform ${index} UL data traffic with T_Put ${T_Put} duration is ${Tput_dura}.

SMAwave Calculate and Verify UL Tput
    [Arguments]    ${index}    ${expect_tput}    ${deviation}
    [Documentation]    This keyword used to calculate and verify SMAwave UE UL T_Put with deviation
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : SMAwave Calculate and Verify UL Tput 1 30M 20%
    Csn_Inst.download_file    remote_path=/tmp/ute_iperf_${index}.log    local_path=${OUTPUT DIR}/ute_iperf_${index}.log
    ...    connection=APP_Server_${index}
    ${dt_ul_row_list}    SWO.Parse Iperf Trace To Rows    file_to_be_parsed=${OUTPUT DIR}/ute_iperf_${index}.log
    Should Not Be Equal    ${dt_ul_row_list}    EMPTY    msg="UL traffic can't be reached, the iperf file is empty or not exist!"
    ${T_put}    SWO.Count Average Throughput    iperf_row_list=${dt_ul_row_list}
    ${return_result}    SWO.Check Tput With Deviation    expect_tput=${expect_tput}    average_tput=${T_put}    deviation=${deviation}
    Should Be Equal    ${return_result}    Success

SMAwave UE attach Succeed
    [Arguments]    ${ue_index}    ${rat}=5G    ${band}=41    ${arfcn}=${None}
    SMAwave remotely login UE    ${ue_index}
    Wait Until Keyword Succeeds    2min    30s    SMAwave attach    ${ue_index}    ${rat}    ${band}    ${arfcn}
    Verify Attach To Which Cell    ${ue_index}
    ${attached_mode}    Set Variable    ${attached_cell_info}[mode]
    Run Keyword If    '${rat}'=='5G'    Should Be True    '${attached_mode}'=='NR'    [ERROR]Expect attached ${rat} cell, But it's ${attached_mode}!
    ...    ELSE    Should Be True    '${attached_mode}'=='LTE'    [ERROR]Expect attached ${rat} cell, But it's ${attached_mode}!
    ${attached_cellid}    Set Variable    ${attached_cell_info}[cell_details][0][cell_id]
    Should Be True    ${attached_cellid} in ${cellId_list}    [ ERROR ] UE is FAILED to attached target cell: ${attached_cellid} ⊈ ${cellId_list}

SMAwave remotely login UE
    [Arguments]    ${ue_index}
    [Documentation]    This keyword used to remotely(UTE VM) login openwrt
    ...    ue_index : ue identifier index
    ...
    ...    Example : SMAwave remotely login UE 1
    ${tmp_openwrt_5G}=    Run Keyword And Ignore Error    Get From Dictionary    ${5G_UEPC_DICT}    ${ue_index}
    ${tmp_openwrt_4G}=    Run Keyword And Ignore Error    Get From Dictionary    ${4G_UEPC_DICT}    ${ue_index}
    ${openwrt}=    Set Variable If    '${tmp_openwrt_5G}[0]'=='PASS'    ${tmp_openwrt_5G}[-1]    ${tmp_openwrt_4G}[-1]
    Log To Console    ${openwrt}
    Wait Until Keyword Succeeds    60s    20s    Csn_Inst.Connect to    ${openwrt}[cpc_ip]    ${openwrt}[cpc_usr]    ${openwrt}[cpc_pwd]
    ...    alias=SMA_${ue_index}

SMAwave Reboot UE
    [Arguments]    ${ue_index}
    [Documentation]    This keyword used to reboot smawave UE and re-login again to check its status after it bringup
    ...    ue_index : ue identifier index
    ...
    ...    Example : SMAwave Reboot UE 1
    SMAwave remotely login UE    ${ue_index}
    Log To Console    \nINFO:Reboot SMAwave ${ue_index}, wait 60s!
    Csn_Inst.execute    command=/sbin/reboot    connection=SMA_${ue_index}    timeout=5
    Csn_Inst.Disconnect    connection=SMA_${ue_index}
    sleep    60s
    Log To Console    \nINFO:Reconnect to SMAwave ${ue_index}.
    SMAwave remotely login UE    ${ue_index}
    ${isStatusOK}    Run Keyword And Return Status    SMAwave Check Status    ${ue_index}
    Run Keyword If    not ${isStatusOK}    Log To Console    UE status is not OK after reboot    level=ERROR

SMAwave Check Status
    [Arguments]    ${index}
    [Documentation]    This keyword used to ensure smawave UE in unattach status
    ...    index : UE identifier index
    ...
    ...    Example : SMAwave Check Status 1
    Log To Console    \nINFO: Begin to check SMAwave ${index} status.
    ${output}    Send AT Command Succeed    ${check_cmd}    ${index}
    ${result}    SWO.VERIFY ATCMD OUTPUT    input_string=${output}
    Log To Console    \nINFO: Currently the SMAwave ${index} status is ${result}.
    [Return]    ${result}

SMAwave attach
    [Arguments]    ${index}    ${rat}=5G    ${band}=41    ${arfcn}=${None}
    [Documentation]    This keyword used to perform smawave UE attach
    ...    index : UE identifier index
    ...
    ...    Example : SMAwave attach 1
    Log To Console    \nINFO: Begin to perform smawave ${index} Airplane mode.
    Csn_Inst.send_command     command=${airplanemode_cmd}    connection=SMA_${index}
    Log To Console    \nINFO: Begin to perform smawave ${index} attach.
    Csn_Inst.send_command     command=${onlinemode_cmd}    connection=SMA_${index}

    ${attach_cmd_by_arfcn}    Set Variable If    '${rat.upper()}'=='5G' and '${arfcn}'!='None'
    ...    atcmd /dev/ttyUSB1 115200 AT+GTFREQLOCK=1,1,${arfcn},1    None

    ${band_length}    Get Length    ${band}
    ${lteband}    Set Variable If    '${rat.upper()}'=='4G' and ${band_length}==1    10${band}
    ...    '${rat.upper()}'=='4G' and ${band_length}>1    1${band}
    ${attach_cmd_by_band}    Set Variable If    '${rat.upper()}'=='5G'    atcmd /dev/ttyUSB1 115200 AT+GTACT=,,,50${band}
    ...    '${rat.upper()}'=='4G'    atcmd /dev/ttyUSB1 115200 AT+GTACT=,,,${lteband}

    ${attach_cmd}    Set Variable If    '${attach_cmd_by_arfcn}'!='None'    ${attach_cmd_by_arfcn}    ${attach_cmd_by_band}

    ${setBandOK}    Run Keyword And Return Status    Run Keywords    Send AT Command Succeed    ${attach_cmd}    ${index}    False
    ...    AND    Sleep    10s
    Run Keyword If    not ${setBandOK}    SMAwave Reboot UE    ${index}
    ${isAttached}    Run Keyword And Return Status    Get and check UE ip address    ${index}
    Run Keyword If    not ${isAttached}    SMAwave Reboot UE    ${index}
    Get and check UE ip address    ${index}
    Set Suite Variable    ${${index}_in_use}    True

Get and check UE ip address
    [Arguments]    ${index}
    ${ute_iperf_itf_ip}    Set Variable
    ...    ${ue_inline['${index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['iperf_interface_ip']}
    Log To Console    \nINFO: The UTE iperf interface IP address for ${index} is ${ute_iperf_itf_ip}.
    Log To Console    \nINFO: Begin to get SMAwave ${index} assigned IP address.
    ${smawave_ue_addr}    Wait Until Keyword Succeeds    60s    20s    Get UE ip address    ${index}
    Run Keyword If    '${ping_flag}' == 'True'    SMAwave Ping peer before data transfer    ${index}    5
    Set To Dictionary    ${sma_ue_addr_dict}    ${index}    ${smawave_ue_addr}
    Set To Dictionary    ${ute_iperf_itf_ip_dict}    ${index}    ${ute_iperf_itf_ip}

Get UE ip address
    [Arguments]    ${index}
    Csn_Inst.send_command    command=${get_IPV4addr_cmd}    connection=SMA_${index}
    ${ip_addr}    Csn_Inst.read_output    connection=SMA_${index}
    ${smawave_ue_addr}    Strip String    ${ip_addr}    mode=right    characters=\n
    Log To Console    \nINFO: SMAwave ${index} assigned IP is ${smawave_ue_addr}.
    Should Not Be Empty    ${smawave_ue_addr}    [ERROR]Cannot fetch ip address, UE is failed to attach!
    [Return]    ${smawave_ue_addr}

SMAwave setup
    [Documentation]    This keyword used to initiate some list variables for SMAwave UE.
    ${ute_iperf_itf_ip_dict}    Create Dictionary
    Set Suite Variable    ${ute_iperf_itf_ip_dict}
    ${sma_ue_addr_dict}    Create Dictionary
    Set Suite Variable    ${sma_ue_addr_dict}

Postconditions_ForUE
    [Documentation]    This keyword is to perform SMAWave UE teardown operation.
    ...    It must be called in Teardown section of test case.
    FOR    ${i}    IN RANGE    ${UE_NUM}
        ${index}=    Evaluate    ${i}+1
        ${ue_in_use_status}    Get Variable Value    ${${index}_in_use}
        postcondition_indexUE    ${index}    ${ue_in_use_status}
        Set Suite Variable    ${${index}_in_use}    False
    END

postcondition_indexUE
    [Arguments]    ${ue_index}    ${ue_in_use_status}
    [Documentation]    This keyword used to perform specific index SMAwave UE teardown operation.
    ...    Note: this KW is private and should not be called by test case directly.
    # add stop comd process to ensure UE successfully detach
    Run Keyword If    '${ue_in_use_status}' == 'True'    run keywords    Csn_Inst.send_command    command=${comd_stop_cmd}
    ...    connection=SMA_${ue_index}
    ...    AND    sleep    5s
    ...    AND    SMAwave detach    ${ue_index}
    ...    AND    sleep    2s
    Run Keyword And Ignore Error    Csn_Inst.send_command    command=${comd_start_cmd}    connection=SMA_${ue_index}
    sleep    2s
    Run Keyword If    '${dl_async_flag}' == 'True'    run keywords    Stop Async    alias=DL_async_${ue_index}
    ...    AND    Run Keyword If    '${ue_index}' == '${UE_NUM}'    Set Suite Variable    ${dl_async_flag}    False
    Run Keyword If    '${ul_async_flag}' == 'True'    run keywords    Stop Async    alias=UL_async_${ue_index}
    ...    AND    Run Keyword If    '${ue_index}' == '${UE_NUM}'    Set Suite Variable    ${ul_async_flag}    False
    sleep    2s
    ${rm_route_file_cmd}    Set Variable    rm -f /tmp/${ue_index}_route_table.txt
    Run Keyword If    '${add_default_route_flag}' == 'True' and '${ue_in_use_status}' == 'True'
    ...    Csn_Inst.send_command    command=${rm_route_file_cmd}    connection=SMA_${ue_index}
    Run Keyword If    '${ue_in_use_status}' == 'True'    run keywords    Csn_Inst.Disconnect    connection=SMA_${ue_index}
    ...    AND    sleep    2s
    ...    AND    Csn_Inst.Disconnect    connection=APP_Server_${ue_index}

SMAwave detach
    [Arguments]    ${index}
    [Documentation]    This keyword used to perform AT command to detach smawave UE
    ...    index : UE identifier index
    ...
    ...    Example : SMAwave detach 1
    Log To Console    \nINFO: Begin to perform smawave ${index} detach.
    Send AT Command Succeed    ${airplanemode_cmd}    ${index}    False
    ${output}    Send AT Command Succeed    ${check_cmd}    ${index}
    ${result}    SWO.VERIFY ATCMD OUTPUT    input_string=${output}
    Should Be Equal    ${result}    Idle

Fetch SMAwave UE Addr
    [Arguments]    ${index}
    [Documentation]    This keyword used to get smawave UE IP address after attach operation.
    ...    please ensure comd service restart otherwise can't obtain assigned address.
    ...    index : UE identifier index
    ...
    ...    Example : Fetch SMAwave UE Addr 1
    Log To Console    \nINFO: Begin to restart ${index} openwrt comd service.
    ${ute_iperf_itf_ip}    Set Variable
    ...    ${ue_inline['${index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['iperf_interface_ip']}
    Set To Dictionary    ${ute_iperf_itf_ip_dict}    ${index}    ${ute_iperf_itf_ip}
    Log To Console    \nINFO: The UTE iperf interface IP address for ${index} is ${ute_iperf_itf_ip}.
    Log To Console    \nINFO: Begin to get SMAwave ${index} assigned IP address.
    Csn_Inst.send_command    command=${get_IPV4addr_cmd}    connection=SMA_${index}
    ${ip_addr}    Csn_Inst.read_output    connection=SMA_${index}
    ${smawave_ue_addr}    Strip String    ${ip_addr}    mode=right    characters=\n
    Set To Dictionary    ${sma_ue_addr_dict}    ${smawave_ue_addr}
    Log To Console    \nINFO: SMAwave ${index} assigned IP address is ${smawave_ue_addr}.
#    Run Keyword If    '${add_default_route_flag}' == 'True'
    ...    Check and Add default route between App Server and SMAwave UE    ${index}

Check and Add default route between App Server and SMAwave UE
    [Arguments]    ${ue_index}
    [Documentation]    This keyword is to enusre the default route is exsit between App Server and SMAwave UE before
    ...    data transfer is performed, add one default route if not exist.
    ...    Note : This keyword is just used for some abnormal SMAwave UEs as WA, it will be removed
    ...    or commented when related bug is resolved, the issue appear on UE load SQXR60_V1.0.1
    ...    ue_index : UE identifier index
    ...
    ...    Example : Check and Add default route between App Server and SMAwave UE 1
    Log To Console    \nINFO:Begin to Check whether default route is exist between App Server and SMAwave UE.
    ${route_check_cmd}    Set Variable    ip route > /tmp/${ue_index}_route_table.txt
#    ${route_add_cmd}    Set Variable    route add -net 0.0.0.0 gw 27.168.1.9
    ${route_add_cmd}    Set Variable    route add -net 0.0.0.0 gw 10.108.241.1
    Csn_Inst.send_command    command=${route_check_cmd}    connection=SMA_${ue_index}
    Csn_Inst.download_file    remote_path=/tmp/${ue_index}_route_table.txt    local_path=${OUTPUT DIR}    connection=SMA_${ue_index}
    ${return_result}    SWO.check default route exist    input_file=${OUTPUT DIR}/${ue_index}_route_table.txt
    Run Keyword If    '${return_result}' == 'True'    Log To Console    \nINFO:the default route is already exist,no other operation is required!
    ...    ELSE    run keywords    Log To Console    \nINFO:the default route is not exist,begin to add it!
    ...    AND    Csn_Inst.send_command    command=${route_add_cmd}    connection=SMA_${ue_index}

Get and Kill Iperf Process on Openwrt
    [Arguments]    ${index}
    [Documentation]    This keyword used to get iperf process on openwrt and then kill them.
    ...    Normally it is used for SMAwave UE DL data transfer.
    ...    index : UE identifier index
    ...
    ...    Example : Get and Kill Iperf Process on Openwrt 1
    Csn_Inst.send_command    command=${get_iperf_id_cmd}    connection=SMA_${index}
    ${process_id}    Csn_Inst.read_output    connection=SMA_${index}
    ${iperf_process}    Split String    ${process_id}    separator=\n
    @{iperf_process_id}    Get Slice From List    ${iperf_process}    start=0    end=-1
    Log To Console    \nINFO: iperf id on ${index} openwrt is @{iperf_process_id}.
    Set suite variable    @{iperf_process_id}
    FOR    ${item}    IN    @{iperf_process_id}
        Log To Console    \nINFO: Begin to kill iperf process id ${item} on ${index} openwrt.
        Csn_Inst.send_command    command=kill -9 ${item}    connection=SMA_${index}
        sleep    2s
    END

Login APP Server
    [Arguments]    ${conn_alias}    ${index}=1
    [Documentation]    This keyword used to remotely login App Server before data transfer.
    ...    conn_alias : remotely login session alias
    ...    index : UE identifier index, default 1
    ...
    ...    Example : Login APP Server login_alias 1
    ${app_server_addr}    Set Variable    ${ue_inline['${index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['ssh']['host']}
    ${app_server_user}    Set Variable    ${ue_inline['${index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['ssh']['user']}
    ${app_server_pwd}    Set Variable    ${ue_inline['${index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['ssh']['password']}
    Wait Until Keyword Succeeds    3min    20s    Csn_Inst.Connect to    ${app_server_addr}    ${app_server_user}    ${app_server_pwd}
    ...    alias=${conn_alias}

Logout APP Server
    [Arguments]    ${conn_alias}
    [Documentation]    This keyword used to remotely logout App Server after data transfer.
    ...    conn_alias : remotely login session alias

    ...    Example : Logout APP Server    login_alias

    ${isLogout}    Run Keyword And Return Status    Csn_Inst.Disconnect        alias=${conn_alias}
    Run Keyword If    ${isLogout}    Log To Console    [ INFO ] Disconnect to Iperf server[conn_alias].
    ...    ELSE    Log To Console    [ ERROR ]Failed to disconnect iperf server.

SMAwave Start DL Async Process
    [Arguments]    ${index}    ${T_Put}    ${Tput_dura}    ${protocol}
    [Documentation]    This keyword used to start SMAwave UE DL async iperf process, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    T_Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...
    ...    Example : SMAwave Start DL Async Process 1 80M 120s tcp/udp
    Wait Until Keyword Succeeds    3min    20s    Fetch SMAwave UE Addr    ${index}
    Log To Console    \nINFO: Begin to generate ${protocol} port for SMAwave UE DL data transfer.
    ${used_port_list}    SWO.Get Occupied Udp Port List
    ${iperf_port_num}    SWO.Get Availabel Udp Port    lines=${used_port_list}
    Log To Console    \nINFO: The ${protocol} port used for SMAwave ${index} Async DL data transfer is ${iperf_port_num}.
    ${smawave_ue_addr}    Get From Dictionary    ${sma_ue_addr_dict}    ${index}
    ${dl_cmd_on_openwrt}    Run Keyword If    '${protocol}'.lower() == 'tcp'
    ...    Set Variable    /usr/bin/iperf -s -p ${iperf_port_num} -i1 -t ${Tput_dura} -D > /tmp/openwrt_iperf_${index}.log
    ...    ELSE IF    '${protocol}'.lower() == 'udp'
    ...    Set Variable    /usr/bin/iperf -s -u -l1400 -w10M -i1 -p ${iperf_port_num} -t ${Tput_dura} -D > /tmp/openwrt_iperf_${index}.log
    Csn_Inst.send_command    command=${dl_cmd_on_openwrt}    connection=SMA_${index}
    sleep    1s
    #Run Keyword If    '${ping_flag}' == 'True'    SMAwave Ping peer before data transfer    ${index}    5
    Log To Console    \nINFO: Begin to perform SMAwave ${index} Async DL data traffic with throughput ${T_Put}.
    ${iperf_cmd_on_app}    Run Keyword If    '${protocol}'.lower() == 'tcp'
    ...    Set Variable    iperf -c ${smawave_ue_addr} -p ${iperf_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400
    ...    ELSE IF    '${protocol}'.lower() == 'udp'
    ...    Set Variable    iperf -c ${smawave_ue_addr} -u -i1 -l1400 -p ${iperf_port_num} -b ${T_Put} -t ${Tput_dura}
    Login APP Server    APP_Server_${index}    ${index}
    Log To Console    \nStart to use ute-async to start iperf process for SMAwave ${index}.
    Start Async    Csn_Inst    execute    command=${iperf_cmd_on_app}    connection=APP_Server_${index}    alias=DL_async_${index}
    Log To Console    \nAsync process has been started for SMAwave ${index}, you can perform other operations/keywords now.
    Set Suite Variable    ${dl_async_flag}    True

Start DL Async Process
    [Arguments]    ${index}    ${T_Put}    ${Tput_dura}    ${protocol}=udp
    [Documentation]    This keyword used to start DL Async process for some specific OAM operation, FOR USER USAGE.
    ...    when data transfer is also ongoing.
    ...    NOTE:Remember to call Postconditions_ForUE do teardown at end of each TC, when you use this KW to start process with SMAwave UE.
    ...    index : UE identifier index
    ...    T_Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...    data_trans_name : data transfer name for android UE
    ...
    ...    Example-1 : Start DL Async Process 1 80M 120s
    ...    Example-2 : Start DL Async Process 1 80M 120s tcp
    ...    Example-3 : Start DL Async Process 1 80M 120s tcp downlink_test
    SMAwave Start DL Async Process    ${index}    ${T_Put}    ${Tput_dura}    ${protocol}

SMAwave Calculate and Verify DL Async Tput
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}
    [Documentation]    This keyword used to calculate and verify SMAwave UE Async DL T_Put, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for smawave waiting the async process completion
    ...
    ...    Example : SMAwave Calculate and Verify DL Async Tput 1 180M 30% 120s
    Log To Console    \nAwait the completion of SMAwave ${index} Async DL data transfer, please wait a sec.
    ${updated_tput_dura}    Strip String    ${Tput_dura}    mode=right    characters=s
    ${result}=    Wait Until Keyword Succeeds    2x    100ms    Wait for async result    timeout=${updated_tput_dura}    alias=DL_async_${index}
    Log    \nSMAwave ${index} DL data transfer async result: ${result}.
    Csn_Inst.download_file    remote_path=/tmp/openwrt_iperf_${index}.log    local_path=${OUTPUT DIR}    connection=SMA_${index}
    Get and Kill Iperf Process on Openwrt    ${index}
    ${dt_dl_row_list}    SWO.Parse Iperf Trace To Rows    file_to_be_parsed=${OUTPUT DIR}/openwrt_iperf_${index}.log
    Should Not Be Equal    ${dt_dl_row_list}    EMPTY    msg="DL traffic can't be reached, the iperf file is empty or not exist!"
    ${T_put}    SWO.Count Average Throughput    iperf_row_list=${dt_dl_row_list}
    ${return_result}    SWO.Check Tput With Deviation    expect_tput=${expect_tput}    average_tput=${T_put}    deviation=${deviation}
    Should Be Equal    ${return_result}    Success

Calculate and Verify DL Async Tput
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}
    [Documentation]    This keyword used to calculate and verify Async DL T_Put with deviation, FOR USER USAGE.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for smawave waiting the async process completion,android ue not used.
    ...    data_trans_name : data transfer name for android UE
    ...
    ...    Example-1 : Calculate and Verify DL Async Tput 1 180M 30% 120s
    ...    Example-2 : Calculate and Verify DL Async Tput 1 180M 30% 120s downlink_test
    SMAwave Calculate and Verify DL Async Tput    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}

SMAwave Start UL Async Process
    [Arguments]    ${index}    ${T_Put}    ${Tput_dura}    ${protocol}
    [Documentation]    This keyword used to start SMAwave UE UL async iperf process, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    T_Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...
    ...    Example : SMAwave Start UL Async Process 1 30M 180s tcp/udp
    Log To Console    \nINFO: Begin to generate ${protocol} port for SMAwave ${index} Async UL data transfer.
    ${used_port_list}    SWO.Get Occupied Udp Port List
    ${ul_port_num}    SWO.Get Availabel Udp Port    lines=${used_port_list}
    Log To Console    \nINFO: The ${protocol} port used for SMAwave ${index} async UL data transfer is ${ul_port_num}.
    Log To Console    \nINFO: Begin to perform SMAwave ${index} async UL data transfer with T_Put ${T_Put}.
    ${app_server_addr}    Get From Dictionary    ${ute_iperf_itf_ip_dict}    ${index}
    ${ul_cmd_on_openwrt}    Run Keyword If    '${protocol}'.lower() == 'tcp'
    ...    Set Variable    nohup /usr/bin/iperf -c ${app_server_addr} -p ${ul_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400 &
    ...    ELSE IF    '${protocol}'.lower() == 'udp'
    ...    Set Variable    /usr/bin/iperf -c ${app_server_addr} -u -i1 -p ${ul_port_num} -t ${Tput_dura} -b ${T_Put}
    Csn_Inst.send_command    command=${ul_cmd_on_openwrt}    connection=SMA_${index}
    ${ul_cmd_on_app_server}    Run Keyword If    '${protocol}'.lower() == 'tcp'
    ...    Set Variable    nohup iperf -s -p ${ul_port_num} -t ${Tput_dura} -i1 > /tmp/ute_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${protocol}'.lower() == 'udp'
    ...    Set Variable    iperf -s -u -i1 -p ${ul_port_num} -t ${Tput_dura} > /tmp/ute_iperf_${index}.log
    Start Async    Csn_Inst    execute    command=${ul_cmd_on_app_server}    connection=APP_Server_${index}    alias=UL_async_${index}
    Log To Console    \nINFO: Successfully perform SMAwave ${index} async UL data transfer with T_Put ${T_Put} duration is ${Tput_dura}.
    Set Suite Variable    ${ul_async_flag}    True

Start UL Async Process
    [Arguments]    ${index}    ${T_Put}    ${Tput_dura}    ${protocol}=udp
    [Documentation]    This keyword used to start UL Async process for some specific OAM operation, FOR USER USAGE.
    ...    when data transfer is also ongoing.
    ...    NOTE:Remember to call Postconditions_ForUE do teardown at end of each TC, when you use this KW to start process with SMAwave UE.
    ...    index : UE identifier index
    ...    T_Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...    data_trans_name : data transfer name for android UE
    ...
    ...    Example-1 : Start UL Async Process 1 30M 180s
    ...    Example-2 : Start UL Async Process 1 30M 180s tcp
    ...    Example-3 : Start UL Async Process 1 30M 180s tcp uplink_test
    SMAwave Start UL Async Process    ${index}    ${T_Put}    ${Tput_dura}    ${protocol}

SMAwave Calculate and Verify UL Async Tput
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}
    [Documentation]    This keyword used to calculate and verify SMAwave UE Async UL T_Put, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for waiting the async process completion
    ...
    ...    Example : SMAwave Calculate and Verify UL Async Tput 1 30M 20% 120s
    Log To Console    \nAwait the completion of SMAwave ${index} Async UL data transfer, please wait a sec.
    ${updated_tput_dura}    Strip String    ${Tput_dura}    mode=right    characters=s
    ${result}=    Wait Until Keyword Succeeds    2x    100ms    Wait for async result    timeout=${updated_tput_dura}    alias=UL_async_${index}
    Log    \nSMAwave ${index} async UL data transfer async result: ${result}.
    Csn_Inst.download_file    remote_path=/tmp/ute_iperf_${index}.log    local_path=${OUTPUT DIR}/ute_iperf_${index}.log
    ...    connection=APP_Server_${index}
    ${dt_ul_row_list}    SWO.Parse Iperf Trace To Rows    file_to_be_parsed=${OUTPUT DIR}/ute_iperf_${index}.log
    Should Not Be Equal    ${dt_ul_row_list}    EMPTY    msg="UL traffic can't be reached, the iperf file is empty or not exist!"
    ${T_put}    SWO.Count Average Throughput    iperf_row_list=${dt_ul_row_list}
    ${return_result}    SWO.Check Tput With Deviation    expect_tput=${expect_tput}    average_tput=${T_put}    deviation=${deviation}
    Should Be Equal    ${return_result}    Success

Calculate and Verify UL Async Tput
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}
    [Documentation]    This keyword used to calculate and verify Async UL T_Put with deviation, FOR USER USAGE.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for smawave waiting the async process completion,android ue not used.
    ...    data_trans_name : data transfer name for android UE
    ...
    ...    Example-1 : Calculate and Verify UL Async Tput 1 30M 20% 120s
    ...    Example-2 : Calculate and Verify UL Async Tput 1 180M 30% 120s uplink_test
    SMAwave Calculate and Verify UL Async Tput    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}

Get and Kill Iperf Process on Remote
    [Arguments]    ${cmd_get_iperf}    ${connection_alias}
    [Documentation]    This keyword used to get iperf process on ute or ue pc and then kill them.
    ...    cmd_get_iperf : the cmd to get iperf
    ...    conn_alias : remotely login session alias
    Csn_Inst.send_command    command=${cmd_get_iperf}    connection=${connection_alias}
    ${process_id}    Csn_Inst.read_output    connection=${connection_alias}
    ${iperf_process}    Split String    ${process_id}    separator=\n
    @{iperf_process_id}    Get Slice From List    ${iperf_process}    start=0    end=-1
    Log To Console    \nINFO: iperf id on remote is @{iperf_process_id}.
    Set suite variable    @{iperf_process_id}
    FOR    ${item}    IN    @{iperf_process_id}
        Log To Console    \nINFO: Begin to kill iperf process id ${item} on remote.
        Csn_Inst.send_command    command=kill -9 ${item}    connection=${connection_alias}
        sleep    2s
    END

Reserve ue for tests
    [Arguments]    ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_ANDROID_UE
    [Documentation]    This keyword is used to detect ue that connect to control PC by USB.
    ...    It is strongly suggested to put this keyword into the suite setup.
    ...    If you put the keyword in the testcase scope, ue.teardown will automatically called when exiting the scope.
    ...    :param UE_CAPABILITIES: REAL_ANDROID_UE.
    ...    :param UE_alias: It is a name to distingush ue.
    ute_ue.require Ue    ${UE_alias}    capabilities=${UE_CAPABILITIES}

Get Remote Pair TestLine Cell Info
    [Arguments]    ${remote_ip}    ${remote_username}    ${remote_passwd}
    [Documentation]    Get remote peer dedicated cell info
    ...    :param remote_ip: ip address of remote testline
    ...    :param remote_username: user name of remote testline
    ...    :param remote_passwd: user password of remote testline
    ${return_cell_info}    SWO.Get Remote Testline Cell Info    vm_ipaddr=${remote_ip}    vm_user=${remote_username}
    ...    vm_password=${remote_passwd}
    ${cell_list}    SWO.Parse Remote Cell Info Into List    cell_info_dict=${return_cell_info['cells']}
    [Return]    ${cell_list}

Verify Attach To Which Cell
    [Arguments]    ${index}
    [Documentation]    verify specific UE attach on which cell
    ${output}    Send AT Command Succeed    ${check_attach_cmd}    ${index}
    ${attached_cell_info}    SWO.Parse Atcmd Cell Info Into Dict    input_str=${output}
    Log To Console    \nINFO: Attached Cell Info : ${attached_cell_info}
    Set Suite Variable    ${attached_cell_info}

Get Frequency Locking Information
    [Arguments]    ${ue_index}
    [Documentation]    This keyword used to get the currently locked frequency.
    ...    Returned locked frequency: {'4G': {'xfcn': '1650', 'pci': '310'}, '5G': {'xfcn': '636200', 'scs': '1'}}
    ...    No frequency locked: {'4G': None, '5G': None}
    ...    Note : Before using this kW, please ensure that the scanning mode selected on the UE web page is full frequency band !!
    ...
    ...    Example : testsuite/Nanjing/OAM/Pilot/Pilot_SMAwave_Lock_Frequency_Test.robot
    SMAwave remotely login UE    ue_index=${ue_index}
    Csn_Inst.send_command    command=${comd_stop_cmd}    connection=SMA_${ue_index}
    Sleep    2s
    Log To Console    \nBegin to query current frequency locking infomation
    Csn_Inst.send_command    command=${check_freq_lock_cmd}    connection=SMA_${ue_index}
    ${output}    Csn_Inst.read_output    connection=SMA_${ue_index}
    ${result}    SWO.Parse Atcmd Locked Freq Info    input_string=${output}
    Log To Console    \nINFO: Currentlly Locked Frequency Info : ${result}
    Dictionary Should Not Contain Value    ${result}    ongoing
    [Teardown]    Run keywords    Csn_Inst.send_command    command=${comd_start_cmd}    connection=SMA_${ue_index}
    ...    AND    Csn_Inst.Disconnect    connection=SMA_${ue_index}
    [Return]    ${result}

Lock 4G or 5G Frequency
    [Arguments]    ${ue_index}    ${tech}    ${xfcn}    ${4g_pci_or_5g_scs}
    [Documentation]    Note : Before using this kW, please ensure that the scanning mode selected on the UE web page is full frequency band !!
    ...
    ...    Example : testsuite/Nanjing/OAM/Pilot/Pilot_SMAwave_Lock_Frequency_Test.robot
    SMAwave remotely login UE    ue_index=${ue_index}
    Csn_Inst.send_command    command=${comd_stop_cmd}    connection=SMA_${ue_index}
    Sleep    2s
    Log To Console    \nBegin to lock ${tech} frequency
    ${lock_cmd}    Run Keyword If    '${tech}'.lower() == '4g'    Set Variable    ${freq_lock_unlock_cmd}0,1,${xfcn},${4g_pci_or_5g_scs}
    ...    ELSE IF    '${tech}'.lower() == '5g'    Set Variable    ${freq_lock_unlock_cmd}1,1,${xfcn},${4g_pci_or_5g_scs}
    Csn_Inst.send_command    command=${lock_cmd}    connection=SMA_${ue_index}
    Sleep    2s
    ${output}    Csn_Inst.read_output    connection=SMA_${ue_index}
    Should Not Contain    ${output}    ERROR
    Should Contain    ${output}    OK
    Log To Console    \nLock ${tech} frequency Success
    [Teardown]    Run keywords    Csn_Inst.send_command    command=${comd_start_cmd}    connection=SMA_${ue_index}
    ...    AND    Csn_Inst.Disconnect    connection=SMA_${ue_index}

Unlock 4G or 5G Frequency
    [Arguments]    ${ue_index}    ${tech}
    [Documentation]    Note : Before using this kW, please ensure that the scanning mode selected on the UE web page is full frequency band !!
    ...
    ...    Example : testsuite/Nanjing/OAM/Pilot/Pilot_SMAwave_Lock_Frequency_Test.robot
    SMAwave remotely login UE    ue_index=${ue_index}
    Csn_Inst.send_command    command=${comd_stop_cmd}    connection=SMA_${ue_index}
    Sleep    2s
    Log To Console    \nBegin to unlock ${tech} frequency
    ${unlock_cmd}    Run Keyword If    '${tech}'.lower() == '4g'    Set Variable    ${freq_lock_unlock_cmd}0,0
    ...    ELSE IF    '${tech}'.lower() == '5g'    Set Variable    ${freq_lock_unlock_cmd}1,0
    Csn_Inst.send_command    command=${unlock_cmd}    connection=SMA_${ue_index}
    ${output}    Csn_Inst.read_output    connection=SMA_${ue_index}
    Should Not Contain    ${output}    ERROR
    Should Contain    ${output}    OK
    Log To Console    \nUnlock ${tech} frequency Success
    [Teardown]    Run keywords    Csn_Inst.send_command    command=${comd_start_cmd}    connection=SMA_${ue_index}
    ...    AND    Csn_Inst.Disconnect    connection=SMA_${ue_index}

Send AT Command Succeed
    [Arguments]    ${at_command}    ${index}    ${isSuccessd}=True
    ${result}    Wait Until Keyword Succeeds    120s    10s    _send at command and read output
    ...    ${at_command}    ${index}    ${isSuccessd}
    [Return]    ${result}

_send at command and read output
    [Arguments]    ${at_command}    ${index}    ${isSuccessd}
    Csn_Inst.send_command    command=${at_command}    connection=SMA_${index}
    ${output}    Csn_Inst.read_output    connection=SMA_${index}
    ${tmp_key}=    Run Keyword If    '=' in '${at_command.split('AT+')[1]}'    Set Variable    ${at_command.split('AT+')[1].split('=')[0]}
    ...    ELSE    Set Variable    ${at_command.split('AT+')[1].split('?')[0]}
    Run Keyword If    ${isSuccessd}    Should Contain    ${output}    ${tmp_key}
    ...    ELSE    Should Be True    '${output.strip('\r\n')}'=='OK'
    [Return]   ${output}
