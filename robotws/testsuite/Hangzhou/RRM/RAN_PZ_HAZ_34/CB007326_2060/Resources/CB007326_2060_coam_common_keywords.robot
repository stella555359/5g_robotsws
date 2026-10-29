*** Settings ***
Documentation
...    author: Bella
...    contact:Bella.chen@nokia-sbell.com
...    squad group: SG_03
...    feature : CB007326

Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library     taf.config.scf    WITH NAME    scf
Library     taf.selenium.gnb.oam.coam.classical   WITH NAME    selenium_coam
Library    taf.analyzer.pcap   WITH NAME    cap
Library     taf.hw.rf_attenuator    WITH NAME    attenuator
Library     taf.config.testline    WITH NAME    testline
#Library     ../../5GC000738/Resources/get_pm_counter.py
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library     taf.hw.mcs    WITH NAME    MCS
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
#Library     ../../libraries/L3Call.py
#Library     ../../libraries/TTI_Trace_Analysis_dl.py
#Library     ../../../../../resources/python_libs/check_csv_log.py
#Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
#Library     ../../../../../resources/python_libs/Attenuation.py
#Library     Attenuation.Attenuation    WITH NAME    atten
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    ../../libraries/biplog_capture/biplog_capture.robot
#Resource    ../../libraries/connection_with_hostname.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Variables    ./Stream_parameter.py


*** Variables ***
##PATH##
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs
${tl_scf_dir_path}          /opt/workspace/CRT/Master/SCF_file/
${gnb_path}                 /tmp/
${enb_path}                 /user/toor4nsn
${ttitrace_path}            /ffs/run/config/toor4nsn/eventTrace_log/
${swconfig_default}         /opt/workspace/SCF/swconfig/swconfig.txt
${tshark_path}              /usr/bin/tshark
${LUA_SCRIPT_PATH}          /opt/workspace/luashark/generated_luashark/luashark.lua
##GNB##
${WEBUI_COAM}             https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}              ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_BTS_host}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb_BTS_username}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gnb_BTS_password}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TestPC_addr}            ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}        ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}        ${tl.test_pc.default_ssh_connection_details.password}
${gnb_instance}           ${tl.gnbs[0].instance_id}
##ENB##
${ENB_ADDRESS}            ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enbx2_para}             administrativeState
${enb_instance}           ${tl.enbs[0].instance_id}
${enbx2_dist}             MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${TL365_enb_dist}         MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${TL362_enb_dist}         MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-12
${defaultgnbcell}         defaultLnRelGnbCellId
##UE##
${SN}                     ${tl.ues[0].serial_number}
${ue_type}                ${tl.ues[0].capabilities[1]}
${UL_PORT}                ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                ${tl.ues[0].iperf_details.port}
${ul_throughput}            100M
${dl_throughput}            1300M
${DL_TIME}                  9999
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
# inseego
#${askey_SN}               ${ue_ccc['serial_number']}
#${askey_hostname}         ${ue_param['ue_pc_ip']}
#${askey_username}         ${ue_param['login']}
#${askey_password}         ${ue_param['password']}
#${iperf_hostname}         ${ue_param['data_transfer']['ssh']['host']}
#${iperf_username}         ${ue_param['data_transfer']['ssh']['user']}
#${iperf_password}         ${ue_param['data_transfer']['ssh']['password']}
#attenuation
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${att_port_1_376}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_376}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_376}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_376}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_5_376}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_6_376}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_7_376}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_8_376}                ${tl.attenuator[0].attenuator_ports[16]}
${att_api_port}    ${tl.attenuator[0].port}
${att_port_1_388}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_388}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_388}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_388}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_388}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_388}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_388}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_388}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_377}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_377}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_377}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_377}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_377}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_377}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_377}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_377}                ${tl.attenuator[0].attenuator_ports[8]}
${vendor}                    ${tl.attenuator[0].vendor}
${max_attenuation_value}      ${127}
${duration}    1200
${iperf_type}    command
${deviation}    15
@{gnb_id}    376    37711    388

*** Keywords ***
##setup and teardown and recovery##
Set suite variables by program
    [Documentation]      This keyword is to set several variables by program.
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

Common Suite Setup for COAM
    Set suite variables by program
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    set_suite_documentation    doc=||| All test suite log will save in this VM IP:${TestPC_addr} logPath:${epc_log_path}
    ...    append=True

