*** Settings ***
Documentation
...    author: Ye Dan Zhou
...    maintainer : Jingang Sun
...    contact: ye_dan.yz.zhou@nokia.com
...             jingang.sun@nokia-sbell.com
...    Generic UE keywords, refer to sample test case at below link
...    https://confluence.ext.net.nokia.com/display/NewMobility/How+to+use+UE+keywords+in+auto+TCs
...    Note: This file is no longer in use, origin path: testsuite/Nanjing/OAM/Resources/robot/SC_UE_keywords.robot

Library    ute_async
Library    String
Library    Collections
Library    OperatingSystem
Library    taf.ue  WITH NAME   ute_ue
Library    taf.gnb.oam.coam.admin    WITH NAME    coam
Library    ../python/DEVNJ_UE.py    WITH NAME    UE
Library    ../python/smawave_operation.py   WITH NAME   SWO
Library    taf.sbts.oam.coam.admin   WITH NAME  sbts_admin
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    Csn_Inst
Library    taf.ul.sc.tl_config.TestLineConfiguration
Library    taf.ul.sc.gnb.oam.rest.CommonOAM  oam_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}  WITH NAME  RestAPI

*** Variables ***
${ADBLogFlag}    True
${ping_flag}    True
${add_default_route_flag}    True
${dl_async_flag}    False
${ul_async_flag}    False
@{SupportedHuaweiUE}    EVR_AN00
${check_cmd}    atcmd /dev/ttyUSB2 115200 AT+COPS?
${attach_cmd}    atcmd /dev/ttyUSB2 115200 AT+CFUN=1
${detach_cmd}    atcmd /dev/ttyUSB2 115200 AT+CFUN=4
${comd_start_cmd}    /etc/init.d/comd  start
${comd_stop_cmd}    /etc/init.d/comd stop
${firewall_stop_cmd}    /etc/init.d/firewall stop
${get_iperf_id_cmd}    /bin/ps | grep iperf | grep -v grep | awk '{print $1}'
${get_iperf_id_cmd_android}     /bin/ps -ef | grep iperf | grep -v grep | awk '{print $2}'
${get_IPV4addr_cmd}    ifconfig usb0.1 | grep 'inet addr' | awk '{print $2}' | tr -d 'addr:'
${get_IPV6addr_cmd}    ifconfig usb0.1 | grep 'inet6 addr' | grep 'Scope:Global'| awk '{print $3}' | tr A-Z a-z | cut -d '/' -f 1
@{exception_ue_list}   ELS_AN00  TAS_AN00
${iperf_path}    /data/local/tmp/iperf
${check_attach_cmd}  atcmd /dev/ttyUSB2 115200 AT+GTCCINFO?
${ipv4_pattern}    (?<![\\.\\d])(([1-9]?\\d|1\\d\\d|2[0-4]\\d|25[0-5])\\.){3}([1-9]?\\d|1\\d\\d|2[0-4]\\d|25[0-5])(?![\\.\\d])
${check_freq_lock_cmd}  atcmd /dev/ttyUSB2 115200 AT+GTFREQLOCK?
${freq_lock_unlock_cmd}  atcmd /dev/ttyUSB2 115200 AT+GTFREQLOCK=

*** Keywords ***
All Setup
    OAM Setup
    Set UE Variables

Postconditions_ForCall
    Stop ADB Log
    Postconditions

Set UE Variables
    # ${ue_config} loaded from the testline configuration file
    ${ue_config}=    UE.Load Ue Config    ${tl}
    Log To Console    load ue configuration result: ${ue_config}
    Return From Keyword If    ${ue_config}==None

    Log To Console    ue configuration was loaded, prepare UE env...
    ${ue_yaml}    Set Variable    ${ue_config}
    ${ue_inline}    Set Variable    ${ue_yaml['UE_POOLS']['AndroidUePool']['inline_config']}
    ${UE_NUM}=    Get length     ${ue_inline}
    ${UEPC_DICT_LIST}    Create List
    :FOR    ${i}    IN RANGE    ${UE_NUM}
    \    ${index}=   Evaluate   ${i}+1
    \    ${ue_name}    Set Variable    UE_${index}
    \    ${ue_details}    Set Variable    ${ue_inline['${ue_name}']}
    \    ${ue_type_flag}    Set Variable    ${ue_details['CAPABILITIES'][1]}
    \    Set Suite Variable     ${ue_type_flag}
    \    ${ue_constr}    Set Variable    ${ue_details['CONSTRUCTOR_PARAMETERS']}
    \    ${ue_config}    Set Variable    ${ue_constr['configuration']}
    \    ${cpc_ip}    Set Variable    ${ue_config['ue_pc_ip']}
    \    ${cpc_usr}    Set Variable    ${ue_config['login']}
    \    ${cpc_pwd}    Set Variable    ${ue_config['password']}
    \    ${sn}    Set Variable    ${ue_constr['serial_number']}
    \    ${pyro_dir}    Set Variable    ${ue_config['server_dir']}
    \    &{UEPC_DICT}=    Create Dictionary
        ...    cpc_ip=${cpc_ip}
        ...    cpc_usr=${cpc_usr}
        ...    cpc_pwd=${cpc_pwd}
        ...    sn=${sn}
        ...    cpc_pyrodir=${pyro_dir}
    \    Append to List    ${UEPC_DICT_LIST}    ${UEPC_DICT}
    Set Suite Variable    ${UEPC_DICT_LIST}
    Set Suite Variable    ${UE_NUM}
    Set Suite Variable    ${ADBLogFlag}
    ${isNSA}=    Get BTS mode
    Set Suite Variable    ${isNSA}
    Set Suite Variable    ${ue_inline}
    Run Keyword If  '${isNSA}' == 'NSA'  Get anchor eNB Info
    ...    ELSE IF  '${isNSA}' == 'SA'  Get gNB Cell Info
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'  SMAwave setup

Get BTS mode
    [Documentation]  This keyword used to get BTS running mode:
    ...    4GSA  for 4G LTE only
    ...    NSA   for 5G NR NSA mode
    ...    SA    for 5G NR SA mode
    Return from keyword if    '${ADBLogFlag}' == 'False'
    ${test_mode}  SWO.Check BTS Mode  input_config=${tl}
    ${running_mode}  Set Variable If  '${test_mode}' == '4GSA'  ${test_mode}
    ${running_mode}  Run Keyword If  '${test_mode}' == '5G'  Get NR Mode From SCF
    [Return]  ${running_mode}

Get NR Mode From SCF
    RestAPI.Get current commissioning  log_dir=${OUTPUT DIR}  scf_name=Current_SCF.xml
    sleep  2s
    scf.Load Scf    file_path=${OUTPUT DIR}/Current_SCF.xml
    ${param_value}    scf.Get Value From Scf    p_name=gNbCuType
    [Return]  ${param_value}

Get anchor eNB info
    Return from keyword if    '${ue_type_flag}' == 'SMAWAVE_UE'
    Return from keyword if    '${ADBLogFlag}' == 'False'
    Return from keyword if    '${isNSA}' != 'NSA'
    ${ip_addr_type}  SWO.Check Ipaddr Type  input_config=${tl}
    ${enb_x2ip}  Run Keyword If  '${ip_addr_type}' == 'X2'  Set Variable  ${tl.enbs[0].x2_link_addr.v4}
    ...    ELSE IF  '${ip_addr_type}' == 'OAM'  Set Variable  ${tl.enbs[0].oam_ip.v4}
    ${enb_username}=    Set Variable     toor4nsn
    ${enb_password}=    Set Variable    oZPS0POrRieRtu
    Wait Until Keyword Succeeds    1min    20s
    ...   Csn_Inst.Connect to   ${enb_x2ip}    ${enb_username}    ${enb_password}    alias=enb
    ${enb_type}=    Get enb type    ${enb_x2ip}    enb
    Run keyword if    '${enb_type}' == 'fzm'    Get FZM enb scf    ${enb_x2ip}    enb    ${OUTPUT DIR}/Enb_SCF.xml
    Csn_Inst.disconnect    connection=enb
    Run Keyword If    '${enb_type}' == 'fzm'    Get anchor FZM cell info
    ...    ELSE    Get anchor cell info

Get eNB Info
    Return from keyword if    '${ADBLogFlag}' == 'False'
    Return from keyword if    '${isNSA}' != 'NSA'
    ${ip_addr_type}  SWO.Check Ipaddr Type  input_config=${tl}
    ${enb_x2ip}  Run Keyword If  '${ip_addr_type}' == 'X2'  Set Variable  ${tl.enbs[0].x2_link_addr.v4}
    ...    ELSE IF  '${ip_addr_type}' == 'OAM'  Set Variable  ${tl.enbs[0].oam_ip.v4}
    ${enb_username}=    Set Variable     toor4nsn
    ${enb_password}=    Set Variable    oZPS0POrRieRtu
    Wait Until Keyword Succeeds    1min    20s
    ...   Csn_Inst.Connect to   ${enb_x2ip}    ${enb_username}    ${enb_password}    alias=enb
    ${enb_type}=    Get enb type    ${enb_x2ip}    enb
    Run keyword if    '${enb_type}' == 'fct'    Get asir enb scf    ${enb_x2ip}    ${OUTPUT DIR}/    Enb_SCF.xml
    ...    ELSE   Get FZM enb scf    ${enb_x2ip}    enb    ${OUTPUT DIR}/Enb_SCF.xml
    Csn_Inst.disconnect    connection=enb
    Get cell info

Get enb type
    Csn_Inst.send_command  command=hostname  connection=enb    timeout=5
    sleep   1s
    ${result}=    Csn_Inst.read_output    connection=enb
    ${enb_type}=    Get Substring    string=${result}    start=0    end=3
    [Return]    ${enb_type}

Get asir enb scf
    [Arguments]     ${host_ip}    ${scf_dir}    ${scf_name}
    ${connection} =    coam.connect to   bts_host=${host_ip}    bts_port=443    name=cOAM
    coam.get_current_scf_file    local_dir_path=${scf_dir}    file_name=${scf_name}    connection=cOAM
    coam.teardown          connection=cOAM

Get FZM enb scf
    [Arguments]     ${scf_local_path}
    Csn_Inst.send_command    command=ls -tr /ffs/run/btsom/config/active/SCF*.xml|tail -1 > /user/toor4nsn/SCFlist.txt
    ...    connection=enb    timeout=5
    Csn_Inst.send_command    command=cp /ffs/run/btsom/config/active/SCF*.xml /user/toor4nsn     connection=enb    timeout=5
    Csn_Inst.send_command    command=chmod 777 /user/toor4nsn/SCF*.xml     connection=enb    timeout=5
    Csn_Inst.send_command    command=chmod 777 /user/toor4nsn/SCFlist.txt     connection=enb    timeout=5
    Csn_Inst.send_command    command=cat /user/toor4nsn/SCFlist.txt    connection=enb    timeout=5
    ${scf_file}=    Csn_Inst.read_output    connection=enb
    ${target_file}    Get Substring    string=${scf_file}    start=0    end=-1
    log to console    \ntarget_file=${target_file}
    Csn_Inst.download file    ${target_file}    ${scf_local_path}    connection=enb
    Csn_Inst.send_command    command=rm /user/toor4nsn/SCF*    connection=enb    timeout=5

Get anchor FZM cell info
    [Documentation]  This keyword used to get anchor FZM cell info
     ${result_cellid}=    Run
    ...    cat ${OUTPUT DIR}/Enb_SCF.xml|grep "NOKLTE:LNCEL"|grep -v "LNCEL_"|awk -F '[-"]' '{print $7}'
    ${cell_num}=    Get Line Count    ${result_cellid}
    ${result_pci}=    Run
    ...    cat ${OUTPUT DIR}/Enb_SCF.xml|grep periodicCqiFeedbackType -A 1|grep phyCellId|awk -F '[<>]' '{print $3}'
    ${result_earfcn}=    Run    cat ${OUTPUT DIR}/Enb_SCF.xml|grep earfcn|grep -v UL|awk -F '[<>]' '{print $3}'
    ${LTE_Cell_Dict_List}    Create List
    :FOR    ${i}    IN RANGE    ${cell_num}
    \    ${cellid}=    Get Line    ${result_cellid}    ${i}
    \    ${pci}=    Get Line    ${result_pci}    ${i}
    \    ${earfcn}=    Get Line    ${result_earfcn}    ${i}
    \    &{LTE_Info_Cell}=    Create Dictionary
        ...    cellid=${cellid}
        ...    pci=${pci}
        ...    earfcn=${earfcn}
    \    Append to List    ${LTE_Cell_Dict_List}    ${LTE_Info_Cell}
    Set Suite Variable    ${LTE_Cell_Dict_List}

Get anchor cell info
    [Documentation]  This keyword used to get anchor None FZM cell info
    sbts_admin.Setup admin  bts_host=${tl.enbs[0].x2_link_addr.v4}
    ${LTE_Cells_Info}=  sbts_admin.Get Cell List
    ${LTE_Cell_Dict_List}  SWO.Parse Anchor Lte Cell Info  cell_info_list=${LTE_Cells_Info['cells']['lte']}
    Set Suite Variable  ${LTE_Cell_Dict_List}
    [Teardown]  sbts_admin.Teardown admin

