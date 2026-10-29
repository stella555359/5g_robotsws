*** Settings ***
Documentation    Kws for AT command UE, eg: Inseego
...              Inseego need extral configurations in ue.yml
...              Inseego need one extral step 'Prepare Ue For Data Transfer'
...              Inseego can't Verify 4G Attach by ADB Command
...              Inseego can't Start the uemanager App
...              Now it is based on ta_ue_plugin_andorid, will replaced by taf.ue.plugin.at later
...              author: Fan Geyou
...              Contact: geyou.fan@nokia-sbell.com
...              Squard: 5G_PZ_HZ_4_SG

Library           taf.ue  WITH NAME   ute_ue
Library           taf.transport.ssh    WITH NAME    csn
Library           ../python/ue.py
Resource          android_common_keyword.robot
Resource          ../Iperf/traffic_via_iperf.robot
Resource          ../LOG/aasyslog.robot

*** Variables ***

*** Keywords ***
Prepare At Cmd UE
    [Documentation]  This keyword is the precondition for at cmd ue
    ...  It uses common require_ue in ute_ue and then reset ue
    ...  :param ue_index:  It is the index of tl.ues
    ...  :param capabilities:  It is the capabilities of ue.
    [Arguments]  ${ue_index}=${0}    ${reboot_ue}=${False}
    _Prepare Variables    ue_index=${ue_index}
    csn.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=cpc_${ue_index}
    csn.Execute   command=adb kill-server   connection=cpc_${ue_index}
    csn.Execute   command=adb start-server   connection=cpc_${ue_index}
    run keyword if    '${reboot_ue}'=='${True}'    _Reboot_UE    connection=cpc_${ue_index}
    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${capabilities[0]}

_Prepare Variables
    [Arguments]  ${ue_index}=${0}
    ${ue_config}   get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
    set suite variable    ${cpc_ip}     ${ue_config['cpc_ip']}
    set suite variable    ${cpc_username}    ${ue_config['cpc_username']}
    set suite variable    ${cpc_password}    ${ue_config['cpc_password']}
    set suite variable    ${appserver_addr}    ${ue_config['data_transfer']['ssh']['host']}
    set suite variable    ${appserver_username}    ${ue_config['data_transfer']['ssh']['user']}
    set suite variable    ${appserver_password}    ${ue_config['data_transfer']['ssh']['password']}
    set suite variable    ${serial}    ${ue_config['serial_number']}
    set suite variable    ${capabilities}    ${ue_config['capabilities']}
    set suite variable    ${qci}    ${ue_config['qci']}
    set suite variable    ${AT_iperf_port}    ${ue_config['data_transfer']['iperf_options']['qci']['5']}
    ${status}    run keyword and return status    get from dictionary    ${ue_config['data_transfer']}    ue_ssh
    run keyword if    ${status}    run keywords    set suite variable    ${ue_manage_ip}    ${ue_config['data_transfer']['ue_ssh']['host']}    AND
    ...    set suite variable    ${ue_manage_username}    ${ue_config['data_transfer']['ue_ssh']['user']}    AND
    ...    set suite variable    ${ue_manage_password}    ${ue_config['data_transfer']['ue_ssh']['password']}    AND
    ...    set suite variable    ${ue_manage_root_password}    ${ue_config['data_transfer']['ue_ssh']['root_password']}

At Cmd UE Attach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=0
    ...    ${log_type}=Aasyslog    ${interval}=${1}    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  With Aasyslog catch normally please confirm the RD parameter 0x1003F=1;0x10040=1 have been setted in swconfig
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    ...  :param  hwcheck_index: The list index with mapping as 0->ASIK 1->ABIL1 2->ABIL2 3ABIL3, it will use the
    ...          mapping HW to check the ue attach status
    ...  :param  interval: define the interval time(seconds) between with UE detach and attach
    Run Keyword And Ignore Error    At Cmd UE Detach    ue_index=${ue_index}
    sleep    ${interval}s
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2hidu
    Ue attach with index    ue_index=${ue_index}
    ${inseego}    run keyword and return status   Should contain match
    ...    ${capabilities}    Inseego    case_insensitive=True
    run keyword if    ${inseego}==${True}    _Set Iptables For Inseego    connection=cpc_${ue_index}
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    ${hwcheck_index}    ${log_type}
    ...    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}

At Cmd UE Detach
    [Documentation]  Use taf.ue to detach UE
    ...  Send AT cmd to UE to detach if taf.ue.detach_ue fail
    ...  :param ue_index:  It is the index of tl.ues
    [Arguments]  ${ue_index}=${0}
    ${status}    Run Keyword And Return Status    Ue Detach With Index    ue_index=${ue_index}
    Run Keyword If   '${status}'=='False'    ute_ue.Send At Cmd To Ue   UE_${ue_index}    at_cmd=AT+CFUN=0