ASKEY UE parameter setup
    [Arguments]  ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set suite variable    ${ue_type}
    ${CF}    Set Variable    CONSTRUCTOR_PARAMETERS
    ${ue_name}    Set Variable    INSEEGO${ue_index}
    ${ue_yaml}    Set Variable    ${tl.ues[${ue_index}]}
    ${ue_ccc}     Set Variable    ${ue_yaml['UE_POOLS']['AndroidUePool']['inline_config']['${ue_name}']['${CF}']}
    ${ue_param}    Set Variable    ${ue_ccc['configuration']}
    set suite variable    ${ASKEY_DL_PORT}      ${ue_param['data_transfer']['iperf_options']['qci'][5]}
    set suite variable    ${ASKEY_UL_PORT}      ${ue_param['data_transfer']['iperf_options']['qci'][6]}
    set suite variable    ${askey_SN}           ${ue_ccc['serial_number']}
    set suite variable    ${askey_hostname}     ${ue_param['ue_pc_ip']}
    set suite variable    ${askey_username}     ${ue_param['login']}
    set suite variable    ${askey_password}     ${ue_param['password']}
    set suite variable    ${iperf_hostname}     ${ue_param['data_transfer']['ssh']['host']}
    set suite variable    ${iperf_username}     ${ue_param['data_transfer']['ssh']['user']}
    set suite variable    ${iperf_password}     ${ue_param['data_transfer']['ssh']['password']}
    set suite variable    ${appserver_addr}     ${iperf_hostname}

Trigger ASKEY UE reboot
    [Arguments]    ${serial_number}=${askey_SN}
    csn.Connect to    hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} reboot    connection=cygwin
    sleep   2s
    csn.disconnect      connection=cygwin

clear cli process
    csn.Connect to    hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}    alias=cygwin
    csn.send command    command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9

Common Suite Teardown for COAM
    [Arguments]    ${localFilePath_default}=${swconfig_default}
    disconect all connections
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections
#    CI_interface.Common Case Teardown

restore swConfig to default
    [Arguments]     ${localFilePath}
    Update the swconfig file    localFilePath=${localFilePath}

Tests Recover
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=killall tcpdump     connection=gnb
    Power UE stop dl traffic
    run keyword and ignore error     Power UE stop ul traffic
    clear cli process
    sleep     3s
    Get product brand
    Power UE Detach
    disconect all connections

disconect all connections
    run keyword and ignore error    csn.disconnect    connection=cpc_0
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=ASIK
    run keyword and ignore error     csn.disconnect    connection=gnb

##prepare BTS##
COAM login page via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

Prepare testline to cell onair for NSA
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    ...    ${enbx2_dist}=${enbx2_dist}
    Update the swconfig file  gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for NSA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    enbx2_dist=${enbx2_dist}

Prepare testline to cell onair for SA
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    ...     ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Update the swconfig file  gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for SA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    bts_host=${bts_host}    username=${username}    password=${password}

Prepare with COAM classical BTS cell onair for SA
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}
    Perform full commission for COAM gnb     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    COAM Wait for gnb ready    bts_host=${bts_host}    username=${username}    password=${password}
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

Update the swconfig file
    [Arguments]    ${localFilePath}    ${gnb_index}=${0}
    wait until keyword succeeds    5min    10s    Connect to Common Unit Master with gnbindex   gnb_index=${gnb_index}    alias=ASIK Master
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK Master
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK Master

Prepare with COAM classical BTS cell onair for NSA
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}    ${enbx2_dist}=${enbx2_dist}
    Perform full commission for COAM gnb     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    COAM Wait for gnb ready    bts_host=${bts_host}    username=${username}    password=${password}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

Perform full commission for COAM gnb
    [Arguments]    ${scf}    ${gnb_ip}    ${username}    ${password}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}    username=${username}      password=${password}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=1000    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

COAM Wait for gnb ready
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${bts_host}=${bts_host}    ${username}=${username}    ${password}=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                    bts_host=${bts_host}
    ...                    username=${username}
    ...                    password=${password}