Get gNB Cell Info
    [Documentation]  This keyword used to get gNB cell related info for attached result verification under SA mode.
    Return from keyword if  '${ue_type_flag}' == 'SMAWAVE_UE'
    sbts_admin.Setup admin
    ${gNB_Cells_Info} =  sbts_admin.Get Cell List
    ${gNB_pci_list}    Create List
    ${gNB_Cell_Dict_List}    Create List
    :FOR  ${cell_info}  IN  @{gNB_Cells_Info['cells']['nr']}
    \    ${cellid}  Set Variable  ${cell_info['globalCellId']}
    \    ${pci}  Set Variable  ${cell_info['physicalCellId']}
    \    ${earfcn}  Set Variable  ${cell_info['nrarfcn']}
    \    &{gNB_cell_info}=  Create Dictionary
         ...  cellid=${cellid}
         ...  pci=${pci}
         ...  nrarfcn=${earfcn}
    \    Append to List  ${gNB_Cell_Dict_List}  ${gNB_cell_info}
    \    Append to List  ${gNB_pci_list}  ${pci}
    Set Suite Variable  ${gNB_Cell_Dict_List}
    Set Suite Variable  ${gNB_pci_list}
    [Teardown]    Run Keyword If  '${ue_type_flag}' != 'SMAWAVE_UE'  sbts_admin.Teardown admin

Stop ADB Log
    Return from keyword if    '${ADBLogFlag}' == 'False'
    :FOR    ${i}    IN RANGE    ${UE_NUM}
    \    ${ue_index}=   Evaluate   ${i}+1
    \    &{cpctmp}=    set variable    @{UEPC_DICT_LIST}[${i}]
    \    Connect to control pc    &{cpctmp}[cpc_ip]    &{cpctmp}[cpc_usr]   &{cpctmp}[cpc_pwd]    cpc_${ue_index}
    \    Stop all ADB logcat process of UE    ${ue_index}    &{cpctmp}[sn]

Stop all ADB logcat process of UE
    [Arguments]    ${ue_index}    ${serial_number}
    ${UEPC_OS_Type}=    Get uepc type    cpc_${ue_index}
    ${ps_command}=    Set variable if     '${UEPC_OS_Type}' == 'windo'
        ...    adb -s ${serial_number} shell ps
        ...    ps -ef|grep ${serial_number}
    Csn_Inst.send_command    command=${ps_command}    connection=cpc_${ue_index}    timeout=5
    ${result}    Csn_Inst.read_output    connection=cpc_${ue_index}
    ${result_pid}=    Run    echo "${result}" | grep logcat | awk '{print $2}'
    ${LogNum}=    Get Line Count    ${result_pid}
    :FOR    ${i}    IN RANGE    ${LogNum}
    \    ${pid}=    Get Line    ${result_pid}    ${i}
    \    ${kill_command}=    Set variable if     '${UEPC_OS_Type}' == 'windo'
         ...    adb -s ${serial_number} shell kill -9 ${pid}
         ...    kill -9 ${pid}
    \    Csn_Inst.send_command    command=${kill_command}   connection=cpc_${ue_index}    timeout=5

SMAwave Ping peer before data transfer
    [Documentation]  This keyword used to ping peer from openwrt before data transfer.
    ...    Note : This keyword is just used for some abnormal SMAwave UEs as WA, it will be removed
    ...    or commented when related bug is resolved.
    ...    ue_index : UE identifier index
    ...    packet_number : ping packet number
    ...
    ...    Example : SMAwave Ping peer before data transfer  1  20
    [Arguments]    ${ue_index}    ${packet_number}=10
    ${app_server_addr}  SWO.Get Epc Side Ipaddr  ip_addr_list=${ute_iperf_itf_ip_list}  ue_index=${ue_index}
    ${ping_command}  Set Variable  /bin/ping -c ${packet_number} ${app_server_addr}
    Log To Console    \nInfo : Begin to execute ping command ${ping_command} on UE_${ue_index}.
    Csn_Inst.send_command    command=${ping_command}  connection=SMA_${ue_index}

Start and Verify Downlink TCP
    [Documentation]  This keyword used to perform TCP downlink traffic
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : dl
    ...    duration : data transfer duration in robot time string format
    ...    iperf_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp
    ...    dl_expect_tput : desired average data transfer throughput
    ...    dl_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Start and Verify Downlink TCP    dl_test  1  dl  120s  80M  tcp  70M  20%
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_throughput}
    ...    ${protocol}    ${dl_expect_tput}    ${dl_deviation}
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'   run keywords
    ...    Wait Until Keyword Succeeds  3min  20s  Fetch SMAwave UE Addr  ${ue_index}
    ...    AND    SMAwave DL Traffic  ${dt_name}  ${ue_index}  ${direction}  ${duration}
    ...    ${iperf_throughput}  ${protocol}  ${dl_expect_tput}  ${dl_deviation}

Start and Verify Downlink UDP
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_throughput}
    ...    ${protocol}    ${dl_expect_tput}    ${dl_deviation}
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'   run keywords
    ...    Wait Until Keyword Succeeds  3min  20s  Fetch SMAwave UE Addr  ${ue_index}
    ...    AND    SMAwave DL Traffic  ${dt_name}  ${ue_index}  ${direction}  ${duration}
    ...    ${iperf_throughput}  ${protocol}  ${dl_expect_tput}  ${dl_deviation}
    ...    ELSE    Start Android Downlink data transfer  ${dt_name}  ${ue_index}  ${direction}  ${duration}
    ...    ${iperf_throughput}  ${protocol}  ${dl_expect_tput}  ${dl_deviation}

SMAwave DL Traffic
    [Documentation]  This keyword used to perform and verify SMAwave UE downlink data transfer.
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : dl
    ...    duration : data transfer duration in robot time string format
    ...    iperf_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp or udp
    ...    dl_expect_tput : desired average data transfer throughput
    ...    dl_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : SMAwave DL Traffic   dl_test  1  dl  120s  80M  udp  70M  20%
    [Arguments]
    ...    ${ue_index}    ${duration}    ${iperf_throughput}
    ...    ${protocol}    ${dl_expect_tput}    ${dl_deviation}
    SMAwave Start DL Iperf Process    ${ue_index}    ${protocol}    ${iperf_throughput}    ${duration}
    Get and Kill Iperf Process on Openwrt    ${ue_index}
    SMAwave Calculate and Verify DL Tput    ${ue_index}    ${dl_expect_tput}    ${dl_deviation}    ${protocol}
    [Teardown]  Get and Kill Iperf Process on Openwrt  ${ue_index}

SMAwave Start DL Iperf Process
    [Documentation]  This keyword used to start iperf process on both UTE VM and openwrt for SMAwave UE DL data transfer
    ...    index : UE identifier index
    ...    proto : tcp or udp
    ...    T-Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...
    ...    Example : SMAwave Start DL Iperf Process  1  tcp  80M  120s
    [Arguments]    ${index}    ${proto}    ${T-Put}    ${Tput_dura}
    Log to console    \nInfo: Begin to generate ${proto} port for DL data transfer .
    ${used_port_list}    SWO.Get Occupied Udp Port List
    ${iperf_port_num}    SWO.Get Availabel Udp Port  lines=${used_port_list}
    Log to console    \nInfo: The ${proto} port used for UE_${index} DL data transfer is ${iperf_port_num}.
    ${smawave_ue_addr}  SWO.Get Epc Side Ipaddr  ip_addr_list=${sma_ue_addr_list}  ue_index=${index}
    ${is_protocol_ipv4}=    Run keyword and return status    should_match_regexp  ${smawave_ue_addr}   ${ipv4_pattern}
    ${dl_cmd_on_openwrt}    Run Keyword If  '${proto}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    /usr/bin/iperf -s -p ${iperf_port_num} -i1 > /tmp/openwrt_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${proto}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    /usr/bin/iperf -s -p ${iperf_port_num} -i1 -V > /tmp/openwrt_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${proto}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    /usr/bin/iperf -s -u -l1400 -w10M -i1 -p ${iperf_port_num} > /tmp/openwrt_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${proto}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    /usr/bin/iperf -s -u -l1400 -w10M -i1 -p ${iperf_port_num} -V > /tmp/openwrt_iperf_${index}.log 2>&1 &
    Csn_Inst.send_command    command=${dl_cmd_on_openwrt}  connection=SMA_${index}
    sleep  1s
    Run Keyword If  '${ping_flag}' == 'True'    SMAwave Ping peer before data transfer  ${index}  5
    Log to console    \nInfo: Begin to perform UE_${index} DL data traffic with throughput ${T-Put}.

    ${iperf_cmd_on_app}    Run Keyword If  '${proto}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    iperf -c ${smawave_ue_addr} -p ${iperf_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400 -P10
    ...    ELSE IF    '${proto}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    iperf -c ${smawave_ue_addr} -p ${iperf_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400 -V -P10
    ...    ELSE IF    '${proto}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    iperf -c ${smawave_ue_addr} -u -i1 -l1400 -p ${iperf_port_num} -b ${T-Put} -t ${Tput_dura}
    ...    ELSE IF    '${proto}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    iperf -c ${smawave_ue_addr} -u -i1 -l1400 -p ${iperf_port_num} -b ${T-Put} -t ${Tput_dura} -V
    Login APP Server  APP_Server_${index}  ${index}
    Csn_Inst.execute  command=${iperf_cmd_on_app}  connection=APP_Server_${index}
    sleep  1s
    Log to console    \nInfo: Successfully perform UE_${index} DL data traffic with throughput ${T-Put} duration is ${Tput_dura}.

SMAwave Calculate and Verify DL Tput
    [Documentation]  This keyword used to calculate and verify SMAwave UE DL T-Put with deviation
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    protocol : tcp or udp
    ...
    ...    Example : SMAwave Calculate and Verify DL Tput  1  180M  30%
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${protocol}
    Csn_Inst.download_file    remote_path=/tmp/openwrt_iperf_${index}.log  local_path=${OUTPUT DIR}  connection=SMA_${index}
    ${dt_dl_row_list}    Run Keyword If  '${protocol}'.lower() == 'tcp'
    ...    SWO.Parse Iperf Trace To Rows  file_to_be_parsed=${OUTPUT DIR}/openwrt_iperf_${index}.log  parallel_streams=${True}
    ...    ELSE    SWO.Parse Iperf Trace To Rows  file_to_be_parsed=${OUTPUT DIR}/openwrt_iperf_${index}.log
    Should Not Be Equal    ${dt_dl_row_list}  EMPTY  msg="DL traffic can't be reached, the iperf file is empty or not exist!"
    ${T_put}    SWO.Count Average Throughput  iperf_row_list=${dt_dl_row_list}
    ${return_result}    SWO.Check Tput With Deviation  expect_tput=${expect_tput}  average_tput=${T_put}  deviation=${deviation}
    Should Be Equal    ${return_result}  Success

Start Android Downlink data transfer
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_throughput}
    ...    ${protocol}    ${dl_expect_tput}    ${dl_deviation}
    Run keyword if    '${5g_attach_result}' == 'False'    Fail    msg='5G attach fail, DL tput will not start'
    log to console    \nInfo:Start DL Data Transfer!
    Start Data Transfer  dt_name=${dt_name}  ue_alias=UE_${ue_index}  direction=${direction}  duration=${duration}
    ...                  throughput=${iperf_throughput}  protocol=${protocol}
    Sleep   10s
    Check Data Transfer Is Alive   ${dt_name}
    Await Data Transfer Finish   ${dt_name}
    log to console    \nInfo:Verify DL Data Tput
    run keyword and continue on failure
    ...    Verify Average Throughput With Deviation   ${dt_name}   ${dl_expect_tput}   ${dl_deviation}

Start and Verify Uplink TCP
    [Documentation]  This keyword used to perform TCP uplink traffic
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : ul
    ...    duration : data transfer duration in robot time string format
    ...    iperf_ul_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp
    ...    ul_expect_tput : desired average data transfer throughput
    ...    ul_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Start and Verify Uplink TCP    ul_test  1  ul  120s  30M  tcp  25M  20%
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_ul_throughput}
    ...    ${protocol}    ${ul_expect_tput}    ${ul_deviation}
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'   run keywords
    ...    Wait Until Keyword Succeeds  3min  20s  Fetch SMAwave UE Addr  ${ue_index}
    ...    AND    SMAwave UL Traffic  ${dt_name}  ${ue_index}  ${direction}  ${duration}
    ...    ${iperf_ul_throughput}  ${protocol}  ${ul_expect_tput}  ${ul_deviation}

Start and Verify Uplink UDP
    [Documentation]  Note: This keyword must be used only after the KW "Start and Verify Downlink UDP".
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_ul_throughput}
    ...    ${protocol}    ${ul_expect_tput}    ${ul_deviation}
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'   run keywords
    ...    Wait Until Keyword Succeeds  3min  20s  Fetch SMAwave UE Addr  ${ue_index}
    ...    AND     SMAwave UL Traffic  ${dt_name}  ${ue_index}  ${direction}  ${duration}
    ...    ${iperf_ul_throughput}  ${protocol}  ${ul_expect_tput}  ${ul_deviation}
    ...    ELSE    Start Android Uplink data transfer  ${dt_name}  ${ue_index}  ${direction}  ${duration}
    ...    ${iperf_ul_throughput}  ${protocol}  ${ul_expect_tput}  ${ul_deviation}

SMAwave UL Traffic
    [Documentation]  This keyword used to perform and verify smawave UE uplink data traffic.
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : ul
    ...    duration : data transfer duration in robot time string format
    ...    iperf_ul_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp or udp
    ...    ul_expect_tput : desired average data transfer throughput
    ...    ul_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : SMAwave UL Traffic  ul_test  1  ul  120s  30M  udp  25M  20%
    [Arguments]
    ...    ${ue_index}    ${duration}    ${iperf_ul_throughput}
    ...    ${protocol}    ${ul_expect_tput}    ${ul_deviation}
    SMAwave Start UL Iperf Process     ${ue_index}    ${protocol}    ${iperf_ul_throughput}    ${duration}
    SMAwave Calculate and Verify UL Tput    ${ue_index}    ${ul_expect_tput}    ${ul_deviation}