At Cmd UE Verify Attach
    [Arguments]    ${5Grach_ed}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${4G_check}=True
    ...            ${5Gstatus}=PASS
    [Documentation]    Verify attach result when plugin self verify not suffient
    ...  With Aasyslog catch normally please confirm the RD parameter 0x1003F=1;0x10040=1 have been setted in swconfig
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for verify attach
    ...  :param  5Grach_ed: the return value from ue attach, contain the RACH count and time and check location
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    ...  :param  4G_check: 4G ue attach need check or not
    ...  :param  5Gstatus: The expected 5G attach result, contain special sce need attach fail check
    run keyword if    ${4G_check} == True    _At Cmd UE Get Attach Info      ue_index=${ue_index}
    ${status}    run keyword and return status    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...    before=${5Grach_ed[0]}    before_time=${5Grach_ed[1]}    hwcheck_index=${5Grach_ed[2]}    log_type=${5Grach_ed[3]}
    ...    gnb_index=${gnb_index}    5Gstatus=${5Gstatus}    log_loca=l2lo
    Run keyword if    '${status}'=='False'    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...    before=${5Grach_ed[4]}    before_time=${5Grach_ed[5]}    hwcheck_index=${5Grach_ed[2]}    log_type=${5Grach_ed[3]}
    ...    gnb_index=${gnb_index}    5Gstatus=${5Gstatus}    log_loca=l2hidu
    [Teardown]    run keyword if  '${5Grach_ed[3]}'=='Aasyslog'    Teardown the Aasyslog save progress
    ...    gnb_index=${gnb_index}    du_index=${du_index}

_At Cmd UE Get Attach Info
    [Documentation]  Get 4G attach information via at command
    ...  :param ue_index:  It is the index of tl.ues
    [Arguments]  ${ue_index}=${0}
    ${cell}=    Get UE INFO    UE_${ue_index}      CELL_ID
    ${enb}=     Get UE INFO    UE_${ue_index}      ENB_ID
    ${ip}=      Get UE INFO    UE_${ue_index}      IP
    set suite variable    ${ue_ip}    ${ip}
    Log To Console    \nAttach to Cell ${cell} in BTS${enb}, IP=${ip}

Start DL Traffic And Check ThoughPut
    [Documentation]   Description: Start AT CMD UE DL traffic and check throughput using taf.ue library.
    [Arguments]   ${dl_time}=120s   ${dl_throughput}=100Mbits/sec   ${dl_deviation}=10   ${ue_index}=${0}
    ...    ${dt_index}=${0}    ${packet_size}=${8}
    ute_ue.Start Data Transfer   duration=${dl_time}   throughput=${dl_throughput}   dt_name=DT_${dt_index}
    ...   ue_alias=UE_${ue_index}   protocol=udp   direction=dl    packet_size=${packet_size}
    ute_ue.Await Data Transfer Finish   dt_name=DT_${dt_index}
    ute_ue.Verify Average Throughput With Deviation
    ...    dt_name=DT_${dt_index}   tput=${dl_throughput}   deviation=${dl_deviation}%

Start UL Traffic And Check ThoughPut
    [Documentation]   Description: Start AT CMD UE UL traffic and check throughput using taf.ue library.
    [Arguments]   ${ul_time}=120s   ${ul_throughput}=10Mbits/sec   ${ul_deviation}=10   ${ue_index}=${0}
    ...   ${dt_index}=${0}    ${packet_size}=${8}
    ute_ue.Start Data Transfer   duration=${ul_time}   throughput=${ul_throughput}   dt_name=DT_${dt_index}
    ...   ue_alias=UE_${ue_index}   protocol=udp   direction=ul    packet_size=${packet_size}
    ute_ue.Await Data Transfer Finish   dt_name=DT_${dt_index}
    ute_ue.Verify Average Throughput With Deviation
    ...    dt_name=DT_${dt_index}   tput=${ul_throughput}   deviation=${ul_deviation}%

_Set Iptables For Inseego
    [Documentation]  This KW is for Inseego only
    ...  it should be called after every attach action
    ...  :param ue_index:  It is the index of tl.ues
    [Arguments]  ${connection}=cpc_0    ${timeout}=${30}
    _Excute ADB Command On UE PC
    ...    command=adb -s ${serial} root    connection=${connection}    timeout=${timeout}
    Sleep    1s
    _Excute ADB Command On UE PC
    ...    command=adb -s ${serial} shell iptables -I INPUT -i rmnet_data0 -j ACCEPT
    ...    timeout=${timeout}    connection=${connection}

_Excute ADB Command On UE PC
    [Documentation]  This KW is for Inseego only
    ...  it should be called after every attach action
    ...  :param ue_index:  It is the index of tl.ues
    [Arguments]    ${command}    ${connection}=cpc_0    ${timeout}=${10}
    #${output}=    csn.execute    command=${command}    connection=${connection}    timeout=${timeout}
    csn.send_command    command=${command}    connection=${connection}
    ${output}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=${connection}    
    [Return]    ${output}

_Reboot UE
    [Arguments]    ${serial}=${serial}    ${connection}=cpc_0    ${timeout}=${10}
    _Excute ADB Command On UE PC     command=adb -s ${serial} reboot    connection=${connection}    timeout=${timeout}
    wait until keyword succeeds    3 min    10s    _UE_Exist    connection=${connection}    

_UE Exist
    [Arguments]    ${connection}=cpc_0    ${timeout}=${10}
    ${ue_info}=    _Excute ADB Command On UE PC    command=adb devices    connection=${connection}    timeout=${timeout}
    Should Contain    ${ue_info}    ${serial}

AT Teardown
    [Arguments]    ${connection}=cpc_0
    csn.disconnect      connection=${connection}
    Log to console    \nINFO:disconnect to UE pc