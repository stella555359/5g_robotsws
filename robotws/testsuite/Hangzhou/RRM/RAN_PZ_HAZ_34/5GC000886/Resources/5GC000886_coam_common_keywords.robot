*** Settings ***
Documentation
...   author: Liu Anle
...   contact: anle.liu@nokia-sbell.com
...   squad group: SG_03


Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    Telnet
Library    DateTime
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.epcsim    WITH NAME    epc
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    taf.analyzer.pcap   WITH NAME    parser
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource   taf/rfrl/common_resources/robot/gnb_classical.robot
Library    taf.analyzer.pcap     WITH NAME    cap
#Library    Attenuation.Attenuation    WITH NAME    atten
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
Library    licence_keeper.licence_keeper     WITH NAME    LK
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Variables    ./__init__.py
Variables    ./886_D_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot

*** Variables ***
#${TS_LOG_PATH_BASE}      /tmp/
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM2}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik2_addr}    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${SN}    ${tl.ues[0].serial_number}
${gnb_path}    /tmp/
${gnb_instance}    ${tl.gnbs[0].instance_id}
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
#${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_filename}    Full_Configuration_scf_1867.xml
#${TESTLINE_NAME}    7_5_CLOUD402T0${tl.enbs[0].instance_id}
${enbx2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-1
${enbx2_para}    administrativeState
${f1_sctp_port}    38472
${x2_sctp_port}    36422
${QPSTexe}    "/cygdrive/c/Program Files (x86)/Qualcomm/QPST/bin/QPSTConfig.exe"
${enb_path}    /user/toor4nsn
${epcsim_ip}    ${tl.core.default_ssh_connection_details.addr}
${realepc_ip}    10.57.164.140
${PM_counter_UL}    M55323C03007
${PM_counter_DL}    M55323C01007
${e1ap}    e1ap_15_3_0_1903_n01
##Attenuator parameter before taf ready
${atten_ip}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${atten_ip2}    ${tl.attenuator[1].ip_addr}
${5GRU_ANT11}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU_ANT12}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU_ANT21}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU_ANT22}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5GRU_ANT31}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU_ANT32}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${4GRU1_ANT1}    ${tl.attenuator[0].attenuator_ports[5]}
${4GRU1_ANT2}    ${tl.attenuator[0].attenuator_ports[6]}
${5GRU1_ANT1_21B}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU1_ANT2_21B}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5GRU1_ANT3_21B}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5GRU1_ANT4_21B}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
@{attenuation_port_numbers_21A}    ${5GRU1_ANT1}     ${5GRU1_ANT2}    ${5GRU1_ANT3}     ${5GRU1_ANT4}
@{attenuation_port_numbers_21B}    ${5GRU1_ANT1_21B}    ${5GRU1_ANT2_21B}    ${5GRU1_ANT3_21B}    ${5GRU1_ANT4_21B}
@{attenuation_port_numbers_trunk}    ${5GRU_ANT11}     ${5GRU_ANT12}
${max_attenuation_value}    ${127}
${vendor}     ${tl.attenuator[0].vendor}
${model}      ${tl.attenuator[0].model}

##Get QXDM log from QC
${LKC_LOGIN_USER}    hai.2.huang@nokia-sbell.com
${LKC_LOGIN_PWD}    Password@4
${LKC_CLIENT_PORT}    6006
${LKC_CLIENT_ALIAS}         lkc
${LKC_CLIENT_PATH}         /cygdrive/c/Users/nokia5G/Desktop/QPM_LK1.5
${5G_QXDM_PATH}    C:/MyDrivers/software/QXDM99
${QCAT_EXE_PATH}    "C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe"
${QCOM_ue_atplmn}     26203
#${QCOM_ue_atplmn_5G}     26203
${tl_038_phone_modem_port}     5
${tl_038_SDX_5G_port}          12
${tl_233_phone_modem_port}     20
${tl_233_SDX_5G_port}           15
${fsp_addr}      ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${tl_scf_filename_enb}