SMAwave Start UL Iperf Process
    [Documentation]  This keyword used to start iperf process on both UTE VM and openwrt for SMAwave UE UL data transfer
    ...    index : UE identifier index
    ...    T-Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...
    ...    Example : SMAwave Start UL Iperf Process  1  tcp  30M  120s
    [Arguments]    ${index}    ${proto}    ${T-Put}    ${Tput_dura}
    Log to console    \nInfo: Begin to generate ${proto} port for UL data transfer.
    ${used_port_list}    SWO.Get Occupied Udp Port List
    ${ul_port_num}    SWO.Get Availabel Udp Port  lines=${used_port_list}
    Log to console    \nInfo: The ${proto} port used for UE_${index} UL data transfer is ${ul_port_num}.
    Log to console    \nInfo: Begin to perform UE_${index} UL data traffic with T-Put ${T-Put}.

    ${app_server_addr}  SWO.Get Epc Side Ipaddr  ip_addr_list=${ute_iperf_itf_ip_list}  ue_index=${index}
    ${is_protocol_ipv4}=    Run keyword and return status    should_match_regexp  ${app_server_addr}   ${ipv4_pattern}

    ${ul_cmd_on_app_server}    Run Keyword If  '${proto}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    nohup iperf -s -p ${ul_port_num} -t ${Tput_dura} -i1 > /tmp/ute_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${proto}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    nohup iperf -s -p ${ul_port_num} -t ${Tput_dura} -i1 -V > /tmp/ute_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${proto}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    iperf -s -u -i1 -p ${ul_port_num} -t ${Tput_dura} > /tmp/ute_iperf_${index}.log
    ...    ELSE IF    '${proto}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    iperf -s -u -i1 -p ${ul_port_num} -t ${Tput_dura} -V > /tmp/ute_iperf_${index}.log
    Csn_Inst.send_command    command=${ul_cmd_on_app_server}  connection=APP_Server_${index}
    ${ul_cmd_on_openwrt}    Run Keyword If  '${proto}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    /usr/bin/iperf -c ${app_server_addr} -p ${ul_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400
    ...    ELSE IF    '${proto}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    /usr/bin/iperf -c ${app_server_addr} -p ${ul_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400 -V
    ...    ELSE IF    '${proto}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    /usr/bin/iperf -c ${app_server_addr} -u -i1 -l1400 -p ${ul_port_num} -t ${Tput_dura} -b ${T-Put}
    ...    ELSE IF    '${proto}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    /usr/bin/iperf -c ${app_server_addr} -u -i1 -l1400 -p ${ul_port_num} -t ${Tput_dura} -b ${T-Put} -V
    Csn_Inst.execute    command=${ul_cmd_on_openwrt}  connection=SMA_${index}
    sleep  1s
    Log to console    \nInfo: Successfully perform UE_${index} UL data traffic with T-Put ${T-Put} duration is ${Tput_dura}.

SMAwave Calculate and Verify UL Tput
    [Documentation]  This keyword used to calculate and verify SMAwave UE UL T-Put with deviation
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : SMAwave Calculate and Verify UL Tput  1  30M  20%
    [Arguments]    ${index}    ${expect_tput}    ${deviation}
    Csn_Inst.download_file  remote_path=/tmp/ute_iperf_${index}.log  local_path=${OUTPUT DIR}/ute_iperf_${index}.log
    ...    connection=APP_Server_${index}
    ${dt_ul_row_list}    SWO.Parse Iperf Trace To Rows  file_to_be_parsed=${OUTPUT DIR}/ute_iperf_${index}.log
    Should Not Be Equal    ${dt_ul_row_list}  EMPTY  msg="UL traffic can't be reached, the iperf file is empty or not exist!"
    ${T_put}    SWO.Count Average Throughput  iperf_row_list=${dt_ul_row_list}
    ${return_result}    SWO.Check Tput With Deviation  expect_tput=${expect_tput}  average_tput=${T_put}  deviation=${deviation}
    Should Be Equal    ${return_result}  Success

Start Android Uplink data transfer
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_ul_throughput}
    ...    ${protocol}    ${ul_expect_tput}    ${ul_deviation}
    Run keyword if    '${5g_attach_result}' == 'False'    Fail    msg='5G attach fail, UL tput will not start'
    log to console    \nInfo:Start UL Data Transfer!
    Start Data Transfer  dt_name=${dt_name}  ue_alias=UE_${ue_index}  direction=${direction}  duration=${duration}
    ...                  throughput=${iperf_ul_throughput}  protocol=${protocol}
    Sleep   10s
    Check Data Transfer Is Alive   ${dt_name}
    Await Data Transfer Finish   ${dt_name}
    log to console    \nInfo:Verify UL Data Tput
    run keyword and continue on failure
    ...    Verify Average Throughput With Deviation   ${dt_name}    ${ul_expect_tput}    ${ul_deviation}

UE attach and Start ADB Log
    [Arguments]    ${ue_index}
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'  run keywords
    ...    SMAwave Service Stop  ${ue_index}
    ...    AND  Wait Until Keyword Succeeds  2min  30s  SMAwave attach  ${ue_index}
    ...    ELSE    Android attach  ${ue_index}

Reboot UEs
    [Documentation]  This keyword used to perform reboot UE operations.
    ...    ue_index :  ue identifier index
    ...
    ...    Example : Reboot UEs  1
    [Arguments]    ${ue_index}
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'    SMAwave Reboot UE  ${ue_index}

SMAwave remotely login UE
    [Documentation]  This keyword used to remotely(UTE VM) login openwrt
    ...    ue_index :  ue identifier index
    ...
    ...    Example : SMAwave remotely login UE  1
    [Arguments]    ${ue_index}
    ${index}=   Evaluate   ${ue_index}-1
    &{openwrt}=    Set Variable    @{UEPC_DICT_LIST}[${index}]
    Wait Until Keyword Succeeds  3min  20s
    ...   Csn_Inst.Connect to  &{openwrt}[cpc_ip]  &{openwrt}[cpc_usr]  &{openwrt}[cpc_pwd]  alias=SMA_${ue_index}

SMAwave Reboot UE
    [Documentation]  This keyword used to reboot smawave UE and re-login again to check its status after it bringup
    ...    ue_index :  ue identifier index
    ...
    ...    Example : SMAwave Reboot UE  1
    [Arguments]    ${ue_index}
    SMAwave remotely login UE  ${ue_index}
    Log to console    \nInfo:Reboot SMAwave UE_${ue_index}, wait 120s!
    Csn_Inst.execute    command=/sbin/reboot  connection=SMA_${ue_index}  timeout=5
    sleep  120s
    Log to console    \nInfo:Reconnect to SMAwave UE_${ue_index}.
    Csn_Inst.Disconnect    connection=SMA_${ue_index}
    SMAwave remotely login UE  ${ue_index}
    Csn_Inst.send_command    command=${comd_stop_cmd}  connection=SMA_${ue_index}
    Csn_Inst.send_command    command=${firewall_stop_cmd}  connection=SMA_${ue_index}
    ${SMA_ue_status}  SMAwave Check Status  ${ue_index}
    Set Suite Variable  ${SMA_ue_status}
    Csn_Inst.Disconnect    connection=SMA_${ue_index}

SMAwave Service Stop
    [Documentation]  This keyword used to stop openwrt comd service. Note: the IP address used here is got from
    ...    ue_config.yaml and it was equipped on openwrt for remotely login.
    ...    ue_index :  ue identifier index which used for remotely login to openwrt
    ...
    ...    Example : SMAwave Service Stop  1
    [Arguments]    ${ue_index}
    SMAwave remotely login UE  ${ue_index}
    @{service_list}=    Create List    ${comd_stop_cmd}  ${firewall_stop_cmd}
    :FOR    ${item}    IN    @{service_list}
    \   Csn_Inst.send_command    command=${item}  connection=SMA_${ue_index}
    \   sleep  2s
    SMAwave Check Status  ${ue_index}

SMAwave Check Status
    [Documentation]  This keyword used to ensure smawave UE in unattach status
    ...    index : UE identifier index
    ...
    ...    Example : SMAwave Check Status  1
    [Arguments]    ${index}
     Log to console    \nInfo: Begin to check SMAwave UE_${index} status.
     Csn_Inst.send_command    command=${check_cmd}  connection=SMA_${index}
     ${output}   Csn_Inst.read_output  connection=SMA_${index}
     ${result}    SWO.VERIFY ATCMD OUTPUT  input_string=${output}
     Log to console    \nInfo: Currently the SMAwave UE_${index} status is ${result}.
#     Run Keyword If    '${result}' != 'Idle'  SMAwave detach  ${index}
     [Return]  ${result}

SMAwave attach
    [Documentation]  This keyword used to perform smawave UE attach
    ...    index : UE identifier index
    ...
    ...    Example : SMAwave attach  1
    [Arguments]    ${index}
    Log to console    \nInfo: Begin to perform smawave UE_${index} detach.
    Csn_Inst.send_command    command=${detach_cmd}  connection=SMA_${index}
    sleep  5s
    Log to console    \nInfo: Begin to perform smawave UE_${index} attach.
    Csn_Inst.send_command    command=${attach_cmd}  connection=SMA_${index}
    sleep  15s
    Csn_Inst.send_command    command=${check_cmd}  connection=SMA_${index}
    ${output}    Csn_Inst.read_output    connection=SMA_${index}
    ${result}    SWO.VERIFY ATCMD OUTPUT  input_string=${output}
    Log to console    \nInfo: UE_${index} try to attach ${result} base station.
    ${attach_status}    SWO.VERIFY ATTACH STATUS  input_value=${result}
    Should Be Equal    ${attach_status}  Attach
    Set Suite Variable  ${UE_${index}_in_use}  True

SMAwave Attach All UEs
    [Documentation]  This keyword used to perform all smawave UE attach operation.
    Log to console    \nInfo: Begin to attach all smawave UEs.
    :FOR  ${i}  IN RANGE  ${UE_NUM}
    \    ${index}=   Evaluate  ${i}+1
    \    SMAwave Service Stop  ${index}
    \    Wait Until Keyword Succeeds  2min  30s  SMAwave attach  ${index}

Android Attach All UEs
    [Documentation]  This keyword used to perform all android UE attach operation.
    Log to console    \nInfo: Begin to attach all android UEs.
    :FOR  ${i}  IN RANGE   ${UE_NUM}
    \    ${ue_index}=   Evaluate  ${i}+1
    \    ute_ue.attach_ue    UE_${ue_index}

UE Attach Only
    [Documentation]  Normally this keyword is ONLY used for abnormal UE to perform additional attach operation.
    ...    Recommend to use 'UE attach and Start ADB Log' to perform attach for regular scenario.
    ...    ue_index :  ue identifier index
    ...
    ...    Example : UE Attach Only  1
    [Arguments]    ${ue_index}
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'    SMAwave attach  ${ue_index}
    ...    ELSE    ute_ue.attach_ue  UE_${ue_index}

UE Detach Only
    [Documentation]  Normally this keyword is ONLY used for abnormal UE to perform additional detach operation.
    ...    For regular scenario, there is no need to call dedicated KW to perform detach operation for Android UE,
    ...    'Postconditions_ForUE' is provided for SMAwave UE teardown operation which detach is included.
    ...    ue_index :  ue identifier index
    ...
    ...    Example : UE Detach Only  1
    [Arguments]    ${ue_index}
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'    SMAwave detach  ${ue_index}
    ...    ELSE    ute_ue.detach_ue  UE_${ue_index}

Android attach
    [Documentation]  This keyword used to perfrom android UE attach and capture adb log
    [Arguments]    ${ue_index}
    ${index}=   Evaluate   ${ue_index}-1
    &{cpctmp}=    set variable    @{UEPC_DICT_LIST}[${index}]
    Connect to control pc    &{cpctmp}[cpc_ip]    &{cpctmp}[cpc_usr]   &{cpctmp}[cpc_pwd]    cpc_${ue_index}
    Check ADB version    ${ue_index}
    Check ADB devices and Restart ADB service    ${ue_index}
    Csn_Inst.execute    command=rm -rf /tmp/ADB_${ue_index}.log
    ...            connection=cpc_${ue_index}    timeout=5
    #activate ue screen
    Csn_Inst.execute    command=adb -s &{cpctmp}[sn] shell input keyevent 224
    ...            connection=cpc_${ue_index}    timeout=5
    #unlock ue screen
    Csn_Inst.execute    command=adb -s &{cpctmp}[sn] shell input swipe 300 1000 300 500
    ...            connection=cpc_${ue_index}    timeout=5
    Log to console    \nInfo: UE_${ue_index} require.
    Reserve ue for tests    UE_${ue_index}    REAL_ANDROID_UE
    Start to catch UE ADB logs    ${ue_index}    &{cpctmp}[sn]
    Repeat keyword    1 times    Run keywords
    ...    log to console    \nInfo:UE_${ue_index} Detach begin!    AND
    ...    ute_ue.detach_ue    UE_${ue_index}    AND
    ...    Sleep    10s    AND
    ...    log to console    \nInfo:UE_${ue_index} Attach begin!    AND
    ...    ute_ue.attach_ue    UE_${ue_index}    AND
    ...    sleep    30s