Commission SCF to eNB
    [Arguments]    ${eNB_asik_addr}    ${connection}    ${scf_file}
    enblte.connect_to    bts_host=${eNB_asik_addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    enblte.perform_commissioning    scf_file=${tl_scf_dir_path}${scf_file}    skip_parameter_relation_errors=${True}
    ...     should_activate=${True}    connection=${connection}    timeout=300

Check BTS status
    [Arguments]    ${localFilePath}   ${tl_scf_filename}
    ${cell_status}=    COAM Check GNB cell on air
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare with COAM classical BTS cell onair for SA
    ...    localFilePath=${localFilePath}   tl_scf_filename=${tl_scf_filename}
    Should be equal    ${cell_status}    PASS

Connect to Classical Common Unit Master gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    ssh.Connect to    hostname=${gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}    ${bts_host}=${gnb_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

###ENB LOCK UNLOCK###
Lock Unlock Enb Cell
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    Connect to eNB via ssl
    Modify the parameter on enblte    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${value}

###log capture###
##Wireshark log##
Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    ...    ${connection}=gnb    ${interface}=any
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}   connection=${connection}

Stop and download wireshark Logs
    [Arguments]    ${logname}    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    ...    ${connection}=gnb
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=${connection}

gNB connections
    [Arguments]    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

##BIP log##
Power UE Precondition
    [Arguments]     ${ue_type}=${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}

Power UE Start DL traffic
    [Arguments]    ${dl_throughput}   ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=${DL_PORT}
    ...    ${ue_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}

Power UE Start UL traffic
    [Arguments]    ${ul_throughput}   ${duration}=${UL_TIME}    ${ul_length}=${UL_LENGTH}    ${ul_port}=${UL_PORT}
    ...    ${ue_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    ...                       iperf_port=${ul_port}    ue_index=${0}    cap_index=${0}    buffer_size=${ul_length}

Check the cell DLUL throughput
    [Arguments]      ${cellid}    ${dlexpect}    ${ulexpect}    ${gnb_index}=${0}    ${ue_type}=${ue_type}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    cellid=${nrcellid}    sleep_time=${20}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect}    cellid=${nrcellid}    sleep_time=${20}

Power UE check throughput with nrcellid
    [Arguments]    ${cellid}    ${dlexpect}    ${gnb_index}=${0}    ${ue_type}=${ue_type}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${dl_tp_l2l0}    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    cellid=${nrcellid}    sleep_time=${20}
    [Return]     ${dl_tp_l2l0}

Power UE stop dl traffic
    [Arguments]    ${dl_port}=${DL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Power UE stop ul traffic
    [Arguments]    ${ul_port}=${UL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}

Power UE Detach
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE stop dl traffic and detach
    [Arguments]    ${dl_port}=${DL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

##ASKEY##
Power UE Attach and Verify attach for askey
    [Arguments]    ${4g_check}    ${ue_type}=${ue_type}    ${gnb_index}=${0}
     Wait until keyword succeeds    4X    5s    attach ue for askey one time    4g_check=${4g_check}    ue_type=${ue_type}    gnb_index=${gnb_index}

attach ue for askey one time
    [Arguments]    ${4g_check}    ${ue_type}=${ue_type}    ${interval}=${1}    ${gnb_index}=${0}
    ${status}    ${5Grach_ed}    run keyword and ignore error  power_ue.UE Attach
    ...    ue_type=${ue_type}   ue_index=${0}    interval=${interval}     gnb_index=${gnb_index}
    ${5Grach_2ed}    run keyword if    '${status}'=='FAIL'    At Cmd UE reAttach    ue_index=${0}
    ${5Grach_ed}    set variable if    '${status}'=='FAIL'    ${5Grach_2ed}    ${5Grach_ed}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    4G_check=${4g_check}

Get UE IP with first UE
    [Documentation]    get UE IP
    ...    get inseego/askey UE IP
    [Arguments]    ${ue_index}=${0}
    ${UE_IP}=    Get the UE Ip address    ${ue_index}
    Set Suite Variable    ${UE_IP}    ${UE_IP}

Start DL date transfer on appserver
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${ASKEY_DL_PORT}    ${time}=${DL_TIME}    #${UE_IP}=172.252.65.7
    ...            ${interval}=1    ${traffic}=${dl_throughput}    ${buffer_size}=${DL_LENGTH}
    Get UE IP with first UE    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}    hostname=${iperf_hostname}
    ...    username=${iperf_username}    password=${iperf_password}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 1 -f m -b ${traffic} -l ${buffer_size} -T 64 &
    ...    connection=EPCAPP

Askey UE stop dl traffic on appserver and detach
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${ASKEY_DL_PORT}    ${ue_type}=${ue_type}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}    hostname=${iperf_hostname}
    ...    username=${iperf_username}    password=${iperf_password}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    sleep    1s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    2s
    [Teardown]    csn.disconnect      connection=EPCAPP

At Cmd UE reAttach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=0
    ...    ${log_type}=Aasyslog    ${interval}=${1}    &{kwargs}
    [Documentation]    reAttach UE for L3 call test.
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
    ute_ue.send_at_cmd_to_ue    alias=UE_0    at_cmd=at+cops=1,2,${mcc}${mnc}
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    ${hwcheck_index}    ${log_type}
    ...    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}