${command_template_with_x2ap}    {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
${dic_path}    BTS/MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NX2CB
#${dic_path}    BTS/BTS/NRBTS-${gnb_instance}/NX2CB
${TS_LOG_PATH_BASE_classical}    /opt/workspace/CRT/Master/Case_Logs/
${TS_CASE_LOG_PATH_classical}    /opt/workspace/CIT/Master/Case_Logs/
${tl_scf_dir_path_classical}    /opt/workspace/CRT/Master/SCF_file/
#${TS_LOG_PATH_BASE_cloud}    /home/ute/workspace/CIT/Master/Case_Logs/
#${TS_CASE_LOG_PATH_cloud}    /home/ute/test_results/Logs/
#${ute_log_path_cloud}    /home/ute/test_results/
#${tl_scf_dir_path_cloud}    /home/ute/Auto5G/commissionings/HGZ/
${testline_name}      null
${CONFIGURATION}      null
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

*** Keywords ***
##Qualcomm keyword
Forbidden the UE data
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command
    ...    command=adb root
    ...    connection=cpc_${ue_index}
    ...    timeout=5
    sleep  10s
    csn.send command
    ...    command=adb -s ${serial_number} shell iptables -A OUTPUT -p udp --dport 53 -j REJECT
    ...    connection=cpc_${ue_index}
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
    ...    command=cd ${LKC_CLIENT_PATH};./ClientMain.exe
    ...    connection=cpc_${ue_index}    timeout=9000
    Sleep    120s
    LK.connect    host=${UE_pc_ip}    port=${LKC_CLIENT_PORT}
    wait until keyword succeeds    2min    30s    LK.login    username=${LKC_LOGIN_USER}    password=${LKC_LOGIN_PWD}    timeout=60

Keep 5G Licence
    LK.get_licence_qxdm_5g    timeout=90
    LK.get_licence_qcat_5g    timeout=90

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
    [Arguments]    ${ue_index}    ${QXDM_log_name}    ${time}=60    #${COMport}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${isf_file} =    set variable    ${5G_QXDM_PATH}/${QXDM_log_name}.hdf
    csn.send command
    ...    command=cmd /c python ${5G_QXDM_PATH}/QXDM5Logcatch.py -t ${time} -p MDM -c ${5G_QXDM_PATH}/volume.dmc -s ${isf_file}
    ...    connection=cpc_${ue_index}    timeout=300
    sleep    5s
    Csn.disconnect      connection=cpc_${ue_index}

Capture QXDM5 log
    [Arguments]    ${ue_index}    ${QXDM_log_name}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command
    ...    command=cmd /c python ${5G_QXDM_PATH}/QXDM5Logcatch.py -t 80 -p MDM -c ${5G_QXDM_PATH}/volume.dmc -s ${5G_QXDM_PATH}/${QXDM_log_name}.hdf
    ...    connection=cpc_${ue_index}    timeout=300
    sleep    5s
    Csn.disconnect      connection=cpc_${ue_index}

5G isf decoder to txt and save to local
    [Arguments]    ${ue_index}    ${QXDM_log_name}
    Connect to control pc enhanced    ue_index=${ue_index}
    wait until keyword succeeds    2min    2s    Csn.Assert file exists
    ...    remote_path=${5G_QXDM_PATH}/${QXDM_log_name}.hdf    connection=cpc_${ue_index}
    Log to console   \nINFO:5G Qmdl decoder to txt
    csn.force_reconnect       connection=cpc_${ue_index}
    ${result}   Csn.execute
    ...  command=cmd /c ${QCAT_EXE_PATH} -txt ${5G_QXDM_PATH}/${QXDM_log_name}.hdf
    ...  connection=cpc_${ue_index}
    Log to console   \nINFO:${result}
    Csn.download file
    ...   ${5G_QXDM_PATH}/${QXDM_log_name}.txt
    ...   ${epc_log_path}${QXDM_log_name}.txt
    ...   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.hdf   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.txt   connection=cpc_${ue_index}
    Csn.disconnect   connection=cpc_${ue_index}

Start the DL/UL data throughput with TL356
    [Arguments]    ${ue_type}=${ue_type}    ${direction}=${direction}    ${duration}=${duration}
    ...    ${throughput}=${throughput}    ${iperf_port}=${iperf_port}
    power_ue.Start traffic    ue_type=${ue_type}    direction=${direction}    duration=${duration}
    ...    throughput=${throughput}    iperf_port=${iperf_port}

Start the DL data throughput
    [Arguments]    ${ue_index}=${0}
    ${ue_addr} =    Get the UE Ip address    ue_index=${ue_index}
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on Qualcomm    ue_index=${ue_index}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_addr}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    dl_length=${dl_length}

Start the UL data throughput
    [Arguments]    ${ue_index}=${0}
    Close the iperf process on APPserver     port=${ul_port}
    Close the iperf process on Qualcomm    ue_index=${ue_index}
    Start UL traffic via iperf from andriod UE    ue_index=${ue_index}    ul_time=${ul_time}
    ...    ul_port=${ul_port}    ul_throughput=${ul_throughput}    ul_length=${ul_length}