Reserve All Android UEs
    :FOR    ${i}    IN RANGE    ${UE_NUM}
    \    ${ue_index}=   Evaluate   ${i}+1
    \    &{cpctmp}=    set variable    @{UEPC_DICT_LIST}[${i}]
    \    Connect to control pc    &{cpctmp}[cpc_ip]    &{cpctmp}[cpc_usr]   &{cpctmp}[cpc_pwd]    cpc_${ue_index}
    \    Check ADB version    ${ue_index}
    \    Check ADB devices and Restart ADB service    ${ue_index}
    Log to console    \nInfo: Require all Ues.
    :FOR    ${i}    IN RANGE    ${UE_NUM}
    \    ${ue_index}=   Evaluate   ${i}+1
    \    Reserve ue for tests    UE_${ue_index}    REAL_ANDROID_UE

Start ADB Log and attach All UEs
    :FOR    ${i}    IN RANGE    ${UE_NUM}
    \    ${ue_index}=   Evaluate   ${i}+1
    \    &{cpctmp}=    set variable    @{UEPC_DICT_LIST}[${i}]
    \    Csn_Inst.execute    command=rm -rf /tmp/ADB_${ue_index}.log    connection=cpc_${ue_index}    timeout=5
    \    Start to catch UE ADB logs    ${ue_index}    &{cpctmp}[sn]
    Repeat keyword    2 times    Run keywords
    ...    Detach All UEs    AND
    ...    Sleep    10s    AND
    ...    Attach All UEs    AND
    ...    sleep    30s

Detach All UEs
    log to console    \nInfo: All UEs Detach!
    :FOR    ${i}    IN RANGE    ${UE_NUM}
    \    ${ue_index}=   Evaluate   ${i}+1
    \    ute_ue.detach_ue    UE_${ue_index}

Attach All UEs
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'    SMAwave Attach All UEs
    ...    ELSE    Android Attach All UEs

Verify 5G success and stop ADB log
    [Documentation]  This keyword used to verify attached result via ADB log.
    ...    ue_index : UE index identifier
    ...    lte_cell_index : the cell index which UE attach to
    [Arguments]    ${ue_index}    ${lte_cell_index}
    ${index}=  Evaluate  ${ue_index}-1
    &{cpctmp}=    set variable    @{UEPC_DICT_LIST}[${index}]
    Save to remote and stop ADB logcat    ${ue_index}    &{cpctmp}[sn]
    ${5g_attach_result}    Set variable if    '${ADBLogFlag}' == 'True'    False    True
    Set Suite Variable    ${5g_attach_result}
    ADB log verify for All UE Type    ${ue_index}    &{cpctmp}[sn]    ${lte_cell_index}
    [Return]    ${5g_attach_result}

Verify 4G success and stop ADB log
    [Arguments]    ${ue_index}    ${lte_cell_index}
    ${index}=   Evaluate   ${ue_index}-1
    &{cpctmp}=    set variable    @{UEPC_DICT_LIST}[${index}]
    sleep    120s
    Save to remote and stop ADB logcat    ${ue_index}    &{cpctmp}[sn]
    ADB 4G log verify for All UE Type     ${ue_index}    &{cpctmp}[sn]    ${lte_cell_index}

Start to catch UE ADB logs
    [Documentation]  Catch the UE adb log for check UE setup.
    [Arguments]     ${ue_index}    ${serial_number}
    Return from keyword if    '${ADBLogFlag}' == 'False'
    log to console    \nInfo:Start to catch ADB logs for UE_${ue_index}
    Csn_Inst.send_command    adb -s ${serial_number} logcat -c   connection=cpc_${ue_index}    timeout=5
    Csn_Inst.send_command    command=rm /tmp/ADB_${ue_index}.log  connection=cpc_${ue_index}    timeout=5
    sleep   1s
    Csn_Inst.send_command
    ...   command=nohup adb -s ${serial_number} logcat -b all > /tmp/ADB_${ue_index}.log &
    ...   connection=cpc_${ue_index}    timeout=5

Save to remote and stop ADB logcat
    [Documentation]      Stop catching UE ADB log and save it to UTE.
    [Arguments]   ${ue_index}    ${serial_number}
    Return from keyword if    '${ADBLogFlag}' == 'False'
    log to console    \nInfo:Save and stop ADB logcat for UE_${ue_index}.
    Csn_Inst.download file    /tmp/ADB_${ue_index}.log    ${OUTPUT_DIR}/ADB_${ue_index}.log    connection=cpc_${ue_index}
    Sleep  2s
    Stop all ADB logcat process of UE    ${ue_index}    ${serial_number}

ADB log verify for All UE Type
    [Documentation]  Check ue attach result in ADB logs. Support Huawei and Qualcomm chipset UE.
    ...    ue_index : UE identifier index
    ...    serial_number : UE serial number which is used for android UE
    ...    cell_index : cell index which support both NSA and SA mode
    [Arguments]    ${ue_index}    ${serial_number}    ${cell_index}
    Return from keyword if    '${ADBLogFlag}' == 'False'
    ${index}=  Evaluate  ${cell_index}-1
    &{celltmp}=    Run Keyword If  '${isNSA}' == 'NSA'  set variable  @{LTE_Cell_Dict_List}[${index}]
    ...    ELSE  set variable  @{gNB_Cell_Dict_List}[${index}]
    ${ue_android_ver}=    Get Ue android version    ${ue_index}    ${serial_number}
    ${isHW}=    Is Huawei UE    ${ue_index}    ${serial_number}    cpc_${ue_index}
    Run keyword if    '${isHW}' == 'False'
    ...    ADB log verify Qualcomm 5G UE setup     ${ue_index}
    ...                                            &{celltmp}[pci]
    ...                                            &{celltmp}[earfcn]
    ...                                            ${ue_android_ver}
    ...    ELSE    Run keyword  ADB log verify for Huawei UE 5G setup    ${ue_index}
    ...                                                                  ${serial_number}
    ...                                                                  &{celltmp}[pci]
    ...                                                                  &{celltmp}[nrarfcn]
    ...                                                                  ${ue_android_ver}
    log to console    \nInfo:UE_${ue_index} 5G Attached=${5g_attach_result}!

ADB 4G log verify for All UE Type
    [Arguments]    ${ue_index}    ${serial_number}    ${lte_cell_index}
    ${index}=   Evaluate   ${lte_cell_index}-1
    &{celltmp}=    set variable    @{LTE_Cell_Dict_List}[${index}]
    ${isHW}=    Is Huawei UE    ${ue_index}    ${serial_number}    cpc_${ue_index}
    log to console    \nInfo:UE_${ue_index} isHuawei=${isHW}
    Run keyword if    '${isHW}' == 'False'
    ...    Verify Qualcomm 4G UE setup by ADB log     ${ue_index}
    ...                                               &{celltmp}[pci]
    ...                                               &{celltmp}[earfcn]
    ...    ELSE    Run keyword   Verify Huawei UE 4G setup by ADB log     ${ue_index}
    ...                                                                   ${serial_number}
    ...                                                                   &{celltmp}[pci]
    ...                                                                   &{celltmp}[earfcn]
    log to console    ADB 4G log verify finished for UE_${ue_index}!

ADB log verify Qualcomm 5G UE setup
    [Documentation]  This keyword is to verify 4G and 5G UE setup successfully via ADB log.
    ...    :param lte_earfcn: earfcnDL in the eNB bts
    [Arguments]  ${ue_index}    ${lte_pci}    ${lte_earfcn}    ${ue_android_ver}
    Verify Qualcomm 4G UE setup by ADB log   ${ue_index}    ${lte_pci}    ${lte_earfcn}    ${ue_android_ver}
    ${result}=    Run    cat ${OUTPUT DIR}/ADB_${ue_index}.log|grep is5GConnected|grep TCPBuffer|tail -1
    ${5g_attach_result}=    Run keyword and return status    should_match_regexp  ${result}   is5GConnected.? true
    Set suite variable    ${5g_attach_result}
    Run Keyword If    '${5g_attach_result}'=='FAIL'  FAIL    \nUE_${ue_index} attach to 5G failed!

Verify Qualcomm 4G UE setup by ADB log
    [Documentation]   Verify 4G UE setup by ADB log.
    ...  :param lte_erafcn: earfcnDL in the eNB bts
    [Arguments]  ${ue_index}    ${lte_pci}    ${lte_earfcn}    ${ue_android_ver}
    Run Keyword If    '${ue_android_ver}'=='9'
    ...    Check Qualcomm 4G android 9 log    ${ue_index}
    ...                                       ${lte_pci}
    ...                                       ${lte_earfcn}
    ...    ELSE    Check Qualcomm 4G android 10 log    ${ue_index}
    ...                                                ${lte_pci}
    ...                                                ${lte_earfcn}

Check Qualcomm 4G android 9 log
    [Arguments]  ${ue_index}    ${lte_pci}    ${lte_earfcn}
    ${result}=    Run    cat ${OUTPUT DIR}/ADB_${ue_index}.log|grep DATA_REGISTRATION |grep rat
    @{adb_results}  split to lines  ${result}
    Run keywords
    ...   Should contain  @{adb_results}[-2]  rat = 14   AND
    ...   Should contain  @{adb_results}[-2]  earfcn = ${lte_earfcn}    AND
    ...   Should contain  @{adb_results}[-2]  pci = ${lte_pci}

Check Qualcomm 4G android 10 log
    [Arguments]  ${ue_index}    ${lte_pci}
    ${result}=    Run
    ...    cat ${OUTPUT DIR}/ADB_${ue_index}.log|grep "IS_CELL_ATTACHED=True"|grep GET_PCI=${lte_pci}|tail -1
    Should contain   ${result}    GET_PCI=${lte_pci}


ADB log verify for Huawei UE 5G setup
    [Arguments]    ${ue_index}    ${serial_number}    ${lte_pci}    ${lte_earfcn}    ${ue_android_ver}
    Run Keyword If  '${isNSA}' == 'NSA'
    ...    Verify Huawei UE 4G setup by ADB log    ${ue_index}    ${serial_number}    ${lte_pci}    ${lte_earfcn}
    ...    ELSE    Verify Huawei UE 5G setup by ADB log    ${ue_index}
    log to console    \nInfo: ADB log verify for Huawei UE 5G setup.
    Run Keyword If    '${ue_android_ver}'=='9'
    ...    Check Huawei 5G android 9 log    ${ue_index}    ${lte_pci}
    ...    ELSE    Check Huawei 5G android 10 log    ${ue_index}    ${lte_pci}

Check Huawei 5G android 9 log
    [Arguments]    ${ue_index}    ${lte_pci}
    ${result}=    Run
    ...    cat ${OUTPUT DIR}/ADB_${ue_index}.log|grep "IS_CELL_ATTACHED=True"|grep GET_PCI=${lte_pci}|tail -1
    ${5g_attach_result}=    Run keyword and return status    Should contain    ${result}    GET_NETWORK_TYPE=NR
    Set suite variable    ${5g_attach_result}

Check Huawei 5G android 10 log
    [Arguments]    ${ue_index}
    ${result}=    Run    cat ${OUTPUT DIR}/ADB_${ue_index}.log|grep -i "converted_rat ="|tail -1
    ${5g_attach_result}=    Run keyword and return status    Should contain any  ${result}  65  66  69
    Set suite variable    ${5g_attach_result}

Verify Huawei UE 4G setup by ADB log
    [Arguments]    ${ue_index}    ${lte_pci}    ${lte_earfcn}
    ${result}=    Run
    ...    grep 'current RAT is LTE' ${OUTPUT DIR}/ADB_${ue_index}.log |tail -1
    Should Contain    ${result}    current RAT is LTE
    Run    cat ${OUTPUT DIR}/ADB_${ue_index}.log|grep mRegistered=YES|sed "s/INFO_LIST/\\n/g">${OUTPUT DIR}/adbtmp
    ${result}=    Run
    ...    cat ${OUTPUT DIR}/adbtmp|sed "s/CellIdentityLte/\\n/g; s/CellSignalStrengthLte/\\n/g"|grep mPci|uniq
    Should contain   ${result}    mPci=${lte_pci}    mEarfcn=${lte_earfcn}
    Run    command=rm -f ${OUTPUT DIR}/adbtmp

Verify Huawei UE 5G setup by ADB log
    [Documentation]  This keyword used to check ADB log for pci and earfcn under NR SA scenario
    ...    ue_index : UE index identifier
    [Arguments]    ${ue_index}
    ${result}=    Run
    ...    grep 'Network type NR' ${OUTPUT DIR}/ADB_${ue_index}.log | tail -2
    Should Contain    ${result}    Network type NR
    Run    cat ${OUTPUT DIR}/ADB_${ue_index}.log|grep mRegistered=YES|sed "s/INFO_LIST/\\n/g">${OUTPUT DIR}/adbtmp
    ${result}=    Run
    ...    cat ${OUTPUT DIR}/adbtmp|sed "s/CellIdentityNr/\\n/g; s/CellSignalStrengthNr/\\n/g"|grep mPci|uniq
    ${matched_result}  SWO.Verify Adblog Result  item_list=${gNB_pci_list}  checked_string=${result}
    Should Be Equal  ${matched_result}  Match
    Run    command=rm -f ${OUTPUT DIR}/adbtmp

Check ADB version
    [Arguments]    ${ue_index}
    Csn_Inst.send_command    command=adb version    connection=cpc_${ue_index}    timeout=5
    ${result} =    Csn_Inst.read output    connection=cpc_${ue_index}
    ${version_line}    Get lines Containing String    string=${result}    pattern=Android Debug Bridge
    ...    case_insensitive=False
    ${adb_version_str}    Get Substring    string=${version_line}    start=-2
    ${adb_version}    Convert to integer    ${adb_version_str}
    ${UEPC_OS_Type}=    Get uepc type    cpc_${ue_index}
    ${allowed_version}=    Set variable if     '${UEPC_OS_Type}' == 'Linux'    ${39}    ${41}
    Should Be True    ${adb_version} >= ${allowed_version}

