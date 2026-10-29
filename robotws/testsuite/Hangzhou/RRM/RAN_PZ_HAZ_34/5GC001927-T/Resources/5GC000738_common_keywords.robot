*** Settings ***
Documentation
...    author: Andy Cheng
...    contact: huimin.1.cheng@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC000738 Multiple PLMN ID support

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    Telnet
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.epcsim    WITH NAME    epc
Library    taf.config.scf    WITH NAME    scf
Library    taf.lteemu     WITH NAME   lteemu
#Library    ../../../../../resources/python_libs/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.transport.ssh                 WITH NAME       ssh
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Library    taf.analyzer.pcap     WITH NAME    cap
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001927-T/Resources/collect_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001927-T/Resources/__init__.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
Library    licence_keeper.licence_keeper     WITH NAME    LK

*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${UE_pc_ip}    ${tl.ues[0].ssh_connection_details.addr}
${UE_pc_user}    ${tl.ues[0].ssh_connection_details.username}
${UE_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${SN}    ${tl.ues[0].serial_number}
${enb_instance}     ${tl.enbs[0].instance_id}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${gnbbts_dist}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${gnbcell1_dist}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${gnbcell2_dist}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-2
${enbbts_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}
${enbactdyn_para}    actDynTrigLteNrDualConnectivity
${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
${enbx2_para}    administrativeState
${enbmme_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-0
${enbmme_dist1}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-1
${enbmme_para}    ipAddrPrim
${enbmme_para2}    administrativeState
${epcsim_ip}    ${tl.core.default_ssh_connection_details.addr}
${realepc_ip}    10.107.182.164
${f1_sctp_port}    38472
${x2_sctp_port}    36422
${gnb_path}    /tmp/
##get Attenuator parameter from TL
${atten_ip}    ${tl.attenuator[0].ip_addr}
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5GRU2_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${fsp2a_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[1].addr}
${ue_poweron}    AT+CFUN=1
${ue_poweroff}    AT+CFUN=0
${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/
${tl_scf_filename}    Configuration_scf_MRBTS-738gnb.xml
##Get QXDM log from QC
${LKC_LOGIN_USER}    hai.2.huang@nokia-sbell.com
${LKC_LOGIN_PWD}    Password@4
${LKC_CLIENT_PORT}    6006
${LKC_CLIENT_ALIAS}         lkc
${LKC_CLIENT_PATH}         /cygdrive/c/Users/tester/Desktop/QPM_LK1.3
${5G_QXDM_PATH}    C:/MyDrivers/software/QXDM99
${QCAT_EXE_PATH}    "C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe"
${edaemon_host}    ${tl.ues[0].imsi}
${edaemon_user}    ${tl.test_pc.default_ssh_connection_details.username}
${edaemon_pass}    ${tl.ues[0].sec_key}
${edaemon_path}    /opt/iphy/WTS_7577/
${edaemon_config}    1927_tl356_QCM.cfg

*** Keywords ***
##Qualcomm keyword
Forbidden the UE data
    Connect to control pc enhanced
    csn.send command
    ...    command=adb root
    ...    connection=cpc_0
    ...    timeout=5
    sleep  10s
    csn.send command
    ...    command=adb shell iptables -A OUTPUT -p udp --dport 53 -j REJECT
    ...    connection=cpc_0
    ...    timeout=5

Get Qualcomm License
    [Arguments]    ${ue_index}
    Kill QXDM and QPSK exe    ue_index=${ue_index}
    Prepare LKC    ue_index=${ue_index}
    Keep 5G Licence
#    LK.disconnect_ssh_runner    alias=${LKC_CLIENT_ALIAS}

Kill QXDM and QPSK exe
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM QXDM.exe    connection=cpc_${ue_index}
    csn.send command    command=taskkill /F /IM QPSTServer.exe    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Kill ClientMain exe
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM ClientMain.exe    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Prepare LKC
    [Arguments]    ${ue_index}
    ${UE_pc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${UE_pc_user} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${UE_pc_password} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    ${res} =    LK.licence_keeper_client_is_running    alias=${LKC_CLIENT_ALIAS}
    Run Keyword If    ${res} == ${True}     Kill ClientMain exe    ue_index=${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command
    ...    command=cd /cygdrive/c/Users/nokia5G/Desktop/QPM_LK1.3.1;./ClientMain.exe
    ...    connection=cpc_${ue_index}    timeout=100
    Sleep    5s
    LK.connect    host=${UE_pc_ip}    port=${LKC_CLIENT_PORT}
    LK.login    username=${LKC_LOGIN_USER}    password=${LKC_LOGIN_PWD}

Keep 5G Licence
    LK.get_licence_qxdm_5g
    LK.get_licence_qcat_5g

Drop License
    [Arguments]    ${ue_index}=${0}
    ${UE_pc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${UE_pc_user} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${UE_pc_password} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    LK.release_licence_qxdm_5g
    LK.release_licence_qcat_5g
    LK.disconnect
    LK.disconnect_ssh_runner    alias=${LKC_CLIENT_ALIAS}

Capture QXDM log by COMport
    [Arguments]    ${ue_index}    ${QXDM_log_name}    ${COMport}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${isf_file} =    set variable    ${5G_QXDM_PATH}/${QXDM_log_name}.isf
    csn.send command
    ...    command=cmd /c python ${5G_QXDM_PATH}/QXDMLogcatch.py -t 60 -p ${COMport} -c ${5G_QXDM_PATH}/volume.dmc -s ${isf_file}
    ...    connection=cpc_${ue_index}    timeout=300
    sleep    5s
    Csn.disconnect      connection=cpc_${ue_index}

5G isf decoder to txt and save to local
    [Arguments]    ${ue_index}    ${QXDM_log_name}
    Connect to control pc enhanced    ue_index=${ue_index}
    wait until keyword succeeds    2min    2s    Csn.Assert file exists
    ...    remote_path=${5G_QXDM_PATH}/${QXDM_log_name}.hdf    connection=cpc_${ue_index}
    Log to console   \nINFO:5G Qmdl decoder to txt
    Csn.force_reconnect       connection=cpc_${ue_index}
    ${result}   Csn.execute
    ...  command=cmd /c ${QCAT_EXE_PATH} -txt ${5G_QXDM_PATH}/${QXDM_log_name}.hdf
    ...  connection=cpc_${ue_index}
    Log to console   \nINFO:${result}
    Csn.download file
    ...   remote_path=${5G_QXDM_PATH}/${QXDM_log_name}.txt
    ...   local_path=${epc_log_path}${QXDM_log_name}.txt
    ...   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.hdf   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.txt   connection=cpc_${ue_index}
    Csn.disconnect   connection=cpc_${ue_index}

Data Usage Report Volumn SUM
    [Arguments]    ${Log_name}
    cap.read_cap    cap_file=${epc_log_path}${Log_name}    display_filter=x2ap||${e1ap}
    @{DataUsageCountUL} =    cap.get_element_value    element_expression=x2ap.usageCountUL
    ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
    @{DataUsageCountDL} =    cap.get_element_value    element_expression=x2ap.usageCountDL
    ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
    ${Report_Times}    Get Length    ${DataUsageCountUL}
    ${range}=    Set Variable    ${Report_Times}
    ##  add all UL volumn
    ${SumUL_Volum}    Set Variable    ${0}
    FOR    ${i}    IN RANGE    ${range}
        ${SumUL_Volum}=   evaluate     ${SumUL_Volum}+${DataUsageCountUL[${i}]}
    END
    ##  add all DL volumn
    ${SumDL_Volum}    Set Variable    ${0}
    FOR    ${i}    IN RANGE    ${range}
        ${SumDL_Volum}=   evaluate     ${SumDL_Volum}+${DataUsageCountDL[${i}]}
    END
    [Return]    ${SumUL_Volum}    ${SumDL_Volum}

Verify 5GRACH success times on gnb side
    [Arguments]    ${abil}=asp1a    ${gnb_index}=1
    wait until keyword succeeds    1 min    10 sec    Connect to BB${gnb_index} master     alias=asik
    wait until keyword succeeds    1 min    10 sec    Connect to ${abil}    alias=${abil}    proxy=asik
    ${output} =    csn.execute    command=journalctl -b | grep "flow control starts" |grep -v grep
    ...                           connection=${abil}
    run keyword and ignore error    csn.disconnect    connection=${abil}
    run keyword and ignore error    csn.disconnect    connection=asik
    @{list}    split string    ${output}    \n
    ${len} =    Get Length    ${list}
    [return]    ${len}

gNB connections
    [Arguments]    ${gnb_index}=${0}
    csn.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=gNB${gnb_index}

enb connections
    csn.Connect To    hostname=${ENB_ADDRESS}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=enb

Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COMA classical BTS cell onair
    set global variable    ${cell_status}

Prepare with COMA classical BTS cell onair
    Perform full commission for COAM gnb
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Check gnb COAM classical start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Check the gnb cell status onair

Check the gnb cell status onair
    [Arguments]    ${gnb_index}=${0}    ${cell_no}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout

Get all cell info
    [Arguments]    ${cell_no}
    FOR   ${cell_idx}    IN     1    ${cell_no}
        Get cell info    cell_idx=${cell_idx}
    END

Get cell info
    [Arguments]    ${cell_idx}=1
    ${cell_status} =    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    5GC000738_common_keywords.Get info status check    info_status=${cell_status}

Perform full commission for COAM gnb
    [Arguments]    ${scf}=${epc_log_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500
    COAM Teardown gnb connections

Start Capture Classical enb x2 Logs
    [Arguments]    ${x2logname}
    RUN KEYWORD AND IGNORE ERROR    enb connections
    Start To Capture Wireshark Logs    filename=${x2logname}    connection=enb    interface=br1
    sleep    3s

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    gNB connections
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

Stop and Save classical x2 Logs
    [Arguments]    ${x2logname}
    gNB connections
    Stop and download Logs    logname=${x2logname}    connection=gnb

Stop and Save classical enb x2 Logs
    [Arguments]    ${x2logname}
    enb connections
    Stop and download Logs    logname=${x2logname}    connection=enb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    gNB connections
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3

Check gnb COAM classical start normally
    [Arguments]    ${gnb_index}=${0}
    sleep    1min
    wait until keyword succeeds    10min    20s    Check the gnb RU status ready    gnb_index=${gnb_index}

Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to BB1 master    alias=BB1
    csn.sendCommand    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    ssh.read_output    connection=BB1
    csn.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

Check the gnb RU status ready
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    wait until keyword succeeds    15min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${Status}    Operational state
    should be equal    ${opr_state}    Enabled    ignore_case=True
#    ${avi_state} =   get from dictionary    ${Status}   Availability status
#    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked    ignore_case=True

Lte ActDynTrig Set to ${actdyn_value}
    Connect and Modify the parameter on enblte    dist_name=${enbbts_dist}    parameter=${enbactdyn_para}    value=${actdyn_value}

Check the enb BTS cell onair
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para2}    value=unlocked
    Wait the enb cell status onair

Wait the enb cell status onair
    Connect to eNB via ssl
    wait until keyword succeeds    3min    10s    COAM Check ENB cell on air
    [Teardown]    Enblte close down

COAM Check ENB cell on air
    [Arguments]    ${connection}=enblte
    ${bts_status}    coam.get_bts_statuses    connection=${connection}
    ${enb_cell_status}    Set variable  ${bts_status['proceduralState']}
    Should be equal as strings    ${enb_cell_status}    OnAir    msg=GNB is not on air, Current status is ${enb_cell_status}
    ...                      ignore_case=${True}

Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${atten_ip}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

Check PM counter
    [Arguments]    ${counter_id}    ${full_path}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${res}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${full_path}
    ${result}    get dictionary values   ${res}
    selenium_coam.logout
    [Return]    ${result}

Get the Counter value from COAM
    [Arguments]    ${counter_id}    ${dic_path}=full    ${date}=all
    Connect to gnb coam via ssl
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    COAM Teardown gnb connections

Tests Recover
    [Arguments]    ${x2logname}
    run keyword and ignore error  Stop and Save classical x2 Logs    x2logname=${x2logname}
    csn.disconnect    connection=gnb

Suite Recovery
    Connect and Modify the parameter on enblte   dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    csn.disconnect    connection=gnb

EPCsim load cfg file
    run keyword if    '${enb_instance}'=='35621'    EPCsim load cfg file TL356
    ...    ELSE    EPCsim load cfg file EPCSIM

EPCsim load cfg file EPCSIM
    Restart UEC Edaemon
    Start Edaemon
    Start Egate
    Check the enb BTS cell onair

Restart UEC Edaemon
     wait until keyword succeeds    10 min    5 sec    Connect to UEC    alias=UEC
     csn.execute    command=sudo killall edaemon    connection=UEC
     csn.execute    command=killall egate    connection=UEC
     csn.execute    command=sudo iptables -F    connection=UEC

Connect to UEC
    [Arguments]    ${alias}=UEC
    csn.Connect to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...    username=${tl.core.default_ssh_connection_details.username}
    ...    password=${tl.core.default_ssh_connection_details.password}    alias=${alias}

Start Edaemon
    [Arguments]    ${edaemon_host}=${tl.core.default_ssh_connection_details.addr}
	...            ${edaemon_path}=${tl.core.dir_path}
	...            ${egate_pass}=${tl.core.default_ssh_connection_details.password}
    epc.setup_edaemon    edaemon_port=10000    host_ip=${edaemon_host}    tool_dir=${edaemon_path}
    ...                  alias=EDAEMON    ssh_pass=${egate_pass}
    epc.start_edaemon_process    alias=EDAEMON

Start Egate
    [Arguments]    ${egate_host}=${tl.core.default_ssh_connection_details.addr}
	...            ${egate_path}=${tl.core.dir_path}
    ...	           ${cfg_file}=${tl.core.cfg_filename}
    ...            ${egate_pass}=${tl.core.default_ssh_connection_details.password}
    epc.setup egate    egate_port=20000    host_ip=${egate_host}    tool_dir=${egate_path}    alias=EGATE
    ...     ssh_pass=${egate_pass}
    epc.start egate process    cfg_file=${egate_path}${cfg_file}    timeout=10    alias=EGATE
    sleep    5s
    Log to console    Edeamon and egate starting!\nWait for "S1 link is Up " \nWait for max 600
    epc.Execute egate command                cmd=start
    ...                                      timeout=30
    ...                                      alias=EGATE

EPCsim load cfg file TL356
    Restart UEC Edaemon TL356
    Start Edaemon TL356
    Start Egate TL356
    Check the enb BTS cell onair

Restart UEC Edaemon TL356
     wait until keyword succeeds    10 min    5 sec    Connect to UEC TL356    alias=UEC
     csn.execute    command=sudo killall edaemon    connection=UEC
     csn.execute    command=killall egate    connection=UEC
     csn.execute    command=sudo iptables -F    connection=UEC

Connect to UEC TL356
    [Arguments]    ${alias}=UEC
    csn.Connect to    hostname=${edaemon_host}
    ...    username=${edaemon_user}
    ...    password=${edaemon_pass}    alias=${alias}

Start Edaemon TL356
    [Arguments]    ${edaemon_host}=${edaemon_host}
	...            ${edaemon_path}=${edaemon_path}
	...            ${egate_pass}=${edaemon_pass}
    epc.setup_edaemon    edaemon_port=10000    host_ip=${edaemon_host}    tool_dir=${edaemon_path}
    ...                  alias=EDAEMON    ssh_pass=${egate_pass}
    epc.start_edaemon_process    alias=EDAEMON

Start Egate TL356
    [Arguments]    ${egate_host}=${edaemon_host}
	...            ${egate_path}=${edaemon_path}
    ...	           ${cfg_file}=${edaemon_config}
    ...            ${egate_pass}=${edaemon_pass}
    epc.setup egate    egate_port=20000    host_ip=${egate_host}    tool_dir=${egate_path}    alias=EGATE
    ...     ssh_pass=${egate_pass}
    epc.start egate process    cfg_file=${egate_path}${cfg_file}    timeout=10    alias=EGATE
    sleep    5s
    Log to console    Edeamon and egate starting!\nWait for "S1 link is Up " \nWait for max 600
    epc.Execute egate command                cmd=start
    ...                                      timeout=30
    ...                                      alias=EGATE