Close iperf progress
    [Arguments]    ${ue_index}=${0}
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on APPserver    port=${ul_port}
    Close the iperf process on Qualcomm    ue_index=${ue_index}

Common UE teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}

##UEC keyword
EPCsim load cfg file
    Restart UEC Edaemon
    Start Edaemon
    Start Egate

Restart UEC Edaemon
     wait until keyword succeeds    10 min    5 sec    Connect to UEC    alias=UEC
     csn.execute    command=sudo killall edaemon    connection=UEC
     csn.execute    command=killall egate    connection=UEC

Connect to UEC
    [Arguments]    ${alias}=UEC
    csn.Connect to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...    username=${tl.core.default_ssh_connection_details.username}
    ...    password=${tl.core.default_ssh_connection_details.password}    alias=${alias}

Start Edaemon
    [Arguments]    ${edaemon_host}=${tl.core.default_ssh_connection_details.addr}
	...            ${edaemon_path}=${tl.core.dir_path}
    epc.setup_edaemon    edaemon_port=${tl.core.edaemon_port}    host_ip=${edaemon_host}    tool_dir=${edaemon_path}
    ...                  alias=EDAEMON
    epc.start_edaemon_process    alias=EDAEMON

Start Egate
    [Arguments]    ${egate_host}=${tl.core.default_ssh_connection_details.addr}
	...            ${egate_path}=${tl.core.dir_path}
    ...	           ${cfg_file}=${tl.core.cfg_filename}
    epc.setup egate    egate_port=20000    host_ip=${egate_host}    tool_dir=${egate_path}    alias=EGATE
    epc.start egate process    cfg_file=${egate_path}${cfg_file}    timeout=10    alias=EGATE
    sleep    5s
    Log to console    Edeamon and egate starting!\nWait for "S1 link is Up"
    epc.Execute egate command and wait for data  cmd=start
    ...                                      pass_regexp=S1 link is Up
    ...                                      timeout=400
    ...                                      alias=EGATE

##BTS keyword
Common Suite Setup for COAM
    COAM Create log directory    ${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Common Suite Teardown for COAM
    [Arguments]    ${epc_log_path}=${epc_log_path}
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections

Connect and save snapshot for enb
    [Arguments]    ${connection}=enb     ${enb_index}=${0}    ${epc_log_path}=${epc_log_path}
    Connect to eNB via ssl    connection=${connection}_${enb_index}     enb_index=${enb_index}
    COAM Save snapshot via rest api    connection=${connection}_${enb_index}    log_path=${epc_log_path}    timeout=900
    [Teardown]    coam.teardown    connection=${connection}_${enb_index}

Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COAM classical BTS cell onair
    set suite variable    ${cell_status}

Prepare with COAM classical BTS cell onair
    5GC000886_coam_common_keywords.Perform full commission for COAM gnb
    Reset UE Control PC
    Run Keyword And Ignore Error    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}
    ...                    parameter=${enbx2_para}    value=locked
    sleep    300s
    #Check gnb COAM classical start normally
    Run Keyword And Ignore Error    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}
    ...                     parameter=${enbx2_para}    value=unlocked
    sleep    600s
    #Check the gnb cell status onair

Prepare the atten for TL
#    Adjust the Attenuation Value    ports=${5GRU_ANT11}    value=18
#    Adjust the Attenuation Value    ports=${5GRU_ANT12}    value=18
#    Adjust the Attenuation Value    ports=${5GRU_ANT21}    value=18
#    Adjust the Attenuation Value    ports=${5GRU_ANT22}    value=18
    #5GC000886_coam_common_keywords.Adjust the Attenuation Value    ports=${5GRU2_ANT1}    value=120
    #5GC000886_coam_common_keywords.Adjust the Attenuation Value    ports=${5GRU2_ANT2}    value=120
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers_21A}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${5GRU_ANT11}    value=${18}
    attenuator.set_attenuation     port=${5GRU_ANT12}   value=${18}
    attenuator.set_attenuation     port=${5GRU_ANT21}     value=${18}
    attenuator.set_attenuation     port=${5GRU_ANT22}    value=${18}
    ${value_port_1}    attenuator.read_attenuation    port=${5GRU_ANT11}
    should be equal    ${value_port_1}    ${18}
    ${value_port_2}    attenuator.read_attenuation    port=${5GRU_ANT12}
    should be equal    ${value_port_2}    ${18}
    ${value_port_3}    attenuator.read_attenuation    port=${5GRU_ANT21}
    should be equal    ${value_port_3}    ${18}
    ${value_port_4}    attenuator.read_attenuation    port=${5GRU_ANT22}
    should be equal    ${value_port_4}    ${18}
    sleep    5s