Check ADB devices and reboot UEPC
    [Documentation]   Sometimes ue is adb offline, reboot UEPC as a workaround.
    [Arguments]    ${ue_index}=1
    ${index}=   Evaluate   ${ue_index}-1
    &{cpctmp}=    set variable    @{UEPC_DICT_LIST}[${index}]
    Csn_Inst.execute    command=rm -rf &{cpctmp}[cpc_pyrodir]    connection=cpc_${ue_index}    timeout=5
    ${result}=    check adb devices status   &{cpctmp}[sn]    cpc_${ue_index}
    log to console    \nInfo:Check adb devices status return ${result}
    Run keyword if  '${result}' == 'FAIL'     run keywords
    ...    Reboot Windows or Linux UEPC    ${ue_index}    AND
    ...    log to console    \nInfo:Reconnect to control pc of UE_${ue_index}.    AND
    ...    Csn_Inst.disconnect    connection=cpc_${ue_index}    AND
    ...    Connect to control pc    &{cpctmp}[cpc_ip]    &{cpctmp}[cpc_usr]   &{cpctmp}[cpc_pwd]    cpc_${ue_index}
    ...    AND
    ...    check adb devices status   &{cpctmp}[sn]    cpc_${ue_index}

Check ADB devices and restart ADB service
    [Documentation]   Sometimes ue is adb offline. Reboot adb service first, then reboot UEPC as a workaround.
    [Arguments]   ${ue_index}
    ${index}=   Evaluate   ${ue_index}-1
    &{cpctmp}=    set variable    @{UEPC_DICT_LIST}[${index}]
    Csn_Inst.execute    command=rm -rf &{cpctmp}[cpc_pyrodir]    connection=cpc_${ue_index}    timeout=5
    ${result}=    check adb devices status   &{cpctmp}[sn]    cpc_${ue_index}
    Run keyword if  '${result}' == 'FAIL'     run keywords
    ...    ADB Service Restart    &{cpctmp}[sn]    cpc_${ue_index}   AND
    ...    log to console    \nInfo:Restart adb service for UE_${ue_index}!
    ${result}=    check adb devices status   &{cpctmp}[sn]    cpc_${ue_index}
    Run keyword if  '${result}' == 'FAIL'     run keywords
    ...    Check ADB devices and reboot UEPC   ${ue_index}    AND
    ...    log to console    Check UE_${ue_index} adb devices again and status return ${result}

Check adb devices status
    [Documentation]  check phone status by serial number
    ...    :param serial_number: the serial number of phone
    [Arguments]    ${serial_number}    ${cpc_alias}
    Csn_Inst.send_command   command=adb devices  connection=${cpc_alias}      timeout=5
    Sleep   2s
    ${result}    Csn_Inst.read_output    connection=${cpc_alias}
    ${device_line}    Get lines Containing String    string=${result}    pattern=${serial_number}
    ...    case_insensitive=False
    ${device_status}    Get Substring    string=${device_line}    start=-6
    ${return_value}=    Set variable if    '${device_status}' == 'device'    PASS    FAIL
    [Return]    ${return_value}

Get uepc type
    [Documentation]  get the OS type of UE PC
    ...    :param cpc_alias: the ssh connection to the ue pc
    [Arguments]    ${cpc_alias}
    Csn_Inst.send_command   command=uname  connection=${cpc_alias}      timeout=5
    Sleep   2s
    ${output_result}    Csn_Inst.read_output    connection=${cpc_alias}
    ${os_type}    Get Substring    string=${output_result}    start=0    end=5
    [Return]    ${os_type}

Get Ue android version
    [Arguments]    ${ue_index}    ${serial_number}
    Csn_Inst.send command
    ...    command=adb -s ${serial_number} shell getprop ro.build.version.release
    ...    connection=cpc_${ue_index}
    ...    timeout=5
    ${result} =    Csn_Inst.read output    connection=cpc_${ue_index}
#    ${version}    Get Substring    string=${result}    start=0    end=-1
    ${version}=    Run    echo "${result}"|tr -d '\r\n'
    log to console    \nUE android version is ${version}.
    [Return]    ${version}

Get adb devices type
    [Documentation]  check UE type by serial number
    ...    :param serial_number: the serial number of phone
    [Arguments]    ${serial_number}    ${cpc_alias}
    Csn_Inst.send_command   command=adb devices -l  connection=${cpc_alias}      timeout=5
    Sleep   2s
    ${output_result}    Csn_Inst.read_output    connection=${cpc_alias}
    ${device_line}    Get lines Containing String    string=${output_result}    pattern=${serial_number}
    ...    case_insensitive=False
    @{device_col}    Split string    string=${device_line}
    ${UEPC_OS_Type}=    Get uepc type    ${cpc_alias}
    ${device_col_num}=    Set variable if     '${UEPC_OS_Type}' == 'Linux'    4    3
    ${device_type}    Get Substring    string=@{device_col}[${device_col_num}]    start=6
    [Return]    ${device_type}

Is Huawei UE
    [Documentation]  check UE type by serial number
    ...    :param serial_number: the serial number of phone
    [Arguments]    ${ue_index}    ${serial_number}    ${cpc_alias}
    ${devie_type}=    Get adb devices type    ${ue_index}    ${serial_number}    ${cpc_alias}
    ${isHW}=    Set variable if   '${devie_type}'=='EVR_AN00'    True    False
    return from keyword if    '${isHW}'=='True'
    ${isHW}=    Set variable if   '${devie_type}'=='TAS_AN00'    True    False
    return from keyword if    '${isHW}'=='True'
    ${isHW}=    Set variable if   '${devie_type}'=='LIO_AN00'    True    False
    [Return]    ${isHW}

Reboot Windows or Linux UEPC
    [Arguments]    ${ue_index}=1
    ${index}=   Evaluate   ${ue_index}-1
    &{cpctmp}=    set variable    @{UEPC_DICT_LIST}[${index}]
    ${UEPC_OS_Type}=    Get uepc type    cpc_${ue_index}
    log to console     \nInfo:Reboot ${UEPC_OS_Type} UEPC for UE_${ue_index}, wait 90s!
    Run Keyword IF     '${UEPC_OS_Type}' == 'windo'
    ...    Csn_Inst.execute    command=shutdown /r /f   connection=cpc_${ue_index}    timeout=5
    ...    ELSE   Csn_Inst.execute    command=sudo reboot   connection=cpc_${ue_index}    timeout=5
    sleep   90s
    Connect to control pc    &{cpctmp}[cpc_ip]    &{cpctmp}[cpc_usr]   &{cpctmp}[cpc_pwd]    cpc_${ue_index}

ADB Reboot UEs
    [Documentation]  Use adb command to reboot the android ue device.
    ...    Attention, This keyword is deprecated, had better change to use Reboot UEs keyword.
    [Arguments]    ${serial_number}    ${cpc_alias}
    log to console     \nInfo:Reboot Android UE ${serial_number}, wait 30s!
    Csn_Inst.execute    command=adb -s ${serial_number} reboot   connection=${cpc_alias}
    sleep   30s

ADB Service Restart
    [Documentation]  Use adb command to recover adb service
    [Arguments]    ${serial_number}    ${cpc_alias}
    log to console     \nInfo:Reboot ADB Service on ${cpc_alias}!
    Csn_Inst.execute    command=sudo adb -s ${serial_number} kill-server    connection=${cpc_alias}
    Csn_Inst.execute    command=sudo adb -s ${serial_number} start-server    connection=${cpc_alias}
    sleep   2s

SMAwave setup
    [Documentation]    This keyword used to initiate some list variables for SMAwave UE.
    ${ute_iperf_itf_ip_list}  Create List
    Set Suite Variable  ${ute_iperf_itf_ip_list}
    ${sma_ue_addr_list}  Create List
    Set Suite Variable  ${sma_ue_addr_list}

Postconditions_ForUE
    [Documentation]  This keyword is to perform SMAWave UE teardown operation.
    ...    It must be called in Teardown section of test case.
    :FOR  ${i}  IN RANGE  ${UE_NUM}
    \    ${index}=   Evaluate  ${i}+1
    \    ${ue_in_use_status}  Get Variable Value  ${UE_${index}_in_use}
    \    postcondition_indexUE  ${index}  ${ue_in_use_status}
    \    Set Suite Variable  ${UE_${index}_in_use}  False

postcondition_indexUE
    [Documentation]  This keyword used to perform specific index SMAwave UE teardown operation.
    ...    Note: this KW is private and should not be called by test case directly.
    [Arguments]  ${ue_index}  ${ue_in_use_status}
    # add stop comd process to ensure UE successfully detach
    Run Keyword If  '${ue_in_use_status}' == 'True'  run keywords
    ...    Csn_Inst.send_command    command=${comd_stop_cmd}  connection=SMA_${ue_index}
    ...    AND    sleep  5s
    ...    AND    SMAwave detach  ${ue_index}
    ...    AND    sleep  2s
    Run Keyword And Ignore Error  Csn_Inst.send_command    command=${comd_start_cmd}  connection=SMA_${ue_index}
    sleep  2s
    Run Keyword If  '${ue_in_use_status}' == 'True'  run keywords
    ...    Run Keyword If  '${dl_async_flag}' == 'True'  Stop Async  alias=DL_async_${ue_index}
    ...    AND  Run Keyword If  '${ue_index}' == '${UE_NUM}'  Set Suite Variable  ${dl_async_flag}  False
    Run Keyword If  '${ue_in_use_status}' == 'True'  run keywords
    ...    Run Keyword If  '${ul_async_flag}' == 'True'  Stop Async  alias=UL_async_${ue_index}
    ...    AND  Run Keyword If  '${ue_index}' == '${UE_NUM}'  Set Suite Variable  ${ul_async_flag}  False
    sleep  2s
    ${rm_route_file_cmd}  Set Variable  rm -f /tmp/ue_${ue_index}_route_table.txt
    Run Keyword If  '${add_default_route_flag}' == 'True' and '${ue_in_use_status}' == 'True'
    ...    Csn_Inst.send_command  command=${rm_route_file_cmd}  connection=SMA_${ue_index}
    Run Keyword If  '${ue_in_use_status}' == 'True'    run keywords
    ...    Csn_Inst.Disconnect    connection=SMA_${ue_index}
    ...    AND    sleep  2s
    ...    AND    Csn_Inst.Disconnect    connection=APP_Server_${ue_index}

SMAwave detach
    [Documentation]  This keyword used to perform AT command to detach smawave UE
    ...    index : UE identifier index
    ...
    ...    Example : SMAwave detach  1
    [Arguments]    ${index}
    Log to console    \nInfo: Begin to perform smawave UE_${index} detach.
    Csn_Inst.send_command    command=${detach_cmd}  connection=SMA_${index}
    sleep  15s
    Csn_Inst.send_command    command=${check_cmd}  connection=SMA_${index}
    ${output}    Csn_Inst.read_output    connection=SMA_${index}
    ${result}    SWO.VERIFY ATCMD OUTPUT  input_string=${output}
    Should Be Equal    ${result}  Idle