##QUALCOMM##
Case variable set for ${case_key}
    test suite variable set for ${case_key}
#    Set Test Tag

test suite variable set for ${case_key}
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    set suite variable    ${qc_id}                ${para_store['${case_key}']['${release_info}']['qc_id']}
    set suite variable    ${scf_disable2200}      ${para_store['${case_key}']['${release_info}']['scf_disable2200']}
    set suite variable    ${scf_enable2200}       ${para_store['${case_key}']['${release_info}']['scf_enable2200']}
    set suite variable    ${att_value}            ${para_store['${case_key}']['${release_info}']['att_value']}
    set suite variable    ${nrcellid}             ${para_store['${case_key}']['${release_info}']['nrcellid']}
    set suite variable    ${enb_dist}             ${para_store['${case_key}']['${release_info}']['enb_dist']}
    set suite variable    ${Expect_ul}            ${para_store['${case_key}']['${release_info}']['Expect_ul']}
    set suite variable    ${mcs_alias}            ${para_store['${case_key}']['${release_info}']['mcs_alias']}
    set suite variable    ${hw_slot}              ${para_store['${case_key}']['${release_info}']['hw_slot']}
    set suite variable    ${Expect_dl_enable}     ${para_store['${case_key}']['${release_info}']['Expect_dl_enable']}
    set suite variable    ${Expect_dl_disable}    ${para_store['${case_key}']['${release_info}']['Expect_dl_disable']}

Select branch and variable for ${case_key}            # 2200C&D
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    set suite variable    ${qc_id}    ${para_store['${case_key}']['${release_info}']['qc_id']}
    set suite variable    ${mcs_alias}    ${para_store['${case_key}']['${release_info}']['mcs_alias']}

Get sagnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Set nrcellid suit varaible
    [Arguments]    ${cellid}    ${gnb_index}=${0}
    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    set suite variable    ${nrcellid}

#attenuation#
Adjust the tl HBTE attenuation value
    [Arguments]     ${tl}=${tl}    ${value1}=${0}    ${value2}=${127}
    Adjust the HBTE attenuation value    value1=${value1}    value2=${value2}    att_port_1=${att_port_1_${tl}}
    ...    att_port_2=${att_port_2_${tl}}    att_port_3=${att_port_3_${tl}}    att_port_4=${att_port_4_${tl}}
    ...    att_port_5=${att_port_5_${tl}}    att_port_6=${att_port_6_${tl}}    att_port_7=${att_port_7_${tl}}
    ...    att_port_8=${att_port_8_${tl}}

Adjust the HBTE attenuation value
    [Arguments]     ${value1}    ${value2}    ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}
    ...    ${att_port_3}=${att_port_3}    ${att_port_4}=${att_port_4}
    ...    ${att_port_5}=${att_port_5}    ${att_port_6}=${att_port_6}
    ...    ${att_port_7}=${att_port_7}    ${att_port_8}=${att_port_8}
    [Documentation]
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value1}
    attenuator.set_attenuation     port=${att_port_3}    value=${value1}
    attenuator.set_attenuation     port=${att_port_4}    value=${value1}
    attenuator.set_attenuation     port=${att_port_5}    value=${value2}
    attenuator.set_attenuation     port=${att_port_6}    value=${value2}
    attenuator.set_attenuation     port=${att_port_7}    value=${value2}
    attenuator.set_attenuation     port=${att_port_8}    value=${value2}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value1}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value1}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value1}
    ${value_port_5}    attenuator.read_attenuation    port=${att_port_5}
    should be equal    ${value_port_5}    ${value2}
    ${value_port_6}    attenuator.read_attenuation    port=${att_port_6}
    should be equal    ${value_port_6}    ${value2}
    ${value_port_7}    attenuator.read_attenuation    port=${att_port_7}
    should be equal    ${value_port_7}    ${value2}
    ${value_port_8}    attenuator.read_attenuation    port=${att_port_8}
    should be equal    ${value_port_8}    ${value2}
    sleep    5

Adjust the HBTE attenuation value tl388
    [Arguments]     ${value1}    ${value2}    ${att_port_1}=${att_port_1_388}    ${att_port_2}=${att_port_2_388}
    ...    ${att_port_3}=${att_port_3_388}    ${att_port_4}=${att_port_4_388}
    ...    ${att_port_5}=${att_port_5_388}    ${att_port_6}=${att_port_6_388}
    [Documentation]
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value1}
    attenuator.set_attenuation     port=${att_port_3}    value=${value1}
    attenuator.set_attenuation     port=${att_port_4}    value=${value1}
    attenuator.set_attenuation     port=${att_port_5}    value=${value2}
    attenuator.set_attenuation     port=${att_port_6}    value=${value2}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value1}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value1}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value1}
    ${value_port_5}    attenuator.read_attenuation    port=${att_port_5}
    should be equal    ${value_port_5}    ${value2}
    ${value_port_6}    attenuator.read_attenuation    port=${att_port_6}
    should be equal    ${value_port_6}    ${value2}
    sleep    5