Change SWconf
    Connect to BB1 master    alias=${asik}
    SWconfig.download_swConfig_file_from_asik_to_test_pc    localFilePath=${epc_log_path}swconfig.txt
    ...    asik_alias=${asik}
    SWconfig.modify_swConfig_file    parametersList=@{rdparameter}    filePath=${epc_log_path}swconfig.txt
    csn.force_reconnect    connection=${asik}
    SWconfig.upload_swConfig_file_to_asik_and_crasign    localFilePath=${epc_log_path}swconfig.txt    asik_alias=${asik}

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}=gnb    ${interface}=any
    gNB connections
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

gNB connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Stop and download Logs
    [Arguments]    ${filename}    ${connection}=gnb
    gNB connections
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   ${gnb_path}${filename}   ${ute_log_path}${filename}   connection=${connection}
    sleep    3

Change the COAM parameter online
    [Arguments]    ${dist_name}    ${parameter_name}    ${new_value}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    sleep    5s
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...                                  filter_param=${parameter_name}
    ...                                  new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    selenium_coam.logout

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    ${parameters}
    COAM Teardown gnb connections

#Trigger RLF by attenutor
#    attenuator.setup_attenuator
#    attenuator.read_attenuation    parameter port=${attenuator_port}
#    attenuator.set_attenuation
#    attenuator.read_attenuation    parameter port=${attenuator_port}

##attenutor
#Adjust the Attenuation Value-----old
#    [Arguments]    ${ports}    ${value}    ${atten_ip}=${atten_ip}
#    atten.connect to    ip=${atten_ip}
#    atten.set_value    channel=${ports}    value=${value}
#    atten.disconnect

#####new topyoung keyword#####
Adjust the Attenuation Value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...    ${att_port_1}    ${att_port_2}    ${att_port_3}
    ...    ${att_port_4}     ${atten_ip}        ${vendor}    #${att_api_port}    ${attenuation_port_numbers}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${3000}
    ...    attenuation_port_numbers=${attenuation_port_numbers_21A}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}
    sleep    5s

Adjust the Attenuation Value to normal
    5GC000886_coam_common_keywords.Adjust the Attenuation Value    ports=${5GRU_ANT11}    value=${5GRU_ANT11_origin}
    5GC000886_coam_common_keywords.Adjust the Attenuation Value    ports=${5GRU_ANT12}    value=${5GRU_ANT12_origin}
    5GC000886_coam_common_keywords.Adjust the Attenuation Value    ports=${5GRU_ANT21}    value=${5GRU_ANT21_origin}
    5GC000886_coam_common_keywords.Adjust the Attenuation Value    ports=${5GRU_ANT22}    value=${5GRU_ANT22_origin}

Check the gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air
    COAM Teardown gnb connections

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${Status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${Status}   Availability status
    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Check gnb COAM classical start normally
    Check Airscale HW module status
    #wait until keyword succeeds    5min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    Check the gnb RU status ready
    wait until keyword succeeds    5min   30s    Check the sctp port UP    port_num=${x2_sctp_port}

Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to BB1 master    alias=BB1
    csn.send Command    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    csn.read_output    connection=BB1
    csn.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    5min   30s    COAM Check GNB RU status
    COAM Teardown gnb connections

Perform full commission for COAM gnb
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_filename}    timeout=600
    ...    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

#Check PM counter
#    [Arguments]    ${counter_id}    ${full_path}
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
#    ${res}    selenium_coam.get_bts_counters_info    ${counter_id}    ${full_path}
#    ${result}    get dictionary values   ${res}
#    [Return]    ${result}
#    [Teardown]    selenium_coam.logout

Check PM counter
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to gnb coam via ssl
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    COAM Teardown gnb connections

Record the counter action timer for TL356
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3    Record time again
#    ${utc_left} =    Evaluate    5-${utc_min}+1
    ${pm_utc_left} =    Evaluate    5-${utc_min}
    set test variable    ${pm_utc_left}

Record the counter action timer for 21B
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%15
    Set Suite Variable    ${utc_min}
    Set Suite Variable    ${pm_utc_left}      0
    Run Keyword If    ${utc_min}>10     Set counter action wait timer

Set counter action wait timer
    ${pm_utc_left} =    Evaluate    15-${utc_min}+1
    Set Suite Variable    ${pm_utc_left}