Fetch SMAwave UE Addr
    [Documentation]  This keyword used to get smawave UE IP address after attach operation.
    ...    please ensure comd service restart otherwise can't obtain assigned address.
    ...    index : UE identifier index
    ...
    ...    Example : Fetch SMAwave UE Addr  1
    [Arguments]    ${index}
    Log to console    \nInfo: Begin to restart UE_${index} openwrt comd service.
    Csn_Inst.send_command    command=${comd_start_cmd}  connection=SMA_${index}
    sleep  30s
    ${ute_iperf_itf_ip}  Set Variable
    ...  ${ue_inline['UE_${index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['iperf_interface_ip']}
    Append To List  ${ute_iperf_itf_ip_list}  ${ute_iperf_itf_ip}
    Log to console    \nInfo: The UTE iperf interface IP address for UE_${index} is ${ute_iperf_itf_ip}.
    ${is_protocol_ipv4}=    Run keyword and return status    should_match_regexp  ${ute_iperf_itf_ip}   ${ipv4_pattern}
    @{tmp_list}    Run Keyword If    '${is_protocol_ipv4}'=='True'
    ...    Split String    ${ute_iperf_itf_ip}   separator=.
    ...    ELSE   Split String    ${ute_iperf_itf_ip}   separator=:
    ${sub_ip_string}    Set Variable    @{tmp_list}[0]
    Log to console    \nInfo: Begin to get SMAwave UE_${index} assigned IP address.
    Run Keyword If    '${is_protocol_ipv4}'=='True'
    ...    Csn_Inst.send_command    command=${get_IPV4addr_cmd}  connection=SMA_${index}
    ...    ELSE    Csn_Inst.send_command    command=${get_IPV6addr_cmd}  connection=SMA_${index}
    ${ip_addr}    Csn_Inst.read_output  connection=SMA_${index}
    Should Contain  ${ip_addr}  ${sub_ip_string}
    ${smawave_ue_addr}   Strip String    ${ip_addr}  mode=right  characters=\n
    Append To List  ${sma_ue_addr_list}  ${smawave_ue_addr}
    Log to console    \nInfo: SMAwave UE_${index} assigned IP address is ${smawave_ue_addr}.
    Run Keyword If  '${add_default_route_flag}' == 'True' and '${is_protocol_ipv4}'=='True'
    ...    Check and Add default route between App Server and SMAwave UE  ${index}

Check and Add default route between App Server and SMAwave UE
    [Documentation]  This keyword is to enusre the default route is exsit between App Server and SMAwave UE before
    ...    data transfer is performed, add one default route if not exist.
    ...    Note : This keyword is just used for some abnormal SMAwave UEs as WA, it will be removed
    ...    or commented when related bug is resolved, the issue appear on UE load SQXR60_V1.0.1
    ...    ue_index : UE identifier index
    ...
    ...    Example : Check and Add default route between App Server and SMAwave UE  1
    [Arguments]    ${ue_index}
    Log to Console    \nInfo:Begin to Check whether default route is exist between App Server and SMAwave UE.
    ${route_check_cmd}    Set Variable  ip route > /tmp/ue_${ue_index}_route_table.txt
    ${route_add_cmd}    Set Variable  route add -net 0.0.0.0 gw 27.168.1.9
    Csn_Inst.send_command    command=${route_check_cmd}  connection=SMA_${ue_index}
    Csn_Inst.download_file    remote_path=/tmp/ue_${ue_index}_route_table.txt  local_path=${OUTPUT DIR}  connection=SMA_${ue_index}
    ${return_result}     SWO.check default route exist  input_file=${OUTPUT DIR}/ue_${ue_index}_route_table.txt
    Run Keyword If    '${return_result}' == 'True'  Log To Console  \nInfo:the default route is already exist,no other operation is required!
    ...    ELSE    run keywords    Log To Console  \nInfo:the default route is not exist,begin to add it!
    ...    AND    Csn_Inst.send_command    command=${route_add_cmd}  connection=SMA_${ue_index}

Get and Kill Iperf Process on Openwrt
    [Documentation]  This keyword used to get iperf process on openwrt and then kill them.
    ...    Normally it is used for SMAwave UE DL data transfer.
    ...    index : UE identifier index
    ...
    ...    Example : Get and Kill Iperf Process on Openwrt  1
    [Arguments]    ${index}
    Csn_Inst.send_command    command=${get_iperf_id_cmd}  connection=SMA_${index}
    ${process_id}    Csn_Inst.read_output  connection=SMA_${index}
    ${iperf_process}    Split String    ${process_id}    separator=\n
    @{iperf_process_id}    Get Slice From List    ${iperf_process}  start=0  end=-1
    Log to console    \nInfo: iperf id on UE_${index} openwrt is @{iperf_process_id}.
    Set suite variable  @{iperf_process_id}
    :FOR    ${item}    IN    @{iperf_process_id}
    \   Log to console    \nInfo: Begin to kill iperf process id ${item} on UE_${index} openwrt.
    \   Csn_Inst.send_command    command=kill -9 ${item}  connection=SMA_${index}
    \   sleep  2s

Login APP Server
    [Documentation]  This keyword used to remotely login App Server before data transfer.
    ...    conn_alias : remotely login session alias
    ...    index : UE identifier index, default 1
    ...
    ...     Example : Login APP Server  login_alias  1
    [Arguments]    ${conn_alias}  ${index}=1
    ${app_server_addr}   Set Variable
    ...  ${ue_inline['UE_${index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['ssh']['host']}
    ${app_server_user}   Set Variable
    ...  ${ue_inline['UE_${index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['ssh']['user']}
    ${app_server_pwd}   Set Variable
    ...  ${ue_inline['UE_${index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['ssh']['password']}
    Wait Until Keyword Succeeds    3min    20s
    ...   Csn_Inst.Connect to    ${app_server_addr}  ${app_server_user}  ${app_server_pwd}  alias=${conn_alias}

SMAwave Start DL Async Process
    [Documentation]    This keyword used to start SMAwave UE DL async iperf process, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    T-Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...
    ...    Example : SMAwave Start DL Async Process  1  80M  120s  tcp/udp
    [Arguments]    ${index}    ${T-Put}    ${Tput_dura}    ${protocol}
    Wait Until Keyword Succeeds  3min  20s  Fetch SMAwave UE Addr  ${index}
    Log to console    \nInfo: Begin to generate ${protocol} port for SMAwave UE DL data transfer.
    ${used_port_list}    SWO.Get Occupied Udp Port List
    ${iperf_port_num}    SWO.Get Availabel Udp Port  lines=${used_port_list}
    Log to console    \nInfo: The ${protocol} port used for SMAwave UE_${index} Async DL data transfer is ${iperf_port_num}.
    ${smawave_ue_addr}  SWO.Get Epc Side Ipaddr  ip_addr_list=${sma_ue_addr_list}  ue_index=${index}
    ${is_protocol_ipv4}=    Run keyword and return status    should_match_regexp  ${smawave_ue_addr}   ${ipv4_pattern}
    ${dl_cmd_on_openwrt}    Run Keyword If  '${protocol}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    /usr/bin/iperf -s -p ${iperf_port_num} -i1 > /tmp/openwrt_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${protocol}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    /usr/bin/iperf -s -p ${iperf_port_num} -i1 -V > /tmp/openwrt_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${protocol}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    /usr/bin/iperf -s -u -l1400 -w10M -i1 -p ${iperf_port_num} > /tmp/openwrt_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${protocol}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    /usr/bin/iperf -s -u -l1400 -w10M -i1 -p ${iperf_port_num} -V > /tmp/openwrt_iperf_${index}.log 2>&1 &
    Csn_Inst.send_command    command=${dl_cmd_on_openwrt}  connection=SMA_${index}
    sleep  1s
    Run Keyword If  '${ping_flag}' == 'True'    SMAwave Ping peer before data transfer  ${index}  5
    Log to console    \nInfo: Begin to perform SMAwave UE_${index} Async DL data traffic with throughput ${T-Put}.

    ${iperf_cmd_on_app}    Run Keyword If  '${protocol}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    iperf -c ${smawave_ue_addr} -p ${iperf_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400 -P10
    ...    ELSE IF    '${protocol}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    iperf -c ${smawave_ue_addr} -p ${iperf_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400 -V -P10
    ...    ELSE IF    '${protocol}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    iperf -c ${smawave_ue_addr} -u -i1 -l1400 -p ${iperf_port_num} -b ${T-Put} -t ${Tput_dura}
    ...    ELSE IF    '${protocol}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    iperf -c ${smawave_ue_addr} -u -i1 -l1400 -p ${iperf_port_num} -b ${T-Put} -t ${Tput_dura} -V
    Login APP Server  APP_Server_${index}  ${index}
    Log to console    \nStart to use ute-async to start iperf process for SMAwave UE_${index}.
    Start Async    Csn_Inst  execute  command=${iperf_cmd_on_app}  connection=APP_Server_${index}  alias=DL_async_${index}
    Log to console    \nAsync process has been started for SMAwave UE_${index}, you can perform other operations/keywords now.
    Set Suite Variable  ${dl_async_flag}  True

Start DL Async Process
    [Documentation]    This keyword used to start DL Async process for some specific OAM operation, FOR USER USAGE.
    ...    when data transfer is also ongoing.
    ...    NOTE:Remember to call Postconditions_ForUE do teardown at end of each TC, when you use this KW to start process with SMAwave UE.
    ...    index : UE identifier index
    ...    T-Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...    data_trans_name : data transfer name for android UE
    ...
    ...    Example-1 : Start DL Async Process  1  80M  120s
    ...    Example-2 : Start DL Async Process  1  80M  120s  tcp
    ...    Example-3 : Start DL Async Process  1  80M  120s  tcp  downlink_test
    [Arguments]    ${index}    ${T-Put}    ${Tput_dura}    ${protocol}=udp    ${data_trans_name}=dl_test
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'  SMAwave Start DL Async Process  ${index}  ${T-Put}  ${Tput_dura}  ${protocol}
    ...    ELSE    run keywords    Log to console  \nTrigger Android UE_${index} Async DL data transfer.
    ...    AND  Start Data Transfer  dt_name=${data_trans_name}  ue_alias=UE_${index}  direction=dl  duration=${Tput_dura}
    ...    throughput=${T-Put}  protocol=${protocol}

SMAwave Calculate and Verify DL Async Tput
    [Documentation]  This keyword used to calculate and verify SMAwave UE Async DL T-Put, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for smawave waiting the async process completion
    ...    protocol : tcp or udp
    ...
    ...    Example : SMAwave Calculate and Verify DL Async Tput  1  180M  30%  120s
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}    ${protocol}
    Log to console    \nAwait the completion of SMAwave UE_${index} Async DL data transfer, please wait a sec.
    ${updated_tput_dura}    Strip String    ${Tput_dura}  mode=right   characters=s
    ${result}=  Wait Until Keyword Succeeds  2x  100ms  Wait for async result  timeout=${updated_tput_dura}  alias=DL_async_${index}
    Log  \nSMAwave UE_${index} DL data transfer async result: ${result}.
    Csn_Inst.download_file   remote_path=/tmp/openwrt_iperf_${index}.log  local_path=${OUTPUT DIR}  connection=SMA_${index}
    Get and Kill Iperf Process on Openwrt  ${index}
    ${dt_dl_row_list}    Run Keyword If  '${protocol}'.lower() == 'tcp'
    ...    SWO.Parse Iperf Trace To Rows  file_to_be_parsed=${OUTPUT DIR}/openwrt_iperf_${index}.log  parallel_streams=${True}
    ...    ELSE    SWO.Parse Iperf Trace To Rows  file_to_be_parsed=${OUTPUT DIR}/openwrt_iperf_${index}.log
    Should Not Be Equal    ${dt_dl_row_list}  EMPTY  msg="DL traffic can't be reached, the iperf file is empty or not exist!"
    ${T_put}    SWO.Count Average Throughput    iperf_row_list=${dt_dl_row_list}
    ${return_result}    SWO.Check Tput With Deviation  expect_tput=${expect_tput}  average_tput=${T_put}  deviation=${deviation}
    Should Be Equal    ${return_result}  Success

Android Calculate and Verify DL Async Tput
    [Documentation]  This keyword used to calculate and verify Android UE DL Async T-Put, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    dt_name : data transfer name for android UE
    ...
    ...    Example : Android Calculate and Verify DL Async Tput  1  180M  30%  downlink_test
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${dt_name}
    Log To Console  \nBegin to check whether Android UE_${index} DL Async data transfer is alive.
    Check Data Transfer Is Alive  ${dt_name}
    Log To Console  \nBegin to check whether Android UE_${index} DL Async data transfer is FINISHED.
    Await Data Transfer Finish  ${dt_name}
    Log to console  \nAndroid UE_${index} DL Async data transfer is COMPLETED, begin to VERIFY its result.
    run keyword and continue on failure
    ...    Verify Average Throughput With Deviation  ${dt_name}  ${expect_tput}  ${deviation}

Calculate and Verify DL Async Tput
    [Documentation]  This keyword used to calculate and verify Async DL T-Put with deviation, FOR USER USAGE.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for smawave waiting the async process completion,android ue not used.
    ...    data_trans_name : data transfer name for android UE
    ...    protocol : tcp or udp
    ...
    ...    Example-1 : Calculate and Verify DL Async Tput  1  180M  30%  120s
    ...    Example-2 : Calculate and Verify DL Async Tput  1  180M  30%  120s  downlink_test
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}    ${data_trans_name}=dl_test    ${protocol}=udp
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'  SMAwave Calculate and Verify DL Async Tput  ${index}  ${expect_tput}
    ...    ${deviation}  ${Tput_dura}  ${protocol}
    ...    ELSE    Android Calculate and Verify DL Async Tput  ${index}  ${expect_tput}  ${deviation}  ${data_trans_name}

SMAwave Start UL Async Process
    [Documentation]    This keyword used to start SMAwave UE UL async iperf process, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    T-Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...
    ...    Example : SMAwave Start UL Async Process  1  30M  180s  tcp/udp
    [Arguments]    ${index}    ${T-Put}    ${Tput_dura}    ${protocol}
    Log to console    \nInfo: Begin to generate ${protocol} port for SMAwave UE_${index} Async UL data transfer.
    ${used_port_list}    SWO.Get Occupied Udp Port List
    ${ul_port_num}    SWO.Get Availabel Udp Port  lines=${used_port_list}
    Log to console    \nInfo: The ${protocol} port used for SMAwave UE_${index} async UL data transfer is ${ul_port_num}.
    Log to console    \nInfo: Begin to perform SMAwave UE_${index} async UL data transfer with T-Put ${T-Put}.

    ${app_server_addr}  SWO.Get Epc Side Ipaddr  ip_addr_list=${ute_iperf_itf_ip_list}  ue_index=${index}
    ${is_protocol_ipv4}=    Run keyword and return status    should_match_regexp  ${app_server_addr}   ${ipv4_pattern}

    ${ul_cmd_on_app_server}    Run Keyword If  '${protocol}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    nohup iperf -s -p ${ul_port_num} -t ${Tput_dura} -i1 > /tmp/ute_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${protocol}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    nohup iperf -s -p ${ul_port_num} -t ${Tput_dura} -i1 -V > /tmp/ute_iperf_${index}.log 2>&1 &
    ...    ELSE IF    '${protocol}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    iperf -s -u -i1 -p ${ul_port_num} -t ${Tput_dura} > /tmp/ute_iperf_${index}.log
    ...    ELSE IF    '${protocol}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    iperf -s -u -i1 -p ${ul_port_num} -t ${Tput_dura} -V > /tmp/ute_iperf_${index}.log
    Csn_Inst.send_command    command=${ul_cmd_on_app_server}  connection=APP_Server_${index}
    ${ul_cmd_on_openwrt}    Run Keyword If  '${protocol}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    /usr/bin/iperf -c ${app_server_addr} -p ${ul_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400
    ...    ELSE IF    '${protocol}'.lower() == 'tcp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    /usr/bin/iperf -c ${app_server_addr} -p ${ul_port_num} -t ${Tput_dura} -i1 -M 1400 -l1400 -V
    ...    ELSE IF    '${protocol}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'True'  Set Variable
    ...    /usr/bin/iperf -c ${app_server_addr} -u -i1 -l1400 -p ${ul_port_num} -t ${Tput_dura} -b ${T-Put}
    ...    ELSE IF    '${protocol}'.lower() == 'udp' and '${is_protocol_ipv4}' == 'False'  Set Variable
    ...    /usr/bin/iperf -c ${app_server_addr} -u -i1 -l1400 -p ${ul_port_num} -t ${Tput_dura} -b ${T-Put} -V
    Start Async    Csn_Inst    execute    command=${ul_cmd_on_openwrt}  connection=SMA_${index}  alias=UL_async_${index}
    Log to console    \nInfo: Successfully perform SMAwave UE_${index} async UL data transfer with T-Put ${T-Put} duration is ${Tput_dura}.
    Set Suite Variable  ${ul_async_flag}  True

Start UL Async Process
    [Documentation]    This keyword used to start UL Async process for some specific OAM operation, FOR USER USAGE.
    ...    when data transfer is also ongoing.
    ...    NOTE:Remember to call Postconditions_ForUE do teardown at end of each TC, when you use this KW to start process with SMAwave UE.
    ...    index : UE identifier index
    ...    T-Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...    data_trans_name : data transfer name for android UE
    ...
    ...    Example-1 : Start UL Async Process  1  30M  180s
    ...    Example-2 : Start UL Async Process  1  30M  180s  tcp
    ...    Example-3 : Start UL Async Process  1  30M  180s  tcp  uplink_test
    [Arguments]    ${index}    ${T-Put}    ${Tput_dura}    ${protocol}=udp    ${data_trans_name}=ul_test
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'  SMAwave Start UL Async Process  ${index}  ${T-Put}  ${Tput_dura}  ${protocol}
    ...    ELSE    run keywords    Log to console  \nTrigger Android UE_${index} Async UL data transfer.
    ...    AND  Start Data Transfer  dt_name=${data_trans_name}  ue_alias=UE_${index}  direction=ul  duration=${Tput_dura}
    ...    throughput=${T-Put}  protocol=${protocol}

SMAwave Calculate and Verify UL Async Tput
    [Documentation]  This keyword used to calculate and verify SMAwave UE Async UL T-Put, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for waiting the async process completion
    ...
    ...    Example : SMAwave Calculate and Verify UL Async Tput  1  30M  20%  120s
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}
    Log to console    \nAwait the completion of SMAwave UE_${index} Async UL data transfer, please wait a sec.
    ${updated_tput_dura}    Strip String    ${Tput_dura}  mode=right  characters=s
    ${result}=  Wait Until Keyword Succeeds  2x  100ms  Wait for async result  timeout=${updated_tput_dura}  alias=UL_async_${index}
    Log  \nSMAwave UE_${index} async UL data transfer async result: ${result}.
    Csn_Inst.download_file  remote_path=/tmp/ute_iperf_${index}.log  local_path=${OUTPUT DIR}/ute_iperf_${index}.log
    ...    connection=APP_Server_${index}
    ${dt_ul_row_list}    SWO.Parse Iperf Trace To Rows  file_to_be_parsed=${OUTPUT DIR}/ute_iperf_${index}.log
    Should Not Be Equal    ${dt_ul_row_list}  EMPTY  msg="UL traffic can't be reached, the iperf file is empty or not exist!"
    ${T_put}    SWO.Count Average Throughput    iperf_row_list=${dt_ul_row_list}
    ${return_result}    SWO.Check Tput With Deviation  expect_tput=${expect_tput}  average_tput=${T_put}  deviation=${deviation}
    Should Be Equal    ${return_result}  Success

Android Calculate and Verify UL Async Tput
    [Documentation]  This keyword used to calculate and verify Android UE UL Async T-Put, KW dev internal usage, not open to USER.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    dt_name : data transfer name for android UE
    ...
    ...    Example : Android Calculate and Verify UL Async Tput  1  80M  30%  uplink_test
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${dt_name}
    Log To Console  \nBegin to check whether Android UE_${index} UL Async data transfer is alive.
    Check Data Transfer Is Alive  ${dt_name}
    Log To Console  \nBegin to check whether Android UE_${index} UL Async data transfer is FINISHED.
    Await Data Transfer Finish  ${dt_name}
    Log to console  \nAndroid UE_${index} UL Async data transfer is COMPLETED, begin to VERIFY its result.
    run keyword and continue on failure
    ...    Verify Average Throughput With Deviation  ${dt_name}  ${expect_tput}  ${deviation}

Calculate and Verify UL Async Tput
    [Documentation]  This keyword used to calculate and verify Async UL T-Put with deviation, FOR USER USAGE.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for smawave waiting the async process completion,android ue not used.
    ...    data_trans_name : data transfer name for android UE
    ...    protocol : tcp or udp
    ...
    ...    Example-1 : Calculate and Verify UL Async Tput  1  30M  20%  120s
    ...    Example-2 : Calculate and Verify UL Async Tput  1  180M  30%  120s  uplink_test
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}    ${data_trans_name}=ul_test
    Run Keyword If  '${ue_type_flag}' == 'SMAWAVE_UE'  SMAwave Calculate and Verify UL Async Tput  ${index}  ${expect_tput}
    ...    ${deviation}  ${Tput_dura}
    ...    ELSE    Android Calculate and Verify UL Async Tput  ${index}  ${expect_tput}  ${deviation}  ${data_trans_name}

Is Exception UE
    [Documentation]  check UE type by serial number
    ...    :param ue_index
    [Arguments]    ${ue_index}
    ${index}=   Evaluate   ${ue_index}-1
    &{cpctmp}=    Set Variable    @{UEPC_DICT_LIST}[${index}]
    Connect to control pc    &{cpctmp}[cpc_ip]    &{cpctmp}[cpc_usr]   &{cpctmp}[cpc_pwd]    cpc_${ue_index}
    ${devie_type}=    Get adb devices type    ${ue_index}    &{cpctmp}[sn]    cpc_${ue_index}
    ${isExceptionUE}=    Set Variable if   """${devie_type}""" in """${exception_ue_list}"""   ${True}    ${False}
    [Return]    ${isExceptionUE}

ADB Reboot UEs With UE Index
    [Documentation]  Use adb command to reboot the android ue device with ue_index
    ...    :param ue_index
    [Arguments]    ${ue_index}
    ${index}=   Evaluate   ${ue_index}-1
    &{cpctmp}=    Set Variable    @{UEPC_DICT_LIST}[${index}]
    Connect to control pc    &{cpctmp}[cpc_ip]    &{cpctmp}[cpc_usr]   &{cpctmp}[cpc_pwd]    cpc_${ue_index}
    ADB Reboot UEs    &{cpctmp}[sn]  cpc_${ue_index}
    Wait Until Keyword Succeeds    20x  5s    Fetch Android UE Addr  &{cpctmp}[sn]  ${ue_index}
    Sleep  10s

Fetch Android UE Addr
    [Documentation]  This keyword used to get Android UE IP address after attach operation.
    ...    :param serial_number
    ...    :param ue_index
    ...    Example : Fetch Android UE Addr  MDX0220C10003775  cpc_1
    [Arguments]    ${serial_number}    ${ue_index}
    ${ute_iperf_itf_ip}  Set Variable
    ...  ${ue_inline['UE_${ue_index}']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['iperf_interface_ip']}
    Set Suite Variable      ${ute_iperf_itf_ip}
    Log to console    \nInfo: The UTE iperf interface IP address is ${ute_iperf_itf_ip}.
    ${get_IPaddr_cmd_android}    Set Variable
    ...    adb -s ${serial_number} shell ip a |grep inet |grep global |awk '{print $2}'| cut -d / -f 1
    Log to console    \nInfo: Begin to get Android UE IP address.
    Csn_Inst.send_command    command=${get_IPaddr_cmd_android}   connection=cpc_${ue_index}
    ${Android_UE_IP_ADDR}   Csn_Inst.read_output     connection=cpc_${ue_index}
    ${Android_UE_IP_ADDR}=    Remove String  ${Android_UE_IP_ADDR}  \n
    ${Android_UE_IP_ADDR}=    Remove String  ${Android_UE_IP_ADDR}  \r
    Run Keyword If  "${Android_UE_IP_ADDR}" == ""  Fail  msg='\nInfo: No IP Address Found.'
    Log to console    \nInfo: Android UE assigned IP address is ${Android_UE_IP_ADDR}.
    Set suite variable  ${Android_UE_IP_ADDR}

Get and Kill Iperf Process on Remote
    [Documentation]  This keyword used to get iperf process on ute or ue pc and then kill them.
    ...    cmd_get_iperf : the cmd to get iperf
    ...    conn_alias : remotely login session alias
    [Arguments]   ${cmd_get_iperf}   ${connection_alias}
    Csn_Inst.send_command    command=${cmd_get_iperf}   connection=${connection_alias}
    ${process_id}   Csn_Inst.read_output     connection=${connection_alias}
    ${iperf_process}   Split String    ${process_id}     separator=\n
    @{iperf_process_id}     Get Slice From List     ${iperf_process}  start=0  end=-1
    Log to console    \nInfo: iperf id on remote is @{iperf_process_id}.
    Set suite variable  @{iperf_process_id}
    :FOR    ${item}     IN    @{iperf_process_id}
    \   Log to console    \nInfo: Begin to kill iperf process id ${item} on remote.
    \   Csn_Inst.send_command    command=kill -9 ${item}  connection=${connection_alias}
    \   sleep  2s

Android DL Traffic with CMD
    [Documentation]  This keyword used to perform and verify Android UE UDP downlink data transfer without UE Manager
    ...    ue_index : ue index
    ...    duration : data transfer duration in robot time string format
    ...    iperf_throughput : desired data transfer throughput, format should be e.g 80M
    ...    dl_expect_tput : desired average data transfer throughput
    ...    dl_deviation : acceptable deviation, format should be similar to 20%
    ...    window_size : window size foe cmd, default is 20M
    ...
    ...    Example : Android DL Traffic with CMD  1  120s  80M  70M  20%
    [Arguments]
    ...    ${ue_index}    ${duration}    ${iperf_throughput}
    ...    ${dl_expect_tput}    ${dl_deviation}    ${window_size}=20m
    Login APP Server  APP_Server_${ue_index}  ${ue_index}
    Android Start DL Iperf Process with CMD    ${ue_index}    ${iperf_throughput}    ${duration}    ${window_size}
    Get and Kill Iperf Process on Remote    ${get_iperf_id_cmd_android}    cpc_${ue_index}
    Get and Kill Iperf Process on Remote    ${get_iperf_id_cmd_android}    APP_Server_${ue_index}
    Run Keyword And Continue On Failure
    ...    Android UE Calculate and Verify DL Tput with CMD    ${ue_index}    ${dl_expect_tput}    ${dl_deviation}
    Csn_Inst.disconnect  connection=APP_Server_${ue_index}

Android Start DL Iperf Process with CMD
    [Documentation]  This keyword used to start iperf process on both UTE VM and UE PC for Android UE DL data transfer
    ...    need put iperf under /data/local/tmp firsly
    ...    ue_index: ue index
    ...    T-Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...
    ...    Example : Android Start DL Iperf Process with CMD  1 80M  120s
    [Arguments]   ${ue_index}    ${T-Put}    ${Tput_dura}   ${size}=20M
    ${index}=   Evaluate   ${ue_index}-1
    &{cpctmp}=    Set Variable    @{UEPC_DICT_LIST}[${index}]

    Log to console    \nInfo: Begin to generate DL data transfer UDP port.
    ${used_port_list}    SWO.Get Occupied Udp Port List
    ${iperf_port_num}    SWO.Get Availabel Udp Port  lines=${used_port_list}
    Log to console    \nInfo: The UDP port used for DL data transfer is ${iperf_port_num}.
    ${dl_cmd_on_ue_pc}    Set Variable
    ...  adb -s &{cpctmp}[sn] shell ${iperf_path} -s -u -l1400 -w ${size} -i1 -p ${iperf_port_num} 2>&1 > /tmp/DL_iperf_${ue_index}.log
    Log to console    \nInfo: DL CMD on UE PC: ${dl_cmd_on_ue_pc}
    Csn_Inst.send_command    command=${dl_cmd_on_ue_pc}    connection=cpc_${ue_index}
    sleep  1s
    Log to console    \nInfo: Begin to perform DL data traffic with throughput ${T-Put}.
    ${iperf_cmd_on_app}   Set Variable
    ...    iperf -c ${Android_UE_IP_ADDR} -u -i1 -l1400 -w ${size} -p ${iperf_port_num} -b ${T-Put} -t ${Tput_dura}
    Log to console    \nInfo: DL CMD on APP Server: ${iperf_cmd_on_app}
    Csn_Inst.execute     command=${iperf_cmd_on_app}   connection=APP_Server_${ue_index}
    sleep  1s
    Log to console    \nInfo: Successfully perform DL data traffic with throughput ${T-Put} duration is ${Tput_dura}.

Android UE Calculate and Verify DL Tput with CMD
    [Documentation]  This keyword used to calculate and verify Android UE DL T-Put with deviation triggered by CMD
    ...    ue_index: ue index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Android UE Calculate and Verify DL Tput with CMD  1  180M  30%
    [Arguments]     ${ue_index}     ${expect_tput}      ${deviation}
    Csn_Inst.download_file   remote_path=/tmp/DL_iperf_${ue_index}.log  local_path=${OUTPUT DIR}/DL_iperf_${ue_index}.log
    ...   connection=cpc_${ue_index}
    ${dt_dl_row_list}   SWO.Parse Iperf Trace To Rows   file_to_be_parsed=${OUTPUT DIR}/DL_iperf_${ue_index}.log
    ${T_put}    SWO.Count Average Throughput    iperf_row_list=${dt_dl_row_list}
    ${return_result}    SWO.Check Tput With Deviation  expect_tput=${expect_tput}    average_tput=${T_put}
    ...   deviation=${deviation}
    Should Be Equal     ${return_result}    Success

Android UL Traffic with CMD
    [Documentation]  This keyword used to perform and verify Android UE UDP uplink data transfer without UE Manager
    ...    ue_index : ue index
    ...    duration : data transfer duration in robot time string format
    ...    iperf_ul_throughput : desired data transfer throughput, format should be e.g 80M
    ...    ul_expect_tput : desired average data transfer throughput
    ...    ul_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Android UL Traffic with CMD  1  120s  30M  25M  20%
    [Arguments]
    ...    ${ue_index}    ${duration}    ${iperf_ul_throughput}
    ...    ${ul_expect_tput}    ${ul_deviation}
    Login APP Server  APP_Server_${ue_index}  ${ue_index}
    Android Start UL Iperf Process with CMD    ${ue_index}    ${iperf_ul_throughput}    ${duration}
    Get and Kill Iperf Process on Remote    ${get_iperf_id_cmd_android}    cpc_${ue_index}
    Get and Kill Iperf Process on Remote    ${get_iperf_id_cmd_android}    APP_Server_${ue_index}
    Run Keyword And Continue On Failure
    ...    Android UE Calculate and Verify UL Tput with CMD    ${ue_index}    ${ul_expect_tput}    ${ul_deviation}
    Csn_Inst.disconnect  connection=APP_Server_${ue_index}

Android Start UL Iperf Process with CMD
    [Documentation]  This keyword used to start iperf process on both UTE VM and UE PC for Android UE UL data transfer
    ...    need put iperf under /data/local/tmp firsly
    ...    ue_index: ue index
    ...    T-Put : desired data transfer throughput, format should be e.g 80M
    ...    Tput_dura : data transfer duration in robot time string format
    ...
    ...    Example : Android Start UL Iperf Process with CMD  1 80M  120s
    [Arguments]   ${ue_index}    ${T-Put}    ${Tput_dura}
    ${index}=   Evaluate   ${ue_index}-1
    &{cpctmp}=    Set Variable    @{UEPC_DICT_LIST}[${index}]
    Log to console    \nInfo: Begin to generate UL data transfer UDP port.
    ${used_port_list}       SWO.Get Occupied Udp Port List
    ${ul_port_num}    SWO.Get Availabel Udp Port  lines=${used_port_list}
    Log to console    \nInfo: The UDP port used for UL data transfer is ${ul_port_num}.
    Log to console    \nInfo: Begin to perform UL data traffic with T-Put ${T-Put}.
    ${ul_cmd_on_ue_pc}    Set Variable
    ...  adb -s &{cpctmp}[sn] shell ${iperf_path} -c ${ute_iperf_itf_ip} -u -i1 -l1400 -p ${ul_port_num} -t ${Tput_dura} -b ${T-Put}
    Log to console    \nInfo: UL CMD on UE PC: ${ul_cmd_on_ue_pc}
    Csn_Inst.send_command    command=${ul_cmd_on_ue_pc}    connection=cpc_${ue_index}
    ${ul_cmd_on_app_server}  Set Variable  iperf -s -u -i1 -p ${ul_port_num} -t ${Tput_dura} 2>&1 > /tmp/UL_iperf_${ue_index}.log
    Log to console    \nInfo: UL CMD on APP Server: ${ul_cmd_on_app_server}
    Csn_Inst.execute     command=${ul_cmd_on_app_server}   connection=APP_Server_${ue_index}
    sleep  1s
    Log to console    \nInfo: Successfully perform UL data traffic with T-Put ${T-Put} duration is ${Tput_dura}.

Android UE Calculate and Verify UL Tput with CMD
    [Documentation]  This keyword used to calculate and verify Android UE UL T-Put with deviation triggered by CMD
    ...    ue_index: ue index
    ...    expect_tput : desired average data transfer throughput
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Android UE Calculate and Verify UL Tput with CMD  1  30M  30%
    [Arguments]     ${ue_index}     ${expect_tput}    ${deviation}
    Csn_Inst.download_file   remote_path=/tmp/UL_iperf_${ue_index}.log  local_path=${OUTPUT DIR}/UL_iperf_${ue_index}.log
    ...  connection=APP_Server_${ue_index}
    ${dt_dl_row_list}   SWO.Parse Iperf Trace To Rows   file_to_be_parsed=${OUTPUT DIR}/UL_iperf_${ue_index}.log
    ${T_put}    SWO.Count Average Throughput    iperf_row_list=${dt_dl_row_list}
    ${return_result}    SWO.Check Tput With Deviation  expect_tput=${expect_tput}    average_tput=${T_put}   deviation=${deviation}
    Should Be Equal     ${return_result}    Success

Reserve ue for tests
    [Documentation]  This keyword is used to detect ue that connect to control PC by USB.
    ...  It is strongly suggested to put this keyword into the suite setup.
    ...  If you put the keyword in the testcase scope, ue.teardown will automatically called when exiting the scope.
    ...  :param UE_CAPABILITIES:  REAL_ANDROID_UE.
    ...  :param UE_alias:  It is a name to distingush ue.
    [Arguments]  ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_ANDROID_UE
    ute_ue.require Ue  ${UE_alias}  capabilities=${UE_CAPABILITIES}

Connect to control pc
    [Documentation]  connect the control PC
    ...   :param cpc_ip: the ip address of control PC
    ...   :param cpc_usrname:  the user name to login in control PC
    ...   :param cpc_passwd: the user password to login in control PC
    [Arguments]    ${cpc_ip}    ${cpc_usrname}   ${cpc_passwd}  ${alias}=cpc
    ${connection_status}    Run keyword and return status   Connect to cpc    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}
    Run keyword if    '${connection_status}'=='${False}'     Log
    ...      CPC connection failed: ${cpc_ip} / ${cpc_usrname} / ${cpc_passwd} !    WARN
    Should be true    ${connection_status}

Connect to cpc
    [Documentation]  connect the control PC
    ...   :param cpc_ip: the ip address of control PC
    ...   :param cpc_usrname:  the user name to login in control PC
    ...   :param cpc_passwd: the user password to login in control PC
    [Arguments]    ${cpc_ip}    ${cpc_usrname}   ${cpc_passwd}  ${alias}=cpc
    Wait Until Keyword Succeeds    5min    20s
    ...   Csn_Inst.Connect to   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}

Get Remote Pair TestLine Cell Info
    [Documentation]  Get remote peer dedicated cell info
    ...   :param remote_ip: ip address of remote testline
    ...   :param remote_username: user name of remote testline
    ...   :param remote_passwd: user password of remote testline
    [Arguments]    ${remote_ip}  ${remote_username}  ${remote_passwd}
    ${return_cell_info}  SWO.Get Remote Testline Cell Info  vm_ipaddr=${remote_ip}  vm_user=${remote_username}
    ...           vm_password=${remote_passwd}
    ${cell_list}  SWO.Parse Remote Cell Info Into List  cell_info_dict=${return_cell_info['cells']}
    [Return]  ${cell_list}

Verify Attach To Target Cell
    [Documentation]  verify specific UE whether attach on the expected cell
    ...   :param index : UE identifier index
    ...   :param target_pci : target pci index
    ...   :param ip_addr: ip address of remote testline
    ...   :param username: user name of remote testline
    ...   :param password: user password of remote testline
    ...
    ...   Example : Verify Attach To Target Cell  1  ${pci_value}  ${ip_addr}  ${user_name}  ${password}
    [Arguments]    ${index}  ${target_pci}  ${ip_addr}  ${username}  ${password}
    #step 1 - get target cell info
    ${target_cell}  Get Remote Pair TestLine Cell Info  ${ip_addr}  ${username}  ${password}
    Log To Console  \nInfo: Target Cell Info : ${target_cell}
    #step 2 - use at command to get attached cell info
    Csn_Inst.send_command  command=${check_attach_cmd}  connection=SMA_${index}
    ${output}  Csn_Inst.read_output  connection=SMA_${index}
    ${attached_cell}  SWO.Parse Atcmd Cell Info Into Dict  input_str=${output}
    Log To Console  \nInfo: Attached Cell Info : ${attached_cell}
    #step 3 - verify attach result
    ${result}  SWO.Verify Cell Attach Result  pci_index=${target_pci}
    ...                                       target_cell=${target_cell}  attach_cell=${attached_cell}
    Log To Console  \nInfo: Check UE attach on target cell result : ${result}
    Should Be Equal    ${result}  YES

Get Frequency Locking Information
    [Documentation]  This keyword used to get the currently locked frequency.
    ...    Returned locked frequency: {'4G': {'xfcn': '1650', 'pci': '310'}, '5G': {'xfcn': '636200', 'scs': '1'}}
    ...    No frequency locked: {'4G': None, '5G': None}
    ...    Note : Before using this kW, please ensure that the scanning mode selected on the UE web page is full frequency band !!
    ...
    ...    Example : testsuite/Nanjing/OAM/Pilot/Pilot_SMAwave_Lock_Frequency_Test.robot
    [Arguments]    ${ue_index}
    SMAwave remotely login UE  ue_index=${ue_index}
    Csn_Inst.send_command    command=${comd_stop_cmd}  connection=SMA_${ue_index}
    Sleep    2s
    Log To Console  \nBegin to query current frequency locking infomation
    Csn_Inst.send_command  command=${check_freq_lock_cmd}  connection=SMA_${ue_index}
    ${output}  Csn_Inst.read_output  connection=SMA_${ue_index}
    ${result}  SWO.Parse Atcmd Locked Freq Info  input_string=${output}
    Log To Console  \nInfo: Currentlly Locked Frequency Info : ${result}
    Dictionary Should Not Contain Value    ${result}    ongoing
    [Return]      ${result}
    [Teardown]    Run keywords    Csn_Inst.send_command    command=${comd_start_cmd}  connection=SMA_${ue_index}
    ...    AND    Csn_Inst.Disconnect    connection=SMA_${ue_index}

Lock 4G or 5G Frequency
    [Documentation]
    ...    Note : Before using this kW, please ensure that the scanning mode selected on the UE web page is full frequency band !!
    ...
    ...    Example : testsuite/Nanjing/OAM/Pilot/Pilot_SMAwave_Lock_Frequency_Test.robot
    [Arguments]    ${ue_index}  ${tech}  ${xfcn}  ${4g_pci_or_5g_scs}
    SMAwave remotely login UE  ue_index=${ue_index}
    Csn_Inst.send_command    command=${comd_stop_cmd}  connection=SMA_${ue_index}
    Sleep    2s
    Log To Console  \nBegin to lock ${tech} frequency
    ${lock_cmd}    Run Keyword If  '${tech}'.lower() == '4g'  Set Variable  ${freq_lock_unlock_cmd}0,1,${xfcn},${4g_pci_or_5g_scs}
    ...    ELSE IF  '${tech}'.lower() == '5g'  Set Variable  ${freq_lock_unlock_cmd}1,1,${xfcn},${4g_pci_or_5g_scs}
    Csn_Inst.send_command  command=${lock_cmd}  connection=SMA_${ue_index}
    Sleep    2s
    ${output}  Csn_Inst.read_output  connection=SMA_${ue_index}
    Should Not Contain  ${output}  ERROR
    Should Contain  ${output}  OK
    Log To Console  \nLock ${tech} frequency Success
    [Teardown]    Run keywords    Csn_Inst.send_command    command=${comd_start_cmd}  connection=SMA_${ue_index}
    ...    AND    Csn_Inst.Disconnect    connection=SMA_${ue_index}

Unlock 4G or 5G Frequency
    [Documentation]
    ...    Note : Before using this kW, please ensure that the scanning mode selected on the UE web page is full frequency band !!
    ...
    ...    Example : testsuite/Nanjing/OAM/Pilot/Pilot_SMAwave_Lock_Frequency_Test.robot
    [Arguments]    ${ue_index}  ${tech}
    SMAwave remotely login UE  ue_index=${ue_index}
    Csn_Inst.send_command    command=${comd_stop_cmd}  connection=SMA_${ue_index}
    Sleep    2s
    Log To Console  \nBegin to unlock ${tech} frequency
    ${unlock_cmd}    Run Keyword If  '${tech}'.lower() == '4g'  Set Variable  ${freq_lock_unlock_cmd}0,0
    ...    ELSE IF  '${tech}'.lower() == '5g'  Set Variable  ${freq_lock_unlock_cmd}1,0
    Csn_Inst.send_command  command=${unlock_cmd}  connection=SMA_${ue_index}
    ${output}  Csn_Inst.read_output  connection=SMA_${ue_index}
    Should Not Contain  ${output}  ERROR
    Should Contain  ${output}  OK
    Log To Console  \nUnlock ${tech} frequency Success
    [Teardown]    Run keywords    Csn_Inst.send_command    command=${comd_start_cmd}  connection=SMA_${ue_index}
    ...    AND    Csn_Inst.Disconnect    connection=SMA_${ue_index}