########### xiaomi ##################
Get all xiaomi11 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1260 2090
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi

Get all xiaomi11 pointer variable tl388
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1251 2208
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi

Get all xiaomi11 pointer variable tl377
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1245 1878
    Set Suite Variable    ${close_task}    717 2920
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}=False
    Wait until keyword succeeds    3X    10s    Check phone attach successfully    4g_check=${4g_check}

Check phone attach successfully
    [Arguments]    ${4g_check}    ${5Gstatus}=PASS    ${gnb_index}=${0}
    unlock the screen    ue_index=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=${4g_check}
    ...    ue_index=${0}    gnb_index=${gnb_index}

unlock the screen
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
#    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    Run Keyword If   '${gnb_instance}'=='${gnb_id[0]}' or '${gnb_instance}'=='${gnb_id[1]}'
    ...    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    ...    ELSE    csn.send_command   command=adb -s ${serial_number} shell input swipe 738 2958 733 1002    connection=${connection}
    sleep    2s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}

Start a VONR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${connection}=cygwin
    Connect to control pc via cygwin    ue_index=${0}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin
    sleep    30s
    #csn.send_command    command=adb -s ${serial_number} shell input tap 720 2897
    #...    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

Stop the VONR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    ...    ${connection}=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input tap 724 2783
    ...    connection=cygwin
    sleep    5s

Start traffic xiaomi
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_type}    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1400B
    ...            &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Start DL traffic and check the TP on EPC    ue_index=${ue_index}
    ...                                                                                     time=${duration}
    ...                                                                                     interval=${interval}
    ...                                                                                     traffic=${throughput}
    ...                                                                                     buffer_size=${buffer_size}
    ...                                                                                     iperf_port=${port}
    ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial    time=${duration}
    ...                                                                                            traffic=${throughput}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            iperf_port=${port}
    ...                                                                                            iperf_type=${iperf_type}

Stop udp traffic
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_iperf_command

Xioami UE stop dl traffic and detach
    [Arguments]    ${ue_type}=${ue_type}
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Set automatic rotation on UEs
    Set automatic rotation
#    Set automatic rotation    ue_index=${1}

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s

Start DL date transfer
    [Arguments]    ${dl_throughput}    ${ue_index}=${0}    ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${dl_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}

Prepare env with UE
    [Arguments]    ${ue_index}=${0}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    reset_sol=${true}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

Power UE check throughput
    [Arguments]    ${Expect_DOWNLINK}    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${gnb_index}=${0}
    ${cell1_id}=    COAM Get Nrcellid With The Lcrid     lcrid=${1}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expect_DOWNLINK}

Power UE check throughput cell2
    [Arguments]    ${Expect_DOWNLINK}    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${gnb_index}=${0}
    ${cell1_id}=    COAM Get Nrcellid With The Lcrid   lcrid=${2}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expect_DOWNLINK}

COAM Get nrcellid with lcrid
    [Arguments]   ${lcrid}
    Connect to gnb coam via ssl
    ${cell_info}   wmplte.get_subcells_info   timeout=20    connection=GNB_OAM
    ${number_of_cell_group_info}    get length    ${cell_info}
    FOR  ${index}    IN RANGE    ${number_of_cell_group_info}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
        ${nrCellId}    Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
        exit for loop if    '${nrCellId}'!='None'
    END
    [Return]    ${nrCellId}

lock LTE
    run keyword if   '${gnb_instance}'=='${gnb_id[0]}'    locked LTE cell
    ...    ELSE    Locked LTE cell tl388

Locked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

Locked LTE cell tl388
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

Unlocked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Unlocked LTE cell tl388
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Unlock LTE
    run keyword if   '${gnb_instance}'=='${gnb_id[0]}'    Unlocked LTE cell
    ...    ELSE    Unlocked LTE cell tl388

COAM gNB Reset site
    Connect to gnb coam via ssl    connection=coam_admin
    coam.reset_site         connection=coam_admin
    COAM Teardown gnb connections    coam_admin
    COAM Wait for gnb ready    bts_host=${gnb_BTS_host}    username=${gnb_BTS_username}    password=${gnb_BTS_password}
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

##xiaomi-end