Download PMCounter File
    [Arguments]     ${PMfile_name}
    Connect to BB1 master    alias=BB1
    sleep    3s
    csn.Send Command    command=ls -l /tmp/PM.BTS-${tl.gnbs[0].instance_id}* | tail -1 | head -1 | awk '{print $9}'    connection=BB1
    ${report_xml}    Run Keyword And Ignore Error    csn.Read Output Until    xml.gz    timeout=5    connection=BB1
    csn.Send Command    command=zcat ${report_xml[1]} >/tmp/${PMfile_name}   connection=BB1
    csn.download_file   remote_path=/tmp/${PMfile_name}   local_path=${epc_log_path}${PMfile_name}  connection=BB1
    sleep    3s

Check the PM counter xml report
    [Arguments]    ${PMfile_name}    ${PM_counter}    ${exp_result}
    sleep    ${pm_utc_left} min
    Download PMCounter File    ${PMfile_name}
    ${counter_value_0}=    run
    ...    xmllint --format ${epc_log_path}${PMfile_name} | grep ${PM_counter} | cut -d '<' -f 2 | cut -d '>' -f 2
    ${result}=    Set Variable    ${counter_value_0}
    ${result}=    convert to integer    ${result}
    ${exp_result}=    convert to integer    ${exp_result}
    Should Be Equal    ${result}    ${exp_result}
    sleep    3s

Check the PM counter should not be zero
    [Arguments]    ${counter_id}    ${exp_result}    ${dic_path}=${dic_path}
    Connect to gnb coam via ssl
    ${counter_result_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
         ...    dic_path=${dic_path}
    Should be equal    ${counter_result_value[0]}    ${exp_result}    msg=check counter fail
    [Teardown]    COAM Teardown gnb connections

Check the PM counter equal
    [Arguments]    ${counter_id}    ${exp_result}    ${dic_path}=${dic_path}
#    ${counter_result_value}    Create List
#    ${counter_result}    Create List
#    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
         ...    dic_path=${dic_path}
    ${counter_sum} =    Get List sum    counter_value=${counter_value}

#    :For    ${index}    IN RANGE    ${counter_lenth}
#    \    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
#         ...    dic_path=${dic_path[${index}]}
#    \    ${counter_dict}    Create Dictionary    ${counter_id[${index}]}=${counter_value[0]}
#    \    append to list    ${counter_result_value}    ${counter_value[0]}
#    \    append to list    ${counter_result}    ${counter_dict}
#    ${counter_result_lenth}    Get Length    ${counter_result_value}
#    Should be equal    ${counter_lenth}    ${counter_result_lenth}
    Should be equal    ${counter_sum}    ${exp_result}    msg=check counter fail
    [Teardown]    COAM Teardown gnb connections

Get List sum
    [Arguments]    ${counter_value}
    ${totalvalue}    Set Variable    0
    ${length}    Set Variable    0
    FOR    ${singlevalue}    IN    @{counter_value}
        ${totalvalue}    Evaluate    ${totalvalue}+${singlevalue}
        ${length}    Evaluate    ${length}+1
    END
    [Return]    ${totalvalue}

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

Caculate the wireshark timevalue to seconds
    [Arguments]    ${input_value}    ${index}
    ${list} =    Evaluate    ${input_value}[${index}].split(' ')
    ${list_0} =    Evaluate    ${list}[-2].split(':')
    ${msg_time_sec} =    EVALUATE  float(${list_0}[0])*0+float(${list_0}[1])*60+float(${list_0}[2])*1
    [Return]    ${msg_time_sec}

Tests Recover
    [Arguments]    ${ue_index}=${0}
    csn.disconnect    connection=gnb
    Close iperf progress
    Android UE release    ue_index=${ue_index}

Change gNB local time
    [Arguments]    ${Time_setting}
    Connect to BB1 master
    csn.force_reconnect    connection=${asik}
    csn.send command    command=ddal -s ddal_sfn_monitor_sync DDAL_SFN_SYNC_OSUTC_TO_BTSRTC DDAL_SFN_STOP    connection=${asik}
    csn.send command    command=date -s ${Time_setting} && date --rfc-3339=ns     connection=${asik}
    Connect to BB1 slave
    csn.send command    command=ddal -s ddal_sfn_monitor_sync DDAL_SFN_SYNC_OSUTC_TO_BTSRTC DDAL_SFN_STOP    connection=${asik_slave}
    ${master_date}=     csn.execute    command=date --rfc-3339=ns         connection=${asik}
    csn.send command    command=date -s "${master_date}" && date --rfc-3339=ns     connection=${asik_slave}
    ${master_time}=     csn.execute    command=date --rfc-3339=ns         connection=${asik}
    ${slave_time}=     csn.execute    command=date --rfc-3339=ns         connection=${asik_slave}

Recovery gNB SYNC
    Connect to BB1 master
    csn.send command    command=ddal -s ddal_sfn_monitor_sync DDAL_SFN_SYNC_OSUTC_TO_BTSRTC DDAL_SFN_START    connection=${asik}
    Connect to BB1 slave
    csn.send command    command=ddal -s ddal_sfn_monitor_sync DDAL_SFN_SYNC_OSUTC_TO_BTSRTC DDAL_SFN_START    connection=${asik_slave}

##ENB Keyword
Start To Capture ENB Logs
    [Arguments]     ${filename}  ${connection}=ENB    ${interface}=any
    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
    csn.send command    command=tcpdump -i ${interface} -w ${enb_path}${filename}   connection=${connection}

Stop and download ENB Logs
    [Arguments]     ${filename}=s1x2log.pcap    ${connection}=ENB
    #wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    5
    csn.download_file   ${enb_path}${filename}   ${epc_log_path}${filename}   connection=${connection}

Stop and download ENB Logs for 21B
    [Arguments]     ${filename}=s1x2log.pcap    ${connection}=ENB
    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    5
    csn.download_file   ${enb_path}${filename}   ${epc_log_path}${filename}   connection=${connection}

Prepare the atten for 19B
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers_21B}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${5GRU1_ANT1_21B}    value=${0}
    attenuator.set_attenuation     port=${5GRU1_ANT2_21B}   value=${0}
    attenuator.set_attenuation     port=${5GRU1_ANT3_21B}     value=${0}
    attenuator.set_attenuation     port=${5GRU1_ANT4_21B}    value=${0}
    ${value_port_1}    attenuator.read_attenuation    port=${5GRU1_ANT1_21B}
    should be equal    ${value_port_1}    ${0}
    ${value_port_2}    attenuator.read_attenuation    port=${5GRU1_ANT2_21B}
    should be equal    ${value_port_2}    ${0}
    ${value_port_3}    attenuator.read_attenuation    port=${5GRU1_ANT3_21B}
    should be equal    ${value_port_3}    ${0}
    ${value_port_4}    attenuator.read_attenuation    port=${5GRU1_ANT4_21B}
    should be equal    ${value_port_4}    ${0}
    sleep    5s

Prepare the atten for trunk
    [Arguments]    ${value1}=${value1}    ${value2}=${value2}    ${value3}=${value3}    ${value4}=${value4}
    ...    ${model}=${model}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${5GRU1_ANT1}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${5GRU1_ANT1}    value=${value1}
    attenuator.set_attenuation     port=${5GRU1_ANT2}   value=${value2}
    attenuator.set_attenuation     port=${5GRU1_ANT3}     value=${value3}
    attenuator.set_attenuation     port=${5GRU1_ANT4}    value=${value4}
    ${value_port_1}    attenuator.read_attenuation    port=${5GRU1_ANT1}
    should be equal    ${value_port_1}    ${value1}
    ${value_port_2}    attenuator.read_attenuation    port=${5GRU1_ANT2}
    should be equal    ${value_port_2}    ${value2}
    ${value_port_3}    attenuator.read_attenuation    port=${5GRU1_ANT3}
    should be equal    ${value_port_3}    ${value3}
    ${value_port_4}    attenuator.read_attenuation    port=${5GRU1_ANT4}
    should be equal    ${value_port_4}    ${value4}
    sleep    5s

Prepare the enb atten for trunk
    [Arguments]    ${value1}=${value1}    ${value2}=${value2}    ${model}=${model}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${5GRU1_ANT1}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${4GRU1_ANT1}    value=${value1}
    attenuator.set_attenuation     port=${4GRU1_ANT2}   value=${value2}
    ${value_port_1}    attenuator.read_attenuation    port=${4GRU1_ANT1}
    should be equal    ${value_port_1}    ${value1}
    ${value_port_2}    attenuator.read_attenuation    port=${4GRU1_ANT2}
    should be equal    ${value_port_2}    ${value2}
    sleep    5s

Prepare the test Env for 19B
    Change UE PLMN    ue_index=${0}    phone_modem_port=${tl_038_phone_modem_port}    plmn=${QCOM_ue_atplmn}
    #Reset UE Control PC
    #sleep    300s
    Prepare the atten for 19B

Prepare the test Env for trunk
    Change UE PLMN    ue_index=${0}    phone_modem_port=${tl_233_phone_modem_port}    plmn=${QCOM_ue_atplmn}
    #Reset UE Control PC
    #sleep    300s
    #Prepare the atten for trunk

Change UE PLMN
    [Arguments]    ${ue_index}=${0}    ${phone_modem_port}=${5}    ${plmn}=${QCOM_ue_atplmn}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=adb root    connection=cpc_${ue_index}
    sleep   90s
    csn.send_command    command=adb shell "echo -e 'at+cops=1,2,${plmn},7\\r\\n' > /dev/${phone_modem_port}"    connection=cpc_${ue_index}
    sleep   5s
    csn.send_command    command=adb shell "echo -e 'at+cops=1,2,${plmn}\\r\\n' > /dev/${phone_modem_port}"
    ...            connection=cpc_${ue_index}
    sleep   20s
    csn.send command    command=adb shell getprop gsm.operator.numeric    connection=cpc_${ue_index}
    ${plmnresult} =    csn.read_output    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Change UE APN
    [Arguments]    ${ue_index}=${0}    ${phone_modem_port}=${11}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=adb root    connection=cpc_${ue_index}
    sleep   90s
    csn.send_command    command=adb shell "echo -e 'at+cgdcont=1,"IP","","0.0.0.0",0,0,0,0\\r\\n' > /dev/${phone_modem_port}"
    ...            connection=cpc_${ue_index}
    sleep   5s
    csn.send_command    command=adb shell "echo -e 'at+cgdcont=2,"IP","ims","0.0.0.0",0,0,0,0\\r\\n' > /dev/${phone_modem_port}"
    ...            connection=cpc_${ue_index}
    sleep   5s
    csn.send_command    command=adb shell "at+cgdcont=3,"IP","DXDATA2","0.0.0.0",0,0,0,0\\r\\n' > /dev/${phone_modem_port}"
    ...            connection=cpc_${ue_index}
    sleep   5s
    csn.send_command    command=adb shell "at+cgdcont=4,"IP","DXDATA2","0.0.0.0",0,0,0,0\\r\\n' > /dev/${phone_modem_port}"
    ...            connection=cpc_${ue_index}
    sleep   5s
    csn.send_command    command=adb shell "at+cgdcont=5,"IP","DXDATA2","0.0.0.0",0,0,0,0\\r\\n' > /dev/${phone_modem_port}"
    ...            connection=cpc_${ue_index}
    sleep   20s
    csn.send_command    command=adb shell "echo -e 'at+cgdcont?\\r\\n' > /dev/${phone_modem_port}"
    ...            connection=cpc_${ue_index}
    ${plmnresult} =    csn.read_output    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Precondition for power UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}

#Attach and check power UE
#    [Arguments]    ${ue_type}    ${5Gstatus}=PASS    ${ue_index}=${0}
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}    ue_index=${ue_index}

Attach and check power UE
    [Arguments]    ${ue_type}    ${filename}    ${filename_ENB}    ${ue_index}=${0}    ${4G_check}=False
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Start To Capture ENB Logs    filename=${filename_ENB}   connection=ENB
    Start To Capture Wireshark Logs    filename=${filename}
    unlock the screen and close all task    ue_index=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
    [Teardown]    Run keywords
    ...    Stop and download ENB Logs    filename=${filename_ENB}    connection=ENB    AND
    ...    Stop and download Logs    filename=${filename}

unlock the screen and close all task
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    sleep    1s
    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}

Detach for power UE
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

killall firefox progress
    Connect to UEC
    csn.send command    command=killall firefox    connection=UEC
    csn.send command    command=killall Xvfb    connection=UEC
    csn.disconnect    connection=UEC
    sleep    10s

Attach and check power UE with modify Plmn
    [Arguments]    ${ue_type}    ${5Gstatus}=PASS    #${ue_index}=${0}    ${phone_modem_port}=${tl_233_phone_modem_port}
#    ...             ${plmn}=${QCOM_ue_atplmn}
    Run Keyword And Ignore Error   csn.Reset Cache
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
#    Change UE PLMN    ue_index=${ue_index}    phone_modem_port=${phone_modem_port}    plmn=${plmn}
    ${result}    Run Keyword And Return Status     power_ue.Verify attach    ue_type=${ue_type}
    ...           5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}
    Log to console   \nINFO:${result}
    Set Suite Variable     ${retry_attach_times}    ${0}
    Run Keyword Unless	    '${result}' == 'True'	   Run Keywords     5GC000886_coam_common_keywords.Detach for power UE   ue_type=${ue_type}
    ...     AND    power_ue.UE Attach    ue_type=${ue_type}
    ...     AND    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}
    ...     AND    Set Suite Variable     ${retry_attach_times}    ${1}

Attach and check power UE with TL356
    [Arguments]    ${ue_type}    ${ue_index}=${0}    #${5Gstatus}=PASS
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${0}
    ${result}    Run Keyword And Return Status     power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
    ...    ue_index=${0}    gnb_index=${0}    4G_check=True
    Log to console   \nINFO:${result}
    Set Suite Variable     ${retry_attach_times}    ${0}
    Run Keyword Unless	    '${result}' == 'True'	   Run Keywords     5GC000886_coam_common_keywords.Detach for power UE   ue_type=${ue_type}
    ...     AND    power_ue.UE Attach    ue_type=${ue_type}
    ...     AND    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    gnb_index=${0}    4G_check=True
    ...     AND    Set Suite Variable     ${retry_attach_times}    ${1}

Start To Capture Wireshark Logs and make sure success
    [Arguments]     ${filename}    ${connection}    ${interface}
    gNB connections
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}
    sleep     3s
    csn.download_file   ${gnb_path}${filename}   ${epc_log_path}${filename}   connection=${connection}
    ${logfile_zie}     Get File Size     ${epc_log_path}${filename}
    Log to console   \logfile_zie:${filename}:${logfile_zie}
    Run Keyword If	    '${logfile_zie}' < '100'     csn.send command    command=killall tcpdump     connection=${connection}
    Should be True     '${logfile_zie}' > '100'

Perform full commission for COAM enb BTS
    [Arguments]    ${scf_file_path_enb}=${tl_scf_dir_path}${tl_scf_filename_enb}
    Connect to eNB via ssl
    COAM Commission with scf file    scf_file_path=${scf_file_path_enb}    timeout=600    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte

ADB Service Restart
    [Documentation]  Use adb command to recover adb service
    [Arguments]    ${serial_number}    ${cpc_alias}
    log to console     \nInfo:Reboot ADB Service on ${cpc_alias}!
    csn.execute    command=sudo adb -s ${serial_number} kill-server    connection=${cpc_alias}
    csn.execute    command=sudo adb -s ${serial_number} start-server    connection=${cpc_alias}
    sleep   2s

Reboot UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...             ${cpc_alias}=cygwin
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${cpc_alias}
    sleep   5s
    ADB Service Restart     serial_number=${serial_number}    cpc_alias=${cpc_alias}
    Sleep   15s
    csn.send_command   command=adb -s ${serial_number} reboot     connection=${cpc_alias}      timeout=5
    Sleep   5s
    [Teardown]         Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

Pre Condition
    [Documentation]    Author: Ren Biyao
    ...    This keyword will set the default path for scf which will be used for ute cloud or lightweight CI.
    [Timeout]    20 min
    [Arguments]
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  24
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
    set suite variable     ${CONFIGURATION}
    set suite variable     ${SCF_PATH}
    set suite variable     ${testlinename}
    Connect to Common Unit Master    alias=ASIK Master
    run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'
    ...    Default directory for ute cloud
    ...    ELSE    Default directory for lightweight ci

Default directory for ute cloud
    [Documentation]    Author: Ding Binmei [PRIVATE]
    ...                Description: Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]    ${timeout}=1min    ${response_timeout}=10
    ${cur_dir}    run    pwd
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua

    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    Run keyword if    ${has_cbts}   wait until keyword succeeds    ${timeout}    2sec    Cloud DU connect to gnb coam via ssl
    ...    ELSE    wait until keyword succeeds    ${timeout}    2sec    Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM    timeout=${response_timeout}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}
    set suite variable    ${epc_log_path}    ${SUITE_LOG_PATH}
    set suite variable    ${TS_LOG_PATH_BASE}     ${SUITE_LOG_PATH}
    Set Suite Variable    ${ute_log_path}    ${SUITE_LOG_PATH}
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    Set Suite Variable    ${tl_scf_dir_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/

    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

#Default directory for ute cloud
#    [Documentation]    Author: Ren Biyao
#    ...     Description: default dir scf and swconfig and log dir for ute cloud.
#    ${cur_dir}    run    pwd
#    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
#    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
#    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua
#    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH_cloud}
#    Set Suite Variable    ${ute_log_path}    ${ute_log_path_cloud}
#    Set Suite Variable    ${tl_scf_dir_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/
#    Common Suite Setup for COAM tl356

Default directory for lightweight ci
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${TS_LOG_PATH_BASE_classical}
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH_classical}
    Set Suite Variable    ${tl_scf_dir_path}     ${tl_scf_dir_path_classical}
    Set Suite Variable    ${ute_log_path}    ${TS_CASE_LOG_PATH_classical}
    Common Suite Setup for COAM tl356

Common Suite Setup for COAM tl356
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Modify NIDD parameter on gnb
    [Arguments]    ${parameters_to_update}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
